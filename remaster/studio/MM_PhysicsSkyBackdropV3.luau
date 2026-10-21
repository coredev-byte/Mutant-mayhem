-- CAOS MUTANTE — reliable physical scenery, ocean horizon and sunset sky (v3).
-- NON-DESTRUCTIVE. Never calls MapBuilder.Build(), never edits labs, reactor, plot pads or player data.
-- Designed for a Studio backup with ServerStorage.MM_RealGardenAssets_v2 and
-- ServerStorage.MM_MountainStaging_v3_Archived available as mesh templates.
local M = {}
local Lighting = game:GetService("Lighting")
local Storage = game:GetService("ServerStorage")
local rng = Random.new(20261020)
local TREE_NAMES = {Cerejeira=true, Pinheiro=true, ArvorePerimetro=true}
local ROCK_NAMES = {PedraMusgo=true, PedraMargem=true}
local function artRoot()
 return workspace:FindFirstChild("MM_RealLandscape_v2")
end
local function collider(name, size, cf, shape, parent)
 local p=Instance.new("Part")
 p.Name=name;p.Anchored=true;p.Size=size;p.CFrame=cf
 p.Transparency=1;p.CastShadow=false;p.CanCollide=true;p.CanTouch=false;p.CanQuery=true
 p.Material=Enum.Material.SmoothPlastic
 p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
 if shape then p.Shape=shape end
 p:SetAttribute("MM_PhysicalHitbox",true)
 p.Parent=parent
 return p
end
function M.Physics()
 local art=artRoot()
 if not art then return {status="missing_landscape"} end
 local railFolder=art:FindFirstChild("MM_SolidCollisions_v3")
 if not railFolder then railFolder=Instance.new("Folder");railFolder.Name="MM_SolidCollisions_v3";railFolder.Parent=art end
 local added={trees=0,rocks=0,benches=0,lanterns=0,bridgeRails=0}
 local models={}
 for _,x in ipairs(art:GetDescendants()) do
  if x:IsA("Model") and (x:GetAttribute("MCPRealAsset")==true or x:GetAttribute("CreatorStoreAssetId")~=nil or TREE_NAMES[x.Name]) then table.insert(models,x) end
 end
 for i,m in ipairs(models) do
  local typ=m.Name
  local pivot=m:GetPivot();local ground=pivot.Position.Y
  local box,size=m:GetBoundingBox()
  if TREE_NAMES[typ] and not m:FindFirstChild("Tronco_Fisico") then
   local h=math.clamp(size.Y*.56,5,13)
   local diameter=(typ=="Cerejeira" and 2.7 or 1.7)
   if typ=="ArvorePerimetro" then diameter=m:FindFirstChild("Sakura_1",true) and 2.3 or 1.45 end
   collider("Tronco_Fisico",Vector3.new(h,diameter,diameter),
    CFrame.new(pivot.Position.X,ground+h*.5,pivot.Position.Z)*CFrame.Angles(0,0,math.rad(90)),Enum.PartType.Cylinder,m)
   added.trees+=1
  elseif ROCK_NAMES[typ] and not m:FindFirstChild("Pedra_Fisica") then
   local dims=Vector3.new(math.clamp(size.X*.84,.65,5),math.clamp(size.Y*.72,.6,4),math.clamp(size.Z*.84,.65,5))
   collider("Pedra_Fisica",dims,CFrame.new(box.Position.X,math.max(ground+dims.Y*.5,box.Position.Y),box.Position.Z),Enum.PartType.Ball,m)
   added.rocks+=1
  elseif typ=="BancoDeMadeira" and not m:FindFirstChild("Banco_Fisico") then
   local dims=Vector3.new(math.max(size.X*.85,1.2),math.max(size.Y*.94,1.3),math.max(size.Z*.85,1.2))
   collider("Banco_Fisico",dims,CFrame.new(box.Position),nil,m)
   added.benches+=1
  elseif typ=="LanternaDeJardim" and not m:FindFirstChild("Lanterna_Fisica") then
   collider("Lanterna_Fisica",Vector3.new(3.55,1.05,1.05),CFrame.new(pivot.Position.X,ground+1.78,pivot.Position.Z)*CFrame.Angles(0,0,math.rad(90)),Enum.PartType.Cylinder,m)
   added.lanterns+=1
  end
  if i%30==0 then task.wait() end
 end
 local bridge=art:FindFirstChild("RiachoPonteJaponesa")
 local deck=bridge and bridge:FindFirstChild("PonteColisaoJogavel")
 if deck then
  deck.Anchored=true;deck.CanCollide=true;deck.CanQuery=true
  local railCount=0
  for _,p in ipairs(railFolder:GetChildren()) do if p.Name=="GuardaCorpo_Fisico" then railCount+=1 end end
  if railCount==0 then
   for _,sign in ipairs({-1,1}) do
    collider("GuardaCorpo_Fisico",Vector3.new(deck.Size.X,1.55,.28),
      CFrame.new(deck.Position.X,deck.Position.Y+1.65,deck.Position.Z+sign*(deck.Size.Z/2-.10)),nil,railFolder)
    added.bridgeRails+=1
   end
  end
 end
 return {status="ok",added=added}
