local Players=game:GetService("Players")
local Rep=game:GetService("ReplicatedStorage")
if not workspace:FindFirstChild("MM_World") then require(script.Parent.MapBuilder).Build() end
local Services=script.Parent.Services
local D=require(Services.PlayerDataService)
local P=require(Services.PlotService)
local C=require(Services.CreatureService)
local I=require(Services.InventoryService)
local E=require(Services.EconomyService)
local M=require(Services.MutationService)
local T=require(Services.TheftService)
local Q=require(Services.QuestService)
local Event=require(Services.EventService)
local Anti=require(Services.AntiExploitService)
local A=require(Services.AnalyticsService)
local Shop=require(Services.MonetizationService)
local Receipt=require(Services.ReceiptService)
local Config=require(Rep.MM.Shared.GameConfig)
local Econ=require(Rep.MM.Shared.EconomyConfig)
local remotes=Rep.MM.Remotes
local closing=false
local durable={Place=true,Collect=true,Upgrade=true,Prestige=true,Research=true,Mutate=true,Discover=true,Daily=true,Missions=true,Setting=true,Style=true}
local function notify(player,message) if player.Parent then remotes.Update:FireClient(player,{Message=message}) end end
T.Notify=notify
local function state(player)
	local d=D.Get(player) if not d then return {Loading=true} end
	local plot=P.Assigned[player]
	return {Coins=math.floor(d.Coins),Stored=math.floor(d.Stored),Tier=d.Tier,Prestige=d.Prestige,Research=d.Research,ResearchCost=Econ.ResearchCost(d.Research),
		Capacity=I.Capacity(d),Rate=E.Rate(d),Creatures=d.Creatures,Discovered=d.Discovered,Rolls=d.Rolls,Misses=d.Misses,
		Tutorial=d.Tutorial,Settings=d.Settings,Quests=Q.List(D.Copy(d)),Daily=d.Daily,Weekly=d.Weekly,Cosmetics=d.Cosmetics,
		Plot=plot and plot:GetAttribute("PlotId"),Demo=D.Demo,SaveHealthy=D.Editable(player),
		Shield=math.max(0,math.ceil((T.Protection[player] or 0)-os.clock())),Carrying=T.Carry[player]~=nil,
		Event=Event.State(),UpgradeCost=Econ.UpgradeCost(d.Tier),Style=d.Style or "Classic"}
end
local function render(player)
	C.Render(player) local plot=P.Assigned[player] local d=D.Get(player)
	if plot and d then
		plot.Canopy.Color=d.Cosmetics.ResearchTrim and Color3.fromRGB(245,199,106) or (d.Style=="Aurora" and Color3.fromRGB(178,165,217) or Color3.fromRGB(241,143,122))
		plot.Sign.BillboardGui.TextLabel.Text=player.DisplayName.."'S LAB"..(d.Research>0 and " • R"..d.Research or "")
		local badge=plot:FindFirstChild("WeeklyBadge")
		if d.Cosmetics.WeeklyGlow and not badge then
			badge=Instance.new("Part") badge.Name="WeeklyBadge" badge.Shape=Enum.PartType.Ball badge.Size=Vector3.new(1.5,1.5,1.5)
			badge.Color=Color3.fromRGB(252,215,134) badge.Material=Enum.Material.Neon badge.Anchored=true badge.CanCollide=false badge.CanTouch=false badge.CanQuery=false
			badge.Position=plot.Sign.Position+Vector3.new(0,3,0) badge.Parent=plot
			local label=Instance.new("BillboardGui") label.Size=UDim2.fromOffset(150,35) label.StudsOffset=Vector3.new(0,1.6,0) label.MaxDistance=65 label.Parent=badge
			local text=Instance.new("TextLabel") text.Size=UDim2.fromScale(1,1) text.BackgroundTransparency=1 text.Text="WEEKLY EXPLORER" text.TextColor3=Color3.fromRGB(255,240,192) text.TextStrokeTransparency=.3 text.Font=Enum.Font.GothamBold text.TextSize=12 text.Parent=label
		end
	end
