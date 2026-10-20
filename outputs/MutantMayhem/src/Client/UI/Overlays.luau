local C=require(game.ReplicatedStorage.MM.Shared.UI.Components)
local T=require(game.ReplicatedStorage.MM.Shared.UI.Theme)
local Tween=game:GetService("TweenService")
local Gui=game:GetService("GuiService")
local O={}
function O.Build(app)
 local toast=C.Frame(app.Root,"Notifications",T.Panel) toast.ZIndex=40 toast.AnchorPoint=Vector2.new(.5,1) toast.Position=UDim2.new(.5,0,1,-12) toast.Size=UDim2.new(.85,0,0,64) toast.Visible=false C.Stroke(toast,T.Cyan,2)
 C.New("UISizeConstraint",toast,{MaxSize=Vector2.new(580,90)})
 local message=C.Label(toast,"",14) message.ZIndex=41 message.Position=UDim2.fromOffset(12,5) message.Size=UDim2.new(1,-24,1,-10) message.TextXAlignment=Enum.TextXAlignment.Center
 local serial,last,lastAt=0,"",0
 function app:Toast(text)
  if text==last and os.clock()-lastAt<2 then return end
  serial+=1 local id=serial last=text lastAt=os.clock() message.Text=text toast.Visible=true
  if not T.ReducedMotion then toast.Position=UDim2.new(.5,0,1,70) Tween:Create(toast,TweenInfo.new(.16),{Position=UDim2.new(.5,0,1,-12)}):Play() end
  task.delay(4,function() if serial==id then toast.Visible=false end end)
 end
 local overlay=C.New("Frame",app.Root,{Name="Popups",Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(),BackgroundTransparency=.35,Visible=false,ZIndex=50,Active=true})
 local box=C.Frame(overlay,"Confirmation") box.AnchorPoint=Vector2.new(.5,.5) box.Position=UDim2.fromScale(.5,.5) box.Size=UDim2.new(.9,0,0,236) box.ZIndex=51 C.New("UISizeConstraint",box,{MaxSize=Vector2.new(440,236)}) C.Stroke(box,T.Purple,2)
 local title=C.Title(box,"Confirmar",22) title.Position=UDim2.fromOffset(18,12) title.ZIndex=52
 local body=C.Label(box,"",15,T.Muted) body.Position=UDim2.fromOffset(18,52) body.Size=UDim2.new(1,-36,0,100) body.ZIndex=52
 local pending,previous
 function app:DismissPopup() overlay.Visible=false pending=nil app.Popup=false if previous and previous.Parent then Gui.SelectedObject=previous end end
 local cancel=C.Button(box,"Cancelar",function() app:DismissPopup() end) cancel.Position=UDim2.new(0,18,1,-64) cancel.Size=UDim2.new(.5,-24,0,46) cancel.ZIndex=52
 local yes=C.Button(box,"Confirmar",function() local fn=pending app:DismissPopup() if fn then task.spawn(fn) end end,T.Green) yes.Position=UDim2.new(.5,6,1,-64) yes.Size=UDim2.new(.5,-24,0,46) yes.ZIndex=52
 cancel.NextSelectionRight=yes yes.NextSelectionLeft=cancel cancel.NextSelectionLeft=yes yes.NextSelectionRight=cancel
 function app:Confirm(text,fn) body.Text=text pending=fn previous=Gui.SelectedObject overlay.Visible=true app.Popup=true Gui.SelectedObject=cancel end
 return O
end
return O
