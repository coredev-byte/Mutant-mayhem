local C=require(game.ReplicatedStorage.MM.Shared.UI.Components) local T=require(game.ReplicatedStorage.MM.Shared.UI.Theme)
local W={}
local destinations={{"Lab","SUA BASE","⌂",.5,.8,T.Cyan},{"Reactor","REATOR","◈",.5,.42,T.Purple},{"Meadow","PRADO","✿",.8,.42,T.Green},{"Events","EVENTOS","✦",.5,.08,T.Pink},{"Showcase","CLUBE","★",.2,.42,T.Gold},{"Shop","LOJA","◆",.8,.8,T.Gold}}
function W.Build(app,host)
 local scroll=C.Scroll(host) C.List(scroll,10)
 local map=C.Frame(scroll,"IslandMap",T.Bg) map.Size=UDim2.new(1,-6,0,340) C.Stroke(map,T.Cyan,2)
 local island=C.Frame(map,"Island",Color3.fromRGB(17,69,74)) island.AnchorPoint=Vector2.new(.5,.5) island.Position=UDim2.fromScale(.5,.5) island.Size=UDim2.fromScale(.88,.83) C.Corner(island,100) C.Stroke(island,T.Green)
 for _,v in destinations do
  local b=C.Button(map,v[3].."\n"..v[2],function() local r=app:Send("Go",v[1]) if r and r.Ok then app:Close() end end,v[6]) b.Name="Go_"..v[1] b.AnchorPoint=Vector2.new(.5,0) b.Position=UDim2.fromScale(v[4],v[5]) b.Size=UDim2.new(.27,0,0,58) b.TextSize=12
 end
 C.Button(scroll,"Descobrir amigo • 60 moedas",function() app:Travel("Meadow","Discover") end,T.Green)
 C.Button(scroll,"Ver missões",function() app:Open("Missions") end)
 C.Section(scroll,"ILHA DO CAOS","Cada ponto representa uma área existente do jogo. Viagem rápida fica indisponível enquanto você transporta uma amostra de DNA.",T.Cyan,110)
 function W.Update(s) app.Subtitle.Text=s.Carrying and "Transporte de DNA: volte a pé para sua base" or "Escolha um destino • viagem rápida" end
 return W
end
return W
