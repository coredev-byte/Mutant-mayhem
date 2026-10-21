# CAOS MUTANTE — Physics + sky + world backdrop v3

**Status:** applied directly through MCP to Roblox Studio `CAOS MUTANTE` (`placeId: 129621048489588`). Last observed **Edit** state. Not published, not verified as a separate local `.rbxl`.

## Requested and implemented
- **Solid collisions** for objects that should block the player: 62 trees (trunk-only cylinders), 47 rocks, eight wooden benches, eight garden lanterns, two bridge guardrails. Total **127 anchored invisible hitboxes**, marked `MM_PhysicalHitbox`, with `CanCollide=true` and `CanQuery=true`. The existing bridge deck is also collidable.
- **125 hitboxes are children of their owning models**, so model pivots and repositioning carry the collision geometry. Two guardrail hitboxes remain under `Workspace.MM_RealLandscape_v2.MM_SolidCollisions_v3`.
- Vegetation that should move/feel soft (leaves, flowers, ferns, grass) remains traversable; mountains are background-only with no collisions.
- Removed accidental preview assets `Workspace.MM_MountainStaging_v3` from the playable scene; archived at `ServerStorage.MM_MountainStaging_v3_Archived`.
- Added `Workspace.MM_DistantScenery_v3`: **16 mesh mountains** arranged ~435–540 studs from center, outside the playable island. Source mesh from Roblox Creator Store asset `79754458690074`, recolored cool blue-gray, with no scripts or collisions and with shadows disabled.
- Replaced broken sunset skybox (noticeable texture seam and apparent doubled sun) with **MM_CloudySunsetSky_v3** using consistent `SkySanDiego` images from Creator Store asset `9779104328`. Turned off celestial overlays to avoid duplicate sun. Enhanced `Terrain.Clouds`, atmosphere, gentle sunrays and late afternoon lighting.
- Desaturated the decorative `MM_World.Ocean` water tint to RGB(79,132,151), .075 reflectance, and the `IslandRim` to RGB(45,76,78) / Slate, retaining ground/ocean collisions.
- Created `ServerStorage.MM_PhysicsSkyBackdropV3`, idempotent rebuild/check source under `remaster/studio/MM_PhysicsSkyBackdropV3.luau`.

## Backups and safety
- Full pre-collision visual and sky backup at `ServerStorage.MM_Backup_20261020_PreCollisionSky_v3`: clone of `MM_RealLandscape_v2`, 4 lighting effects, copied ground/island, ocean and rim, lighting attributes, and removed problematic sky asset.
- Dedicated collision attachment rollback: `ServerStorage.MM_SolidCollisionAttachBackup_v3` (127 original collider parts in one folder).
- Earlier `ServerStorage.MM_GardenBackup_20261021_BeforeRealAssets` remains untouched.
- Crucially **never call `MapBuilder.Build()`** in the populated place; it would destroy and rebuild `MM_World`.
- After a Play-to-Edit transition, `Island`, `Ocean`, `IslandRim` were unexpectedly absent. They were restored from backup; the module's `RestoreGround()` and `Check()` now detect/repair this specific issue. A further controlled Play→Edit cycle confirmed all three pieces remained present after stopping.

## Tests
- Roblox Studio MCP: connected to correct CAOS MUTANTE place.
- Pathfinder **12/12 approaches to labs** succeeded while collider hitboxes were present. Labs remained **12**, reactor and welcome spawn present.
- A set of actual `workspace:Raycast` tests hit the respective 3D collider of trees, rocks, benches, lanterns and bridge rails. All are collidable.
- Studio Play test found **127 hitboxes** and **16 mountain meshes**, with Island/Ocean/Rim all present and one test player.
- Client **120-frame** measurement after sky/backdrop before final cleanup: approximately **59.98 average FPS**, max frame ~18.7 ms, and ~1237 MB Stats memory in Studio. Not representative of mobile nor production load.
- Images captured with Roblox Studio MCP show final cloudy mauve sky, distant mountain ring, intact labs and cherry gardens.
- A direct humanoid walking-through-object test was inconclusive because external command execution did not produce reliable character movement. The raycast + `CanCollide` checks confirm the implemented static collider geometry, not exhaustive avatar collision coverage.

## Current structure
```text
Workspace
  MM_World
    Island / Ocean / IslandRim (restored and present)
    Plots (12)
    Reactor...
  MM_RealLandscape_v2
    Bosque_1 ... Bosque_4
    RiachoPonteJaponesa
    MM_SolidCollisions_v3 (2 bridge guardrails)
    [125 model-child hitboxes]
  MM_DistantScenery_v3 (16 low-poly mesh mountains)
Terrain
  MM_PastelClouds_v3
Lighting
  MM_CloudySunsetSky_v3
  MM_SunRays_v3
ServerStorage
  MM_PhysicsSkyBackdropV3
  MM_Backup_20261020_PreCollisionSky_v3
  MM_SolidCollisionAttachBackup_v3
  MM_MountainStaging_v3_Archived
```

## Unfinished / action required
1. **Save a new native `.rbxl`** manually via Roblox Studio File → Save to File As (e.g. `CAOS-MUTANTE-PhysicsSky-v3.rbxl`) before closing. No save-as was performed or confirmed by MCP.
2. Exercise collision on real character from different directions and on mobile; adjust trunk/rock/bench collider shapes for feel as needed.
3. Measure FPS with multiple players/pets on mobile; 120 frames in one Studio client is only a smoke test.
4. The user's ten original GardenKit GLBs remain pending direct Studio 3D Importer validation; current visual meshes originate from inspected Creator Store assets.
5. Do not publish until gameplay is reviewed and a separate native file saved.
