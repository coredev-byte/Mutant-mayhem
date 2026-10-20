-- Original procedural art. Re-runnable only against the owned MM_World container.
local M={}
function M.Build()
	local W=workspace:FindFirstChild("MM_World") if W then W:Destroy() end
	W=Instance.new("Folder") W.Name="MM_World" W.Parent=workspace
	local F=require(game.ReplicatedStorage.MM.Shared.CreatureFactory)
	local C={cream=Color3.fromRGB(248,233,201),ink=Color3.fromRGB(36,75,79),mint=Color3.fromRGB(133,207,170),coral=Color3.fromRGB(241,143,122),lilac=Color3.fromRGB(178,165,217),grass=Color3.fromRGB(111,172,130),gold=Color3.fromRGB(245,199,106)}
	local function part(parent,name,size,cf,color,shape,material)
		local p=Instance.new("Part") p.Name=name p.Anchored=true p.Size=size p.CFrame=cf p.Color=color p.Material=material or Enum.Material.SmoothPlastic
		p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth if shape then p.Shape=shape end p.Parent=parent return p
	end
	local function disk(parent,name,r,h,pos,color) return part(parent,name,Vector3.new(h,r*2,r*2),CFrame.new(pos)*CFrame.Angles(0,0,math.pi/2),color,Enum.PartType.Cylinder) end
	local function label(parent,text,pos,width)
		local a=part(parent,"Sign",Vector3.new(width or 18,2,.4),CFrame.new(pos),C.ink) a.CanCollide=false
		local g=Instance.new("BillboardGui") g.Size=UDim2.fromOffset((width or 18)*13,55) g.StudsOffset=Vector3.new(0,1,0) g.MaxDistance=130 g.Parent=a
		local t=Instance.new("TextLabel") t.Size=UDim2.fromScale(1,1) t.BackgroundTransparency=1 t.Text=text t.TextColor3=C.cream t.TextScaled=true t.Font=Enum.Font.GothamBold t.Parent=g return t
	end
	disk(W,"Island",218,12,Vector3.new(0,-2,0),C.grass)
	disk(W,"IslandRim",221,5,Vector3.new(0,-9,0),C.ink)
	part(W,"Ocean",Vector3.new(1600,2,1600),CFrame.new(0,-15,0),Color3.fromRGB(89,158,174))
	disk(W,"CentralCourt",45,.5,Vector3.new(0,4.2,0),C.cream)
	local paths=Instance.new("Folder") paths.Name="Paths" paths.Parent=W
	local plots=Instance.new("Folder") plots.Name="Plots" plots.Parent=W
	for i=1,12 do
		local angle=(i-1)*math.pi/6 local pos=Vector3.new(math.sin(angle)*105,5,math.cos(angle)*105)
		local cf=CFrame.lookAt(pos,Vector3.new(0,5,0))
		part(paths,"LabPath"..i,Vector3.new(9,.4,66),CFrame.lookAt(pos*.61+Vector3.new(0,1.3,0),Vector3.new(0,4.35,0)),C.cream)
		local plot=Instance.new("Model") plot.Name="Plot"..i plot:SetAttribute("PlotId",i) plot:SetAttribute("OwnerId",0)
		local base=part(plot,"Base",Vector3.new(32,1.4,28),cf,C.ink) plot.PrimaryPart=base
		part(plot,"Floor",Vector3.new(30,.3,26),cf*CFrame.new(0,.85,0),C.cream)
		part(plot,"BackWall",Vector3.new(30,7,.8),cf*CFrame.new(0,4,13),C.mint)
		for side=-1,1,2 do
			part(plot,"Pillar",Vector3.new(1,10,1),cf*CFrame.new(side*15,5,12),C.ink)
			part(plot,"RoofFin",Vector3.new(1,1,18),cf*CFrame.new(side*15,10,4),C.coral)
			part(plot,"Rail",Vector3.new(.6,2,18),cf*CFrame.new(side*15,1.8,3),C.mint)
		end
		part(plot,"Canopy",Vector3.new(32,1.2,8),cf*CFrame.new(0,10,10),i%2==0 and C.coral or C.lilac)
		local terminal=part(plot,"Terminal",Vector3.new(3,3,2),cf*CFrame.new(-11,2.3,-10),C.ink)
		local screen=part(plot,"Screen",Vector3.new(2.5,1.4,.15),terminal.CFrame*CFrame.new(0,.4,-1.05),C.mint, nil,Enum.Material.Neon) screen.CanCollide=false
		for slot=1,12 do
			local x=((slot-1)%4-1.5)*6.6 local z=math.floor((slot-1)/4)*6.6-5
			local pad=disk(plot,"Pad"..slot,2.5,.25,(cf*CFrame.new(x,1.1,z)).Position,slot<=2 and C.mint or C.lilac)
			pad:SetAttribute("Slot",slot)
		end
		label(plot,"LAB "..string.format("%02d",i), (cf*CFrame.new(0,11,10)).Position,15)
		plot.Parent=plots task.wait()
	end
	local reactor=Instance.new("Model") reactor.Name="Reactor" reactor.Parent=W
	disk(reactor,"Base",14,1,Vector3.new(0,5,0),C.ink)
	disk(reactor,"GoldLip",12,1,Vector3.new(0,6,0),C.gold)
	local chamber=part(reactor,"GlassChamber",Vector3.new(12,15,12),CFrame.new(0,14,0),C.mint,Enum.PartType.Cylinder,Enum.Material.Glass)
	chamber.Size=Vector3.new(15,12,12) chamber.CFrame=CFrame.new(0,14,0)*CFrame.Angles(0,0,math.pi/2) chamber.Transparency=.65 chamber.CanCollide=true
	disk(reactor,"Lid",8,.8,Vector3.new(0,22,0),C.ink)
	for ring=1,3 do
		local model=Instance.new("Model") model.Name="EnergyRing"..ring
		for j=1,16 do local a=j*math.pi/8 local p=part(model,"Segment",Vector3.new(3,.35,.55),CFrame.new(math.sin(a)*8.8,9+ring*3,math.cos(a)*8.8)*CFrame.Angles(0,a,0),ring==2 and C.coral or C.gold,nil,Enum.Material.Neon) p.CanCollide=false end
		model.Parent=reactor model:SetAttribute("Home",model:GetPivot()) game:GetService("CollectionService"):AddTag(model,"MMRing")
	end
	local mascot=F.Build(1,{Palette=1,Eyes=3,Horns=2,Wings=1,Tail=1,Scale=1.8,Material=2,Sparkles=true},Vector3.new(0,13,0)) mascot.Name="ReactorMascot" mascot.Parent=reactor
	label(reactor,"THE MUTATION REACTOR",Vector3.new(0,26,0),25)
	local spawn=Instance.new("SpawnLocation") spawn.Name="WelcomeSpawn" spawn.Anchored=true spawn.Neutral=true spawn.Size=Vector3.new(12,1,10) spawn.Position=Vector3.new(0,5,33) spawn.Color=C.mint spawn.Material=Enum.Material.SmoothPlastic spawn.Parent=W
	local zones={{"Meadow",Vector3.new(165,5,0),C.mint,"DISCOVERY MEADOW"},{"Events",Vector3.new(0,5,-165),C.coral,"MUTATION FESTIVAL"},{"Showcase",Vector3.new(-165,5,0),C.lilac,"THE CREATURE CLUB"},{"Shop",Vector3.new(0,5,165),C.gold,"STYLE LAB"}}
	for _,z in zones do
		local zone=Instance.new("Model") zone.Name=z[1] zone.Parent=W
		disk(zone,"Base",29,1,z[2],z[3])
		local marker=part(zone,"Marker",Vector3.new(1,1,1),CFrame.new(z[2]+Vector3.new(0,3,0)),z[3]) marker.Transparency=1 marker.CanCollide=false
		label(zone,z[4],z[2]+Vector3.new(0,10,10),24)
		local pathCenter=Vector3.new(z[2].X*.62,4.35,z[2].Z*.62)
		part(paths,z[1].."Path",Vector3.new(10,.35,120),CFrame.lookAt(pathCenter,Vector3.new(0,4.35,0)),C.cream)
		for j=1,6 do local a=j*math.pi/3 disk(zone,"Stool",2,1,z[2]+Vector3.new(math.sin(a)*23,1,math.cos(a)*23),C.ink) end
		if z[1]=="Meadow" then
			for j=1,6 do local a=j*math.pi/3 local p=z[2]+Vector3.new(math.sin(a)*16,3,math.cos(a)*16) local pet=F.Build(j,nil,p) pet.Parent=zone end
		elseif z[1]=="Showcase" then
			for j=7,12 do local a=j*math.pi/3 local p=z[2]+Vector3.new(math.sin(a)*16,3,math.cos(a)*16) local pet=F.Build(j,nil,p) pet.Parent=zone end
		elseif z[1]=="Events" then
			local text=label(zone,"Festival countdown",z[2]+Vector3.new(0,6,-5),23) text.Name="EventText"
		elseif z[1]=="Shop" then
			for j=1,3 do local p=z[2]+Vector3.new((j-2)*9,2,0) disk(zone,"StylePedestal",3,1,p,C.ink) local pet=F.Build(j+7,{Palette=j+2,Eyes=2,Horns=1,Wings=0,Tail=1,Scale=1,Material=j,Sparkles=false},p+Vector3.new(0,2,0)) pet.Parent=zone end
		end
		task.wait()
	end
	local nature=Instance.new("Folder") nature.Name="Gardens" nature.Parent=W
	local rng=Random.new(6142)
	for i=1,64 do
		local a=i*math.pi*2/64 local r=rng:NextNumber(190,209) local pos=Vector3.new(math.sin(a)*r,5,math.cos(a)*r)
		part(nature,"Trunk",Vector3.new(1.8,7,1.8),CFrame.new(pos+Vector3.new(0,2,0)),C.ink)
		part(nature,"RoundCanopy",Vector3.new(9,10,9),CFrame.new(pos+Vector3.new(0,8,0)),i%3==0 and C.lilac or C.mint,Enum.PartType.Ball)
		if i%12==0 then task.wait() end
	end
	for i=1,60 do local a=rng:NextNumber(0,math.pi*2) local r=rng:NextNumber(48,75) local pos=Vector3.new(math.sin(a)*r,4.9,math.cos(a)*r)
		part(nature,"Flower",Vector3.new(.8,.6,.8),CFrame.new(pos),i%2==0 and C.coral or C.gold,Enum.PartType.Ball)
	end
	local L=game:GetService("Lighting") L.ClockTime=15.5 L.Brightness=2.5 L.Ambient=Color3.fromRGB(145,159,163) L.OutdoorAmbient=Color3.fromRGB(156,171,183)
	for _,name in {"MMAtmosphere","MMBloom","MMColor"} do local old=L:FindFirstChild(name) if old then old:Destroy() end end
	local a=Instance.new("Atmosphere") a.Name="MMAtmosphere" a.Density=.25 a.Offset=.15 a.Color=Color3.fromRGB(215,235,238) a.Decay=Color3.fromRGB(236,198,162) a.Parent=L
	local bloom=Instance.new("BloomEffect") bloom.Name="MMBloom" bloom.Intensity=.15 bloom.Size=22 bloom.Threshold=1.5 bloom.Parent=L
	local tone=Instance.new("ColorCorrectionEffect") tone.Name="MMColor" tone.Saturation=.08 tone.Contrast=.05 tone.Parent=L
	if workspace.CurrentCamera then workspace.CurrentCamera.CFrame=CFrame.lookAt(Vector3.new(220,210,255),Vector3.new(0,4,0)) end
	return {Descendants=#W:GetDescendants(),Plots=#plots:GetChildren()}
end
return M
