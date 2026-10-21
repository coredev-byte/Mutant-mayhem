-- CAOS MUTANTE / Garden refinement (native Roblox geometry)
-- Additive only: never destroys MM_World, plots, reactor, scripts or interactions.
-- Authored 2026-10-20; reusable via require(ServerStorage.MM_LandscapeGardenBuilderV1).Build()
local M={}
local C={
 pink=Color3.fromRGB(249,183,210),pink2=Color3.fromRGB(255,209,226),pink3=Color3.fromRGB(232,135,185),
 green=Color3.fromRGB(73,131,93),green2=Color3.fromRGB(102,156,91),green3=Color3.fromRGB(129,177,104),
 grass=Color3.fromRGB(108,154,91),bark=Color3.fromRGB(112,77,69),rock=Color3.fromRGB(143,153,142),
 rock2=Color3.fromRGB(170,174,150),sand=Color3.fromRGB(188,166,127),water=Color3.fromRGB(91,176,195),
 golden=Color3.fromRGB(248,201,126),ivory=Color3.fromRGB(242,229,202),bronze=Color3.fromRGB(78,83,66),
}
local rng=Random.new(20261020)
local n=0
local function mk(par,name,size,cf,color,material,shape,collide)
 local p=Instance.new("Part")
 p.Name=name;p.Anchored=true;p.CanCollide=collide==true;p.CanTouch=false
 p.Size=size;p.CFrame=cf;p.Color=color;p.Material=material or Enum.Material.SmoothPlastic
 p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
 if shape then p.Shape=shape end
 p.Parent=par;n+=1
 return p
end
local function ball(par,name,loc,size,c,mat)
 return mk(par,name,Vector3.new(size,size*.77,size),CFrame.new(loc),c,mat or Enum.Material.Grass,Enum.PartType.Ball)
end
local function segment(par,name,a,b,width,color,material)
 local dif=b-a
 return mk(par,name,Vector3.new(width,width,dif.Magnitude),CFrame.lookAt((a+b)*.5,b),color,material)
end
local function tree(par,x,z,scale)
 local tree=Instance.new("Model");tree.Name="Cerejeira";tree.Parent=par
 local h=9*scale
 mk(tree,"Tronco",Vector3.new(1.5*scale,h,1.5*scale),CFrame.new(x,4+h/2,z),C.bark,Enum.Material.Wood,Enum.PartType.Cylinder,true)
 local colors={C.pink,C.pink2,C.pink3}
 for j=1,3 do
  local a=j*math.pi*2/3+.28
  local A=Vector3.new(x,4+h*.67,z)
  local B=Vector3.new(x+math.cos(a)*4.3*scale,4+h*1.12,z+math.sin(a)*4.3*scale)
  segment(tree,"Galho",A,B,.8*scale,C.bark,Enum.Material.Wood)
 end
 for j=1,9 do
  local a=j*2.4
  local r=(j%3==0 and 2.5 or 5.3)*scale
  local y=4+h+(j%4)*1.13*scale
  ball(tree,"Flores",Vector3.new(x+math.cos(a)*r,y,z+math.sin(a)*r),(5.1+((j*3)%4)*.6)*scale,colors[(j%3)+1])
 end
 tree:SetAttribute("MMNativePreview",true)
 return tree
end
local function bush(par,x,z,scale)
 for j=1,3 do
  local a=j*2.09
  ball(par,"Arbusto",Vector3.new(x+math.cos(a)*1.35*scale,5.35*scale,z+math.sin(a)*1.35*scale),3*scale,j%2==0 and C.green2 or C.green3)
 end
end
local function clump(par,x,z,scale)
 for j=1,3 do
  local a=j*2.5
  local dx=math.cos(a)*.6*scale;local dz=math.sin(a)*.6*scale
  mk(par,"Capim",Vector3.new(.32*scale,2.1*scale,.38*scale),CFrame.new(x+dx,4.9+scale*.7,z+dz)*CFrame.Angles(0,a,math.rad(18)),j%2==0 and C.green2 or C.grass,Enum.Material.Grass)
 end
end
local function rock(par,x,z,scale)
 return mk(par,"Pedra",Vector3.new(2.7*scale,1.15*scale,2.2*scale),CFrame.new(x,4.25+scale*.35,z)*CFrame.Angles(0,rng:NextNumber(0,6.28),math.rad(rng:NextNumber(-14,14))),rng:NextInteger(0,1)==0 and C.rock or C.rock2,Enum.Material.Slate,Enum.PartType.Block)
