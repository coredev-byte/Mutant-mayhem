-- Synthetic active-player strategy using the exact shipped config. Not player telemetry.
local Shared=game.ReplicatedStorage.MM.Shared
local E=require(Shared.EconomyConfig)
local M=require(Shared.MutationConfig)
local Catalog=require(Shared.CreatureCatalog)
local rows={}
for _,collectEvery in {30,90} do
	local d={Coins=100,Stored=0,Tier=0,Prestige=0,Research=0,Creatures={{Archetype=1,Rarity=1}},Rolls=0,Misses=0}
	local milestones={} local spent={discovery=0,upgrade=0,mutation=0,prestige=0,research=0} local earned=0
	for sec=1,360000 do
		local rate=0 for _,c in d.Creatures do rate+=E.Rate(Catalog[c.Archetype].Base,M.Multipliers[c.Rarity],d.Prestige) end
		d.Stored=math.min(rate*E.StorageSeconds,d.Stored+rate*(sec%900<180 and 1.25 or 1))
		if sec%collectEvery==0 then
			local n=math.floor(d.Stored) d.Stored-=n d.Coins+=n earned+=n
			if #d.Creatures<E.Capacity(d.Tier) and d.Coins>=E.DiscoverCost then d.Coins-=E.DiscoverCost spent.discovery+=E.DiscoverCost table.insert(d.Creatures,{Archetype=#d.Creatures+1,Rarity=1})
			elseif d.Tier<E.MaxTier and d.Coins>=E.UpgradeCost(d.Tier) then local cost=E.UpgradeCost(d.Tier) d.Coins-=cost spent.upgrade+=cost d.Tier+=1
			elseif d.Tier==E.MaxTier and d.Prestige<10 and d.Coins>=E.PrestigeCost then d.Coins-=E.PrestigeCost spent.prestige+=E.PrestigeCost d.Prestige+=1
			elseif d.Prestige==10 and d.Coins>=E.ResearchCost(d.Research)+E.MutationCost then local cost=E.ResearchCost(d.Research) d.Coins-=cost spent.research+=cost d.Research+=1 end
		end
		if sec%180==0 and d.Coins>=E.MutationCost then local c=d.Creatures[(d.Rolls%#d.Creatures)+1] local desc=M.Roll(75000+sec,d.Misses) d.Misses=desc.Rarity>=3 and 0 or d.Misses+1 c.Rarity=desc.Rarity d.Rolls+=1 d.Coins-=E.MutationCost spent.mutation+=E.MutationCost end
		if sec==300 or sec==900 or sec==1800 or sec==3600 or sec==36000 or sec==360000 then table.insert(milestones,{seconds=sec,coins=math.floor(d.Coins),tier=d.Tier,pets=#d.Creatures,prestige=d.Prestige,research=d.Research,rolls=d.Rolls,rate=math.floor(rate*100)/100}) end
		if sec%10000==0 then task.wait() end
	end
	table.insert(rows,{collectEvery=collectEvery,milestones=milestones,sinks=spent,grossIncome=earned})
end
local distribution={0,0,0,0,0,0}
local deterministic=true local pity=true
for seed=1,100000 do
	local a=M.Roll(seed,0) distribution[a.Rarity]+=1
	if seed<1000 then local b=M.Roll(seed,0) for k,v in a do if b[k]~=v then deterministic=false end end if M.Roll(seed,19).Rarity<3 then pity=false end end
	if seed%10000==0 then task.wait() end
end
return {simulations=rows,mutationSamples=100000,distribution=distribution,deterministic=deterministic,pityAt20=pity,weightsTotal=10000}
