-- CAOS MUTANTE • real Creator Store mesh landscape v2
-- Non-destructive: writes only Workspace.MM_RealLandscape_v2.
-- Templates must be present in ServerStorage.MM_RealGardenAssets_v2.
-- Based on supplied GardenKit v1 layout direction; no GLB import is claimed.
local M={}
local S=game:GetService("ServerStorage")
local Templates=S:WaitForChild("MM_RealGardenAssets_v2")
local rng=Random.new(20261021)
local C={soil=Color3.fromRGB(89,116,69),grass=Color3.fromRGB(99,142,86),
 stone=Color3.fromRGB(155,161,149),stone2=Color3.fromRGB(177,184,166),
 wood=Color3.fromRGB(98,71,52),water=Color3.fromRGB(78,155,166),
 flower1=Color3.fromRGB(240,182,208),flower2=Color3.fromRGB(254,239,202)}
local assetInstances=0
local function piece(parent,name,size,cf,color,material,collide,shape)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf
 p.Anchored=true;p.CanCollide=collide or false;p.CanTouch=false;p.CanQuery=collide==true
 p.Color=color;p.Material=material or Enum.Material.SmoothPlastic
 p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
 if shape then p.Shape=shape end
 p.Parent=parent
 return p
end
local function mesh(parent,template,name,x,z,scale,angle,y)
 local src=Templates:FindFirstChild(template)
 if not src then error("Missing sanitized asset template: "..template) end
 local m=src:Clone()
 m.Name=name or template
 m:ScaleTo(scale or 1)
 m:PivotTo(CFrame.new(x,y or 4.04,z)*CFrame.Angles(0,angle or 0,0))
 m:SetAttribute("MCPRealAsset",true)
 m.Parent=parent
 assetInstances+=1
 return m
end
local function tooCloseToGameplay(x,z)
 if x*x+z*z<125*125 then return true end
 for _,v in ipairs({{165,0},{-165,0},{0,165},{0,-165}}) do
  if (Vector2.new(x,z)-Vector2.new(v[1],v[2])).Magnitude<36 then return true end
 end
 return false
end
local function grassTuft(parent,x,z,height)
 for j=1,4 do
  local a=j*math.pi*.67
  local p=piece(parent,"Capim",
   Vector3.new(.18+height*.05,1.65*height,.20+height*.05),
   CFrame.new(x+math.cos(a)*.35*height,4.35+.65*height,z+math.sin(a)*.35*height)*CFrame.Angles(0,a,math.rad((j%2==0 and 21 or -21))),
   j%2==0 and C.grass or C.soil,Enum.Material.Grass)
 end
end
local function flower(parent,x,z,pink)
 local p=piece(parent,"Flor",Vector3.new(.42,.28,.47),CFrame.new(x,4.28,z),
   pink and C.flower1 or C.flower2,Enum.Material.SmoothPlastic,false,Enum.PartType.Ball)
 return p
