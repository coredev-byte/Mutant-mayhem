local C=require(game.ReplicatedStorage.MM.Shared.UI.Components) local T=require(game.ReplicatedStorage.MM.Shared.UI.Theme)
local Q={}
function Q.Build(app,host)
 local tabs=C.New("Frame",host,{BackgroundTransparency=1,Size=UDim2.new(1,0,0,44)})
 local scroll=C.Scroll(host,"MissionRows") scroll.Position=UDim2.fromOffset(0,54) scroll.Size=UDim2.new(1,0,1,-54) C.List(scroll,10)
 local selected="Diárias" local s local buttons={} local key="" local Http=game:GetService("HttpService")
 local function render()
  if not s then return end
  for _,o in scroll:GetChildren() do if o:IsA("GuiObject") then o:Destroy() end end
  for name,b in buttons do b.BackgroundColor3=name==selected and T.Purple or T.Card end
  if selected=="Diárias" then
   C.Section(scroll,"PRESENTE DIÁRIO","200 moedas + até 150 de recuperação. Sem perda de sequência.",T.Gold,94)
   local claimed=s.Daily==math.floor(os.time()/86400)
   local daily=C.Button(scroll,claimed and "Presente de hoje resgatado" or "Resgatar presente",function() app:Send("Daily") end,T.Gold) C.Disabled(daily,claimed)
   for _,q in s.Quests do C.Section(scroll,q.Name,"Recompensa: "..q.Reward.." moedas"..(q.Claimed and " • RESGATADA" or ""),T.Cyan,86) C.Progress(scroll,q.Progress/q.Goal,math.min(q.Progress,q.Goal).." / "..q.Goal,T.Green) end
   C.Button(scroll,"Resgatar missões concluídas",function() app:Send("Missions") end,T.Green)
  elseif selected=="Semanais" then
   C.Section(scroll,"EXPLORADOR DA SEMANA","Resgate o presente em quatro dias nesta semana para ganhar a decoração Weekly Glow.",T.Purple,120)
   C.Progress(scroll,(s.Weekly.Count or 0)/4,tostring(s.Weekly.Count or 0).." / 4 dias",T.Purple)
   C.Section(scroll,s.Cosmetics.WeeklyGlow and "DECORAÇÃO DESBLOQUEADA" or "RECOMPENSA: WEEKLY GLOW","O emblema aparece no seu laboratório quando desbloqueado.",T.Gold,110)
  else
   local count=0 for _ in s.Discovered do count+=1 end
   C.Section(scroll,"COLECIONADOR","Descubra todas as 12 espécies originais de MUTANT MAYHEM.",T.Pink,100) C.Progress(scroll,count/12,count.." / 12 espécies",T.Cyan)
   C.Section(scroll,"MARCOS DA COLEÇÃO","Recompensas ao descobrir 3, 6, 9 e 12 espécies. O servidor valida os marcos e concede cada recompensa uma única vez.",T.Gold,120)
   C.Button(scroll,"Resgatar conquistas disponíveis",function() app:Send("Missions") end,T.Green)
   C.Button(scroll,"Explorar o Prado",function() app:Send("Go","Meadow") end)
  end
 end
 for i,name in {"Diárias","Semanais","Conquistas"} do local b=C.Button(tabs,name,function() selected=name key="" render() end) b.Position=UDim2.new((i-1)/3,0,0,0) b.Size=UDim2.new(1/3,-6,1,0) b.TextSize=13 buttons[name]=b end
 function Q.Update(state) s=state local nextKey=Http:JSONEncode({s.Quests,s.Weekly,s.Discovered,s.Daily,s.Cosmetics.WeeklyGlow}) if key~=nextKey then key=nextKey render() end app.Subtitle.Text="Pequenas metas • grandes descobertas" end
 return Q
end
return Q
