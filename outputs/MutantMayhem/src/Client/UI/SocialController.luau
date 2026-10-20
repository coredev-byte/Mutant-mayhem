local Players=game:GetService("Players") local C=require(game.ReplicatedStorage.MM.Shared.UI.Components) local T=require(game.ReplicatedStorage.MM.Shared.UI.Theme)
local S={}
function S.Build(app,host)
 local tabs=C.New("Frame",host,{BackgroundTransparency=1,Size=UDim2.new(1,0,0,44)})
 local list=C.Scroll(host) list.Position=UDim2.fromOffset(0,54) list.Size=UDim2.new(1,0,1,-54) C.List(list,10)
 local page="Servidor" local buttons={}
 local function render()
  for _,o in list:GetChildren() do if o:IsA("GuiObject") then o:Destroy() end end
  for name,b in buttons do b.BackgroundColor3=name==page and T.Purple or T.Card end
  if page=="Servidor" then
   for _,p in Players:GetPlayers() do C.Section(list,p.DisplayName,"@"..p.Name.." • Online neste servidor"..(p==Players.LocalPlayer and " • Você" or ""),T.Cyan,90) end
   C.Section(list,"VISITAS","Encontre outros laboratórios caminhando pela ilha. Viagem direta para bases de jogadores ainda não está conectada.",T.Purple,120)
  elseif page=="Amigos" then C.Section(list,"AMIGOS","Integração de amigos e convites ainda indisponível. Nenhuma lista simulada é apresentada.",T.Cyan,150)
  else C.Section(list,"SEU CLÃ","Clãs, membros e convites ainda não estão disponíveis nesta versão.",T.Gold,150)
   for _,label in {"Membros • em breve","Convites • em breve","Configurações • em breve"} do C.Disabled(C.Button(list,label,nil),true) end
  end
 end
 for i,name in {"Servidor","Amigos","Clã"} do local b=C.Button(tabs,name,function() page=name render() end) b.Position=UDim2.new((i-1)/3,0,0,0) b.Size=UDim2.new(1/3,-6,1,0) buttons[name]=b end
 local a=Players.PlayerAdded:Connect(render) local b=Players.PlayerRemoving:Connect(function() task.defer(render) end) render()
 function S.Update() app.Subtitle.Text="Pessoas conectadas • comunidade" end
 function S.Destroy() a:Disconnect() b:Disconnect() end
 return S
end
return S
