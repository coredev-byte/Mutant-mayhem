local Gui=game:GetService("GuiService")
local Input=game:GetService("UserInputService")
local CAS=game:GetService("ContextActionService")
local N={}
function N.Start(app)
 local pages={"Pets","Mutation","Shop","Lab","Missions","Map","Social","Settings"}
 function app:Focus()
  if Input.PreferredInput~=Enum.PreferredInput.Gamepad then return end
  local target=app.Window.Visible and app.CloseButton or app.FirstNav
  Gui.SelectedObject=target
 end
 local function handle(name,state)
  if Gui.MenuIsOpen or Input:GetFocusedTextBox() then return Enum.ContextActionResult.Pass end
  if name=="MMBack" and not app.Page and not app.Popup then return Enum.ContextActionResult.Pass end
  if state~=Enum.UserInputState.Begin then return Enum.ContextActionResult.Sink end
  if name=="MMBack" then if app.Popup then app:DismissPopup() elseif app.Page=="Details" then app:Open("Pets") else app:Close() end
  elseif app.Popup then return Enum.ContextActionResult.Sink
  elseif name=="MMOpen" then app:Open("Lab")
  else local i=table.find(pages,app.Page) or 1 app:Open(pages[(i-1+(name=="MMNext" and 1 or -1))%#pages+1]) end
  return Enum.ContextActionResult.Sink
 end
 CAS:BindActionAtPriority("MMOpen",handle,false,3000,Enum.KeyCode.ButtonY)
 CAS:BindActionAtPriority("MMBack",handle,false,3000,Enum.KeyCode.ButtonB,Enum.KeyCode.Escape)
 CAS:BindActionAtPriority("MMNext",handle,false,3000,Enum.KeyCode.ButtonR1)
 CAS:BindActionAtPriority("MMPrevious",handle,false,3000,Enum.KeyCode.ButtonL1)
 Input.InputBegan:Connect(function(i,used) if not used and i.KeyCode==Enum.KeyCode.M then app:Open("Lab") end end)
 Input:GetPropertyChangedSignal("PreferredInput"):Connect(function() app:Focus() end)
 Gui:GetPropertyChangedSignal("SelectedObject"):Connect(function()
  local o=Gui.SelectedObject if not o or not o:IsDescendantOf(app.Root) then return end
  if app.Popup and not o:IsDescendantOf(app.Root.Popups) then Gui.SelectedObject=app.Root.Popups.Confirmation:FindFirstChild("Cancelar") return end
  local scroll=o:FindFirstAncestorWhichIsA("ScrollingFrame") if not scroll then return end
  local start=o.AbsolutePosition.Y-scroll.AbsolutePosition.Y local finish=start+o.AbsoluteSize.Y local delta=0
  if start<0 then delta=start elseif finish>scroll.AbsoluteSize.Y then delta=finish-scroll.AbsoluteSize.Y end
  scroll.CanvasPosition=Vector2.new(0,math.max(0,scroll.CanvasPosition.Y+delta))
 end)
end
return N