end
local function garden(parent,cx,cz,id)
 local root=Instance.new("Model");root.Name="Bosque_"..id;root.Parent=parent
 root:SetAttribute("MMGardenNumber",id)
 piece(root,"GramaIrregular",Vector3.new(43,1,38),
  CFrame.new(cx,3.75,cz)*CFrame.Angles(0,id*.37,0),
  C.grass,Enum.Material.Grass,false,Enum.PartType.Ball).Transparency=.09
 piece(root,"Canteiro",Vector3.new(25,.36,29),CFrame.new(cx+4,4.03,cz-1)*CFrame.Angles(0,id*.23,0),C.soil,Enum.Material.Ground).Transparency=.15
 local trees=Instance.new("Folder");trees.Name="ArvoresReais";trees.Parent=root
 local points={{-14,-7,.90},{13,-12,.82},{11,12,1.00},{-10,14,.76}}
 for j,pt in ipairs(points) do
  local jitterX=rng:NextNumber(-2.4,2.4);local jitterZ=rng:NextNumber(-2.4,2.4)
  mesh(trees,j==4 and "Pine" or "Sakura",j==4 and "Pinheiro" or "Cerejeira",cx+pt[1]+jitterX,cz+pt[2]+jitterZ,pt[3],rng:NextNumber(0,6.283))
 end
 task.wait()
 local under=Instance.new("Folder");under.Name="SubBosque";under.Parent=root
 for j=1,12 do
  local a=rng:NextNumber(0,6.283);local r=rng:NextNumber(6,23)
  mesh(under,"Fern","Samambaia",cx+math.cos(a)*r,cz+math.sin(a)*r,rng:NextNumber(.37,.69),a)
 end
 for j=1,8 do
  local a=rng:NextNumber(0,6.283);local r=rng:NextNumber(8,23)
  mesh(under,"MossRock","PedraMusgo",cx+math.cos(a)*r,cz+math.sin(a)*r,rng:NextNumber(.40,.65),a)
 end
 task.wait()
 for j=1,12 do
  local a=rng:NextNumber(0,6.283);local r=rng:NextNumber(4,23)
  grassTuft(under,cx+math.cos(a)*r,cz+math.sin(a)*r,rng:NextNumber(.65,1.2))
 end
 for j=1,22 do
  local a=rng:NextNumber(0,6.283);local r=rng:NextNumber(5,21)
  flower(under,cx+math.cos(a)*r,cz+math.sin(a)*r,j%2==0)
 end
 -- Paths angle toward the central reactor through the diagonal gap between labs.
 for j=1,3 do
  local f=j/4
  local x=cx*(1-f*.31);local z=cz*(1-f*.31)
  mesh(root,"StonePath","PedrasDoCaminho",x,z,.29,math.atan2(-x,-z))
 end
 for s=-1,1,2 do
  mesh(root,"Lantern","LanternaDeJardim",cx+s*17,cz+s*2,.43,s*.4)
  mesh(root,"Bench","BancoDeMadeira",cx+s*6,cz-s*19,1.15,s<0 and 2.6 or .5)
 end
 task.wait()
end
local function streamAndBridge(parent)
 local root=Instance.new("Model");root.Name="RiachoPonteJaponesa";root.Parent=parent
 local bx,bz=-143,-62
 -- Decorative stream crosses below bridge; safe with the existing solid island.
 for j=-6,6 do
  local z=bz+j*4.4;local x=bx+math.sin(j*.42)*1.3
  local p=piece(root,"AguaOrnamental",
   Vector3.new(8.8,.045,4.95),CFrame.new(x,4.06,z)*CFrame.Angles(0,math.sin(j)*.07,0),
   C.water,Enum.Material.Glass)
  p.Transparency=.24;p.Reflectance=.08
  if j%2==0 then
   mesh(root,"MossRock","PedraMargem",x+6.1,z,.48,j*.6)
   mesh(root,"Fern","SamambaiaMargem",x-6.2,z,.53,j)
  end
 end
 local bridge=mesh(root,"WoodBridge","PonteMalhaReal",bx,bz,.175,math.pi/2,3.97)
 bridge:SetAttribute("CosmeticMeshCollisionDisabled",true)
 local deck=piece(root,"PonteColisaoJogavel",
  Vector3.new(17.9,.55,6),CFrame.new(bx,4.98,bz),C.wood,Enum.Material.WoodPlanks,true)
 deck.Transparency=1;deck.CanQuery=true;deck:SetAttribute("MMBridgeSurface",true)
 for sign=-1,1,2 do
  for j=1,3 do
   mesh(root,"StonePath","PedrasAcesso",bx+sign*(11+j*5.2),bz,.24,math.pi/2)
  end
 end
 task.wait()
end
local function perimeter(parent)
 local section=Instance.new("Folder");section.Name="FlorestaPerimetral";section.Parent=parent
 local planted=0
 for i=1,55 do
  local a=i*2.39996323
  local radius=rng:NextNumber(181,201)
  local x=math.sin(a)*radius;local z=math.cos(a)*radius
  if not tooCloseToGameplay(x,z) then
   local species=i%5==0 and "Sakura" or "Pine"
   mesh(section,species,"ArvorePerimetro",x,z,species=="Sakura" and rng:NextNumber(.68,.83) or rng:NextNumber(.62,.78),a)
   planted+=1
   if i%2==0 then mesh(section,"Fern","VegetacaoBorda",x+2.5,z+2,.40,a*.5) end
  end
  if i%12==0 then task.wait() end
 end
 section:SetAttribute("TreeCount",planted)
