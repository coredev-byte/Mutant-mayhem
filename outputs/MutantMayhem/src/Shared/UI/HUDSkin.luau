local C=require(script.Parent.Components)
local T=require(script.Parent.Theme)
local Tween=game:GetService("TweenService")
local Skin={Cyan=Color3.fromRGB(100,211,229),Purple=Color3.fromRGB(169,151,226),Blue=Color3.fromRGB(115,156,205),Green=Color3.fromRGB(79,198,154)}
function Skin.Label(parent,name,text,size,color)
 local l=C.Label(parent,text,size,color or T.Text)
 l.Name=name l.Font=Enum.Font.GothamMedium l.TextWrapped=false
 l.TextTruncate=Enum.TextTruncate.AtEnd
 return l
end
function Skin.Panel(parent,name,color,radius)
 local f=C.Frame(parent,name,Color3.fromRGB(15,26,43))
 f.BackgroundTransparency=.08 C.Corner(f,radius or 16)
 local border=C.Stroke(f,color or Color3.fromRGB(94,119,147),1)
 border.Name="Edge" border.Transparency=.76
 return f
end
function Skin.Button(parent,name,callback,color,radius)
 local wrapper=Skin.Panel(parent,name,color,radius)
 local b=C.New("TextButton",wrapper,{Name="HitTarget",Text="",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,AutoButtonColor=false,Selectable=true,ZIndex=4})
 local border=wrapper.Edge local tween
 local function focus(on)
  if tween then tween:Cancel() end
  if T.ReducedMotion then border.Transparency=on and .05 or .76
  else tween=Tween:Create(border,TweenInfo.new(.12),{Transparency=on and .05 or .76}) tween:Play() end
 end
 b.MouseEnter:Connect(function() focus(true) end) b.MouseLeave:Connect(function() focus(false) end)
 b.SelectionGained:Connect(function() focus(true) end) b.SelectionLost:Connect(function() focus(false) end)
 b.Activated:Connect(function() if not b:GetAttribute("Disabled") and callback then callback() end end)
 return wrapper,b
end
function Skin.Badge(parent)
 local f=C.Frame(parent,"Attention",Skin.Cyan)
 f.AnchorPoint=Vector2.new(.5,.5) f.Position=UDim2.new(1,-9,0,9)
 f.Size=UDim2.fromOffset(6,6) f.ZIndex=8 C.Corner(f,6) f.Visible=false
 return f
end
function Skin.Icon(parent,key,size)
 local icon=C.Icon(parent,key,size) icon.Name="Icon" icon.ZIndex=3 return icon
end
return Skin