end
local function nearLab(player) local p=P.Position(player) return p and Anti.Near(player,p,30) end
local function handle(player,action,arg)
	if not Anti.Allow(player,action) then return {Ok=false,Message="Slow down a moment."} end
	if action=="State" then return {Ok=true,State=state(player)} end
	if not D.Editable(player) then return {Ok=false,Message="Your data is loading or saving. Please try again shortly."} end
	if durable[action] and not D.Demo then
		local session=D.Sessions[player] local now=os.clock()
		if now-(session.LastAction or -100)<2 then return {Ok=false,Message="Please wait a moment for your previous action to settle."} end
		session.LastAction=now -- Bound durable action writes to 30/minute per player, plus autosaves.
	end
	local ok,message=false,"Unknown action."
	if action=="Go" then
		if T.Carry[player] then return {Ok=false,Message="Carry the DNA home on foot."} end
		if arg=="Lab" then P.Spawn(player) ok=true
		else local positions={Reactor=Vector3.new(0,8,20),Meadow=Vector3.new(165,9,0),Events=Vector3.new(0,9,-165),Showcase=Vector3.new(-165,9,0),Shop=Vector3.new(0,9,165)}
			if type(arg)=="string" and positions[arg] and player.Character then player.Character:PivotTo(CFrame.new(positions[arg])) ok=true end end
		message=ok and "Arrived!" or "Unknown destination."
	elseif action=="Place" then if not Anti.String(arg) then return {Ok=false,Message="Invalid creature."} end if nearLab(player) then ok,message=I.Place(player,arg) if ok then render(player) end else message="Visit your lab to place or store a creature." end
	elseif action=="Collect" then if nearLab(player) then ok,message=E.Collect(player) if ok then C.Mood(player,"Happy",3) end else message="Visit your lab to collect." end
	elseif action=="Upgrade" then if nearLab(player) then ok,message=E.Upgrade(player) if ok then render(player) end else message="Visit your lab to expand it." end
	elseif action=="Prestige" then if nearLab(player) then ok,message=E.Prestige(player) else message="Visit your lab for mastery." end
	elseif action=="Research" then if nearLab(player) then ok,message=E.Research(player) if ok then render(player) end else message="Visit your lab for research." end
	elseif action=="Mutate" then if not Anti.String(arg) then return {Ok=false,Message="Invalid creature."} end if Anti.Near(player,Vector3.new(0,6,0),30) then ok,message=M.Mutate(player,arg) if ok then render(player) C.Mood(player,"Mutation",4) end else message="Visit the central reactor first." end
	elseif action=="Discover" then if Anti.Near(player,Vector3.new(165,5,0),35) then ok,message=C.Discover(player) else message="Visit Discovery Meadow first." end
	elseif action=="Shield" then
		if nearLab(player) then if T.Carry[player] then message="Finish your DNA run first." else T.Protect(player,90) local d=D.Get(player) if d.Tutorial==4 then d.Tutorial=5 A.Log("tutorial_complete",player.UserId) end C.Mood(player,"Reaction",2) ok=true message="Free lab shield: 90 seconds. Your friends are protected." end else message="Visit your lab to protect it." end
	elseif action=="Raid" then ok,message=T.Start(player)
	elseif action=="Defend" then ok,message=T.Defend(player)
	elseif action=="Daily" then ok,message=Q.Daily(player) if ok then render(player) end
	elseif action=="Missions" then ok,message=Q.Claim(player)
	elseif action=="Setting" then
		if type(arg)=="string" and D.Get(player).Settings[arg]~=nil then local settings=D.Get(player).Settings settings[arg]=not settings[arg]
			if arg=="Peaceful" then T.Cancel(player) if T.Victims[player] then T.Cancel(T.Victims[player]) end T.Protect(player,90) end
			ok=true message=arg..": "..tostring(settings[arg]) end
	elseif action=="Style" then if Anti.Near(player,Vector3.new(0,5,165),35) then ok,message=Shop.Style(player) if ok then render(player) end else message="Visit the Style Lab first." end
	elseif action=="ShopView" then A.Log("shop_view",player.UserId) ok=true message="All current styles use earned coins."
	elseif action=="BuyProduct" or action=="BuyPass" then
		if Anti.Near(player,Vector3.new(0,5,165),35) then ok,message=Shop.Prompt(player,action=="BuyProduct" and "Product" or "Pass",arg) else message="Visit the Style Lab first." end
	end
	if ok and durable[action] and not D.Save(player,false) then
		ok=false message="Save not confirmed yet. Your action is queued; please wait for recovery before trying again."
	end
	return {Ok=ok,Message=message,State=state(player)}