end
local function centralGreens(parent)
 local f=Instance.new("Folder");f.Name="CanteirosLaterais";f.Parent=parent
 for i=1,30 do
  local a=i*2.39996323
  local r=rng:NextNumber(130,155)
  local x=math.sin(a)*r;local z=math.cos(a)*r
  if not tooCloseToGameplay(x,z) then
   mesh(f,"Fern","Samambaia",x,z,rng:NextNumber(.37,.65),a)
   if i%3==0 then mesh(f,"MossRock","PedraMusgo",x+2.8,z-2,.42,a) end
  end
 end
end
function M.Supplement()
 local root=workspace:FindFirstChild("MM_RealLandscape_v2")
 if not root then return {status="missing_art"} end
 local prior=root:FindFirstChild("VegetacaoRealComplementar")
 if prior then return {status="already_exists",descendants=#prior:GetDescendants()} end
 if not Templates:FindFirstChild("GrassPatch") or not Templates:FindFirstChild("Wildflower") then
  return {status="missing_sanitized_templates"}
 end
 local supplement=Instance.new("Folder")
 supplement.Name="VegetacaoRealComplementar"
 supplement.Parent=root
 local rd=Random.new(2741)
 local count=0
 for i,point in ipairs({{109,109},{-109,109},{109,-109},{-109,-109}}) do
  local gr=Instance.new("Folder");gr.Name="Bosque"..i;gr.Parent=supplement
  local cx,cz=point[1],point[2]
  for j=1,15 do
   local angle=rd:NextNumber(0,6.283185)
   local radius=rd:NextNumber(6,21)
   mesh(gr,"GrassPatch","GramaMesh",cx+math.cos(angle)*radius,cz+math.sin(angle)*radius,
    rd:NextNumber(.19,.37),angle)
   count+=1
  end
  for j=1,10 do
   local angle=rd:NextNumber(0,6.283185)
   local radius=rd:NextNumber(3,20)
   mesh(gr,"Wildflower","FloresNaturais",cx+math.cos(angle)*radius,cz+math.sin(angle)*radius,
    rd:NextNumber(.38,.68),angle)
   count+=1
  end
  task.wait()
 end
 local border=Instance.new("Folder");border.Name="FlorestaBorda";border.Parent=supplement
 for i=1,36 do
  local angle=i*2.39996323
  local r=rd:NextNumber(160,193)
  local x,z=math.sin(angle)*r,math.cos(angle)*r
  if not tooCloseToGameplay(x,z) then
   mesh(border,"GrassPatch","GramaBorda",x,z,rd:NextNumber(.19,.34),angle)
   count+=1
  end
  if i%12==0 then task.wait() end
 end
 supplement:SetAttribute("NoGameplayInteraction",true)
 supplement:SetAttribute("RealMeshInstances",count)
 return {status="built",instances=count,descendants=#supplement:GetDescendants()}
end
function M.Build()
 if not workspace:FindFirstChild("MM_World") then error("MM_World missing") end
 local old=workspace:FindFirstChild("MM_RealLandscape_v2")
 if old then return {status="already_exists",descendants=#old:GetDescendants()} end
 assetInstances=0
 local root=Instance.new("Folder")
 root.Name="MM_RealLandscape_v2"
 root:SetAttribute("UsesCreatorStoreMeshParts",true)
 root:SetAttribute("UsesOriginalGardenKitGLB",false)
 root:SetAttribute("PreservesGameWorld",true)
 root.Parent=workspace
 local ok,err=pcall(function()
  garden(root,109,109,1)
  garden(root,-109,109,2)
  garden(root,109,-109,3)
  garden(root,-109,-109,4)
  streamAndBridge(root)
  perimeter(root)
  centralGreens(root)
  M.Supplement()
 end)
 if not ok then root.Name="MM_RealLandscape_v2_INCOMPLETE";error(err) end
 return {status="built",instances=assetInstances,descendants=#root:GetDescendants()}
end
return M
