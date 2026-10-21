local Tween=game:GetService("TweenService")
local T=require(script.Parent.Theme)
local Icons=require(script.Parent.Icons)
local Atlas=require(script.Parent.HUDAtlas)
local Factory=require(script.Parent.Parent.CreatureFactory)
local C={}
function C.New(class,parent,props)
 local o=Instance.new(class) for k,v in props or {} do o[k]=v end o.Parent=parent return o
end
function C.Corner(o,r)
 local corner=o:FindFirstChildWhichIsA("UICorner") or C.New("UICorner",o)
 corner.CornerRadius=UDim.new(0,r or 12) return corner
end
function C.Stroke(o,color,width) return C.New("UIStroke",o,{Color=color or T.Cyan,Thickness=width or 1,Transparency=.35,ApplyStrokeMode=Enum.ApplyStrokeMode.Border}) end
function C.Frame(parent,name,color)
 local f=C.New("Frame",parent,{Name=name,BorderSizePixel=0,BackgroundColor3=color or T.Panel}) C.Corner(f) return f
end
function C.Label(parent,text,size,color)
 return C.New("TextLabel",parent,{BackgroundTransparency=1,Text=text or "",TextSize=size or 15,Font=Enum.Font.GothamMedium,TextColor3=color or T.Text,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,Size=UDim2.new(1,0,0,32)})
end
function C.Title(parent,text,size)
 local l=C.Label(parent,text,size or 25) l.Font=Enum.Font.GothamBold return l
