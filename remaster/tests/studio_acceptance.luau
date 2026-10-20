-- Run only in a disposable Studio EDIT-mode copy after Rojo sync.
-- This test has not run in cloud CI: Roblox engine required.
local world=workspace.MM_World
local remaster=require(game.ServerScriptService.MM.Services.WorldRemaster)
local before={}
for _,plot in world.Plots:GetChildren() do
 local pads={} for i=1,12 do pads[i]=plot["Pad"..i] end
 before[plot]={Base=plot.Base,CF=plot.Base.CFrame,Owner=plot:GetAttribute("OwnerId"),Pads=pads}
end
assert(remaster.Apply(world))
for plot,state in before do
 for tier=0,6 do
  remaster.SetTier(plot,tier)
  assert(plot.Base==state.Base and plot.Base.CFrame==state.CF)
  assert(plot:GetAttribute("OwnerId")==state.Owner)
  for i,pad in state.Pads do assert(plot["Pad"..i]==pad) end
  for _,p in plot.VisualRemaster:GetChildren() do assert(not p.CanCollide and not p.CanTouch and not p.CanQuery) end
 end
end
assert(remaster.Apply(world))
assert(#world:GetChildren()>0)
remaster.Rollback(world)
assert(not world:FindFirstChild("MM_Remaster"))
for plot,state in before do
 assert(not plot:FindFirstChild("VisualRemaster"))
 assert(plot.Base==state.Base and plot.Base.CFrame==state.CF)
end
assert(remaster.Apply(world))
print("Remaster contracts and rollback passed; now playtest movement, pets, raids and teleports.")
