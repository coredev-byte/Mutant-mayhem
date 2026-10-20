local Players=game:GetService("Players")
local Rep=game:GetService("ReplicatedStorage")
local Tween=game:GetService("TweenService")
local GuiService=game:GetService("GuiService")
local Input=game:GetService("UserInputService")
local Actions=game:GetService("ContextActionService")
local player=Players.LocalPlayer
local MM=Rep:WaitForChild("MM") local remote=MM.Remotes.Action
local Catalog=require(MM.Shared.CreatureCatalog)
local Mutations=require(MM.Shared.MutationConfig)
local Factory=require(MM.Shared.CreatureFactory)
local Config=require(MM.Shared.GameConfig)
local state,selected,page=nil,nil,"Creatures"
local indexDetails=nil
local requestBusy=false
local controllerMode=Input.PreferredInput==Enum.PreferredInput.Gamepad
local pages={"Creatures","Lab","Mutate","Explore","Goals","Index","Style","Settings"}
local focusKeys={}
GuiService.AutoSelectGuiEnabled=true GuiService.GuiNavigationEnabled=true
local colors={ink=Color3.fromRGB(29,55,63),card=Color3.fromRGB(249,242,223),muted=Color3.fromRGB(105,126,127),mint=Color3.fromRGB(147,224,180),coral=Color3.fromRGB(248,163,140),lilac=Color3.fromRGB(192,175,234),gold=Color3.fromRGB(252,215,134)}
local gui=Instance.new("ScreenGui") gui.Name="MutantMayhemUI" gui.ResetOnSpawn=false gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling gui.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets gui.ClipToDeviceSafeArea=true gui.Parent=player:WaitForChild("PlayerGui")
pcall(function() game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList,false) end)
local function corner(o,r) local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,r or 16) c.Parent=o end
local function stroke(o) local s=Instance.new("UIStroke") s.Color=colors.ink s.Transparency=.88 s.Thickness=1 s.Parent=o end
local function text(parent,value,size)
	local t=Instance.new("TextLabel") t.BackgroundTransparency=1 t.Text=value t.TextSize=size or 16 t.TextColor3=colors.ink t.Font=Enum.Font.GothamMedium t.TextWrapped=true t.TextXAlignment=Enum.TextXAlignment.Left t.Size=UDim2.new(1,0,0,40) t.Parent=parent return t
end
local function button(parent,value,fn,color)
	local b=Instance.new("TextButton") b.Name=value:gsub("[^%w]",""):sub(1,40) b.Size=UDim2.new(1,0,0,48) b.BackgroundColor3=color or colors.mint b.Text=value b.TextColor3=colors.ink b.TextSize=15 b.Font=Enum.Font.GothamBold b.AutoButtonColor=true b.Selectable=true b.Parent=parent corner(b,12)
	b:SetAttribute("FocusKey",value:match("^([^•:]+)") or value) b.Active=true b.Activated:Connect(fn) return b
end
local top=Instance.new("Frame") top.Name="TopBar" top.Position=UDim2.fromOffset(14,12) top.Size=UDim2.new(1,-28,0,58) top.BackgroundColor3=colors.ink top.Parent=gui corner(top)
local title=text(top,"MUTANT\nMAYHEM",17) title.TextColor3=colors.mint title.Font=Enum.Font.GothamBlack title.Position=UDim2.fromOffset(16,7) title.Size=UDim2.new(.35,-12,1,-14)
local money=text(top,"Loading your lab…",17) money.TextColor3=colors.card money.TextXAlignment=Enum.TextXAlignment.Right money.Position=UDim2.new(.35,0,0,5) money.Size=UDim2.new(.65,-18,1,-10)
local status=text(gui,"",12) status.Name="SaveStatus" status.TextColor3=colors.ink status.Position=UDim2.fromOffset(18,73) status.Size=UDim2.new(1,-36,0,20)
local guide=Instance.new("TextButton") guide.Name="Onboarding" guide.Position=UDim2.fromOffset(16,99) guide.Size=UDim2.new(1,-32,0,48) guide.BackgroundColor3=colors.gold guide.TextColor3=colors.ink guide.Font=Enum.Font.GothamBold guide.TextSize=14 guide.TextWrapped=true guide.Parent=gui corner(guide,12)
local panel=Instance.new("Frame") panel.Name="Panel" panel.Position=UDim2.fromOffset(16,157) panel.Size=UDim2.new(0,420,1,-245) panel.BackgroundColor3=colors.card panel.Parent=gui corner(panel,18) stroke(panel)
local heading=text(panel,"YOUR CREATURES",19) heading.Font=Enum.Font.GothamBlack heading.Position=UDim2.fromOffset(18,10) heading.Size=UDim2.new(1,-74,0,35)
local function hide()
	page=nil panel.Visible=false
	if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(gui) then GuiService.SelectedObject=nil end
