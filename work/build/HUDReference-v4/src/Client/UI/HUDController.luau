local Players=game:GetService("Players")
local Shared=game.ReplicatedStorage.MM.Shared
local C=require(Shared.UI.Components)
local T=require(Shared.UI.Theme)
local Skin=require(Shared.UI.HUDSkin)

local H={}
function H.Build(app)
 local root=C.New("Frame",app.Root,{Name="MainHUD",BackgroundTransparency=1,Size=UDim2.fromScale(1,1)})
 local canvas=C.New("Frame",root,{Name="ReferenceCanvas",BackgroundTransparency=1,Size=UDim2.fromOffset(1672,941),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5)})
 local scale=C.New("UIScale",canvas,{Scale=1})
 local top=Skin.Panel(canvas,"CurrencyBar",Skin.Cyan,23,true)
 top.AnchorPoint=Vector2.new(.5,0)
 local slots={}
 local function wallet(key,label,accent,callback)
  local frame=Skin.Panel(top,key,accent,19,false)
  local icon=Skin.Icon(frame,key,62)
  local amount=Skin.Label(frame,"Amount","—",29)
  local caption=Skin.Label(frame,"Caption",label,14,Color3.fromRGB(219,239,255)) caption.Font=Enum.Font.GothamMedium
  local plus,hit=Skin.Button(frame,"Add",callback,accent,12,true)
  plus.BackgroundColor3=Color3.new(1,1,1)
  local plusGradient=plus:FindFirstChildWhichIsA("UIGradient") plusGradient.Color=ColorSequence.new(accent,Color3.fromRGB(0,80,125))
  local p=Skin.Label(plus,"Plus","+",30) p.Size=UDim2.fromScale(1,1) p.TextXAlignment=Enum.TextXAlignment.Center
  slots[key]={Frame=frame,Icon=icon,Amount=amount,Caption=caption,Plus=plus,Hit=hit}
  return slots[key]
 end
 local coins=wallet("Coins","Moedas",Skin.Green,function() app:Open("Shop") end)
 local gems=wallet("Gems","Gemas",Skin.Blue,function() app:Toast("Gemas ainda não estão disponíveis nesta versão.") end)
 local mutagen=wallet("Mutagen","Mutação",Skin.Green,function() app:Open("Mutation") end)
 gems.Hit:SetAttribute("Disabled",true) gems.Hit:SetAttribute("Tooltip","Gemas: recurso ainda indisponível nesta versão.")
 mutagen.Hit:SetAttribute("Disabled",true) mutagen.Hit:SetAttribute("Tooltip","Recurso de mutação ainda indisponível. As mutações atuais usam moedas.")
 gems.Plus.BackgroundTransparency=.35 mutagen.Plus.BackgroundTransparency=.35
 local income=Skin.Panel(top,"Income",Skin.Cyan,19,false)
 local incomeIcon=Skin.Icon(income,"Income",56)
 local incomeAmount=Skin.Label(income,"Amount","+0.0/s",26,Skin.Cyan)
 local incomeCaption=Skin.Label(income,"Caption","Renda por segundo",14,Color3.fromRGB(136,238,255)) incomeCaption.Font=Enum.Font.GothamMedium
 local collecting=false
 local collect,collectHit=Skin.Button(top,"Collect",function()
  if collecting then return end collecting=true
  local result=app:Travel("Lab","Collect") collecting=false
  if result and result.Ok then app:Toast("Renda coletada no laboratório!") end
 end,Skin.Green,20,true)
 collect:FindFirstChildWhichIsA("UIGradient").Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(70,255,67)),ColorSequenceKeypoint.new(.5,Color3.fromRGB(0,188,30)),ColorSequenceKeypoint.new(1,Color3.fromRGB(0,146,119))})
 local collectText=Skin.Label(collect,"Label","COLETAR",23) collectText.Size=UDim2.fromScale(1,1) collectText.TextXAlignment=Enum.TextXAlignment.Center
 local collectBadge=Skin.Badge(collect)
 local status=Skin.Panel(canvas,"SessionStatus",Skin.Blue,16,false) status.AnchorPoint=Vector2.new(.5,0)
 local sessionLabel=Skin.Label(status,"Session","",14) sessionLabel.Position=UDim2.fromOffset(12,0) sessionLabel.Size=UDim2.new(1,-24,1,0) sessionLabel.TextXAlignment=Enum.TextXAlignment.Center
 local left=C.Scroll(canvas,"LeftNavigation") C.List(left,10)
 local right=C.Scroll(canvas,"RightUtilities") C.List(right,10)
 right.AnchorPoint=Vector2.new(1,0) left.ScrollBarThickness=0 right.ScrollBarThickness=0
 left.ClipsDescendants=false right.ClipsDescendants=false
 local navs={} local badges={}
 local function nav(parent,key,label,page,accent,badgeKey)
  local f,hit=Skin.Button(parent,key,function() app:Open(page) end,accent,21,true)
  local icon=Skin.Icon(f,key,68) icon.AnchorPoint=Vector2.new(.5,0) icon.Position=UDim2.new(.5,0,0,7)
  local text=Skin.Label(f,"Label",label,20) text.Position=UDim2.new(0,2,1,-34) text.Size=UDim2.new(1,-4,0,28) text.TextXAlignment=Enum.TextXAlignment.Center
  table.insert(navs,{Frame=f,Icon=icon,Label=text,Hit=hit})
  if badgeKey then badges[badgeKey]=Skin.Badge(f) end
  return hit
 end
 app.FirstNav=nav(left,"Shop","LOJA","Shop",Skin.Blue,"Shop")
 nav(left,"Pets","PETS","Pets",Skin.Cyan)
 nav(left,"Mutation","MUTAÇÃO","Mutation",Skin.Purple)
 nav(left,"Laboratory","LAB","Lab",Skin.Cyan)
 nav(left,"Achievements","MISSÕES","Missions",Skin.Purple,"Missions")
 nav(left,"Map","MAPA","Map",Skin.Blue)
 nav(right,"Gift","PRESENTE","Missions",Skin.Purple,"Daily")
 nav(right,"Calendar","EVENTO","Event",Skin.Purple)
 nav(right,"Portal","VIAJAR","Map",Skin.Blue)
 nav(right,"Friends","SOCIAL","Social",Skin.Blue)
 nav(right,"Settings","OPÇÕES","Settings",Skin.Blue)
 local summary=Skin.Panel(canvas,"BaseSummary",Skin.Cyan,24,true) summary.AnchorPoint=Vector2.new(.5,1)
 local summaryCells={}
 for i,row in {{"Laboratory","LAB 2","Sua base","Lab"},{"Paw","1 pets","Seus pets","Pets"},{"Countdown","Evento em 00:00","Evento especial","Event"}} do
  local f,hit=Skin.Button(summary,"Summary"..i,function() app:Open(row[4]) end,Skin.Blue,20,false)
  local icon=Skin.Icon(f,row[1],50)
  local title=Skin.Label(f,"Title",row[2],23)
  local caption=Skin.Label(f,"Caption",row[3],14,Color3.fromRGB(185,206,255)) caption.Font=Enum.Font.GothamMedium
  summaryCells[i]={Frame=f,Icon=icon,Title=title,Caption=caption}
 end
 local first,firstHit=Skin.Button(canvas,"FirstPet",function()
  local s=app.Data.State if not s then return end
  local placed=false for _,pet in s.Creatures do if pet.Placed then placed=true break end end
  if not placed and s.Creatures[1] then app:Travel("Lab","Place",s.Creatures[1].Id) else app:Open("Pets") end
 end,Skin.Cyan,27,true)
 first.AnchorPoint=Vector2.new(.5,1)
 first:FindFirstChildWhichIsA("UIGradient").Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(44,17,132)),ColorSequenceKeypoint.new(.5,Color3.fromRGB(1,15,69)),ColorSequenceKeypoint.new(1,Color3.fromRGB(4,69,174))})
 local plus=C.Frame(first,"PlusCircle",Color3.fromRGB(0,166,247)) C.Corner(plus,60) local ps=C.Stroke(plus,Skin.Cyan,2) ps.Transparency=0
 local pt=Skin.Label(plus,"Mark","+",43) pt.Size=UDim2.fromScale(1,1) pt.TextXAlignment=Enum.TextXAlignment.Center
 local petIcon=Skin.Icon(first,"Pets",64)
 local firstTitle=Skin.Label(first,"Title","Colocar meu primeiro pet",21)
 local firstCaption=Skin.Label(first,"Caption","Comece sua jornada no laboratório!",14,Color3.fromRGB(199,223,255)) firstCaption.Font=Enum.Font.GothamMedium
 local paw=Skin.Icon(first,"Paw",32) paw.Position=UDim2.new(1,-48,0,14)
 local currentState local compact=false local narrow=false
 local function updateText(s)
  coins.Amount.Text=T.Number(s.Coins)
  gems.Amount.Text=s.Gems~=nil and T.Number(s.Gems) or "—"
  mutagen.Amount.Text=s.Mutagen~=nil and T.Number(s.Mutagen) or "—"
  incomeAmount.Text=string.format("+%.1f/s",s.Rate)
  local n=#Players:GetPlayers()
  if compact then sessionLabel.Text=(s.Demo and "TESTE • temporário" or (s.SaveHealthy and "PROGRESSO SALVO" or "SALVANDO…")).."   |   LAB "..tostring(s.Plot or "—").."   |   "..n.." online"
  else sessionLabel.Text=(s.Demo and "TESTE STUDIO    •    Progresso temporário" or (s.SaveHealthy and "PROGRESSO SALVO AUTOMATICAMENTE" or "AGUARDANDO CONFIRMAÇÃO DO SERVIDOR")).."     |     Sua Base: LAB "..tostring(s.Plot or "—").."     |     "..n.." jogadores online" end
  summaryCells[1].Title.Text="LAB "..tostring(s.Plot or "—")
  summaryCells[1].Caption.Text=narrow and "Sua base" or ("Laboratório • nível "..s.Tier)
  summaryCells[2].Title.Text=#s.Creatures.." pets"
  summaryCells[3].Title.Text=narrow and T.Time(s.Event.Remaining) or (s.Event.Active and "Evento ativo " or "Evento em ")..T.Time(s.Event.Remaining)
  summaryCells[3].Caption.Text=s.Event.Active and "Festival ativo" or "Evento especial"
  local hasPlaced=false for _,p in s.Creatures do if p.Placed then hasPlaced=true break end end
  firstTitle.Text=hasPlaced and (narrow and "Meus pets" or "Gerenciar meus pets") or (narrow and "Colocar primeiro pet" or "Colocar meu primeiro pet")
  firstCaption.Text=narrow and "Abra seu laboratório!" or (hasPlaced and "Seus mutantes estão produzindo moedas!" or "Comece sua jornada no laboratório!")
  collectBadge.Visible=s.Stored>0 badges.Daily.Visible=s.Daily<math.floor(os.time()/86400)
  badges.Shop.Visible=s.Coins>=500 and not s.Cosmetics.Aurora
  local claimable=false for _,q in s.Quests do if q.Progress>=q.Goal and not q.Claimed then claimable=true end end
  local discoveries=0 for _ in s.Discovered do discoveries+=1 end
  for _,goal in {3,6,9,12} do if discoveries>=goal and not s.Cosmetics["discovery"..goal] then claimable=true end end
  badges.Missions.Visible=claimable
  collectHit:SetAttribute("Tooltip",T.Number(s.Stored).." moedas disponíveis. Coletar leva você à sua base.")
 end
 function H.Update(s) currentState=s updateText(s) end
 local lastSize=""
 local function place(o,x,y,w,h) o.Position=UDim2.fromOffset(x,y) o.Size=UDim2.fromOffset(w,h) end
 local function walletLayout(slot,width,small)
  local iconSize=small and 40 or 62
  place(slot.Icon,small and 2 or 6,small and 5 or 5,iconSize,iconSize)
  place(slot.Amount,small and 43 or 75,small and 5 or 6,width-(small and 46 or 128),small and 25 or 36) slot.Amount.TextSize=small and 19 or 29
  place(slot.Caption,small and 43 or 75,small and 30 or 42,width-(small and 44 or 78),small and 16 or 22) slot.Caption.TextSize=small and 10 or 14
  slot.Plus.Visible=not small place(slot.Plus,width-51,14,39,43)
 end
 function H.Resize()
  local viewport=workspace.CurrentCamera.ViewportSize local inset=game:GetService("GuiService"):GetGuiInset()
  root.Position=UDim2.fromOffset(0,-inset.Y) root.Size=UDim2.new(1,0,1,inset.Y)
  local key=tostring(viewport) if lastSize==key then return end lastSize=key
  compact=viewport.X<1000 or viewport.Y<600 narrow=viewport.X<650
  local w,h=1672,941
  if compact then w=viewport.X h=viewport.Y scale.Scale=1 else scale.Scale=math.min(viewport.X/1672,viewport.Y/941) end
  canvas.Size=UDim2.fromOffset(w,h)
  local topW,topH,topY=1080,84,49
  if narrow then topW=w-20 topH=112 topY=64 elseif compact then topW=w-170 topH=58 topY=10 end
  place(top,w/2,topY,topW,topH)
  if not compact then
   place(coins.Frame,14,9,226,66) place(gems.Frame,250,9,196,66) place(mutagen.Frame,456,9,198,66)
   place(income,664,9,210,66) place(collect,888,11,174,62)
  elseif narrow then
   local cell=(topW-24)/3
   place(coins.Frame,6,6,cell,48) place(gems.Frame,12+cell,6,cell,48) place(mutagen.Frame,18+cell*2,6,cell,48)
   place(income,6,60,topW*.54-9,46) place(collect,topW*.54+3,60,topW*.46-9,46)
  else
   local cell=(topW-24)/3
   place(coins.Frame,6,5,cell,48) place(income,12+cell,5,cell,48) place(collect,18+cell*2,5,cell,48)
  end
  gems.Frame.Visible=not compact or narrow mutagen.Frame.Visible=not compact or narrow
  for _,slot in slots do walletLayout(slot,slot.Frame.Size.X.Offset,compact) end
  place(incomeIcon,compact and 5 or 12,compact and 5 or 6,compact and 34 or 54,compact and 34 or 54)
  place(incomeAmount,compact and 44 or 72,compact and 3 or 8,income.Size.X.Offset-(compact and 46 or 75),compact and 25 or 30) incomeAmount.TextSize=compact and 19 or 26
  place(incomeCaption,compact and 44 or 72,compact and 28 or 39,income.Size.X.Offset-(compact and 46 or 75),20) incomeCaption.TextSize=compact and 9 or 14
  incomeCaption.Text=compact and "Renda / segundo" or "Renda por segundo" collectText.TextSize=compact and 16 or 23
  place(status,w/2,topY+topH+9,compact and topW or 818,compact and 27 or 35) sessionLabel.TextSize=compact and 10 or 14
  local navW,navH,gap=128,98,9
  local railY=175
  if compact then navW=64 navH=62 gap=7 railY=narrow and 216 or 106 end
  local railH=compact and h-railY-(narrow and 15 or 105) or 650
  place(left,compact and 8 or 14,railY,navW+6,railH)
  place(right,w-(compact and 8 or 16),railY,navW+6,railH)
  left.ClipsDescendants=compact right.ClipsDescendants=compact
  left.UIListLayout.Padding=UDim.new(0,gap) right.UIListLayout.Padding=UDim.new(0,gap)
  for _,nav in navs do
   nav.Frame.Size=UDim2.fromOffset(navW,navH)
   local iconSize=compact and 40 or 68
   nav.Icon.Size=UDim2.fromOffset(iconSize,iconSize) nav.Icon.Position=UDim2.new(.5,0,0,compact and 2 or 5)
   nav.Label.Position=UDim2.new(0,1,1,compact and -23 or -32) nav.Label.Size=UDim2.new(1,-2,0,compact and 20 or 27) nav.Label.TextSize=compact and 11 or 20
  end
  for _,b in badges do b.Size=UDim2.fromOffset(compact and 19 or 28,compact and 22 or 32) b.Mark.TextSize=compact and 16 or 23 end
  collectBadge.Size=UDim2.fromOffset(compact and 19 or 28,compact and 22 or 32) collectBadge.Mark.TextSize=compact and 16 or 23
  local summaryW=compact and math.max(200,w-166) or 728 local summaryH=compact and 54 or 74
  local firstW=narrow and w-152 or (compact and math.min(480,w-180) or 480)
  local firstH=compact and 66 or 96 local bottom=narrow and 128 or (compact and 14 or 34)
  place(first,w/2,h-bottom,firstW,firstH)
  place(summary,w/2,h-bottom-firstH-12,summaryW,summaryH)
  local cellX=8
  for i,v in summaryCells do
   local cell=(summaryW-24)*(narrow and 1/3 or ({.33,.28,.39})[i]) place(v.Frame,cellX,6,cell,summaryH-12) cellX+=cell+4
   local iconSize=narrow and 23 or (compact and 32 or 50)
   place(v.Icon,narrow and 3 or 9,(summaryH-12-iconSize)/2,iconSize,iconSize)
   v.Icon.Visible=not narrow
   local tx=narrow and 6 or (compact and 45 or 69)
   place(v.Title,tx,compact and 3 or 6,cell-tx-4,compact and 20 or 28) v.Title.TextSize=narrow and 12 or (compact and 16 or 23)
   place(v.Caption,tx,compact and 23 or 35,cell-tx-4,compact and 15 or 20) v.Caption.TextSize=narrow and 8 or (compact and 10 or 14)
  end
  place(plus,compact and 10 or 23,compact and 12 or 20,compact and 40 or 56,compact and 40 or 56) pt.TextSize=compact and 33 or 43
  petIcon.Visible=not narrow place(petIcon,compact and 58 or 88,compact and 7 or 14,compact and 50 or 64,compact and 50 or 64)
  local textX=narrow and 58 or (compact and 118 or 169)
  place(firstTitle,textX,compact and 13 or 20,firstW-textX-14,compact and 23 or 30) firstTitle.TextSize=narrow and 12 or (compact and 15 or 21)
  place(firstCaption,textX,compact and 38 or 52,firstW-textX-14,compact and 18 or 23) firstCaption.TextSize=compact and 10 or 14
  paw.Visible=not compact
  if currentState then updateText(currentState) end
 end
 return H
end
return H