end
local function flower(par,x,z)
 local cols={Color3.fromRGB(255,231,169),Color3.fromRGB(245,174,155),Color3.fromRGB(244,238,229),Color3.fromRGB(203,188,233)}
 ball(par,"Flor",Vector3.new(x,4.42,z),.55,cols[rng:NextInteger(1,#cols)],Enum.Material.SmoothPlastic)
end
local function garden(root,cx,cz,index)
 local zone=Instance.new("Model");zone.Name="Jardim_"..index;zone.Parent=root
 local ground=Instance.new("Folder");ground.Name="Canteiros";ground.Parent=zone
 local flora=Instance.new("Folder");flora.Name="Vegetacao";flora.Parent=zone
 local details=Instance.new("Folder");details.Name="PedrasEFlores";details.Parent=zone
 local flat=mk(ground,"BaseJardim",Vector3.new(38,.12,36),CFrame.new(cx,4.02,cz),Color3.fromRGB(116,160,101),Enum.Material.Grass,Enum.PartType.Cylinder)
 flat.Transparency=.65
 for j=1,4 do
  local a=(j-1)*1.57+.35*index
  tree(flora,cx+math.cos(a)*12,cz+math.sin(a)*12,rng:NextNumber(.78,1.15))
 end
 task.wait()
 for j=1,10 do
  local a=rng:NextNumber(0,6.283);local r=rng:NextNumber(5,19)
  bush(flora,cx+math.cos(a)*r,cz+math.sin(a)*r,rng:NextNumber(.5,1))
 end
 for j=1,12 do
  local a=rng:NextNumber(0,6.283);local r=rng:NextNumber(3,20)
  clump(flora,cx+math.cos(a)*r,cz+math.sin(a)*r,rng:NextNumber(.7,1.15))
 end
 task.wait()
 for j=1,11 do
  local a=rng:NextNumber(0,6.283);local r=rng:NextNumber(2,20)
  rock(details,cx+math.cos(a)*r,cz+math.sin(a)*r,rng:NextNumber(.65,1.45))
 end
 for j=1,25 do
  local a=rng:NextNumber(0,6.283);local r=rng:NextNumber(2,19)
  flower(details,cx+math.cos(a)*r,cz+math.sin(a)*r)
 end
 local logA=Vector3.new(cx+18,5.05,cz-4);local logB=Vector3.new(cx+23,5.0,cz-7)
 segment(details,"TroncoCaido",logA,logB,1.6,C.bark,Enum.Material.Wood)
 zone:SetAttribute("GardenIndex",index)
 task.wait()
end
local function streams(root)
 local group=Instance.new("Model");group.Name="RiachoEPonte";group.Parent=root
 -- Cosmetic creek over existing terrain, crossed by a flat, traversable timber footbridge.
 for j=-4,4 do
  local z=-111+j*4.7
  local x=-111+math.sin(j*.55)*3.3
  local water=mk(group,"Agua",Vector3.new(9,.08,5.35),CFrame.new(x,4.15,z)*CFrame.Angles(0,math.rad(math.sin(j)*9),0),C.water,Enum.Material.Glass)
  water.Transparency=.22
  for side=-1,1,2 do
   rock(group,x+side*5.3,z,rng:NextNumber(.5,.8))
  end
 end
 local bx=-111;local bz=-111
 -- Crossing from west to east, safe because terrain underneath remains intact.
 local deck=mk(group,"TabladoPonte",Vector3.new(17,.55,7.5),CFrame.new(bx,5.00,bz),C.bark,Enum.Material.WoodPlanks,nil,true)
 deck:SetAttribute("Passagem",true)
 for j=-4,4 do
  mk(group,"Tabua",Vector3.new(1.73,.08,7.42),CFrame.new(bx+j*1.86,5.32,bz),j%2==0 and C.sand or C.bark,Enum.Material.WoodPlanks)
 end
 for side=-1,1,2 do
  for j=-1,1 do
   local x=bx+j*7.5
   mk(group,"PosteCorrimao",Vector3.new(.65,3,.65),CFrame.new(x,6.65,bz+side*3.25),C.bronze,Enum.Material.Wood)
  end
  mk(group,"Corrimao",Vector3.new(16,.5,.5),CFrame.new(bx,7.9,bz+side*3.25),C.bark,Enum.Material.Wood)
 end
 for side=-1,1,2 do
  for j=1,4 do
   local x=bx+side*(8.8+j*2.7)
   mk(group,"AcessoPedras",Vector3.new(2.65,.2,6.4),CFrame.new(x,4.57,bz),C.rock2,Enum.Material.Cobblestone)
  end
 end
end
local function paths(root)
 local group=Instance.new("Folder");group.Name="DetalheCaminhos";group.Parent=root
 for path=1,12 do
  local a=(path-1)*math.pi/6
  for j=1,5 do
   local r=31+j*12
   local x=math.sin(a)*r;local z=math.cos(a)*r
   mk(group,"PaverLaboratorio",Vector3.new(7.1,.07,5.5),CFrame.lookAt(Vector3.new(x,4.61,z),Vector3.new(0,4.61,0)),j%3==0 and C.rock2 or C.ivory,Enum.Material.Cobblestone)
  end
 end
end
local function lamps(root)
 local group=Instance.new("Model");group.Name="LuminariasJardim";group.Parent=root
 local coords={{83,83},{83,-83},{-83,83},{-83,-83}}
 for _,v in ipairs(coords) do
  local x,z=v[1],v[2]
  mk(group,"Coluna",Vector3.new(.8,7,.8),CFrame.new(x,7.8,z),C.bronze,Enum.Material.Metal)
  local glow=ball(group,"Lanterna",Vector3.new(x,11.2,z),2.4,C.golden,Enum.Material.Neon)
  local li=Instance.new("PointLight");li.Color=Color3.fromRGB(255,218,161);li.Brightness=.8;li.Range=17;li.Shadows=false;li.Parent=glow
 end
end
function M.Finish()
 local root=workspace:FindFirstChild("MM_LandscapeGarden_v1")
 if not root then return {status="no_preview"} end
 if root:FindFirstChild("SoloEVegetacaoExtra") then return {status="already_exists"} end
 local zone=Instance.new("Folder");zone.Name="SoloEVegetacaoExtra";zone.Parent=root
 local rd=Random.new(12391);local made=0
 local function protected(x,z)
  for _,v in ipairs({{165,0},{-165,0},{0,165},{0,-165}}) do
   if (Vector2.new(x,z)-Vector2.new(v[1],v[2])).Magnitude<37 then return true end
  end
  for _,v in ipairs({{109,109},{-109,109},{109,-109},{-109,-109}}) do
   if (Vector2.new(x,z)-Vector2.new(v[1],v[2])).Magnitude<28 then return true end
  end
  return false
 end
 for _,site in ipairs({{109,109},{-109,109},{109,-109},{-109,-109}}) do
  local x,z=site[1],site[2]
  for j=1,3 do
   local a=j*2.09+.45
   local p=mk(zone,"CanteiroIrregular",Vector3.new(19+rd:NextNumber(0,6),.7,15+rd:NextNumber(0,7)),CFrame.new(x+math.cos(a)*9,4.22,z+math.sin(a)*9)*CFrame.Angles(0,a,0),j%2==0 and C.green3 or C.grass,Enum.Material.Grass,Enum.PartType.Ball)
   p.Transparency=.2;made+=1
  end
  for j=1,7 do
   local f=j/8
   mk(zone,"PassoPedra",Vector3.new(3.25,.12,2.25),CFrame.new(x*(1-f*.21)+math.sin(j*1.4)*2,4.6,z*(1-f*.21)+math.cos(j*.9)*2)*CFrame.Angles(0,.35*j,0),j%2==0 and C.rock2 or C.ivory,Enum.Material.Cobblestone)
   made+=1
  end
  task.wait()
 end
 for i=1,175 do
  local a=rd:NextNumber(0,6.283);local r=rd:NextNumber(140,184)
  local x=math.sin(a)*r;local z=math.cos(a)*r
  if not protected(x,z) then
   if i%5==0 then rock(zone,x,z,rd:NextNumber(.45,.85))
   elseif i%3==0 then bush(zone,x,z,rd:NextNumber(.45,.8))
   else clump(zone,x,z,rd:NextNumber(.5,1)) end
   made+=1
  end
  if i%35==0 then task.wait() end
 end
 zone:SetAttribute("NonCollidingCosmetic",true)
 return {status="built",groupItems=made,descendants=#zone:GetDescendants()}
end
function M.Build()
 if not workspace:FindFirstChild("MM_World") then error("MM_World nao encontrado") end
 local existing=workspace:FindFirstChild("MM_LandscapeGarden_v1")
 if existing then return {status="already_exists",count=#existing:GetDescendants()} end
 local root=Instance.new("Folder");root.Name="MM_LandscapeGarden_v1";root:SetAttribute("NativePreview",true)
 root:SetAttribute("BlenderGLBImported",false)
 root:SetAttribute("SafeAdditiveBuild",true)
 root.Parent=workspace
 local ok,err=pcall(function()
  garden(root,109,109,1)
  garden(root,-109,109,2)
  garden(root,109,-109,3)
  garden(root,-109,-109,4)
  streams(root)
  paths(root)
  lamps(root)
  M.Finish()
 end)
 if not ok then root.Name="MM_LandscapeGarden_v1_INCOMPLETE";error(err) end
 return {status="built",count=#root:GetDescendants(),parts=n,gardens=4,glb=false}
end
return M