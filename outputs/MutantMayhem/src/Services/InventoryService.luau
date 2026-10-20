local Data=require(script.Parent.PlayerDataService)
local E=require(game.ReplicatedStorage.MM.Shared.EconomyConfig)
local Config=require(game.ReplicatedStorage.MM.Shared.GameConfig)
local I={}
function I.Find(player,id)
	local d=Data.Get(player) if not d or type(id)~="string" then return end
	for _,c in d.Creatures do if c.Id==id then return c end end
end
function I.CountPlaced(d) local n=0 for _,c in d.Creatures do if c.Placed then n+=1 end end return n end
function I.Capacity(d) return E.Capacity(d.Tier,d.ExtraCapacity or 0) end
function I.Room(d) return #d.Creatures<Config.InventoryLimit end
function I.Place(player,id)
	local d=Data.Get(player) local c=I.Find(player,id) if not c then return false,"Choose your creature first." end
	if not c.Placed and I.CountPlaced(d)>=I.Capacity(d) then return false,"Lab full. Upgrade or store another creature." end
	c.Placed=not c.Placed if c.Placed then d.Tutorial=math.max(d.Tutorial,2) end return true,c.Placed and "Creature placed! Income is growing." or "Creature safely stored."
end
return I
