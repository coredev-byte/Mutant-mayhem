local C=require(game.ReplicatedStorage.MM.Shared.UI.Components)
local T=require(game.ReplicatedStorage.MM.Shared.UI.Theme)
local Menu={}
function Menu.Build(app,host)
 local scroll=C.Scroll(host,"SecondaryNavigation")
 local grid=C.New("UIGridLayout",scroll,{CellSize=UDim2.new(.5,-8,0,76),CellPadding=UDim2.fromOffset(12,12),SortOrder=Enum.SortOrder.LayoutOrder})
 local entries={} local first
 for i,row in {
  {"Shop","Loja","Estilos para o laboratório","Shop"},
  {"Achievements","Missões","Objetivos e recompensa diária","Missions"},
  {"Map","Mapa","Explore e viaje pela ilha","Map"},
  {"Calendar","Evento","Festival de mutação","Event"},
  {"Friends","Social","Jogadores da ilha","Social"},
  {"Settings","Opções","Controles e preferências","Settings"},
 } do
  local b=C.Button(scroll,"",function() app:Open(row[4]) end)
  b.Name=row[4] b.LayoutOrder=i
  if not first then first=b end
  local icon=C.Icon(b,row[1],28) icon.Position=UDim2.fromOffset(14,20)
  local title=C.Title(b,row[2],16) title.Position=UDim2.fromOffset(54,13) title.Size=UDim2.new(1,-66,0,24)
  local caption=C.Label(b,row[3],12,T.Muted) caption.Position=UDim2.fromOffset(54,39) caption.Size=UDim2.new(1,-66,0,26)
  entries[row[4]]=caption
 end
 local function resize()
  local narrow=scroll.AbsoluteSize.X<480
  grid.CellSize=UDim2.new(narrow and 1 or .5,narrow and -6 or -8,0,76)
 end
 local connection=scroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize) task.defer(resize)
 return {
  FirstFocus=first,
  Update=function(s)
   local daily=(s.Daily or 0)<math.floor(os.time()/86400)
   entries.Missions.Text=daily and "Recompensa diária disponível" or "Objetivos e conquistas"
   entries.Event.Text=s.Event.Active and ("Ativo • "..T.Time(s.Event.Remaining)) or ("Começa em "..T.Time(s.Event.Remaining))
  end,
  Destroy=function() connection:Disconnect() end,
 }
end
return Menu
