-- Small decorative details only. Structural readability and gameplay remain visible.
local Collection=game:GetService("CollectionService")
local Players=game:GetService("Players")
local player=Players.LocalPlayer
local tracked={}
local function add(p)
 if p:IsA("BasePart") then tracked[p]=true end
end
for _,p in Collection:GetTagged("MMRemasterDetail") do add(p) end
Collection:GetInstanceAddedSignal("MMRemasterDetail"):Connect(add)
Collection:GetInstanceRemovedSignal("MMRemasterDetail"):Connect(function(p)
 tracked[p]=nil
 if p:IsA("BasePart") then p.LocalTransparencyModifier=0 end
end)
while script.Parent do
 task.wait(.35)
 local camera=workspace.CurrentCamera
 if camera then
  local distance=player:GetAttribute("MMLowGraphics") and 65 or 135
  local limit=distance*distance
  for p in tracked do
   if p.Parent then
    local delta=p.Position-camera.CFrame.Position
    local hidden=delta:Dot(delta)>limit
    p.LocalTransparencyModifier=hidden and 1 or 0
   end
  end
 end
end
