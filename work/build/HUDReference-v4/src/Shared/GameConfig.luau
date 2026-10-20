--!strict
return {
	Title = "MUTANT MAYHEM", Schema = 2, MaxPlayers = 12,
	StudioDemo = true, DataStoreName = "MutantMayhem_Player_v2",
	AutosaveSeconds = 45, LeaseSeconds = 180,
	InventoryLimit = 60, StarterCoins = 100,
	SpawnProtection = 90, TheftCooldown = 120,
	OwnershipTheftEnabled = false, -- Requires verified durable cross-profile escrow before release.
	EventPeriod = 900, EventDuration = 180,
	Products = {}, -- [real developer product ID] = {Kind="Coins",Amount=500}
	Passes = {}, -- [real game pass ID] = {Kind="VIP"} or {Kind="Capacity",Amount=2}
}