end
local close=button(panel,"×",hide,colors.coral) close.Name="Close" close.Size=UDim2.fromOffset(44,40) close.Position=UDim2.new(1,-52,0,8)
local content=Instance.new("ScrollingFrame") content.Name="Content" content.Position=UDim2.fromOffset(16,58) content.Size=UDim2.new(1,-32,1,-70) content.BackgroundTransparency=1 content.BorderSizePixel=0 content.ScrollBarThickness=3 content.AutomaticCanvasSize=Enum.AutomaticSize.Y content.CanvasSize=UDim2.new() content.Parent=panel
local layout=Instance.new("UIListLayout") layout.Padding=UDim.new(0,9) layout.SortOrder=Enum.SortOrder.LayoutOrder layout.Parent=content
local dock=Instance.new("ScrollingFrame") dock.Name="Navigation" dock.Position=UDim2.new(0,14,1,-72) dock.Size=UDim2.new(1,-28,0,62) dock.BackgroundColor3=colors.ink dock.BorderSizePixel=0 dock.ScrollBarThickness=3 dock.AutomaticCanvasSize=Enum.AutomaticSize.X dock.CanvasSize=UDim2.new() dock.ScrollingDirection=Enum.ScrollingDirection.X dock.Parent=gui corner(dock,16)
local dl=Instance.new("UIListLayout") dl.FillDirection=Enum.FillDirection.Horizontal dl.SortOrder=Enum.SortOrder.LayoutOrder dl.Padding=UDim.new(0,8) dl.VerticalAlignment=Enum.VerticalAlignment.Center dl.Parent=dock
local dp=Instance.new("UIPadding") dp.PaddingLeft=UDim.new(0,8) dp.PaddingRight=UDim.new(0,8) dp.Parent=dock
panel.SelectionGroup=true dock.SelectionGroup=true
local focusOutline=Instance.new("Frame") focusOutline.Name="ControllerFocus" focusOutline.BackgroundTransparency=1 focusOutline.Size=UDim2.new(1,6,1,6) focusOutline.Position=UDim2.fromOffset(-3,-3)
corner(focusOutline,14) local outline=Instance.new("UIStroke") outline.Color=colors.ink outline.Thickness=3 outline.Parent=focusOutline
local function keepVisible(object)
	local scroll=object and object:FindFirstAncestorWhichIsA("ScrollingFrame") if not scroll then return end
	local vertical=scroll==content local pos=scroll.CanvasPosition
	local itemStart=vertical and object.AbsolutePosition.Y or object.AbsolutePosition.X
	local itemSize=vertical and object.AbsoluteSize.Y or object.AbsoluteSize.X
	local viewStart=vertical and scroll.AbsolutePosition.Y or scroll.AbsolutePosition.X
	local viewSize=vertical and scroll.AbsoluteSize.Y or scroll.AbsoluteSize.X
	local delta=0 if itemStart<viewStart+6 then delta=itemStart-viewStart-6 elseif itemStart+itemSize>viewStart+viewSize-6 then delta=itemStart+itemSize-viewStart-viewSize+6 end
	local maximum=math.max(0,(vertical and scroll.AbsoluteCanvasSize.Y or scroll.AbsoluteCanvasSize.X)-viewSize)
	if vertical then scroll.CanvasPosition=Vector2.new(pos.X,math.clamp(pos.Y+delta,0,maximum)) else scroll.CanvasPosition=Vector2.new(math.clamp(pos.X+delta,0,maximum),pos.Y) end
