# MUTANT MAYHEM world remaster

Development branch: `feature/world-remaster`. Main snapshot:
`13b53c1d4987dc2f694e83cde01f9433fe28b855`.

## What is implemented
- A 97-component modular laboratory kit with five cumulative architectural stages.
- Existing backend levels 0–6 map to visual tiers 1, 2, 2, 3, 4, 4, 5. Costs and unlock rules are unchanged.
- A 299-component world overlay: reactor buttresses/crown, plaza edges/seating, planted discovery beds, social backdrop, event framing, shop canopy and labelled future-region foundations.
- Reversible server integration for all 12 existing plot transforms. Existing pads, terminals, signs, ownership, collisions and teleports remain the gameplay authority.
- Distance culling for small plant/stone details, with a shorter distance in the existing low-graphics setting. Structural elements stay visible.
- Restrained daylight adjustments with rollback. Existing reactor/pet animation remains active.
- One shared recipe drives both the Blender mesh exports and Roblox primitive placement.
- Original UI, creatures, persistence, economy and raid logic are preserved.

## Cloud build
The Actions workflow runs on a GitHub-hosted Ubuntu runner. It installs Blender, compiles all Luau sources, tests reserved clearances and progression, generates real .blend, .glb, .fbx and PNG files, then verifies export integrity and records actual geometry counts.

Verified outputs are saved permanently under `remaster/generated/` on the development branch by the cloud job. The manifest records the exact source commit and file hashes. A concurrent branch update aborts asset saving instead of overwriting newer work. Main is never targeted.

The same outputs are also available as `world-remaster-cloud-artifacts` on the successful Actions run (90-day artifact retention). The committed recipe and generator reproduce them.

Generated files:
- `MutantMayhem_Environment.blend`: five lab collections, world overlay, preserved-layout reference stage and render setup.
- `LAB_Tier_1..5.glb/.fbx`: complete visual kit for each stage, origin at the original plot Base transform.
- `WORLD_Overlay.glb/.fbx`: world-space decorative geometry.
- Lab entrance renders for all five tiers, a tier-one interior render, manifest and capabilities report.

## Studio integration and acceptance
The source overlay is enabled by Bootstrap on this branch. Set `workspace.MM_World.MMRemasterDisabled` attribute to true **before starting a server** to opt out. Do not run MapBuilder.Build against a populated edit session; that existing function rebuilds the whole owned world.

1. Sync the branch using the existing Rojo project into a recoverable Studio copy.
2. Run `remaster/tests/studio_acceptance.luau` in edit mode on that disposable copy.
3. Playtest all 12 spawns, all 12 pads, every backend upgrade, release/reassignment, styles, collect/mutate/discover, raid/defend/delivery, teleports and event timer.
4. Inspect entrance/interior/third-person/mobile views, gaps, clipping, shadows and existing tree/gateway intersections.
5. Capture before/after screenshots and measure frame time, memory and draw calls with pets and multiplayer load.
6. Only after validation, import the FBX/GLB models with the Studio 3D Importer. Verify one stud per authored unit and the origin at Base.CFrame. Do not import the reference stage as gameplay geometry.
7. Uploaded mesh IDs must come from actual imports. Replace primitive visual overlays with validated mesh instances in a separate reviewed change; never stack both versions.

## Important limits
Roblox source currently uses primitive equivalents of the recipe. Blender exports have controlled bevels and weighted normals; those bevels are **not** magically transferred to Roblox before mesh import. No asset IDs are invented.

Generated visuals are noncolliding/nonqueryable and add no interactive machines, functional future teleports or monetization. Existing paths and gameplay colliders remain unchanged. Outer gateway foundations are labelled EM BREVE.

No Roblox cloud runtime or remote hosting of the connected Studio instance has been verified. Actual Studio import, gameplay, mobile FPS and image acceptance remain pending. Cloud compilation, geometric clearances and export tests do not substitute for engine testing.

## Recovery
Keep the main snapshot above. `WorldRemaster.Rollback(workspace.MM_World)` removes only owned visual folders and restores original transparency/lighting. Disable the overlay before the next server starts to keep it off. Player data is never read or written by the remaster module.

## Technical references
- [Blender glTF export](https://docs.blender.org/manual/en/4.0/addons/import_export/scene_gltf2.html)
- [Roblox parts](https://create.roblox.com/docs/parts)
- [Roblox model pivots](https://create.roblox.com/docs/reference/engine/classes/Model)