end
local SKY_FACES={
 SkyboxBk="rbxassetid://9778108979",SkyboxDn="rbxassetid://9778110864",
 SkyboxFt="rbxassetid://9778101192",SkyboxLf="rbxassetid://9778103329",
 SkyboxRt="rbxassetid://9778104889",SkyboxUp="rbxassetid://9778106496"
}
function M.Atmosphere()
 local sk=Lighting:FindFirstChildOfClass("Sky")
 if not sk or sk.Name~="MM_CloudySunsetSky_v3" then
  if sk then sk.Name="Sky_Pre_MMV3";sk.Parent=Storage end
  sk=Instance.new("Sky");sk.Name="MM_CloudySunsetSky_v3";sk.Parent=Lighting
 end
 for name,id in pairs(SKY_FACES) do sk[name]=id end
 sk.CelestialBodiesShown=false
 sk:SetAttribute("CreatorStoreAssetId","9779104328")
 local c=workspace.Terrain:FindFirstChildOfClass("Clouds")
 if not c then c=Instance.new("Clouds");c.Name="MM_PastelClouds_v3";c.Parent=workspace.Terrain end
 c.Cover=.34;c.Density=.31;c.Color=Color3.fromRGB(255,223,229)
 local r=Lighting:FindFirstChild("MM_SunRays_v3")
 if not r then r=Instance.new("SunRaysEffect");r.Name="MM_SunRays_v3";r.Parent=Lighting end
 r.Intensity=.04;r.Spread=.75
 local a=Lighting:FindFirstChild("MMAtmosphere")
 if a and a:IsA("Atmosphere") then
  a.Density=.25;a.Haze=1.05;a.Glare=.24
  a.Color=Color3.fromRGB(235,225,228);a.Decay=Color3.fromRGB(202,170,177)
 end
 Lighting.ClockTime=16.65;Lighting.Brightness=2.25
 Lighting.OutdoorAmbient=Color3.fromRGB(165,166,171)
 Lighting.Ambient=Color3.fromRGB(135,138,151)
 Lighting.ShadowSoftness=.55
 return {status="ok",sky=sk.Name}
end
function M.RestoreGround()
 local world=workspace:FindFirstChild("MM_World")
 local backup=Storage:FindFirstChild("MM_Backup_20261020_PreCollisionSky_v3")
 if not world then return {status="missing_world"} end
 local restored={}
 for _,name in ipairs({"Island","Ocean","IslandRim"}) do
  if not world:FindFirstChild(name) then
   local source=backup and backup:FindFirstChild(name)
   if not source then return {status="missing_ground_backup",name=name,restored=restored} end
   local copy=source:Clone();copy.Parent=world
   table.insert(restored,name)
  end
 end
 return {status="ok",restored=restored}
end
function M.Water()
 local world=workspace:FindFirstChild("MM_World")
 if not world then return {status="world_missing"} end
 local ocean=world:FindFirstChild("Ocean")
 if ocean and ocean:IsA("BasePart") then
  ocean.Material=Enum.Material.SmoothPlastic
  ocean.Color=Color3.fromRGB(79,132,151);ocean.Reflectance=.075
 end
 local rim=world:FindFirstChild("IslandRim")
 if rim and rim:IsA("BasePart") then
  rim.Color=Color3.fromRGB(45,76,78);rim.Material=Enum.Material.Slate
 end
 return {status="ok",ocean=ocean~=nil,rim=rim~=nil}
