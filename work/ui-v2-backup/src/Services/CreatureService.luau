local Http=game:GetService("HttpService")
local Data=require(script.Parent.PlayerDataService)
local I=require(script.Parent.InventoryService)
local Plot=require(script.Parent.PlotService)
local A=require(script.Parent.AnalyticsService)
local F=require(game.ReplicatedStorage.MM.Shared.CreatureFactory)
local E=require(game.ReplicatedStorage.MM.Shared.EconomyConfig)
local C={}
function C.Add(player,index)
	local d=Data.Get(player) if not I.Room(d) then return nil end
	local c={Id=Http:GenerateGUID(false),Archetype=index,Placed=false,Mutation=nil}
	table.insert(d.Creatures,c) d.Discovered[tostring(index)]=true d.Stats.Found+=1
	A.Log("creature_discovered",player.UserId,{archetype=index}) return c
end
function C.Starter(player)
	local d=Data.Get(player) if #d.Creatures==0 then C.Add(player,1) A.Log("first_creature",player.UserId) end
end
function C.Discover(player)
	local d=Data.Get(player) if not I.Room(d) then return false,"Inventory full." end
	if d.Coins<E.DiscoverCost then return false,"Discovery needs "..E.DiscoverCost.." coins." end
	local index=1 for i=1,12 do if not d.Discovered[tostring(i)] then index=i break end index=Random.new():NextInteger(1,12) end
	d.Coins-=E.DiscoverCost C.Add(player,index) A.Log("economy_sink",player.UserId,{kind="discovery",amount=E.DiscoverCost})
	return true,"New friend discovered! Open Creatures to place them."
end
function C.Mood(player,mood,duration)
	local plot=Plot.Assigned[player] local pets=plot and plot:FindFirstChild("Creatures") if not pets then return end
	for _,model in pets:GetChildren() do model:SetAttribute("Mood",mood) end
	task.delay(duration,function() if pets.Parent then for _,model in pets:GetChildren() do if model:GetAttribute("Mood")==mood then model:SetAttribute("Mood","Idle") end end end end)
end
function C.Render(player)
	local plot=Plot.Assigned[player] local d=Data.Get(player) if not plot or not d then return end
	local old=plot:FindFirstChild("Creatures") if old then old:Destroy() end
	local folder=Instance.new("Folder") folder.Name="Creatures" folder.Parent=plot local n=0
	for _,c in d.Creatures do if c.Placed then n+=1 local pad=plot:FindFirstChild("Pad"..n)
		if pad then local model=F.Build(c.Archetype,c.Mutation,pad.Position+Vector3.new(0,2.1,0))
			model.Name=c.Id model:SetAttribute("OwnerId",player.UserId) model:SetAttribute("CreatureId",c.Id) model.Parent=folder end
	end end
	for slot=1,12 do plot["Pad"..slot].Color=slot<=I.Capacity(d) and Color3.fromRGB(133,207,170) or Color3.fromRGB(178,165,217) end
end
return C
