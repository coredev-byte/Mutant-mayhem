local C=require(script.Parent.Components)
local T=require(script.Parent.Theme)
local Tween=game:GetService("TweenService")
local Skin={Cyan=Color3.fromRGB(0,214,255),Purple=Color3.fromRGB(149,66,255),Blue=Color3.fromRGB(35,91,255),Green=Color3.fromRGB(0,240,78)}
function Skin.Label(parent,name,text,size,color)
 local l=C.Label(parent,text,size,color or Color3.fromRGB(247,250,255)) l.Name=name l.Font=Enum.Font.GothamBold l.TextWrapped=false
 return l
end
local function outline(parent,name,width,alpha,color,inset,radius)
 local f=C.New("Frame",parent,{Name=name,BackgroundTransparency=1,Position=UDim2.fromOffset(inset,inset),Size=UDim2.new(1,-inset*2,1,-inset*2),ZIndex=parent.ZIndex})
 C.Corner(f,radius) local stroke=C.Stroke(f,color,width) stroke.Transparency=alpha
 return stroke
end
function Skin.Panel(parent,name,color,radius,glow)
 local f=C.Frame(parent,name,Color3.new(1,1,1)) C.Corner(f,radius or 20)
 C.New("UIGradient",f,{Rotation=90,Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(19,28,84)),ColorSequenceKeypoint.new(.48,Color3.fromRGB(4,9,31)),ColorSequenceKeypoint.new(1,Color3.fromRGB(4,25,72))})})
 if glow then
  outline(f,"BloomOuter",15,.94,color,-3,radius or 20)
  outline(f,"BloomMiddle",8,.82,color,-2,radius or 20)
  outline(f,"BloomNear",4,.48,color,-1,radius or 20)
 end
 outline(f,"NeonEdge",2.5,.04,color,0,radius or 20)
 outline(f,"WhiteHighlight",1,.28,Color3.fromRGB(215,247,255),2,radius or 20)
 outline(f,"InnerBorder",1,.55,color,6,(radius or 20)-3)
 return f
end
function Skin.Button(parent,name,callback,color,radius,glow)
 local wrapper=Skin.Panel(parent,name,color or Skin.Cyan,radius or 19,glow)
 local b=C.New("TextButton",wrapper,{Name="HitTarget",Text="",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,AutoButtonColor=false,Selectable=true,ZIndex=4})
 local scale=C.New("UIScale",wrapper,{Scale=1}) local tween
 local function animate(n)
  if tween then tween:Cancel() end
  if T.ReducedMotion then scale.Scale=1 else tween=Tween:Create(scale,TweenInfo.new(.12),{Scale=n}) tween:Play() end
 end
 b.MouseEnter:Connect(function() animate(1.025) end) b.MouseLeave:Connect(function() animate(1) end)
 b.SelectionGained:Connect(function() animate(1.025) end) b.SelectionLost:Connect(function() animate(1) end)
 b.MouseButton1Down:Connect(function() animate(.975) end) b.MouseButton1Up:Connect(function() animate(1) end)
 b.Activated:Connect(function() if not b:GetAttribute("Disabled") and callback then callback() end end)
 return wrapper,b
end
function Skin.Badge(parent)
 local f=C.Frame(parent,"Attention",Color3.fromRGB(255,45,63)) f.AnchorPoint=Vector2.new(.5,.5) f.Position=UDim2.new(1,-3,0,5) f.Size=UDim2.fromOffset(28,32) f.ZIndex=8 C.Corner(f,20)
 local s=C.Stroke(f,Color3.fromRGB(255,227,236),2) s.Transparency=0
 local l=Skin.Label(f,"Mark","!",23) l.Size=UDim2.fromScale(1,1) l.TextXAlignment=Enum.TextXAlignment.Center l.ZIndex=9 f.Visible=false return f
end
function Skin.Icon(parent,key,size)
 local icon=C.Icon(parent,key,size) icon.Name="Icon" icon.ZIndex=3 return icon
end
return Skin
