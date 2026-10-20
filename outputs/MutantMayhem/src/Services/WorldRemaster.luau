-- Reversible visual overlay. No remotes, economy changes or new collision geometry.
local Recipe=require(script.Parent.RemasterRecipe)
local VisualTier=require(script.Parent.VisualTier)
local R={}
local VERSION=1
local OWNER="MMWorldRemaster"
local function folder(name,parent)
 local f=Instance.new("Folder") f.Name=name f:SetAttribute("RemasterOwner",OWNER) f.Parent=parent return f
end
local function owned(object) return object and object:GetAttribute("RemasterOwner")==OWNER end
local function make(item,origin,parent)
 local p=Instance.new("Part") p.Name=item.name p.Anchored=true
 p.CanCollide=false p.CanTouch=false p.CanQuery=false
 local size=Vector3.new(table.unpack(item.size))
 local rot=item.rot or {0,0,0}
 p.CFrame=origin*CFrame.new(table.unpack(item.pos))*CFrame.Angles(math.rad(rot[1]),math.rad(rot[2]),math.rad(rot[3]))
 if item.shape=="cylinder" then
  p.Shape=Enum.PartType.Cylinder p.Size=Vector3.new(size.Y,size.X,size.Z)
  p.CFrame=p.CFrame*CFrame.Angles(0,0,math.pi/2)
 else p.Size=size p.Shape=item.shape=="sphere" and Enum.PartType.Ball or Enum.PartType.Block end
 p.Color=Color3.fromRGB(table.unpack(Recipe.palette[item.material]))
 local glow=item.material=="cyan" or item.material=="violet" or item.material=="pink" or item.material=="gold"
 p.Material=glow and Enum.Material.Neon or (item.material=="glass" and Enum.Material.Glass or Enum.Material.SmoothPlastic)
 p.Transparency=item.material=="glass" and .65 or 0
 p.CastShadow=not glow and item.material~="glass" and math.min(size.X,size.Y,size.Z)>.4
 p:SetAttribute("RemasterOwner",OWNER)
 p.Parent=parent return p
end
local hideNames={BackWall=true,Pillar=true,RoofFin=true,Canopy=true}
local function hideOriginal(plot)
 for _,p in plot:GetChildren() do
  if p:IsA("BasePart") and hideNames[p.Name] then
   if p:GetAttribute("MMOriginalTransparency")==nil then p:SetAttribute("MMOriginalTransparency",p.Transparency) end
   p.Transparency=1
  end
 end
end
function R.SetTier(plot,backendTier)
 if not plot or not plot:FindFirstChild("Base") or not plot:GetAttribute("MMRemasterApplied") then return end
 local tier=VisualTier(backendTier)
 local old=plot:FindFirstChild("VisualRemaster")
 if old and not owned(old) then return end
 if old and old:GetAttribute("Version")==VERSION and old:GetAttribute("VisualTier")==tier then return end
 local staged=folder("VisualRemaster",nil)
 local ok,err=pcall(function()
  for _,item in Recipe.lab do if item.minTier<=tier then make(item,plot.Base.CFrame,staged) end end
  staged:SetAttribute("Version",VERSION) staged:SetAttribute("VisualTier",tier)
 end)
 if not ok then staged:Destroy() warn("Visual tier build skipped: "..tostring(err)) return false,err end
 if old then old:Destroy() end
 staged.Parent=plot
end
function R.RefreshStyle(plot)
 local visuals=plot and plot:FindFirstChild("VisualRemaster")
 if not visuals or not plot:FindFirstChild("Canopy") then return end
 for _,p in visuals:GetChildren() do
  if p.Name:find("BackAccent",1,true) then p.Color=plot.Canopy.Color end
 end
end
local Lighting=game:GetService("Lighting")
local function setSaved(object,property,value)
 local key="MMRemasterOriginal_"..property
 if object:GetAttribute(key)==nil then object:SetAttribute(key,object[property]) end
 object[property]=value
