--!strict
local M = {}
M.Rarities = {"Common","Uncommon","Rare","Epic","Legendary","Mythic"}
M.Weights = {5500,2500,1200,600,170,30}
M.Multipliers = {1,1.15,1.35,1.6,1.9,2.2}
M.PityAt = 20
M.Palette = {{145,224,180},{252,166,143},{176,162,239},{122,208,234},{245,213,129},{247,161,202}}
-- The seed and every returned descriptor are stored with the creature.
function M.Roll(seed: number, misses: number)
	local rng = Random.new(seed)
	local n, cumulative, rarity = rng:NextInteger(1,10000),0,1
	for i,w in M.Weights do cumulative += w if n <= cumulative then rarity=i break end end
	local pity = misses >= M.PityAt-1 and rarity < 3
	if pity then rarity=3 end
	return {Seed=seed,Version=1,Rarity=rarity,Palette=rng:NextInteger(1,6),
		Horns=rng:NextInteger(0,2),Eyes=rng:NextInteger(2,3),Wings=rng:NextInteger(0,1),
		Tail=rng:NextInteger(0,1),Scale=rng:NextInteger(90,115)/100,
		Material=rng:NextInteger(1,3),Sparkles=rarity>=4,Pity=pity}
end
return M
