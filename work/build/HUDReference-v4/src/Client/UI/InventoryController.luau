local Shared=game.ReplicatedStorage.MM.Shared
local C=require(Shared.UI.Components) local T=require(Shared.UI.Theme)
local Catalog=require(Shared.CreatureCatalog)
local Http=game:GetService("HttpService") local Gui=game:GetService("GuiService")
local I={}
function I.Build(app,host)
 local search=C.New("TextBox",host,{Name="Search",PlaceholderText="Buscar pet…",Text="",ClearTextOnFocus=false,Font=Enum.Font.Gotham,TextSize=15,TextColor3=T.Text,PlaceholderColor3=T.Muted,BackgroundColor3=T.Bg,BorderSizePixel=0,Size=UDim2.new(1,-4,0,44)}) C.Corner(search,9) C.Stroke(search,T.Cyan)
 local tabs=C.New("Frame",host,{Name="Filters",BackgroundTransparency=1,Position=UDim2.fromOffset(0,52),Size=UDim2.new(1,0,0,40)})
 local filter="Todos" local limit=24 local cache="" local lastState
 local scroll=C.Scroll(host,"InventoryGrid") scroll.Position=UDim2.fromOffset(0,102) scroll.Size=UDim2.new(1,0,1,-164)
 local grid=C.New("UIGridLayout",scroll,{CellSize=UDim2.fromOffset(145,162),CellPadding=UDim2.fromOffset(10,10),SortOrder=Enum.SortOrder.LayoutOrder})
 search.Size=UDim2.new(.76,-6,0,44)
 local footer=C.Button(host,"Inspecionar",function() app:Open("Details") end,T.Cyan) footer.Position=UDim2.new(0,0,1,-52) footer.Size=UDim2.new(.25,-6,0,46) footer.TextSize=12
 local place=C.Button(host,"Equipar",function() local pet=app:Pet() if pet then app:Travel("Lab","Place",pet.Id) end end,T.Green) place.Position=UDim2.new(.25,0,1,-52) place.Size=UDim2.new(.25,-6,0,46) place.TextSize=12
 local lock=C.Button(host,"Bloquear",function() local pet=app:Pet() if pet then app:Send("PetFlag",{Id=pet.Id,Flag="Locked"}) end end,T.Gold) lock.Position=UDim2.new(.5,0,1,-52) lock.Size=UDim2.new(.25,-6,0,46) lock.TextSize=12
 local sell=C.Button(host,"Vender\nEm breve",nil) sell.Position=UDim2.new(.75,0,1,-52) sell.Size=UDim2.new(.25,-6,0,46) sell.TextSize=12 C.Disabled(sell,true)
 local more=C.Button(host,"+ 24",function() limit+=24 cache="" if lastState then I.Update(lastState) end end) more.Position=UDim2.new(.76,0,0,0) more.Size=UDim2.new(.24,-4,0,44) more.TextSize=12
 local tabButtons={}
 for index,name in {"Todos","No lab","Favoritos"} do local b=C.Button(tabs,name,function() filter=name cache="" if lastState then I.Update(lastState) end end) b.Position=UDim2.new((index-1)/3,0,0,0) b.Size=UDim2.new(1/3,-7,1,0) tabButtons[name]=b end
 function I.Update(s)
  lastState=s local key=Http:JSONEncode(s.Creatures)..search.Text..filter..limit..tostring(app.Selected)
  if key==cache then return end cache=key
  local focus=Gui.SelectedObject local focusName=focus and focus.Name
  for _,o in scroll:GetChildren() do if o:IsA("GuiObject") then o:Destroy() end end
  for name,b in tabButtons do b.BackgroundColor3=name==filter and T.Purple or T.Card end
  local pets={} for _,p in s.Creatures do
   if string.find(string.lower(Catalog[p.Archetype].Name),string.lower(search.Text),1,true) and (filter=="Todos" or filter=="No lab" and p.Placed or filter=="Favoritos" and p.Favorite) then table.insert(pets,p) end
  end
  table.sort(pets,function(a,b) local ar=a.Mutation and a.Mutation.Rarity or 1 local br=b.Mutation and b.Mutation.Rarity or 1 if ar==br then return a.Id<b.Id end return ar>br end)
  for index=1,math.min(limit,#pets) do local pet=pets[index]
   local b=C.PetCard(scroll,pet,Catalog[pet.Archetype].Name,function() app.Selected=pet.Id cache="" I.Update(s) end,app.Selected==pet.Id) b.LayoutOrder=index
   if focusName==b.Name then Gui.SelectedObject=b end
  end
  if #pets==0 then C.Section(scroll,"Nenhum pet","Experimente outro filtro ou descubra um amigo no Prado.") end
  local chosen=app:Pet() footer.Text="Inspecionar"
  place.Text=chosen and chosen.Placed and "Retirar" or "Equipar" lock.Text=chosen and chosen.Locked and "Desbloquear" or "Bloquear"
  C.Disabled(place,not chosen) C.Disabled(lock,not chosen)
  C.Disabled(footer,not chosen) C.Disabled(more,#pets<=limit) more.Text=#pets>limit and "+ 24" or (#s.Creatures.." / 60")
  app.Subtitle.Text=#pets.." encontrados • raridade decrescente"
 end
 search:GetPropertyChangedSignal("Text"):Connect(function() if lastState then I.Update(lastState) end end)
 local function resize() local w=scroll.AbsoluteSize.X local columns=math.max(2,math.floor((w+10)/145)) local cell=(w-6-(columns-1)*10)/columns grid.CellSize=UDim2.fromOffset(cell,math.min(180,cell+38)) end
 local connection=scroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize) task.defer(resize)
 function I.Destroy() connection:Disconnect() end
 return I
end
return I
