-- Visual progression only; economy remains in Shared/EconomyConfig.
local tiers={1,2,2,3,4,4,5}
return function(backendTier)
 if type(backendTier)~="number" or backendTier~=backendTier then return 1 end
 return tiers[math.clamp(math.floor(backendTier),0,6)+1]
end
