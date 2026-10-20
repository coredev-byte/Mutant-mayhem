local Shared=game.ReplicatedStorage.MM.Shared local C=require(Shared.UI.Components) local T=require(Shared.UI.Theme)
local Catalog=require(Shared.CreatureCatalog) local M=require(Shared.MutationConfig) local E=require(Shared.EconomyConfig)
local U={}
function U.Build(app,host)
 local scroll=C.Scroll(host) C.List(scroll,10)
 local stage=C.New("Frame",scroll,{Name="MutationStage",BackgroundTransparency=1,Size=UDim2.new(1,-6,0,310)})
 local selectedCard=C.Frame(stage,"SelectedPet",T.Bg) C.Stroke(selectedCard,T.Gold)
 local selectedName=C.Label(selectedCard,"",14) selectedName.Position=UDim2.new(0,8,1,-34) selectedName.Size=UDim2.new(1,-16,0,28) selectedName.TextXAlignment=Enum.TextXAlignment.Center
 local chamber=C.Frame(stage,"MutationChamber",T.Bg) C.Stroke(chamber,T.Purple,2)
 local chamberTitle=C.Label(chamber,"CÂMARA DE MUTAÇÃO",13,T.Pink) chamberTitle.Position=UDim2.fromOffset(12,8) chamberTitle.ZIndex=3
 local glow=C.Frame(chamber,"Energy",T.Purple) glow.AnchorPoint=Vector2.new(.5,.5) glow.Position=UDim2.fromScale(.5,.5) glow.Size=UDim2.fromScale(.52,.8) glow.BackgroundTransparency=.88 C.Corner(glow,100) C.Stroke(glow,T.Cyan,2)
 local choose=C.Button(stage,"Escolher pet",function() app:Open("Pets") end) choose.TextSize=12
 local odds=C.Frame(stage,"Odds") C.Stroke(odds,T.Cyan)
 local title=C.Title(odds,"CHANCES POR RARIDADE",14) title.Position=UDim2.fromOffset(12,5)
 local oddsLabels={} for i=1,6 do local l=C.Label(odds,T.RarityNames[i].."     "..(M.Weights[i]/100).."%",13,T.Rarity[i]) table.insert(oddsLabels,l) end
 local function resize()
  if not stage.Parent then return end
  local wide=stage.AbsoluteSize.X>=680
  stage.Size=UDim2.new(1,-6,0,wide and 310 or 460)
  selectedCard.Position=UDim2.fromOffset(0,0) selectedCard.Size=wide and UDim2.new(.24,-8,0,248) or UDim2.new(.37,-6,0,220)
  choose.Position=wide and UDim2.new(0,0,0,258) or UDim2.new(0,0,0,230) choose.Size=wide and UDim2.new(.24,-8,0,46) or UDim2.new(.37,-6,0,46)
  chamber.Position=wide and UDim2.new(.24,4,0,0) or UDim2.new(.37,4,0,0) chamber.Size=wide and UDim2.new(.44,-14,1,0) or UDim2.new(.63,-4,0,276)
  odds.Position=wide and UDim2.new(.68,0,0,0) or UDim2.fromOffset(0,288) odds.Size=wide and UDim2.new(.32,0,1,0) or UDim2.new(1,0,0,164)
  for i,l in oddsLabels do l.Position=wide and UDim2.new(0,12,0,40+(i-1)*40) or UDim2.new(i>3 and .5 or 0,12,0,40+((i-1)%3)*36) l.Size=wide and UDim2.new(1,-24,0,32) or UDim2.new(.5,-20,0,30) end
 end
 local resizeConnection=stage:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize) task.defer(resize)
 local pity=C.Progress(scroll,0,"",T.Purple)
 local roll
 roll=C.Button(scroll,"MUTAR",function()
  local pet=app:Pet() if not pet then return end local id=pet.Id
  app:Confirm("Usar "..E.MutationCost.." moedas? A mutação atual será substituída por um resultado aleatório.",function()
   if roll.Parent then roll.Text="MUTANDO…" C.Disabled(roll,true) end
   local result=app:Travel("Reactor","Mutate",id)
   if result and result.Ok then app:Toast("✦ Mutação confirmada! Inspecione seu novo pet.") end
   if roll.Parent then U.Update(app.Data.State) end
  end)
 end,T.Green)
 C.Section(scroll,"Resultados reais","As chances usam a configuração do servidor. Raro ou superior garantido em até 20 tentativas. Cor, olhos, chifres e outros traços também variam.",T.Purple,118)
 local key=""
 function U.Update(s)
  local pet=app:Pet() local rarity=pet and pet.Mutation and pet.Mutation.Rarity or 1
  local nextKey=pet and pet.Id..tostring(pet.Mutation and pet.Mutation.Seed) or "none"
  if key~=nextKey then key=nextKey for _,area in {chamber,selectedCard} do local old=area:FindFirstChild("PetPreview") if old then old:Destroy() end if pet then local v=C.Preview(area,pet) if area==selectedCard then v.Size=UDim2.new(1,0,1,-38) end end end end
  selectedName.Text=pet and (Catalog[pet.Archetype].Name.." • "..T.RarityNames[rarity]) or "Nenhum pet"
  choose.Text="Trocar pet"
  pity.Fill.Size=UDim2.new(s.Misses/M.PityAt,0,1,0) pity:FindFirstChildWhichIsA("TextLabel").Text="Garantia Raro+   "..s.Misses.." / "..M.PityAt
  roll.Text=pet and pet.Locked and "PET BLOQUEADO" or ("MUTAR   ● "..E.MutationCost)
  C.Disabled(roll,not pet or pet.Locked or s.Coins<E.MutationCost or app.Data.Busy)
  app.Subtitle.Text="Sua próxima descoberta começa aqui"
 end
 function U.Destroy() resizeConnection:Disconnect() end
 return U
end
return U