end
function C.Icon(parent,key,size,color)
 local cell=Atlas.Cells[key]
 if cell and Atlas.Image~="" then
  local f=C.New("Frame",parent,{BackgroundTransparency=1,ClipsDescendants=true,Size=UDim2.fromOffset(size,size)})
  C.New("ImageLabel",f,{Name="AtlasImage",BackgroundTransparency=1,Image=Atlas.Image,Size=UDim2.fromScale(Atlas.Columns,Atlas.Rows),Position=UDim2.fromScale(-((cell-1)%Atlas.Columns),-math.floor((cell-1)/Atlas.Columns)),ZIndex=3})
  return f
 end
 local def=Icons[key] or Icons.Info
 if def.Image~="" then return C.New("ImageLabel",parent,{BackgroundTransparency=1,Image=def.Image,Size=UDim2.fromOffset(size,size)}) end
 local native={Pets=true,Pet=true,Shop=true,Coins=true,Laboratory=true,Mutation=true,Map=true,Portal=true,Daily=true,Friends=true,Gift=true,Calendar=true,Income=true,Paw=true,Countdown=true,Settings=true,Achievements=true,Gems=true,Mutagen=true}
 if native[key] then
  local f=C.New("Frame",parent,{BackgroundTransparency=1,Size=UDim2.fromOffset(size,size)})
  local function shape(x,y,w,h,c,r)
   local o=C.Frame(f,"Shape",c) o.Position=UDim2.fromScale(x,y) o.Size=UDim2.fromScale(w,h) C.Corner(o,r or size) return o
  end
  local cyan=Color3.fromRGB(38,215,255) local light=Color3.fromRGB(207,248,255)
  if key=="Pets" or key=="Pet" then
   shape(.13,.05,.23,.35,cyan,6).Rotation=-20 shape(.64,.05,.23,.35,cyan,6).Rotation=20
   local face=shape(.06,.22,.88,.72,cyan,10) C.Stroke(face,light,1)
   shape(.24,.44,.13,.2,T.Bg) shape(.63,.44,.13,.2,T.Bg) shape(.26,.45,.04,.05,T.Text) shape(.65,.45,.04,.05,T.Text) shape(.43,.73,.15,.06,T.Bg)
  elseif key=="Coins" then local coin=shape(.04,.04,.92,.92,T.Gold) C.Stroke(coin,Color3.fromRGB(255,239,156),2) shape(.27,.25,.46,.5,Color3.fromRGB(232,155,27),5)
  elseif key=="Shop" or key=="Daily" or key=="Gift" then
   shape(.14,.3,.72,.62,key=="Shop" and T.Pink or T.Gold,6) shape(.32,.05,.36,.36,T.Gold,7) shape(.41,.13,.18,.17,T.Panel,5)
   shape(.43,.31,.14,.61,T.Text,2) shape(.14,.47,.72,.12,T.Text,2)
  elseif key=="Laboratory" then
   shape(.31,.05,.38,.15,light,3) shape(.39,.18,.22,.3,cyan,3) local tube=shape(.18,.4,.64,.56,cyan,8) C.Stroke(tube,light,1) shape(.25,.65,.5,.23,T.Purple,6) shape(.4,.48,.13,.12,T.Text)
  elseif key=="Mutation" then
   for i=0,3 do local x=i%2==0 and .15 or .62 local a=shape(x,.08+i*.22,.24,.19,i%2==0 and T.Pink or T.Cyan) shape(1-x-.24,.08+i*.22,.24,.19,i%2==0 and T.Cyan or T.Pink) local bar=shape(.35,.15+i*.22,.3,.05,T.Text,1) bar.Rotation=i%2==0 and 25 or -25 end
  elseif key=="Friends" then shape(.35,.05,.3,.3,cyan) shape(.23,.38,.54,.58,cyan,8) shape(0,.22,.23,.24,T.Purple) shape(.77,.22,.23,.24,T.Purple) shape(0,.51,.18,.4,T.Purple,6) shape(.82,.51,.18,.4,T.Purple,6)
  elseif key=="Map" then shape(.04,.15,.9,.75,T.Cyan,4) shape(.12,.22,.3,.5,T.Green,3).Rotation=15 shape(.57,.25,.28,.58,T.Green,3).Rotation=-10 shape(.38,.05,.3,.36,T.Red,8) shape(.47,.13,.1,.1,T.Text)
  elseif key=="Calendar" then
   shape(.08,.17,.84,.78,light,5) shape(.08,.17,.84,.22,T.Pink,3) shape(.24,.02,.1,.26,cyan,3) shape(.66,.02,.1,.26,cyan,3)
   for y=0,1 do for x=0,2 do shape(.2+x*.23,.49+y*.23,.14,.14,T.Purple,2) end end
  elseif key=="Income" then
   for i=0,2 do shape(.1+i*.28,.64-i*.2,.2,.31+i*.2,cyan,3) end
   shape(.15,.2,.66,.09,light,2).Rotation=-27
  elseif key=="Paw" then
   shape(.21,.48,.59,.46,T.Pink,9)
   for i=0,3 do shape(.03+i*.24,(i==0 or i==3) and .25 or .07,.21,.28,T.Purple,8) end
  elseif key=="Countdown" then
   local circle=shape(.06,.06,.88,.88,cyan) C.Stroke(circle,light,2) shape(.18,.18,.64,.64,T.Blue)
   shape(.46,.28,.08,.28,T.Text,2) shape(.46,.5,.27,.08,T.Text,2)
  elseif key=="Settings" then
   for i=0,3 do local tooth=shape(.08,.36,.84,.28,light,3) tooth.Rotation=i*45 end
   shape(.21,.21,.58,.58,light) shape(.36,.36,.28,.28,T.Blue)
  elseif key=="Achievements" then
   local gold=shape(.22,.2,.56,.56,T.Gold,3) gold.Rotation=45
   local star=C.Label(f,"★",size*.85,T.Gold) star.Font=Enum.Font.SourceSansBold star.TextXAlignment=Enum.TextXAlignment.Center star.Size=UDim2.fromScale(1,1)
  elseif key=="Gems" then local gem=shape(.2,.2,.6,.6,T.Purple,3) gem.Rotation=45 C.Stroke(gem,T.Pink,2)
  elseif key=="Mutagen" then shape(.17,.21,.67,.67,T.Green) shape(.17,.1,.2,.2,T.Green) shape(.71,.06,.13,.13,T.Green) shape(.3,.31,.14,.14,light)
  else local ring=shape(.08,.08,.84,.84,T.Purple) C.Stroke(ring,light,2) shape(.28,.2,.44,.6,T.Bg) shape(.39,.31,.22,.38,T.Cyan) end
  return f
 end
 local l=C.Label(parent,def.Fallback,size,color or T.Cyan) l.Size=UDim2.fromOffset(size+4,size+4) l.TextXAlignment=Enum.TextXAlignment.Center l.Font=Enum.Font.GothamBold return l
end
function C.Button(parent,text,callback,color)
 local b=C.New("TextButton",parent,{Name=text,Text=text,Font=Enum.Font.GothamBold,TextSize=15,TextColor3=T.Text,BackgroundColor3=color or T.Card,BorderSizePixel=0,Size=UDim2.new(1,0,0,46),AutoButtonColor=false,Selectable=true,TextWrapped=true})
 if #text>35 then b:SetAttribute("Tooltip",text) end
 C.Corner(b,10) local border=C.Stroke(b,Color3.fromRGB(102,135,161),1)

 local activeTween
 local function glow(on)
  if activeTween then activeTween:Cancel() end
  if T.ReducedMotion then border.Transparency=on and .05 or .65 else activeTween=Tween:Create(border,TweenInfo.new(.12),{Transparency=on and .05 or .65,Thickness=on and 2 or 1}) activeTween:Play() end
 end
 b.MouseEnter:Connect(function() glow(true) end) b.MouseLeave:Connect(function() glow(false) end)
 b.SelectionGained:Connect(function() glow(true) end) b.SelectionLost:Connect(function() glow(false) end)
 b.Activated:Connect(function() if b:GetAttribute("Disabled") then return end if callback then callback() end end)
 return b
