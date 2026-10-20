-- Temporary test harness. Install with EightClients.client.luau; remove both after QA.
local TS=game:GetService("StudioTestService")
if not game:GetService("RunService"):IsStudio() or TS:GetTestArgs()~="MM_EIGHT" then return end
local Players=game:GetService("Players")
local services=game.ServerScriptService.MM.Services
local D=require(services.PlayerDataService) local P=require(services.PlotService)
local C=require(services.CreatureService) local T=require(services.TheftService)
local results={}
local remote=game.ReplicatedStorage:WaitForChild("MM_QAReport")
remote.OnServerEvent:Connect(function(player,result) if result.Stage then player:SetAttribute("MMQAStage",result.Stage) else results[player]=result end end)
remote:SetAttribute("Active",true)
local function run()
 local deadline=os.clock()+120
 repeat task.wait(.25) local count=0 for _ in results do count+=1 end if count==8 then break end until os.clock()>deadline
 local players=Players:GetPlayers() assert(#players==8,"Eight clients did not connect")
 local plots,ids={},{} local remoteMs={}
 for _,player in players do
  local r=results[player] assert(r and r.Success,r and r.Error or ("Client "..player.UserId.." did not report; stage="..tostring(player:GetAttribute("MMQAStage"))))
  local d=D.Get(player) assert(d and d.Creatures[1].Placed and d.Daily>0 and d.Settings.ReducedMotion,"Remote changes missing")
  assert(not plots[P.Assigned[player]],"Duplicate lab") plots[P.Assigned[player]]=true
  while #d.Creatures<8 do local pet=C.Add(player,(#d.Creatures%12)+1) pet.Placed=true end
  d.Tier=6 C.Render(player)
  for _,pet in d.Creatures do assert(not ids[pet.Id],"Duplicate specimen") ids[pet.Id]=true end
  table.insert(remoteMs,r.StateRoundTripMs)
 end
 -- Test a real PlayerRemoving event while a defender is being sampled.
 local thief,victim=players[1],players[2]
 D.Get(thief).Settings.Peaceful=false D.Get(victim).Settings.Peaceful=false T.Protection[victim]=0
 thief.Character:PivotTo(P.Assigned[victim].Base.CFrame*CFrame.new(0,4,0)) task.wait(.15)
 local started,message=T.Start(thief) assert(started,message)
 local victimPlot=P.Assigned[victim] victim:Kick("QA disconnect cleanup check")
 deadline=os.clock()+10 repeat task.wait(.1) until (not D.Sessions[victim] and not T.Carry[thief]) or os.clock()>deadline
 assert(not D.Sessions[victim] and not P.Assigned[victim] and not T.Carry[thief],"Disconnect leaked profile, plot, or carry")
 assert(victimPlot:GetAttribute("OwnerId")==0 and not victimPlot:FindFirstChild("Creatures"),"Plot not released")
 local maxMs=0 local sum=0 for _,ms in remoteMs do sum+=ms maxMs=math.max(maxMs,ms) end
 return {Clients=8,UniqueLabs=8,UniqueCreatures=64,AllClientsRemotePlaceDailySetting=true,AllClientUIsReady=true,ActualDisconnectCleanup=true,StateRoundTripMeanMs=sum/8,StateRoundTripMaxMs=maxMs,RemainingClients=#Players:GetPlayers(),Demo=D.Demo}
end
local ok,result=xpcall(run,debug.traceback)
print("[MM_EIGHT] "..game.HttpService:JSONEncode({Success=ok,Result=result}))
TS:EndTest({Success=ok,Result=result})