end
function M.DistantMountains()
 local existing=workspace:FindFirstChild("MM_DistantScenery_v3")
 if existing then return {status="already_exists",count=#existing:GetChildren()} end
 local stage=Storage:FindFirstChild("MM_MountainStaging_v3_Archived")
 local parent=stage and stage:FindFirstChild("Backdrop_MountainLowpoly")
 if not parent then return {status="missing_store_mesh_template",assetId="79754458690074"} end
 local meshes={}
 for _,v in ipairs(parent:GetDescendants()) do if v:IsA("MeshPart") then table.insert(meshes,v) end end
 table.sort(meshes,function(a,b)return a.Size.X>b.Size.X end)
 if #meshes<2 then return {status="missing_source_meshes"} end
 local folder=Instance.new("Folder")
 folder.Name="MM_DistantScenery_v3"
 folder:SetAttribute("DecorativeOnly",true)
 folder:SetAttribute("HasCollision",false)
 folder:SetAttribute("MountainAssetId","79754458690074")
 for i=1,16 do
  local ang=i/16*math.pi*2+.13
  local radius=rng:NextNumber(435,540)
  local x,z=math.sin(ang)*radius,math.cos(ang)*radius
  local src=meshes[(i%5==0) and 2 or 1]
  local v=src:Clone();v.Name="MontanhaDistante_"..i
  for _,d in ipairs(v:GetDescendants()) do if d:IsA("LuaSourceContainer") then d:Destroy() end end
  v.Anchored=true;v.CanCollide=false;v.CanQuery=false;v.CanTouch=false;v.CastShadow=false
  local scale=rng:NextNumber(.55,.89)
  v.Size=src.Size*scale
  v.Material=Enum.Material.Slate
  v.Color=i%3==0 and Color3.fromRGB(112,133,155) or (i%3==1 and Color3.fromRGB(139,152,159) or Color3.fromRGB(122,139,152))
  v.Transparency=i%3==0 and .10 or .035
  v.CFrame=CFrame.new(x,-16+v.Size.Y*.47,z)*CFrame.Angles(0,-ang,0)
  v.Parent=folder
  if i%5==0 then task.wait() end
 end
 folder.Parent=workspace
 return {status="created",count=#folder:GetChildren()}
end
function M.Check()
 local art=artRoot()
 local world=workspace:FindFirstChild("MM_World")
 local p={status="ok",labs=0,solidHitboxes=0,decorativeMountains=0,sky="",backups={}}
 if world and world:FindFirstChild("Plots") then p.labs=#world.Plots:GetChildren() end
 p.ground={island=world and world:FindFirstChild("Island")~=nil,ocean=world and world:FindFirstChild("Ocean")~=nil,rim=world and world:FindFirstChild("IslandRim")~=nil}
 if not p.ground.island or not p.ground.ocean or not p.ground.rim then p.status="missing_ground" end
 if art then
  for _,v in ipairs(art:GetDescendants()) do
   if v:IsA("BasePart") and v:GetAttribute("MM_PhysicalHitbox") then p.solidHitboxes+=1 end
  end
 end
 local bg=workspace:FindFirstChild("MM_DistantScenery_v3")
 if bg then p.decorativeMountains=#bg:GetChildren() end
 local sky=Lighting:FindFirstChildOfClass("Sky")
 p.sky=sky and sky.Name or ""
 for _,n in ipairs({"MM_Backup_20261020_PreCollisionSky_v3","MM_GardenBackup_20261021_BeforeRealAssets"}) do
  p.backups[n]=Storage:FindFirstChild(n)~=nil
 end
 return p
end
function M.Apply()
 local ground=M.RestoreGround()
 local physics=M.Physics()
 local sky=M.Atmosphere()
 local water=M.Water()
 local background=M.DistantMountains()
 return {ground=ground,physics=physics,sky=sky,water=water,background=background,check=M.Check()}
end
return M
