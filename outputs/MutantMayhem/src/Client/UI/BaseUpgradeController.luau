local S=game.ReplicatedStorage.MM.Shared local C=require(S.UI.Components) local T=require(S.UI.Theme) local E=require(S.EconomyConfig)
local B={}
function B.Build(app,host)
 local scroll=C.Scroll(host) C.List(scroll,10)
 local hero=C.Frame(scroll,"LaboratoryPreview",T.Bg) hero.Size=UDim2.new(1,-6,0,170) C.Stroke(hero,T.Cyan,2)
 local icon=C.Icon(hero,"Laboratory",62,T.Cyan) icon.Position=UDim2.fromOffset(16,38)
 local level=C.Title(hero,"",22) level.Position=UDim2.new(.3,0,0,25) level.Size=UDim2.new(.7,-10,0,40)
 local benefits=C.Label(hero,"",14,T.Muted) benefits.Position=UDim2.new(.3,0,0,68) benefits.Size=UDim2.new(.7,-10,0,90)
 local progress=C.Progress(scroll,0,"",T.Cyan)
 local upgrade=C.Button(scroll,"",function() app:Travel("Lab","Upgrade") end,T.Green)
 local collect=C.Button(scroll,"",function() app:Travel("Lab","Collect") end,T.Gold)
 C.Button(scroll,"⬡ Ativar escudo grátis • 90 segundos",function() app:Travel("Lab","Shield") end,T.Purple)
 C.Button(scroll,"⌂ Voltar à minha base",function() app:Send("Go","Lab") end)
 local mastery=C.Section(scroll,"MAESTRIA","",T.Gold,126)
 C.Button(scroll,"Conquistar maestria • 18.000 moedas",function() app:Travel("Lab","Prestige") end,T.Gold)
 local research=C.Button(scroll,"",function() app:Travel("Lab","Research") end)
 C.Button(scroll,"✿ Decoração do laboratório",function() app:Open("Shop") end,T.Purple)
 function B.Update(s)
  level.Text="Laboratório • nível "..s.Tier
  benefits.Text=string.format("%d espaços  •  %.1f moedas/s\n%s",s.Capacity,s.Rate,s.Tier<E.MaxTier and "Próximo nível: +1 espaço de pet" or "Expansão máxima atingida")
  progress.Fill.Size=UDim2.new(s.Tier/E.MaxTier,0,1,0) progress:FindFirstChildWhichIsA("TextLabel").Text=s.Tier.." / "..E.MaxTier.." melhorias"
  upgrade.Text=s.Tier>=E.MaxTier and "LABORATÓRIO NO MÁXIMO" or "MELHORAR   ● "..T.Number(s.UpgradeCost)
  C.Disabled(upgrade,s.Tier>=E.MaxTier or s.Coins<s.UpgradeCost)
  collect.Text="COLETAR   ● "..T.Number(s.Stored)
  local labels={} for _,o in mastery:GetChildren() do if o:IsA("TextLabel") then table.insert(labels,o) end end
  labels[2].Text="Rank "..s.Prestige.." / 10. Cada rank concede +5% de renda base. Requer laboratório nível 6. Seus pets e melhorias são preservados."
  research.Text="Pesquisa "..s.Research.." • investir "..T.Number(s.ResearchCost).." moedas"
  app.Subtitle.Text="Sua base • produção, proteção e expansão"
 end
 return B
end
return B
