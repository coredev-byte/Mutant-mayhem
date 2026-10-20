local D=require(script.Parent.PlayerDataService)
local I=require(script.Parent.InventoryService)
local A=require(script.Parent.AnalyticsService)
local Event=require(script.Parent.EventService)
local E=require(game.ReplicatedStorage.MM.Shared.EconomyConfig)
local Catalog=require(game.ReplicatedStorage.MM.Shared.CreatureCatalog)
local M=require(game.ReplicatedStorage.MM.Shared.MutationConfig)
local S={}
function S.Rate(d)
	local rate=0 for _,c in d.Creatures do if c.Placed then rate+=E.Rate(Catalog[c.Archetype].Base,M.Multipliers[c.Mutation and c.Mutation.Rarity or 1],d.Prestige) end end return rate
end
function S.Tick(player,dt)
	local d=D.Get(player) if not d or not D.Editable(player) then return end
	local rate=S.Rate(d) d.Stored=math.min(rate*E.StorageSeconds,d.Stored+rate*math.min(dt,5)*Event.State().Multiplier)
end
function S.Collect(player)
	local d=D.Get(player) local amount=math.floor(d.Stored) if amount<1 then return false,"Your creatures are making coins. Come back in a moment." end
	d.Stored-=amount d.Coins+=amount d.Stats.Collected+=amount d.Tutorial=math.max(d.Tutorial,3)
	A.Log("economy_source",player.UserId,{kind="collect",amount=amount}) return true,"Collected "..amount.." coins!"
end
function S.Upgrade(player)
	local d=D.Get(player) if d.Tier>=E.MaxTier then return false,"Your lab is fully expanded." end
	local cost=E.UpgradeCost(d.Tier) if d.Coins<cost then return false,"Upgrade needs "..cost.." coins." end
	d.Coins-=cost d.Tier+=1 A.Log("plot_upgrade",player.UserId,{tier=d.Tier,cost=cost}) return true,"Lab expanded! More room for friends."
end
function S.Research(player)
	local d=D.Get(player) local cost=E.ResearchCost(d.Research)
	if d.Coins<cost then return false,"Research dedication needs "..cost.." coins." end
	d.Coins-=cost d.Research+=1 if d.Research>=5 then d.Cosmetics.ResearchTrim=true end
	A.Log("economy_sink",player.UserId,{kind="research",amount=cost,rank=d.Research})
	return true,"Research dedication "..d.Research.."! A permanent cosmetic lab title."
end
function S.Prestige(player)
	local d=D.Get(player) if d.Tier<E.MaxTier or d.Coins<E.PrestigeCost then return false,"Reach lab tier 6 and save 18,000 coins to prestige." end
	if d.Prestige>=10 then return false,"Mastery complete!" end
	d.Coins-=E.PrestigeCost d.Prestige+=1 -- Keep creatures and lab; permanent capped 5% mastery.
	A.Log("prestige",player.UserId,{level=d.Prestige}) return true,"Mastery +1! Permanent +5% base income."
end
return S