end
function C.Disabled(b,disabled) b:SetAttribute("Disabled",disabled) b.TextTransparency=disabled and .5 or 0 b.BackgroundTransparency=disabled and .5 or 0 end
function C.Nav(parent,key,label,callback,color)
 local b=C.Button(parent,"",callback,T.Panel) b.Name=key b.Size=UDim2.fromOffset(84,66) C.Stroke(b,color or T.Cyan,1.5)
 local icon=C.Icon(b,key,27,color or T.Cyan) icon.AnchorPoint=Vector2.new(.5,0) icon.Position=UDim2.new(.5,0,0,3)
 local l=C.Label(b,label,11) l.TextXAlignment=Enum.TextXAlignment.Center l.Position=UDim2.new(0,3,1,-26) l.Size=UDim2.new(1,-6,0,24)
 return b
end
function C.List(parent,gap)
 return C.New("UIListLayout",parent,{Padding=UDim.new(0,gap or 10),SortOrder=Enum.SortOrder.LayoutOrder})
end
function C.Scroll(parent,name)
 return C.New("ScrollingFrame",parent,{Name=name or "Scroll",BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.fromScale(1,1),CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=4,ScrollBarImageColor3=T.Cyan,ScrollingDirection=Enum.ScrollingDirection.Y})
end
function C.Padding(o,n) C.New("UIPadding",o,{PaddingLeft=UDim.new(0,n),PaddingRight=UDim.new(0,n),PaddingTop=UDim.new(0,n),PaddingBottom=UDim.new(0,n)}) end
function C.Section(parent,title,body,accent,height)
 local f=C.Frame(parent,title) f.Size=UDim2.new(1,-6,0,height or 112) C.Stroke(f,accent or T.Cyan)
 f.AutomaticSize=Enum.AutomaticSize.Y
 local h=C.Title(f,title,18) h.Position=UDim2.fromOffset(14,8) h.Size=UDim2.new(1,-28,0,30)
 local l=C.Label(f,body,14,T.Muted) l.Position=UDim2.fromOffset(14,40) l.Size=UDim2.new(1,-28,0,0) l.AutomaticSize=Enum.AutomaticSize.Y l.TextYAlignment=Enum.TextYAlignment.Top
 C.New("UIPadding",f,{PaddingBottom=UDim.new(0,12)})
 return f
end
function C.Progress(parent,value,label,color)
 local f=C.Frame(parent,"Progress",T.Bg) f.Size=UDim2.new(1,-6,0,34)
 local fill=C.Frame(f,"Fill",color or T.Cyan) fill.Size=UDim2.new(math.clamp(value,0,1),0,1,0)
 local l=C.Label(f,label,12) l.Size=UDim2.fromScale(1,1) l.TextXAlignment=Enum.TextXAlignment.Center l.ZIndex=2 return f
end
function C.Preview(parent,pet)
 local v=C.New("ViewportFrame",parent,{Name="PetPreview",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Ambient=Color3.fromRGB(210,220,255),LightColor=Color3.new(1,1,1),LightDirection=Vector3.new(-1,-1,-3)})
 local world=C.New("WorldModel",v)
 local model=Factory.Build(pet.Archetype,pet.Mutation,Vector3.zero) model.Parent=world
 local bounds,extent=model:GetBoundingBox() local target=bounds.Position
 local camera=C.New("Camera",v,{FieldOfView=36}) v.CurrentCamera=camera
 local function fit()
  if not v.Parent then return end
  local aspect=v.AbsoluteSize.X/math.max(1,v.AbsoluteSize.Y)
  local half=math.rad(18) if aspect>0 and aspect<1 then half=math.atan(math.tan(half)*aspect) end
  local distance=(extent.Magnitude*.5)/math.sin(half)*1.08
  camera:SetAttribute("Target",target) camera:SetAttribute("Distance",distance)
  camera.CFrame=CFrame.lookAt(target+Vector3.new(.36,.12,-1).Unit*distance,target)
 end
 v:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit) task.defer(fit)
 return v,camera
end
function C.PetCard(parent,pet,name,callback,selected)
 local rarity=pet.Mutation and pet.Mutation.Rarity or 1
 local b=C.Button(parent,"",callback,T.Card) b.Name="Pet_"..pet.Id C.Stroke(b,selected and T.Cyan or T.Rarity[rarity],selected and 2 or 1)
 local v=C.Preview(b,pet) v.Size=UDim2.new(1,0,1,-42)
 local title=C.Title(b,name,14) title.Position=UDim2.new(0,4,1,-44) title.Size=UDim2.new(1,-8,0,23) title.TextXAlignment=Enum.TextXAlignment.Center
 local r=C.Label(b,T.RarityNames[rarity],11,T.Rarity[rarity]) r.Position=UDim2.new(0,4,1,-23) r.Size=UDim2.new(1,-8,0,20) r.TextXAlignment=Enum.TextXAlignment.Center
 local flags=C.Label(b,(pet.Favorite and "♥ " or "")..(pet.Locked and "▣ " or "")..(pet.Placed and "✓" or ""),13,T.Gold) flags.Position=UDim2.fromOffset(7,4) flags.ZIndex=3
 return b
end
return C
