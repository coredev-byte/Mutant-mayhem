local S=game.ReplicatedStorage.MM.Shared local C=require(S.UI.Components) local T=require(S.UI.Theme) local Config=require(S.GameConfig)
local Shop={}
local categories={"Destaques","Passes","Moedas","Gemas","Skins","Decoração","Boosts"}
function Shop.Build(app,host)
 local tabs=C.Scroll(host,"ShopCategories") tabs.Size=UDim2.new(0,104,1,0) C.List(tabs,8)
 local content=C.Scroll(host,"Products") content.Position=UDim2.fromOffset(116,0) content.Size=UDim2.new(1,-116,1,0) C.List(content,12)
 local category="Destaques" local buttons={} local last
 local function render()
  for _,o in content:GetChildren() do if o:IsA("GuiObject") then o:Destroy() end end
  for name,b in buttons do b.BackgroundColor3=name==category and T.Purple or T.Card end
  if category=="Destaques" or category=="Decoração" then
   local card=C.Section(content,"AURORA","Um novo teto lavanda para seu laboratório. Desbloqueio permanente com moedas ganhas jogando.",T.Purple,150)
   C.Button(content,last and last.Cosmetics.Aurora and "Alternar Classic / Aurora" or "Desbloquear   ● 500",function() app:Travel("Shop","Style") render() end,T.Green)
  end
  local count=0
  if category=="Destaques" or category=="Moedas" then for id,def in Config.Products do count+=1
   C.Section(content,def.Name or "Pacote de moedas",tostring(def.Amount or "").." moedas. Preço e detalhes no diálogo oficial do Roblox.",T.Gold,130)
   C.Button(content,"Ver oferta no Roblox",function() app:Travel("Shop","BuyProduct",id) end,T.Green)
  end end
  if category=="Destaques" or category=="Passes" then for id,def in Config.Passes do count+=1
   C.Section(content,def.Kind=="VIP" and "VIP" or "Mais espaços",def.Kind=="VIP" and "+25% de produção. Consulte a oferta oficial do Roblox." or "Capacidade extra para o laboratório. Consulte a oferta oficial.",T.Gold,130)
   C.Button(content,"Ver passe no Roblox",function() app:Travel("Shop","BuyPass",id) end,T.Gold)
  end end
  if count==0 and category~="Decoração" then C.Section(content,category=="Destaques" and "VITRINE PREMIUM" or category,"Nenhuma oferta disponível nesta categoria. Produtos e preços reais aparecerão quando forem configurados.",T.Gold,170) end
  C.Section(content,"Compra transparente","Nenhuma cobrança ocorre ao abrir esta tela. Compras Robux sempre usam a confirmação oficial do Roblox.",T.Cyan,140)
 end
 for _,name in categories do buttons[name]=C.Button(tabs,name,function() category=name render() end) buttons[name].Size=UDim2.new(1,-6,0,48) buttons[name].TextSize=12 end
 function Shop.Update(s) local initial=last==nil local changed=last and last.Cosmetics.Aurora~=s.Cosmetics.Aurora last=s if initial or changed then render() end app.Subtitle.Text="Estilo para seu laboratório • moedas ganhas jogando" end
 return Shop
end
return Shop
