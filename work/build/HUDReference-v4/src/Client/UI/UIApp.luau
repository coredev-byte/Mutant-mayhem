local Players=game:GetService("Players") local Gui=game:GetService("GuiService") local Tween=game:GetService("TweenService")
local Shared=game.ReplicatedStorage.MM.Shared local C=require(Shared.UI.Components) local T=require(Shared.UI.Theme)
local Data=require(script.Parent.DataAdapter)
local App={Data=Data}
local screens={Pets={"Meus Pets","InventoryController"},Details={"Detalhes do Pet","PetDetailsController"},Mutation={"Máquina de Mutação","MutationController"},Shop={"Loja","ShopController"},Lab={"Meu Laboratório","BaseUpgradeController"},Map={"Mapa da Ilha","MapController"},Missions={"Missões e Conquistas","MissionsController"},Social={"Amigos e Clãs","SocialController"},Settings={"Configurações","UtilityController"},Event={"Eventos","UtilityController"},Care={"Cuidados e Utilidades","UtilityController"}}
function App:Pet()
 local state=Data.State if not state then return end
 for _,pet in state.Creatures do if pet.Id==self.Selected then return pet end end
 local pet=state.Creatures[1] if pet then self.Selected=pet.Id end return pet
end
function App:Send(action,arg) return Data.Send(action,arg) end
function App:Travel(destination,action,arg) return Data.Travel(destination,action,arg) end
function App:Close()
 if self.Popup then self:DismissPopup() end
 if self.Controller and self.Controller.Destroy then self.Controller.Destroy() end self.Controller=nil
 self.Page=nil self.Window.Visible=false self.Shade.Visible=false self.HUDRoot.Visible=true Gui.SelectedObject=nil
 for _,o in self.Content:GetChildren() do o:Destroy() end
end
function App:Open(page)
 if self.Popup then return end
 if not Data.State then self:Toast("Carregando dados do laboratório…") return end
 self:Close() self.Page=page self.Window.Visible=true self.Shade.Visible=true self.HUDRoot.Visible=false
 self.Title.Text=screens[page][1] self.Subtitle.Text="MUTANT MAYHEM"
 self.Controller=require(script.Parent[screens[page][2]]).Build(self,self.Content)
 if self.Controller.Update then self.Controller.Update(Data.State) end
 self:Focus()
 if not T.ReducedMotion then self.Scale.Scale=.97 Tween:Create(self.Scale,TweenInfo.new(.14,Enum.EasingStyle.Quad),{Scale=1}):Play() end
end
function App.Start()
 local player=Players.LocalPlayer local old=player.PlayerGui:FindFirstChild("MutantMayhemUI") if old then old:Destroy() end
 local root=C.New("ScreenGui",player.PlayerGui,{Name="MutantMayhemUI",ResetOnSpawn=false,IgnoreGuiInset=false,DisplayOrder=10,ZIndexBehavior=Enum.ZIndexBehavior.Sibling}) App.Root=root
 App.HUD=require(script.Parent.HUDController).Build(App) App.HUDRoot=root.MainHUD
 App.Shade=C.New("Frame",root,{Name="Overlays",BackgroundColor3=Color3.new(),BackgroundTransparency=.38,Size=UDim2.fromScale(1,1),Visible=false,Active=true,ZIndex=5})
 local window=C.Frame(root,"Menus") App.Window=window window.ZIndex=10 window.AnchorPoint=Vector2.new(.5,.5) window.Position=UDim2.fromScale(.5,.5) window.Size=UDim2.new(.87,0,.92,0) window.Visible=false C.Stroke(window,T.Cyan,2)
 C.New("UISizeConstraint",window,{MaxSize=Vector2.new(950,760)}) App.Scale=C.New("UIScale",window,{Scale=1}) window.SelectionGroup=true
 App.Title=C.Title(window,"",24) App.Title.Position=UDim2.fromOffset(20,12) App.Title.Size=UDim2.new(1,-90,0,32)
 App.Subtitle=C.Label(window,"",12,T.Muted) App.Subtitle.Position=UDim2.fromOffset(20,44) App.Subtitle.Size=UDim2.new(1,-90,0,28)
 App.CloseButton=C.Button(window,"×",function() App:Close() end,T.Red) App.CloseButton.Name="Close" App.CloseButton.Position=UDim2.new(1,-58,0,14) App.CloseButton.Size=UDim2.fromOffset(44,44) App.CloseButton.TextSize=28
 App.Content=C.New("Frame",window,{Name="ScreenContent",Position=UDim2.fromOffset(18,82),Size=UDim2.new(1,-36,1,-98),BackgroundTransparency=1})
 C.New("Folder",root,{Name="Templates"})
 require(script.Parent.Overlays).Build(App) require(script.Parent.NavigationController).Start(App)
 require(script.Parent.TooltipController).Start(App)
 local function resize()
  local v=workspace.CurrentCamera.ViewportSize local inset=Gui:GetGuiInset() local size=Vector2.new(v.X,v.Y-inset.Y)
  window.Size=UDim2.new(size.X<650 and .96 or .87,0,.94,0)
  App.Title.TextSize=size.X<650 and 20 or 25 App.HUD.Resize(size)
 end
 workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize) resize()
 Data.Changed.Event:Connect(function(s)
  T.ReducedMotion=s.Settings.ReducedMotion player:SetAttribute("MMReducedMotion",s.Settings.ReducedMotion) player:SetAttribute("MMLowGraphics",s.Settings.LowGraphics)
  App.HUD.Update(s) resize()
  if App.Controller and App.Controller.Update then App.Controller.Update(s) end
 end)
 Data.Notice.Event:Connect(function(message) App:Toast(message) end)
 Data.Start()
 return App
end
return App
