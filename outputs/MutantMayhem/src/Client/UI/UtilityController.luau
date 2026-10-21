local C=require(game.ReplicatedStorage.MM.Shared.UI.Components) local T=require(game.ReplicatedStorage.MM.Shared.UI.Theme)
local U={}
function U.Build(app,host)
 local scroll=C.Scroll(host) C.List(scroll,10) local binds={} local eventLabel
 if app.Page=="Settings" then
  for _,setting in {{"Peaceful","Modo pacífico"},{"ReducedMotion","Reduzir movimento"},{"LowGraphics","Gráficos leves"}} do
   binds[setting[1]]=C.Button(scroll,setting[2],function() app:Send("Setting",setting[1]) end) binds[setting[1]]:SetAttribute("Label",setting[2])
  end
  C.Section(scroll,"CONTROLES","M / Y: menu. B / Esc: voltar. LB / RB: mudar tela dentro dos menus. Direcional: navegar. A: selecionar. Touch: toque e deslize as listas.",T.Cyan,140)
  C.Section(scroll,"DADOS","No Studio com modo de teste, o progresso é temporário. Nos servidores públicos, o jogo usa o sistema de persistência.",T.Gold,120)
 elseif app.Page=="Event" then
  eventLabel=C.Section(scroll,"FESTIVAL DE MUTAÇÃO","",T.Pink,150)
  C.Button(scroll,"Ir ao evento",function() app:Send("Go","Events") end,T.Purple)
  C.Section(scroll,"DNA • OPCIONAL","O modo pacífico está ativo por padrão. Amostras de DNA nunca removem o pet original. Leve a amostra à sua base em 45 segundos.",T.Cyan,140)
  C.Button(scroll,"Coletar amostra de base próxima",function() app:Send("Raid") end,T.Gold)
  C.Button(scroll,"Defender • pulso grátis",function() app:Send("Defend") end,T.Red)
 else
  for _,row in {{"ALIMENTAR","Alimentos e fome ainda não têm serviço de gameplay."},{"EVOLUIR","Evolução e XP ainda não estão disponíveis. Mutação já está conectada."},{"TROCAS E VENDA","Trocas e venda de pets aguardam um sistema seguro de transações."},{"SKINS","Skins individuais ainda não estão disponíveis. Decoração do laboratório está na loja."}} do C.Section(scroll,row[1],row[2],T.Purple,105) end
  C.Button(scroll,"Ir para mutação",function() app:Open("Mutation") end,T.Purple)
 end
 function U.Update(s)
  for key,b in binds do b.Text=b:GetAttribute("Label")..": "..(s.Settings[key] and "ATIVADO" or "DESATIVADO") b.BackgroundColor3=s.Settings[key] and T.Green or T.Card end
  if eventLabel then local labels={} for _,o in eventLabel:GetChildren() do if o:IsA("TextLabel") then table.insert(labels,o) end end labels[2].Text=s.Event.Active and ("ATIVO • +25% de renda\nTermina em "..T.Time(s.Event.Remaining)) or ("Próximo festival em "..T.Time(s.Event.Remaining).."\nVisite a zona de eventos para participar.") end
 end
 return U
end
return U
