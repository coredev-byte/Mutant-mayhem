local C=require(game.ReplicatedStorage.MM.Shared.GameConfig)
local E={}
function E.State(now)
	now=now or os.time() local phase=now%C.EventPeriod local active=phase<C.EventDuration
	return {Active=active,Remaining=active and C.EventDuration-phase or C.EventPeriod-phase,Multiplier=active and 1.25 or 1,Name="Mutation Festival"}
end
return E
