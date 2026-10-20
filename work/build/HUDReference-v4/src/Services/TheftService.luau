-- Safe vertical-slice mode: opt-in DNA raids create a NEW specimen, never remove a saved creature.
-- Permanent ownership theft is deliberately gated in GameConfig until escrow recovery is verified.
local Players=game:GetService("Players")
local D=require(script.Parent.PlayerDataService)
local P=require(script.Parent.PlotService)
local I=require(script.Parent.InventoryService)
local C=require(script.Parent.CreatureService)
local Anti=require(script.Parent.AntiExploitService)
local A=require(script.Parent.AnalyticsService)
local T={Carry={},Protection={},Cooldown={},Victims={},LastPosition={}}
local function speed(player,value) local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed=value end end
function T.Protect(player,seconds) T.Protection[player]=os.clock()+seconds end
function T.Cancel(player,message)
	local c=T.Carry[player] if not c then return end
	T.Victims[c.Victim]=nil T.Protect(c.Victim,90) T.Carry[player]=nil T.LastPosition[player]=nil
	player:SetAttribute("MMCarrying",false) speed(player,16)
	local prop=player.Character and player.Character:FindFirstChild("DNA_Carry") if prop then prop:Destroy() end
	if T.Notify then T.Notify(player,message or "DNA run ended safely.") end
end
function T.Start(player)
	local d=D.Get(player)
	if d.Settings.Peaceful then return false,"Enable social DNA raids in Settings first. Originals are always safe." end
	if T.Carry[player] or (T.Cooldown[player] or 0)>os.clock() then return false,"Your DNA sampler is cooling down." end
	if not I.Room(d) then return false,"Inventory full." end
	for victim,plot in P.Assigned do
		local vd=D.Get(victim)
		if victim~=player and vd and not vd.Settings.Peaceful and (T.Protection[victim] or 0)<os.clock() and not T.Victims[victim] and Anti.Near(player,plot.Base.Position,20) then
			for _,creature in vd.Creatures do if creature.Placed then
				T.Carry[player]={Victim=victim,Archetype=creature.Archetype,Started=os.clock(),Deadline=os.clock()+45}
				T.Victims[victim]=player T.Cooldown[player]=os.clock()+120 T.Protect(victim,90)
				player:SetAttribute("MMCarrying",true) speed(player,10)
				local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
				if root then local prop=Instance.new("Part") prop.Name="DNA_Carry" prop.Shape=Enum.PartType.Ball prop.Size=Vector3.new(1.7,1.7,1.7) prop.Material=Enum.Material.Neon prop.Color=Color3.fromRGB(143,225,179) prop.CanCollide=false prop.Massless=true prop.CFrame=root.CFrame*CFrame.new(0,.2,-2) prop.Parent=player.Character local weld=Instance.new("WeldConstraint") weld.Part0=root weld.Part1=prop weld.Parent=prop T.LastPosition[player]=root.Position end
				if T.Notify then T.Notify(victim,player.DisplayName.." is sampling your lab! Use DEFEND nearby. Your original is safe.") end
				A.Log("theft_attempt",player.UserId,{victim=victim.UserId,mode="non_destructive_DNA"})
				return true,"Carry the DNA home on foot in 45 seconds. Defender can interrupt!"
			end end
		end
	end
	return false,"Stand near an unshielded, opted-in player's lab."
end
function T.Defend(player)
	local thief=T.Victims[player]
	if thief then local root=thief.Character and thief.Character:FindFirstChild("HumanoidRootPart") if root and Anti.Near(player,root.Position,24) then T.Cancel(thief,"DNA run stopped by the defender!") return true,"Sample recovered. Lab shielded for 90 seconds." end end
	return false,"No sampler within defense range."
end
function T.Tick(dt)
	for player,c in T.Carry do
		local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		local victimData=D.Get(c.Victim)
		if not root or not victimData or victimData.Settings.Peaceful or os.clock()>c.Deadline or (T.LastPosition[player] and (root.Position-T.LastPosition[player]).Magnitude>24*dt+6) then T.Cancel(player,"DNA run canceled. All original creatures are safe.")
		else
			T.LastPosition[player]=root.Position
			if os.clock()-c.Started>=8 and P.Position(player) and Anti.Near(player,P.Position(player),18) and D.Editable(player) then
				local pet=C.Add(player,c.Archetype) if pet then D.Get(player).Stats.Raid+=1 A.Log("dna_raid_complete",player.UserId) end
				T.Cancel(player,pet and "DNA delivered. Saving your new specimen…" or "Inventory full. DNA returned safely.")
				if pet then task.spawn(function()
					local saved=D.Save(player,false)
					if T.Notify then T.Notify(player,saved and "New specimen saved in your inventory!" or "Specimen save is pending. Actions pause until recovery.") end
				end) end
			end
		end
	end
end
function T.Leave(player)
	T.Cancel(player) local thief=T.Victims[player] if thief then T.Cancel(thief,"Defender disconnected. DNA run canceled safely.") end
	T.Protection[player]=nil T.Cooldown[player]=nil T.LastPosition[player]=nil
end
return T