end
GuiService:GetPropertyChangedSignal("SelectedObject"):Connect(function()
	local object=GuiService.SelectedObject
	if object and object:IsDescendantOf(gui) then
		if page and object.Parent==content then focusKeys[page]=object:GetAttribute("FocusKey") or object.Name end
		keepVisible(object)
	end
end)
local function connectSelection(preferred)
	local buttons={} for _,object in content:GetChildren() do if object:IsA("GuiButton") then table.insert(buttons,object) end end
	table.sort(buttons,function(a,b) return a.LayoutOrder<b.LayoutOrder end)
	local nav={} for _,object in dock:GetChildren() do if object:IsA("GuiButton") then table.insert(nav,object) end end
	table.sort(nav,function(a,b) return a.LayoutOrder<b.LayoutOrder end)
	local currentNav=nav[1] for _,b in nav do if b.Text==page then currentNav=b end end
	local target=buttons[1] or close
	for i,b in buttons do
		b.SelectionImageObject=focusOutline b.NextSelectionUp=buttons[i-1] or close b.NextSelectionDown=buttons[i+1] or currentNav
		b.NextSelectionLeft=currentNav b.NextSelectionRight=close
		if (b:GetAttribute("FocusKey") or b.Name)==preferred then target=b end
	end
	close.SelectionImageObject=focusOutline close.NextSelectionDown=target close.NextSelectionUp=currentNav close.NextSelectionLeft=target close.NextSelectionRight=currentNav
	for i,b in nav do
		b.SelectionImageObject=focusOutline b.NextSelectionLeft=nav[(i-2)%#nav+1] b.NextSelectionRight=nav[i%#nav+1]
		b.NextSelectionUp=target b.NextSelectionDown=target
	end
	if controllerMode then task.defer(function() if target.Parent and panel.Visible then GuiService.SelectedObject=target keepVisible(target) end end) end
end
local toast=text(gui,"",15) toast.Name="Notification" toast.AnchorPoint=Vector2.new(.5,1) toast.Position=UDim2.new(.5,0,1,-85) toast.Size=UDim2.new(.9,0,0,64) toast.BackgroundColor3=colors.ink toast.BackgroundTransparency=.04 toast.TextColor3=colors.card toast.TextXAlignment=Enum.TextXAlignment.Center toast.Visible=false toast.ZIndex=20 corner(toast,16)
local messageVersion=0
local function announce(message)
	if not message or message=="" then return end messageVersion+=1 local version=messageVersion toast.Text=message toast.Visible=true
	if state and not state.Settings.ReducedMotion then toast.BackgroundTransparency=.5 Tween:Create(toast,TweenInfo.new(.2),{BackgroundTransparency=.04}):Play() end
	task.delay(4,function() if messageVersion==version then toast.Visible=false end end)
end
local render
local steps={"1 / 4  Open your starter Pip → Place in lab","2 / 4  Let coins grow → Collect at your lab","3 / 4  Give Pip a new look → Mutate at the reactor","4 / 4  Protect your friends → Activate your free shield"}
local function updateHUD()
	if not state or state.Loading then return end
	money.Text=string.format("%s coins   •   %.1f / sec\n%d ready to collect",tostring(state.Coins),state.Rate,state.Stored)
	status.Text=(state.Demo and "STUDIO DEMO • progress resets after Play" or (state.SaveHealthy and "Progress saving automatically" or "Saving / connection interrupted • actions paused")).."  |  Lab "..tostring(state.Plot or "—")
	guide.Text=steps[state.Tutorial] or (state.Event.Active and "FESTIVAL LIVE  •  Your creatures earn 25% more" or string.format("Next festival %02d:%02d  •  Tap to visit",math.floor(state.Event.Remaining/60),state.Event.Remaining%60))
	player:SetAttribute("MMReducedMotion",state.Settings.ReducedMotion) player:SetAttribute("MMLowGraphics",state.Settings.LowGraphics)
end
local function send(action,arg)
	if requestBusy then return nil end requestBusy=true
	local ok,result=pcall(function() return remote:InvokeServer(action,arg) end) requestBusy=false
	if not ok then announce("Connection interrupted. Try again shortly.") return end
	if result.State and not result.State.Loading then state=result.State updateHUD() end
	announce(result.Message) if render and page then render() end return result
end
local function travelAction(destination,action,arg)
	local r=send("Go",destination) if r and r.Ok then send(action,arg) end
end
local function row(value,size) local t=text(content,value,size or 14) t.Size=UDim2.new(1,-5,0,44) return t end
local function show(name) page=name if name=="Index" then indexDetails=nil end panel.Visible=true render() end
local function choice() if not state then return end for _,c in state.Creatures do if c.Id==selected then return c end end return state.Creatures[1] end
local function preview(c)
	local frame=Instance.new("ViewportFrame") frame.Name="CreaturePreview" frame.Size=UDim2.new(1,0,0,145) frame.BackgroundColor3=colors.ink frame.Ambient=Color3.fromRGB(210,220,223) frame.LightColor=Color3.new(1,1,1) frame.LightDirection=Vector3.new(-1,-1,-2) frame.Parent=content corner(frame,14)
	local world=Instance.new("WorldModel") world.Parent=frame local model=Factory.Build(c.Archetype,c.Mutation,Vector3.new(0,0,0)) model.Parent=world
	local camera=Instance.new("Camera") camera.FieldOfView=35 camera.CFrame=CFrame.lookAt(Vector3.new(3,1.7,-6),Vector3.new(0,0,0)) camera.Parent=frame frame.CurrentCamera=camera
end
render=function()
	if not page then return end panel.Visible=true
	local preferred=focusKeys[page]
	for _,child in content:GetChildren() do if child~=layout then child:Destroy() end end
	heading.Text=string.upper(page)
	if not state then row("Setting up your laboratory…") return end
	if page=="Creatures" or page=="Mutate" then
		local c=choice() if c then selected=c.Id local def=Catalog[c.Archetype]
			row(def.Name.."  •  "..Mutations.Rarities[c.Mutation and c.Mutation.Rarity or 1],19).Size=UDim2.new(1,-5,0,32)
			if page=="Creatures" then button(content,c.Placed and "Store safely" or "Place in lab",function() travelAction("Lab","Place",selected) end)
			else row("Free-play odds: Common 55% • Uncommon 25% • Rare 12% • Epic 6% • Legendary 1.7% • Mythic 0.3%",12).Size=UDim2.new(1,-4,0,58)
				row("A roll replaces the current look. Rare+ guaranteed within 20 rolls. Pity: "..state.Misses.." / 20",12)
				button(content,"Mutate selected • 75 coins",function() travelAction("Reactor","Mutate",selected) end,colors.lilac)
			end
			preview(c)
			row(def.Personality.."  "..(c.Placed and "Living in your lab." or "Safe in your inventory."))
		end
		row("Choose a friend  •  "..#state.Creatures.." / 60 in inventory",13)
		for _,pet in state.Creatures do local b=button(content,(pet.Id==selected and "● " or "○ ")..Catalog[pet.Archetype].Name..(pet.Placed and "  •  earning" or "  •  stored"),function() selected=pet.Id render() end,pet.Id==selected and colors.gold or colors.mint) b:SetAttribute("FocusKey",pet.Id) end
	elseif page=="Lab" then
		row("LAB "..state.Plot.."  •  Tier "..state.Tier.." / 6",21)
		row(string.format("%d spaces  •  %.1f coins / second\n%d coins ready to collect",state.Capacity,state.Rate,state.Stored),16)
		button(content,"Collect lab income",function() travelAction("Lab","Collect") end)
		button(content,"Expand lab • "..state.UpgradeCost.." coins",function() travelAction("Lab","Upgrade") end,colors.gold)
		button(content,"Activate free 90-second shield",function() travelAction("Lab","Shield") end,colors.lilac)
		button(content,"Return to my lab",function() send("Go","Lab") end)
		row("MASTERY "..state.Prestige.." / 10. Tier 6 + 18,000 coins grants permanent +5% base income. Keep your creatures and lab.",13).Size=UDim2.new(1,0,0,65)
		button(content,"Earn mastery • 18,000 coins",function() travelAction("Lab","Prestige") end,colors.coral)
		row("Optional research dedication: "..state.Research..". Earn a permanent lab title; rank 5 adds gold trim. Costs cap at 10,000 coins.",13).Size=UDim2.new(1,0,0,65)
		button(content,"Fund research • "..state.ResearchCost.." coins",function() travelAction("Lab","Research") end,colors.gold)
	elseif page=="Explore" then
		row("A friendly island full of strange little friends.",18)
		button(content,"Discover a friend • 60 coins",function() travelAction("Meadow","Discover") end)
		button(content,"Visit Discovery Meadow",function() send("Go","Meadow") end)
		button(content,"Visit the Creature Club",function() send("Go","Showcase") end,colors.lilac)
		button(content,"Visit Mutation Festival",function() send("Go","Events") end,colors.coral)
		row("DNA RAIDS • optional, peaceful by default. Carry a sample home in 45 seconds. The original creature always stays with its owner.",13).Size=UDim2.new(1,0,0,70)
		button(content,"Sample nearby opted-in lab",function() send("Raid") end,colors.gold)
		button(content,"DEFEND • free pulse",function() send("Defend") end,colors.coral)
		if state.Carrying then row("CARRYING DNA • run home on foot! Fast travel is locked.",17) end
	elseif page=="Goals" then
		button(content,"Claim today's free gift",function() send("Daily") end,colors.gold)
		row("200 coins daily + up to 150 catch-up coins. No streak resets. Four visits this week unlock a glow badge.",13).Size=UDim2.new(1,0,0,58)
		row("Weekly visits: "..tostring(state.Weekly.Count or 0).." / 4")
		for _,q in state.Quests do row(string.format("%s\n%d / %d  •  %d coins%s",q.Name,math.min(q.Progress,q.Goal),q.Goal,q.Reward,q.Claimed and "  ✓" or ""),14).Size=UDim2.new(1,0,0,54) end
		button(content,"Claim completed goals",function() send("Missions") end)
		row("Discovery milestones: 3, 6, 9 and 12 species. Claim their rewards here.",13)
	elseif page=="Index" then
		local count=0 for _ in state.Discovered do count+=1 end row(count.." / 12 original species discovered",18)
		if indexDetails then
			local def=Catalog[indexDetails]
			button(content,"Back to all species",function() indexDetails=nil render() end)
			row(def.Name,21) preview({Archetype=indexDetails}) row(def.Personality,16)
			row(state.Discovered[tostring(indexDetails)] and "Discovered! Find your specimens in Creatures." or "Not discovered yet. Meet new friends at Discovery Meadow.",14)
			button(content,"Visit Discovery Meadow",function() send("Go","Meadow") end)
		else
			for i,def in Catalog do button(content,(state.Discovered[tostring(i)] and "✓ " or "○ ")..def.Name.."  •  View species",function() indexDetails=i render() end) end
		end
	elseif page=="Style" then
		row("AURORA LAB TRIM",21) row("A soft lavender canopy for your laboratory. Preview the collection at the Style Lab.",15)
		button(content,"Visit the Style Lab",function() send("Go","Shop") end,colors.lilac)
		button(content,state.Cosmetics.Aurora and "Toggle Classic / Aurora" or "Unlock Aurora • 500 coins",function() travelAction("Shop","Style") end,colors.gold)
		row("Current style: "..state.Style)
		local hasProducts=false
		for id in Config.Products do hasProducts=true button(content,"Review product in Roblox",function() travelAction("Shop","BuyProduct",id) end) end
		for id in Config.Passes do hasProducts=true button(content,"Review pass in Roblox",function() travelAction("Shop","BuyPass",id) end) end
		if not hasProducts then row("No Robux products are on sale in this build. All playable progression uses earned coins.",13).Size=UDim2.new(1,0,0,65) end
	elseif page=="Settings" then
		for _,s in {{"Peaceful","Peaceful mode"},{"ReducedMotion","Reduce motion"},{"LowGraphics","Low graphics"}} do button(content,s[2]..": "..(state.Settings[s[1]] and "ON" or "OFF"),function() send("Setting",s[1]) end,colors.mint) end
		row("Peaceful mode prevents DNA sampling. All creatures remain safe even when raids are enabled.",13).Size=UDim2.new(1,0,0,65)
		row("Controller: Y opens Lab; D-pad selects; A confirms; B returns to walking; LB/RB changes tabs. Keyboard: M opens Lab. Touch: swipe navigation.",13).Size=UDim2.new(1,0,0,85)
	end
	local order=0 for _,v in content:GetChildren() do if v:IsA("GuiObject") then order+=1 v.LayoutOrder=order end end
	connectSelection(preferred)
end
for order,name in pages do
	local b=button(dock,name,function() show(name) if name=="Style" then send("ShopView") end end,name=="Mutate" and colors.lilac or colors.card) b.Size=UDim2.fromOffset(101,48) b.LayoutOrder=order
end
guide.Activated:Connect(function() if not state then return end if state.Tutorial==1 then show("Creatures") elseif state.Tutorial==2 or state.Tutorial==4 then show("Lab") elseif state.Tutorial==3 then show("Mutate") else send("Go","Events") end end)
local function controllerAction(action,inputState)
	if GuiService.MenuIsOpen or Input:GetFocusedTextBox() then return Enum.ContextActionResult.Pass end
	if action=="MMClose" and not panel.Visible then return Enum.ContextActionResult.Pass end
	if inputState~=Enum.UserInputState.Begin then return Enum.ContextActionResult.Sink end
	controllerMode=true
	if action=="MMOpen" then show("Lab")
	elseif action=="MMClose" then hide()
	else local index=table.find(pages,page) or 1 show(pages[(index-1+(action=="MMNext" and 1 or -1))%#pages+1]) end
	return Enum.ContextActionResult.Sink
end
Actions:BindActionAtPriority("MMOpen",controllerAction,false,3000,Enum.KeyCode.ButtonY)
Actions:BindActionAtPriority("MMClose",controllerAction,false,3000,Enum.KeyCode.ButtonB)
Actions:BindActionAtPriority("MMNext",controllerAction,false,3000,Enum.KeyCode.ButtonR1)
Actions:BindActionAtPriority("MMPrevious",controllerAction,false,3000,Enum.KeyCode.ButtonL1)
Input.InputBegan:Connect(function(input,processed) if not processed and input.KeyCode==Enum.KeyCode.M then show("Lab") end end)
Input:GetPropertyChangedSignal("PreferredInput"):Connect(function()
	controllerMode=Input.PreferredInput==Enum.PreferredInput.Gamepad
	if controllerMode and page then connectSelection(focusKeys[page]) end
end)
Input.GamepadDisconnected:Connect(function()
	if #Input:GetConnectedGamepads()==0 then controllerMode=false GuiService.SelectedObject=nil end
end)
local function resize()
	local viewport=workspace.CurrentCamera.ViewportSize
	local portraitTouch=Input.TouchEnabled and viewport.X<=600
	panel.Size=UDim2.new(0,math.min(430,viewport.X-32),1,portraitTouch and -323 or -245)
	if Input.TouchEnabled and viewport.X>600 then dock.Position=UDim2.new(0,110,1,-62) dock.Size=UDim2.new(1,-220,0,54)
	elseif portraitTouch then dock.Position=UDim2.new(0,14,1,-150) dock.Size=UDim2.new(1,-28,0,62)
	else dock.Position=UDim2.new(0,14,1,-72) dock.Size=UDim2.new(1,-28,0,62) end
	if viewport.Y<500 then
		top.Position=UDim2.fromOffset(14,4) top.Size=UDim2.new(1,-28,0,50) status.Visible=false
		panel.Position=UDim2.fromOffset(16,62) panel.Size=UDim2.new(0,math.min(430,viewport.X-32),1,-126)
		content.Position=UDim2.fromOffset(16,48) content.Size=UDim2.new(1,-32,1,-56) heading.Position=UDim2.fromOffset(18,4) close.Position=UDim2.new(1,-52,0,4) guide.Visible=false
	else
		top.Position=UDim2.fromOffset(14,12) top.Size=UDim2.new(1,-28,0,58) status.Visible=true
		panel.Position=UDim2.fromOffset(16,157) content.Position=UDim2.fromOffset(16,58) content.Size=UDim2.new(1,-32,1,-70) heading.Position=UDim2.fromOffset(18,10) close.Position=UDim2.new(1,-52,0,8) guide.Visible=true
	end
end
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize) resize()
MM.Remotes.Update.OnClientEvent:Connect(function(packet)
	if packet.State and not packet.State.Loading then local first=state==nil state=packet.State updateHUD() if first then render() end end
	if packet.Message then announce(packet.Message) end
end)
render()
task.spawn(function() for _=1,20 do local result=send("State") if state then render() break end task.wait(1) end end)
