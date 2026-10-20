local D=require(script.Parent.PlayerDataService)
local I=require(script.Parent.InventoryService)
local A=require(script.Parent.AnalyticsService)
local M=require(game.ReplicatedStorage.MM.Shared.MutationConfig)
local E=require(game.ReplicatedStorage.MM.Shared.EconomyConfig)
local rng=Random.new()
local S={}
function S.Mutate(player,id)
	local d=D.Get(player) local c=I.Find(player,id) if not c then return false,"Choose one of your creatures." end
	if c.Locked then return false,"Pet bloqueado. Desbloqueie nos detalhes antes de mutar." end
	if d.Coins<E.MutationCost then return false,"Mutation needs "..E.MutationCost.." coins." end
	local seed=rng:NextInteger(1,2147483646) local result=M.Roll(seed,d.Misses)
	d.Coins-=E.MutationCost c.Mutation=result d.Rolls+=1 d.Misses=result.Rarity>=3 and 0 or d.Misses+1 d.Stats.Mutated+=1 d.Tutorial=math.max(d.Tutorial,4)
	A.Log("mutation_roll",player.UserId,{seed=seed,descriptor=result,roll=d.Rolls,cost=E.MutationCost})
	if d.Rolls==1 then A.Log("first_mutation",player.UserId) end
	return true,M.Rarities[result.Rarity].." mutation! "..(result.Pity and "Your free-play pity guarantee activated." or "A new look for your friend.")
end
return S
