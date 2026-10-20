local Run=game:GetService("RunService")
local Tags=game:GetService("CollectionService")
local player=game:GetService("Players").LocalPlayer
local pets={}
local function add(m)
	local eyes,limbs={},{}
	for _,p in m:GetDescendants() do if p:IsA("BasePart") then
		if p.Name=="Pupil" or p.Name=="EyeWhite" or p.Name=="EyeShine" then table.insert(eyes,{Part=p,Size=p.Size}) end
		if p.Name:find("Wing") or p.Name=="Tentacle" or p.Name=="Leaf" then table.insert(limbs,{Part=p,Offset=m:GetPivot():ToObjectSpace(p.CFrame)}) end
	end end
	pets[m]={Home=m:GetAttribute("Home") or m:GetPivot(),Eyes=eyes,Limbs=limbs,Phase=#pets*.7,Body=m.PrimaryPart,BodySize=m.PrimaryPart and m.PrimaryPart.Size}
end
for _,m in Tags:GetTagged("MMCreature") do add(m) end
Tags:GetInstanceAddedSignal("MMCreature"):Connect(add)
Tags:GetInstanceRemovedSignal("MMCreature"):Connect(function(m) pets[m]=nil end)
local elapsed=0
Run.RenderStepped:Connect(function(dt)
	elapsed+=dt local low=player:GetAttribute("MMLowGraphics") local reduced=player:GetAttribute("MMReducedMotion")
	if elapsed<(low and .1 or 1/30) then return end elapsed=0
	local camera=workspace.CurrentCamera local now=os.clock() local count=0
	for model,v in pets do if model:IsDescendantOf(workspace) then
		local distance=(camera.CFrame.Position-v.Home.Position).Magnitude
		local active=distance<(low and 65 or 120) and count<(low and 10 or 24)
		for _,effect in model:GetDescendants() do if effect:IsA("Sparkles") then effect.Enabled=active and not low and not reduced end end
		if active then count+=1 local t=now+v.Home.Position.X*.07
			local mood=model:GetAttribute("Mood") or "Idle" local amplitude=.13 local frequency=2
			if mood=="Idle" then local cycle=t%60 if cycle>50 then mood="Sleep" elseif cycle>35 and cycle<42 then mood="Walk" end end
			if mood=="Happy" then amplitude=.45 frequency=6 elseif mood=="Walk" then amplitude=.22 frequency=8 elseif mood=="Sleep" then amplitude=.04 frequency=.8 elseif mood=="Reaction" then amplitude=.28 frequency=10 elseif mood=="Mutation" then amplitude=.6 frequency=5 end
			local offset=reduced and CFrame.new() or CFrame.new(0,math.sin(t*frequency)*amplitude,0)*CFrame.Angles(0,math.sin(t)*.07,math.sin(t*1.3)*.025)
			model:PivotTo(v.Home*offset)
			local blink=(t%4.7)>.0 and (t%4.7)<.12
			for _,eye in v.Eyes do if eye.Part.Parent then eye.Part.Size=Vector3.new(eye.Size.X,eye.Size.Y*(blink and .1 or 1),eye.Size.Z) end end
			if v.Body and v.Body.Parent and v.BodySize then local scale=reduced and 1 or 1+math.sin(t*frequency)*.025 v.Body.Size=Vector3.new(v.BodySize.X/scale,v.BodySize.Y*scale,v.BodySize.Z) end
			if not reduced then for _,limb in v.Limbs do if limb.Part.Parent then limb.Part.CFrame=model:GetPivot()*limb.Offset*CFrame.Angles(0,0,math.sin(t*3)*.1) end end end
		end
	end end
	if not reduced and not low then for _,ring in Tags:GetTagged("MMRing") do local home=ring:GetAttribute("Home") if home and (camera.CFrame.Position-home.Position).Magnitude<140 then ring:PivotTo(home*CFrame.Angles(0,now*.2,0)) end end end
end)
