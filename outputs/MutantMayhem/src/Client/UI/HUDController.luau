local Shared=game.ReplicatedStorage.MM.Shared
local C=require(Shared.UI.Components)
local T=require(Shared.UI.Theme)
local Skin=require(Shared.UI.HUDSkin)
local Layout=require(Shared.UI.HUDLayout)
local Input=game:GetService("UserInputService")
local Gui=game:GetService("GuiService")
local H={}
function H.Build(app)
 local root=C.New("Frame",app.Root,{Name="MainHUD",BackgroundTransparency=1,Size=UDim2.fromScale(1,1)})
 root.SelectionGroup=true
 local wallet=Skin.Panel(root,"Wallet",Skin.Blue,16)
 local coinIcon=Skin.Icon(wallet,"Coins",28) coinIcon.Position=UDim2.fromOffset(12,14)
 local amount=Skin.Label(wallet,"Amount","—",23)
 amount.Font=Enum.Font.GothamBold amount.Position=UDim2.fromOffset(50,7) amount.Size=UDim2.new(1,-60,0,27)
 local rate=Skin.Label(wallet,"Rate","",12,T.Muted)
 rate.Position=UDim2.fromOffset(50,34) rate.Size=UDim2.new(1,-60,0,16)
 local collecting=false local state
 local collect,collectHit
 collect,collectHit=Skin.Button(root,"Collect",function()
  if collecting or not state or state.SaveHealthy==false or (state.Stored or 0)<1 then return end
  collecting=true collectHit:SetAttribute("Disabled",true)
  local ok,result=pcall(function() return app:Travel("Lab","Collect") end)
  collecting=false collectHit:SetAttribute("Disabled",state and state.SaveHealthy==false)
  if not ok then app:Toast("Não foi possível coletar agora. Tente novamente.") end
 end,Skin.Green,16)
 collect.BackgroundColor3=Color3.fromRGB(29,96,80) collect.Visible=false
 local collectTitle=Skin.Label(collect,"Title","Coletar",15) collectTitle.Font=Enum.Font.GothamBold
 collectTitle.Position=UDim2.fromOffset(14,8) collectTitle.Size=UDim2.new(1,-28,0,22)
 local stored=Skin.Label(collect,"Stored","",12,Color3.fromRGB(193,232,215))
 stored.Position=UDim2.fromOffset(14,31) stored.Size=UDim2.new(1,-28,0,18)
 local status=Skin.Label(root,"SaveStatus","",12,T.Muted) status.Visible=false
 local dock=Skin.Panel(root,"PrimaryDock",Skin.Blue,18)
 local nav={}
 for i,row in {{"Pets","Pets","Pets"},{"Mutation","Mutação","Mutation"},{"Laboratory","Lab","Lab"},{"Menu","Menu","Menu"}} do
  local frame,hit=Skin.Button(dock,row[1],function() app:Open(row[3]) end,Skin.Cyan,12)
  frame.BackgroundTransparency=1 frame.Edge.Transparency=1
  local icon
  if row[1]=="Menu" then
   icon=Skin.Label(frame,"Icon","•••",24) icon.TextXAlignment=Enum.TextXAlignment.Center
  else icon=Skin.Icon(frame,row[1],28) end
  icon.AnchorPoint=Vector2.new(.5,0) icon.Position=UDim2.new(.5,0,0,5)
  local label=Skin.Label(frame,"Label",row[2],12) label.TextXAlignment=Enum.TextXAlignment.Center
  label.Position=UDim2.new(0,0,1,-22) label.Size=UDim2.new(1,0,0,18)
  hit:SetAttribute("Tooltip",row[2])
  nav[i]={Frame=frame,Hit=hit,Icon=icon,Label=label}
 end
 app.FirstNav=nav[1].Hit
 local attention=Skin.Badge(nav[4].Frame)
 local intro,introHit=Skin.Button(root,"FirstPet",function()
  if not state then return end
  for _,pet in state.Creatures do if pet.Placed then app:Open("Pets") return end end
  if state.Creatures[1] then app:Travel("Lab","Place",state.Creatures[1].Id) end
 end,Skin.Cyan,14)
 intro.Visible=false
 local introIcon=Skin.Icon(intro,"Pets",26) introIcon.Position=UDim2.fromOffset(12,10)
 local introText=Skin.Label(intro,"Label","Colocar meu primeiro pet",14)
 introText.Position=UDim2.fromOffset(48,0) introText.Size=UDim2.new(1,-60,1,0)
 local function safeFocus(hidden)
  if Gui.SelectedObject and Gui.SelectedObject:IsDescendantOf(hidden) then Gui.SelectedObject=app.FirstNav end
 end
 function H.Update(s)
  state=s local view=Layout.State(s,math.floor(os.time()/86400))
  amount.Text=T.Number(s.Coins) rate.Text="+"..T.Number(s.Rate or 0).." / segundo"
  if not view.ShowCollect then safeFocus(collect) end
  collect.Visible=view.ShowCollect collectHit:SetAttribute("Disabled",collecting or s.SaveHealthy==false)
  stored.Text=T.Number(s.Stored).." moedas"
  collectHit:SetAttribute("Tooltip","Coletar leva você ao seu laboratório.")
  if not view.ShowIntro then safeFocus(intro) end
  intro.Visible=view.ShowIntro attention.Visible=view.Attention
  status.Text=view.Status status.Visible=view.Status~=""
  H.Resize()
 end
 local function rect(o,r) o.Position=UDim2.fromOffset(r[1],r[2]) o.Size=UDim2.fromOffset(r[3],r[4]) end
 function H.Resize(size)
  size=size or root.AbsoluteSize
  if size.X<1 or size.Y<1 then return end
  local l=Layout.Compute(size.X,size.Y,Input.TouchEnabled)
  rect(wallet,l.Wallet) rect(collect,l.Collect) rect(status,l.Status) rect(dock,l.Dock) rect(intro,l.Intro)
  local gap=4 local cell=(l.Dock[3]-16-gap*3)/4
  for i,v in nav do
   rect(v.Frame,{8+(i-1)*(cell+gap),5,cell,l.Dock[4]-10})
   v.Icon.Size=UDim2.fromOffset(l.Compact and 24 or 28,l.Compact and 24 or 28)
   v.Label.TextSize=l.Compact and 11 or 12
   v.Hit.NextSelectionLeft=nav[(i-2)%4+1].Hit
   v.Hit.NextSelectionRight=nav[i%4+1].Hit
   v.Hit.NextSelectionUp=intro.Visible and introHit or (collect.Visible and collectHit or v.Hit)
  end
  introHit.NextSelectionDown=app.FirstNav collectHit.NextSelectionDown=app.FirstNav
 end
 root:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() H.Resize() end)
 return H
end
return H
