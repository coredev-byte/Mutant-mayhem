local C=require(game.ReplicatedStorage.MM.Shared.UI.Components)
local T=require(game.ReplicatedStorage.MM.Shared.UI.Theme)
local U={}
function U.Start(app)
 local box=C.Frame(app.Root,"Tooltip",T.Bg) box.Visible=false box.ZIndex=70 box.Size=UDim2.fromOffset(230,62) C.Stroke(box,T.Cyan)
 local text=C.Label(box,"",12) text.Position=UDim2.fromOffset(10,6) text.Size=UDim2.new(1,-20,1,-12) text.ZIndex=71
 local current
 local function bind(o)
  if not o:IsA("GuiButton") then return end
  local function show()
   local message=o:GetAttribute("Tooltip") if not message then return end
   current=o text.Text=message local p=o.AbsolutePosition local view=workspace.CurrentCamera.ViewportSize local inset=game:GetService("GuiService"):GetGuiInset()
   box.Position=UDim2.fromOffset(math.clamp(p.X,8,math.max(8,view.X-238)),math.clamp(p.Y+o.AbsoluteSize.Y-inset.Y+6,8,math.max(8,view.Y-inset.Y-70))) box.Visible=true
  end
  local function hide() if current==o then current=nil box.Visible=false end end
  o.MouseEnter:Connect(show) o.MouseLeave:Connect(hide) o.SelectionGained:Connect(show) o.SelectionLost:Connect(hide) o.Destroying:Connect(hide)
 end
 for _,o in app.Root:GetDescendants() do bind(o) end app.Root.DescendantAdded:Connect(bind)
end
return U
