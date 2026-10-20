if not game:GetService("RunService"):IsStudio() then return end
print("[MM_EIGHT_CLIENT] startup")
-- Test arguments are not propagated to every client DataModel. The guarded server
-- harness explicitly signals this disposable test session after installing its listener.
local report=game.ReplicatedStorage:WaitForChild("MM_QAReport",20) if not report then return end
local activationDeadline=os.clock()+30
while not report:GetAttribute("Active") and os.clock()<activationDeadline do task.wait(.1) end
if not report:GetAttribute("Active") then return end
report:FireServer({Stage="active"})
local player=game.Players.LocalPlayer
local remote=game.ReplicatedStorage:WaitForChild("MM").Remotes.Action
local function run()
 report:FireServer({Stage="waiting_ui"})
 player.PlayerGui:WaitForChild("MutantMayhemUI",30)
 report:FireServer({Stage="waiting_character"})
 local character=player.Character or player.CharacterAdded:Wait() character:WaitForChild("HumanoidRootPart",20)
 task.wait(3)
 report:FireServer({Stage="invoking_actions"})
 local before=os.clock() local packet=remote:InvokeServer("State") local elapsed=(os.clock()-before)*1000
 assert(packet.State and packet.State.Creatures[1],"Starter missing")
 assert(remote:InvokeServer("Go","Lab").Ok)
 assert(remote:InvokeServer("Place",packet.State.Creatures[1].Id).Ok)
 task.wait(.5)
 assert(remote:InvokeServer("Daily").Ok)
 task.wait(.5)
 assert(remote:InvokeServer("Setting","ReducedMotion").Ok)
 return {Success=true,StateRoundTripMs=elapsed}
end
local ok,result=xpcall(run,debug.traceback)
report:FireServer(ok and result or {Success=false,Error=result})
