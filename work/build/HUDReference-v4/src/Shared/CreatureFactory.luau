local Catalog=require(script.Parent.CreatureCatalog)
local Mutations=require(script.Parent.MutationConfig)
local Collection=game:GetService("CollectionService")
local F={}
function F.Build(index,descriptor,position)
	local def=Catalog[index] or Catalog[1]
	local m=Instance.new("Model") m.Name=def.Name
	local rgb=descriptor and Mutations.Palette[descriptor.Palette] or def.Color
	local color=Color3.fromRGB(table.unpack(rgb))
	local cream=Color3.fromRGB(255,244,213)
	local dark=Color3.fromRGB(37,62,69)
	local function part(name,size,pos,c,shape)
		local p=Instance.new("Part") p.Name=name p.Anchored=true p.CanCollide=false p.CanTouch=false p.CanQuery=false
		p.Size=size p.CFrame=CFrame.new(pos) p.Color=c or color p.Material=Enum.Material.SmoothPlastic
		p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth
		if shape then p.Shape=shape end p.Parent=m return p
	end
	local function ball(name,size,pos,c) return part(name,size,pos,c,Enum.PartType.Ball) end
	local body=ball("Body",Vector3.new(3.2,2.8,2.6),Vector3.new(0,2,0)) m.PrimaryPart=body
	ball("Belly",Vector3.new(2.3,1.9,.65),Vector3.new(0,1.7,-1.08),cream)
	local shape=def.Shape
	if shape=="pod" then
		for i=-1,1,2 do local leaf=ball("Leaf",Vector3.new(.8,1.6,.35),Vector3.new(i*.5,3.7,0),Color3.fromRGB(64,153,119)) leaf.CFrame*=CFrame.Angles(0,0,i*.5) end
	elseif shape=="snail" then
		body.Size=Vector3.new(4,1.8,2.6) ball("Shell",Vector3.new(2.9,3,2.4),Vector3.new(0,2.8,.8),cream)
		ball("ShellSpiral",Vector3.new(1.7,1.7,.4),Vector3.new(0,3,2),color)
	elseif shape=="ghost" then
		body.Size=Vector3.new(3.1,3.7,2.7)
		for i=-1,1 do ball("Wisp",Vector3.new(1.1,1.6,1.2),Vector3.new(i,0.7,0)) end
	elseif shape=="deer" then
		for i=-1,1,2 do part("Antler",Vector3.new(.28,2,.3),Vector3.new(i,4.1,0),cream) part("Twig",Vector3.new(1,.25,.3),Vector3.new(i*1.2,4.3,0),cream) end
	elseif shape=="crab" then
		body.Size=Vector3.new(4,2.2,2.7)
		for i=-1,1,2 do ball("Claw",Vector3.new(1.6,1.7,1.2),Vector3.new(i*2.5,2,-.3)) for z=-1,1 do part("Leg",Vector3.new(1.8,.3,.3),Vector3.new(i*2,1,z),color) end end
	elseif shape=="jelly" then
		body.Size=Vector3.new(3.8,2.2,3.4)
		for i=-1,1 do ball("Tentacle",Vector3.new(.4,2.3,.4),Vector3.new(i,.5,0),cream) end
	elseif shape=="rock" then
		body.Shape=Enum.PartType.Block body.Size=Vector3.new(3,2.6,2.5) body.CFrame*=CFrame.Angles(0,0,.12)
		for i=-1,1 do local crystal=part("Crystal",Vector3.new(.6,1.2,.6),Vector3.new(i*.8,3.5,0),cream) crystal.CFrame*=CFrame.Angles(0,0,i*.3) end
	elseif shape=="bat" or shape=="moth" then
		for i=-1,1,2 do local wing=ball("Wing",Vector3.new(2.5,shape=="moth" and 3.3 or 1.7,.5),Vector3.new(i*2.1,2,.5),cream) wing.CFrame*=CFrame.Angles(0,0,i*.4) end
	elseif shape=="axolotl" then
		for i=-1,1,2 do for j=1,3 do local gill=ball("Gill",Vector3.new(1.5,.35,.4),Vector3.new(i*1.8,1.7+j*.45,0),cream) gill.CFrame*=CFrame.Angles(0,0,i*(j-2)*.5) end end
	elseif shape=="cloud" then
		for i=-1,1 do ball("Cloudlet",Vector3.new(2,2,2),Vector3.new(i*1.3,2.4,0)) end
	elseif shape=="dragon" then
		for i=-1,1,2 do local horn=part("Crown",Vector3.new(.5,1.5,.5),Vector3.new(i*.8,3.6,0),cream) horn.CFrame*=CFrame.Angles(0,0,i*.25) end
		ball("Snout",Vector3.new(2,1.3,1.4),Vector3.new(0,1.6,-1.5))
		ball("DragonTail",Vector3.new(1,1,3),Vector3.new(0,1,2))
	end
	for i=-1,1,2 do ball("Foot",Vector3.new(1,.65,1.4),Vector3.new(i*.9,.5,-.1),color) end
	local eyes=descriptor and descriptor.Eyes or 2
	for i=1,eyes do local x=(i-(eyes+1)/2)*.95
		ball("EyeWhite",Vector3.new(.8,.9,.5),Vector3.new(x,2.4,-1.25),Color3.new(1,1,1))
		ball("Pupil",Vector3.new(.36,.49,.2),Vector3.new(x,2.38,-1.53),dark)
		ball("EyeShine",Vector3.new(.12,.14,.09),Vector3.new(x-.08,2.51,-1.65),Color3.new(1,1,1))
	end
	ball("Smile",Vector3.new(.5,.17,.14),Vector3.new(0,1.65,-1.48),dark)
	if descriptor then
		for i=1,descriptor.Horns do local p=part("MutationHorn",Vector3.new(.4,1.25,.4),Vector3.new((i-(descriptor.Horns+1)/2)*1.3,3.7,-.3),cream) p.CFrame*=CFrame.Angles(0,0,(i-1.5)*.35) end
		if descriptor.Wings==1 and shape~="bat" and shape~="moth" then for i=-1,1,2 do ball("MutationWing",Vector3.new(1.8,1.6,.4),Vector3.new(i*1.9,2,.7),cream) end end
		if descriptor.Tail==1 then ball("MutationTail",Vector3.new(.7,.7,2.5),Vector3.new(0,1.3,2),cream) end
		if descriptor.Material==2 then body.Material=Enum.Material.Glass body.Transparency=.12 elseif descriptor.Material==3 then body.Material=Enum.Material.Marble end
		if descriptor.Sparkles then local s=Instance.new("Sparkles") s.Name="MutationGlints" s.SparkleColor=color s.Parent=body end
		m:ScaleTo(descriptor.Scale)
	end
	m:PivotTo(CFrame.new(position)) m:SetAttribute("Home",m:GetPivot()) m:SetAttribute("Mood","Idle") m:SetAttribute("Archetype",index)
	Collection:AddTag(m,"MMCreature") return m
end
return F
