--!strict
local E={MutationCost=75,DiscoverCost=60,StorageSeconds=600,MaxTier=6,PrestigeCost=18000}
function E.Capacity(tier: number,extra: number?): number return math.min(12,2+tier+(extra or 0)) end
function E.UpgradeCost(tier: number): number return 150+150*tier+100*tier*tier end
function E.ResearchCost(rank: number): number return 2500+250*math.min(rank,30) end
function E.Rate(base: number,multiplier: number,prestige: number): number
	return base*multiplier*(1+math.min(prestige,10)*0.05)
end
return E
