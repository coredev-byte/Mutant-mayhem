# World remaster audit — 2026-10-20

Recoverable source snapshot: 13b53c1d4987dc2f694e83cde01f9433fe28b855.
Development branch: feature/world-remaster. Main is not modified.

## Verified capabilities
GitHub MCP supports reading and writing this repository. No Blender MCP is exposed. Studio MCP lists CAOS MUTANTE, but does not establish cloud hosting; no changes or tests are performed against that session. No local shell, file access, browser, desktop control or local Blender is used for this remaster.
A GitHub-hosted runner will probe Blender and compile Luau. Runner execution is unverified until a successful run is recorded.

## Preserved contracts
MM_World.Plots contains Plot1..Plot12, with PlotId/OwnerId/OwnerName, PrimaryPart=Base, twelve direct child PadN parts with Slot attribute, Canopy and Sign.BillboardGui.TextLabel.
PlotService spawns at Base.CFrame*(0,5,-18). CreatureService renders at PadN.Position+(0,2.1,0). Base pivots are on radius 105, y=5.
Mutation range is 30 from (0,6,0); discovery range 35 from (165,5,0); shop range 35 from (0,5,165).
Teleports: reactor (0,8,20); meadow (165,9,0); events (0,9,-165); showcase (-165,9,0); shop (0,9,165).
Events.EventText is found recursively and updated each second. MMRing/Home and MMCreature tags belong to existing animation code.
Economic MaxTier=6, starting Tier=0. Five visual tiers will map [0,1,2,3,4,5,6] to [1,2,2,3,4,4,5], preserving costs, capacity and saved profiles.

## Source-based visual diagnosis
Current labs use one thin canopy, two rear pillars, solid flat back wall and undecorated platforms. Radius/plot clearances are usable, but there are no architectural tier changes.
The reactor is assembled from stacked disks and a large glass cylinder; existing rings already animate. Gardens consist of a repeated outer tree ring and sparse flower spheres. Other destinations have only disks, stools and showcase creatures.
Lighting uses high ambient values; material variation is weak. There is no imported mesh/PBR registry. No existing collision groups or custom model mesh pivots are defined by MapBuilder.
These are source observations, not a new live scene inspection. Actual screen-space aliasing, shadow behavior, streaming and physical navigation require Studio acceptance.

## Non-destructive integration design
Add an owned MM_Remaster subtree and plot VisualRemaster subtrees. Retain all gameplay instances, transforms, ownership, slots, markers, UI and creature scripts. Record original appearance/collision settings before hiding selected old architectural pieces; provide rollback. Do not rebuild or destroy MM_World.
Use stable local coordinates, additive decoration without collisions/touch/query, bounded per-zone batches and server-driven visual tiers. Keep an unobstructed entry and use the existing floor as collision support.
Blender modular exports are optional replacements with no fabricated Roblox IDs. The primitive fallback remains functional while export import is pending.
