local Shared=game.ReplicatedStorage.MM.Shared local C=require(Shared.UI.Components) local T=require(Shared.UI.Theme)
local Catalog=require(Shared.CreatureCatalog) local M=require(Shared.MutationConfig) local E=require(Shared.EconomyConfig)
local Run=game:GetService("RunService") local P={}
function P.Build(app,host)
 local scroll=C.Scroll(host) C.List(scroll,10)
 local overview=C.New("Frame",scroll,{Name="Overview",BackgroundTransparency=1,Size=UDim2.new(1,-6,0,260)})
 local hero=C.Frame(overview,"PetHero",T.Bg) hero.Size=UDim2.new(.52,-6,1,0) C.Stroke(hero,T.Purple,2)
 local badge=C.Label(hero,"",14,T.Pink) badge.Position=UDim2.fromOffset(12,8) badge.ZIndex=3
 local stats=C.Section(overview,"","",T.Cyan,260) stats.Position=UDim2.fromScale(.52,0) stats.Size=UDim2.new(.48,0,1,0)
 local function resize()
  if not overview.Parent then return end local wide=overview.AbsoluteSize.X>540
  overview.Size=UDim2.new(1,-6,0,wide and 290 or 360)
  hero.Size=wide and UDim2.new(.55,-10,1,0) or UDim2.new(1,0,0,225)
  stats.Position=wide and UDim2.new(.55,0,0,0) or UDim2.fromOffset(0,235)
  stats.Size=wide and UDim2.new(.45,0,1,0) or UDim2.new(1,0,0,125)
 end
 local resizeConnection=overview:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize) task.defer(resize)
 local place=C.Button(scroll,"",function() local p=app:Pet() if p then app:Travel("Lab","Place",p.Id) end end,T.Green)
 C.Button(scroll,"◈ Mudar mutação",function() app:Open("Mutation") end,T.Purple)
 local favorite=C.Button(scroll,"",function() local p=app:Pet() if p then app:Send("PetFlag",{Id=p.Id,Flag="Favorite"}) end end,T.Pink)
 local lock=C.Button(scroll,"",function() local p=app:Pet() if p then app:Send("PetFlag",{Id=p.Id,Flag="Locked"}) end end,T.Gold)
 C.Button(scroll,"Alimentar / Evoluir / Skin",function() app:Open("Care") end)
 C.Button(scroll,"← Voltar ao inventário",function() app:Open("Pets") end)
 local key,camera="",nil local angle=0
 local connection=Run.RenderStepped:Connect(function(dt) if camera and not T.ReducedMotion then angle+=dt*.25 local target=camera:GetAttribute("Target") or Vector3.zero local distance=camera:GetAttribute("Distance") or 10 camera.CFrame=CFrame.lookAt(target+Vector3.new(math.sin(angle),.12,-math.cos(angle)).Unit*distance,target) end end)
 function P.Update(s)
  local p=app:Pet() if not p then app:Open("Pets") return end
  local def=Catalog[p.Archetype] local rarity=p.Mutation and p.Mutation.Rarity or 1
  local nextKey=p.Id..tostring(p.Mutation and p.Mutation.Seed)
  if key~=nextKey then key=nextKey local old=hero:FindFirstChild("PetPreview") if old then old:Destroy() end local v v,camera=C.Preview(hero,p) angle=.4 end
  badge.Text=T.RarityNames[rarity].."   •   "..(p.Placed and "NO LABORATÓRIO" or "NO INVENTÁRIO") badge.TextColor3=T.Rarity[rarity]
  stats:FindFirstChildWhichIsA("TextLabel").Text=def.Name
  local labels={} for _,o in stats:GetChildren() do if o:IsA("TextLabel") then table.insert(labels,o) end end
  labels[2].Text=string.format("Produção base: %.2f /s  •  Multiplicador: ×%.2f\n%s",E.Rate(def.Base,M.Multipliers[rarity],s.Prestige),M.Multipliers[rarity],def.Personality)
  place.Text=p.Placed and "✓ Retirar do laboratório" or "✓ Colocar no laboratório"
  favorite.Text=p.Favorite and "♥ Remover dos favoritos" or "♡ Marcar como favorito"
  lock.Text=p.Locked and "▣ Desbloquear mutação" or "▣ Bloquear mutação"
  app.Subtitle.Text=def.Name.." • dados do servidor"
 end
 function P.Destroy() connection:Disconnect() resizeConnection:Disconnect() end
 return P
end
return P