end
remotes.Action.OnServerInvoke=function(player,action,arg)
	local success,result=xpcall(function() return handle(player,action,arg) end,debug.traceback)
	if not success then A.Log("action_error",player.UserId,{error=result}) return {Ok=false,Message="That action could not finish. Please try again."} end return result
end
local function join(player)
	if closing then player:Kick("Server is closing. Please rejoin.") return end
	if not P.Assign(player) then player:Kick("All 12 labs are occupied. Please join another server.") return end
	local data,err=D.Load(player)
	if not data then P.Release(player) player:Kick(err) return end
	if not player.Parent or closing then P.Release(player) D.Close(player,20) return end
	Q.Prepare(data) C.Starter(player) T.Protect(player,Config.SpawnProtection) render(player)
	local function spawn(character)
		character:WaitForChild("HumanoidRootPart",10) if not player.Parent then return end P.Spawn(player)
		T.Cancel(player) T.Protect(player,Config.SpawnProtection)
		local h=character:FindFirstChildOfClass("Humanoid") if h then h.Died:Connect(function() T.Cancel(player,"DNA run canceled on respawn.") end) end
	end
	player.CharacterAdded:Connect(spawn) if player.Character then task.spawn(spawn,player.Character) end
	task.spawn(Shop.Refresh,player) notify(player,D.Demo and "STUDIO DEMO: progress resets when Play stops." or "Welcome to your laboratory!")
end
Players.PlayerAdded:Connect(join)
Players.PlayerRemoving:Connect(function(player)
	T.Leave(player) local s=D.Sessions[player]
	if s then s.Closing=true A.Log("session_end",player.UserId,{seconds=math.floor(os.clock()-s.Joined)}) end
	P.Release(player) Anti.Clear(player) D.Close(player,20)
end)
Receipt.Init() Shop.Init()
for _,player in Players:GetPlayers() do task.spawn(join,player) end
task.spawn(function()
	local last=os.clock() local tick=0
	while not closing do task.wait(1) local now=os.clock() local dt=now-last last=now tick+=1
		for player,session in D.Sessions do
			if session.Lost and player.Parent then player:Kick("Your profile moved to another server. Please reconnect.")
			elseif not session.Detached then E.Tick(player,dt) if tick%2==0 and player.Parent then remotes.Update:FireClient(player,{State=state(player)}) end end
		end
		T.Tick(dt)
		local e=Event.State() local zone=workspace.MM_World:FindFirstChild("Events") if zone then local label=zone:FindFirstChild("EventText",true) if label then label.Text=e.Active and "FESTIVAL LIVE  •  +25% income" or string.format("NEXT FESTIVAL  %02d:%02d",math.floor(e.Remaining/60),e.Remaining%60) end end
	end
end)
task.spawn(function() while not closing do task.wait(Config.AutosaveSeconds) for player in D.Sessions do task.spawn(D.Autosave,player) end end end)
game:BindToClose(function()
	closing=true local pending=0 for player in D.Sessions do pending+=1 task.spawn(function() D.Close(player,23) pending-=1 end) end
	local deadline=os.clock()+25 while pending>0 and os.clock()<deadline do task.wait(.1) end
end)
A.Log("server_ready",0,{plots=12,demo=D.Demo,ownershipTheft=false})