end
function R.ApplyLighting()
 setSaved(Lighting,"ClockTime",14.3)
 setSaved(Lighting,"Brightness",2.2)
 setSaved(Lighting,"Ambient",Color3.fromRGB(100,116,138))
 setSaved(Lighting,"OutdoorAmbient",Color3.fromRGB(135,151,169))
 local atmosphere=Lighting:FindFirstChild("MMAtmosphere")
 if atmosphere then setSaved(atmosphere,"Density",.2) end
 local bloom=Lighting:FindFirstChild("MMBloom")
 if bloom then setSaved(bloom,"Intensity",.1) setSaved(bloom,"Threshold",1.8) end
end
function R.ResetPlot(plot) R.SetTier(plot,0) end
function R.Rollback(world)
 for _,object in {Lighting,Lighting:FindFirstChild("MMAtmosphere"),Lighting:FindFirstChild("MMBloom")} do
  for key,value in object:GetAttributes() do
   local prop=key:match("^MMRemasterOriginal_(.+)")
   if prop then object[prop]=value object:SetAttribute(key,nil) end
  end
 end
 local plots=world:FindFirstChild("Plots")
 if plots then for _,plot in plots:GetChildren() do
  local f=plot:FindFirstChild("VisualRemaster") if owned(f) then f:Destroy() end
  for _,p in plot:GetChildren() do
   local original=p:GetAttribute("MMOriginalTransparency")
   if original~=nil and p:IsA("BasePart") then p.Transparency=original p:SetAttribute("MMOriginalTransparency",nil) end
  end
  plot:SetAttribute("MMRemasterApplied",nil)
 end end
 local f=world:FindFirstChild("MM_Remaster") if owned(f) then f:Destroy() end
 world:SetAttribute("MMRemasterVersion",nil)
end
function R.Apply(world)
 if world:GetAttribute("MMRemasterDisabled") then R.Rollback(world) return false,"Disabled by world attribute" end
 local plots=world:FindFirstChild("Plots")
 if not plots or #plots:GetChildren()~=12 then return false,"Expected 12 existing plots" end
 local existing=world:FindFirstChild("MM_Remaster")
 if existing and not owned(existing) then return false,"MM_Remaster name belongs to another system" end
 -- Validate every contract before touching the world.
 for _,plot in plots:GetChildren() do
  for _,name in {"Base","Canopy","Sign","Terminal","Pad1","Pad12"} do
   if not plot:FindFirstChild(name) then return false,plot.Name.." missing "..name end
  end
  local f=plot:FindFirstChild("VisualRemaster")
  if f and not owned(f) then return false,"VisualRemaster name belongs to another system" end
 end
 if existing and world:GetAttribute("MMRemasterVersion")==VERSION then return true end
 local staged=folder("MM_Remaster",nil)
 local ok,err=pcall(function()
  for _,item in Recipe.world do make(item,CFrame.new(),staged) end
  for i,label in Recipe.labels do
   local anchor=Instance.new("Part") anchor.Name="Wayfinding"..i anchor.Size=Vector3.one
   anchor.Anchored=true anchor.CanCollide=false anchor.CanTouch=false anchor.CanQuery=false anchor.Transparency=1
   anchor.Position=Vector3.new(table.unpack(label.pos)) anchor.Parent=staged
   local gui=Instance.new("BillboardGui") gui.Name="Label" gui.Size=UDim2.fromOffset(270,44)
   gui.MaxDistance=90 gui.AlwaysOnTop=false gui.Parent=anchor
   local t=Instance.new("TextLabel") t.Size=UDim2.fromScale(1,1) t.BackgroundTransparency=1
   t.Text=label.text t.TextColor3=Color3.fromRGB(225,248,255) t.TextStrokeTransparency=.35
   t.TextSize=15 t.Font=Enum.Font.GothamBold t.Parent=gui
  end
 end)
 if not ok then staged:Destroy() return false,err end
 if existing then existing:Destroy() end
 staged.Parent=world
 for _,plot in plots:GetChildren() do
  plot:SetAttribute("MMRemasterApplied",true)
  hideOriginal(plot)
  R.SetTier(plot,0)
 end
 R.ApplyLighting()
 world:SetAttribute("MMRemasterVersion",VERSION)
 return true
end
return R
