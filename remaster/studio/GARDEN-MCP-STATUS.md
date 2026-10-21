# CAOS MUTANTE — Garden MCP preview (20 Oct 2026)

## What was verified in the live Roblox Studio (place 129621048489588)
- MCP connected to CAOS MUTANTE in Edit mode.
- A pre-change in-Studio backup was created at `ServerStorage.MM_ArtBackup_20261020_PreGardenRefinement`. Contains a cloned `MM_World` (885 descendants) and copies of 4 lighting children/lighting property attributes.
- The original `workspace.MM_World` remains with 885 descendants after changes. It still has 12 plots, 144 pads, reactor and spawn.
- Added additive, removable `workspace.MM_LandscapeGarden_v1` (1062 descendants, 1022 BaseParts), including four sakura gardens, irregular vegetation, rocks, flowers, detail paths, cosmetic stream and walkable bridge.
- Added editable reusable generator at `ServerStorage.MM_LandscapeGardenBuilderV1` and committed the source under `remaster/studio/MM_LandscapeGardenBuilderV1.luau`.
- Updated ambient lighting to warm late-afternoon values (ClockTime 17.1, Brightness 2.3, Atmosphere Density .22, Bloom Intensity .18, etc.). Original lighting is copied in the backup folder.
- Tested in Studio Play (one test player). Game server emitted `server_ready`, demo session started, starter creature acquired.
- Four independent Pathfinder tests returned Success after final changes: Garden, Meadow, Shop and Bridge destination. This does NOT establish the bridge was walked over: the initial route across the bridge went around the deck.
- Actual Studio MCP screenshots were inspected during work. GitHub source contains no fabricated images or mesh IDs.
- After playtesting, Studio was returned to Edit mode.

## Critical caveats
- GardenKit ZIP (`MutantMayhem-GardenKit-v1.zip`), `MAP-ART-STATUS.md`, `art/environment/README.md` and 10 supposed GLBs were not available in this conversation runtime or GitHub branches examined. Therefore no GardenKit GLB/Blender import took place.
- The `feature/world-remaster` branch includes a Blender generator/recipe and README, but not committed finished mesh exports. The referenced Blender render was not accepted as a Roblox screenshot.
- The visible preview is made of Roblox primitive parts; silhouettes and terrain layering are preliminary, not photorealistic/production-quality.
- No FPS/mobile memory metrics; no complete 12-player, 12-lab interactions, rewards, mutation or purchases acceptance.
- A new native `.rbxl` was not saved automatically: this MCP does not expose a safe explicit Save As for the user's Windows Studio. Before closing Studio, manually use File > Save to File As to create a new native checkpoint.

## Preservation and rollback
- No `MapBuilder.Build()` call was made. IMPORTANT: this function destroys and rebuilds `MM_World`.
- Existing `workspace.MM_World`, gameplay scripts, plot/slot ownership, reactor, events and remotes were not edited during landscaping.
- Delete `workspace.MM_LandscapeGarden_v1` to remove just the new geometry and effects, and restore lighting attributes from `ServerStorage.MM_ArtBackup_20261020_PreGardenRefinement` if a rollback is desired.
- The standalone module currently needs an existing MM_World. `Build()` does nothing if an instance named MM_LandscapeGarden_v1 already exists; `Finish()` is idempotent for extra vegetation.

## Next steps
1. Save the place as a **new .rbxl** manually.
2. Upload/provide the missing GardenKit ZIP, or provide a direct accessible binary artifacts location and a supported 3D-import workflow.
3. Review geometry collision/performance, perform a character crossing test, test all interactive systems and 12 spawns, check mobile memory/FPS.
4. Replace/progress native preview with validated MeshParts only after comparing GLB bounding boxes/materials/orientation in Studio. Avoid overlay stacking.
