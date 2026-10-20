local C=require(game.ReplicatedStorage.MM.Shared.UI.Components)
local T=require(game.ReplicatedStorage.MM.Shared.UI.Theme)
local Catalog=require(game.ReplicatedStorage.MM.Shared.CreatureCatalog)
local H={}
function H.Build(app)
 local root=C.New("Frame",app.Root,{Name="MainHUD",Size=UDim2.fromScale(1,1),BackgroundTransparency=1})
 local top=C.Frame(root,"CurrencyBar") top.AnchorPoint=Vector2.new(.5,0) top.Position=UDim2.new(.5,0,0,10) top.Size=UDim2.new(.62,0,0,56) C.Stroke(top)
 local coin=C.Icon(top,"Coins",28,T.Gold) coin.Position=UDim2.fromOffset(12,9)
 local amount=C.Title(top,"…",20) amount.Position=UDim2.fromOffset(50,4) amount.Size=UDim2.new(.5,-52,0,28)
 local caption=C.Label(top,"MOEDAS",9,T.Muted) caption.Position=UDim2.fromOffset(50,29) caption.Size=UDim2.fromOffset(100,18)
 local plus=C.Button(top,"+",function() app:Open("Shop") end,T.Green) plus.Size=UDim2.fromOffset(40,40) plus.Position=UDim2.new(.5,-4,0,8)
 local rate=C.Label(top,"",13,T.Cyan) rate.Position=UDim2.new(.5,45,0,6) rate.Size=UDim2.new(.5,-52,1,-12)
 local state=C.Label(root,"Conectando ao laboratório…",11,T.Muted) state.AnchorPoint=Vector2.new(.5,0) state.Position=UDim2.new(.5,0,0,69) state.Size=UDim2.new(.74,0,0,25) state.TextXAlignment=Enum.TextXAlignment.Center
 state.BackgroundTransparency=.1 state.BackgroundColor3=T.Bg C.Corner(state,8)
 local left=C.Scroll(root,"LeftNavigation") left.Position=UDim2.fromOffset(10,102) left.Size=UDim2.new(0,90,1,-210) C.List(left,7)
 local entries={{"Shop","LOJA","Shop",T.Gold},{"Pets","PETS","Pets",T.Cyan},{"Mutation","MUTAÇÃO","Mutation",T.Purple},{"Laboratory","LAB","Lab",T.Cyan},{"Achievements","MISSÕES","Missions",T.Gold},{"Map","MAPA","Map",T.Cyan}}
 for _,v in entries do local b=C.Nav(left,v[1],v[2],function() app:Open(v[3]) end,v[4]) if not app.FirstNav then app.FirstNav=b end end
 local right=C.Scroll(root,"RightUtilities") right.AnchorPoint=Vector2.new(1,0) right.Position=UDim2.new(1,-10,0,102) right.Size=UDim2.new(0,90,1,-210) C.List(right,7)
 C.Nav(right,"Daily","PRESENTE",function() app:Open("Missions") end,T.Gold)
 local event=C.Nav(right,"Meteor","EVENTO",function() app:Open("Event") end,T.Pink)
 C.Nav(right,"Portal","VIAJAR",function() app:Open("Map") end,T.Cyan)
 C.Nav(right,"Friends","SOCIAL",function() app:Open("Social") end,T.Purple)
 C.Nav(right,"Settings","OPÇÕES",function() app:Open("Settings") end,T.Card)
 local quick=C.Frame(root,"QuickPets") quick.AnchorPoint=Vector2.new(.5,1) quick.Position=UDim2.new(.5,0,1,-10) quick.Size=UDim2.fromOffset(390,84) C.Stroke(quick,T.Purple)
 local qlayout=C.New("UIListLayout",quick,{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,6),HorizontalAlignment=Enum.HorizontalAlignment.Center,VerticalAlignment=Enum.VerticalAlignment.Center})
 local guide=C.Button(root,"",function() app:Open("Pets") end,T.Panel) guide.AnchorPoint=Vector2.new(.5,1) guide.Position=UDim2.new(.5,0,1,-102) guide.Size=UDim2.new(.6,0,0,38) guide.TextSize=12
 local lastQuick=""
 function H.Update(s)
  amount.Text=T.Number(s.Coins) rate.Text=string.format("+%.1f /s\n%s para coletar",s.Rate,T.Number(s.Stored))
  state.Text=s.Demo and "TESTE STUDIO • progresso temporário" or (s.SaveHealthy and "PROGRESSO SALVO AUTOMATICAMENTE" or "AGUARDANDO CONFIRMAÇÃO DO SERVIDOR")
  guide.Text=s.Carrying and "AMOSTRA DNA • volte à sua base a pé" or ("LAB "..s.Plot.."   •   "..#s.Creatures.." pets   •   "..(s.Event.Active and "FESTIVAL ATIVO" or "Evento em "..T.Time(s.Event.Remaining)))
  local key="" local pets={} for _,p in s.Creatures do if p.Placed then table.insert(pets,p) key..=p.Id..tostring(p.Mutation and p.Mutation.Seed) end end
  if key~=lastQuick or not quick:FindFirstChildWhichIsA("TextButton") then
   lastQuick=key for _,o in quick:GetChildren() do if o:IsA("GuiObject") then o:Destroy() end end
   if #pets==0 then local b=C.Button(quick,"+ Colocar meu primeiro pet",function() app:Open("Pets") end,T.Panel) b.Name="EmptySlot" b.Size=UDim2.new(1,-16,1,-16)
   else for i=1,math.min(5,#pets) do local pet=pets[i] local b=C.Button(quick,"",function() app.Selected=pet.Id app:Open("Details") end) b.Size=UDim2.fromOffset(62,70) C.Preview(b,pet).Size=UDim2.new(1,0,1,-17) local l=C.Label(b,tostring(i).." "..Catalog[pet.Archetype].Name,9) l.Position=UDim2.new(0,0,1,-20) l.Size=UDim2.new(1,0,0,20) l.TextXAlignment=Enum.TextXAlignment.Center end end
  end
 end
 function H.Resize(size)
  local narrow=size.X<650 local short=size.Y<480
  top.Size=UDim2.new(narrow and .94 or .62,0,0,56)
  left.Position=UDim2.fromOffset(8,short and 78 or 102) right.Position=UDim2.new(1,-8,0,short and 78 or 102)
  left.Size=UDim2.new(0,74,1,short and -180 or -220) right.Size=left.Size
  for _,rail in {left,right} do for _,o in rail:GetChildren() do if o:IsA("GuiButton") then o.Size=UDim2.fromOffset(66,short and 54 or 62) end end end
  state.Visible=not short guide.Visible=not narrow and not short
  quick.Size=UDim2.new(0,math.min(390,size.X-180),0,short and 64 or 84)
  quick.Position=UDim2.new(.5,0,1,-10)
  for _,o in quick:GetChildren() do if o:IsA("GuiButton") then if o.Name=="EmptySlot" then o.Size=UDim2.new(1,-16,1,-12) o.TextSize=12 else o.Size=UDim2.fromOffset(math.min(62,(quick.AbsoluteSize.X-30)/5),short and 56 or 70) end end end
 end
 return H
end
return H
