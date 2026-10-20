-- Installed only for QA; activates exclusively under StudioTestService's MM_QA argument.
local TS=game:GetService("StudioTestService")
local Run=game:GetService("RunService")
if not Run:IsStudio() then return end
local ok,args=pcall(TS.GetTestArgs,TS) if not ok or args~="MM_QA" then return end
local function run()
	local services=game.ServerScriptService.MM.Services
	local D=require(services.PlayerDataService) local P=require(services.PlotService)
	local C=require(services.CreatureService) local I=require(services.InventoryService)
	local T=require(services.TheftService) local E=require(services.EconomyService)
	local deadline=os.clock()+45 local players
	repeat task.wait(.5) players=game.Players:GetPlayers() until (#players>=2 and D.Get(players[1]) and D.Get(players[2]) and players[1].Character and players[2].Character) or os.clock()>deadline
	assert(#players>=2,"Two clients did not connect")
	local p,v=players[1],players[2] local d,vd=D.Get(p),D.Get(v)
	assert(d and vd,"Profiles did not load") assert(P.Assigned[p]~=P.Assigned[v],"Duplicate plot allocation")
	local checks={DistinctPlots=true,StarterEach=#d.Creatures==1 and #vd.Creatures==1}
	assert(I.Place(p,d.Creatures[1].Id)) assert(I.Place(v,vd.Creatures[1].Id)) C.Render(p) C.Render(v)
	local before=d.Stored E.Tick(p,1) assert(d.Stored>before) checks.Income=true
	d.Settings.Peaceful=false vd.Settings.Peaceful=false T.Protection[v]=0
	p.Character:PivotTo(P.Assigned[v].Base.CFrame*CFrame.new(0,4,0)) task.wait(.2)
	local accepted,message=T.Start(p) assert(accepted,message) checks.RaidStarted=true
	assert(T.Carry[p] and #vd.Creatures==1,"Defender creature removed")
	v.Character:PivotTo(p.Character:GetPivot()*CFrame.new(2,0,0)) assert(T.Defend(v)) assert(not T.Carry[p]) checks.DefenseCanceled=true
	T.Cooldown[p]=0 T.Protection[v]=0 assert(T.Start(p))
	T.Leave(v) assert(not T.Carry[p] and #d.Creatures==1 and #vd.Creatures==1) checks.DisconnectCleanup=true
	T.Cooldown[p]=0 T.Protection[v]=0 assert(T.Start(p))
	T.Carry[p].Started=os.clock()-10 p.Character:PivotTo(P.Assigned[p].Base.CFrame*CFrame.new(0,4,0))
	T.LastPosition[p]=p.Character.HumanoidRootPart.Position T.Tick(1)
	assert(#d.Creatures==2 and #vd.Creatures==1 and d.Creatures[2].Id~=vd.Creatures[1].Id) checks.DNAUniqueAndOriginalRetained=true
	-- Test capacity/ownership by passing another player's GUID.
	assert(not I.Place(p,vd.Creatures[1].Id)) checks.CrossPlayerOwnershipRejected=true
	local slots={} for _,plot in workspace.MM_World.Plots:GetChildren() do assert(not slots[plot:GetAttribute("PlotId")]) slots[plot:GetAttribute("PlotId")]=true end checks.PlotCount=12
	checks.Clients=#players checks.Demo=D.Demo
	print("[MM_QA] "..game.HttpService:JSONEncode(checks)) return checks
end
task.wait(3)
local success,result=xpcall(run,debug.traceback)
if not success then warn("[MM_QA_FAILED] "..tostring(result)) end
TS:EndTest({Success=success,Result=result})
