# MUTANT MAYHEM — playable vertical slice

Built and tested in the connected Roblox Studio on 18 October 2026. This is a working local multiplayer slice, not a completed production release. The full original brief is larger than the features verified here.

## Play

Open `MutantMayhem.rbxl` in Roblox Studio and press Play. The build is already installed in the connected Studio project as well. Studio was left in Edit mode with the default viewport restored.

1. You receive a lab, 100 coins, and Pip immediately.
2. Press **Place in lab**. Pip begins earning coins.
3. Open **Lab** and collect the stored income. Storage holds ten minutes of base production.
4. Open **Mutate**, choose Pip, and spend 75 earned coins. The action transports you to the reactor, where the server verifies proximity and ownership.
5. Open **Goals** to claim the daily gift; expand your lab for 150 coins and discover another friend in **Explore** for 60 coins.
6. Use the free shield. Explore the collection index, Style Lab, events, and optional DNA raids.

**This unpublished place uses an explicitly labeled Studio demo profile. Progress resets when Play stops.** Published places use the DataStore path; they do not silently fall back to demo data when a load fails.

## What exists

- Original pastel island with 12 numbered labs, radial paths, reactor chamber and animated rings, discovery meadow, festival plaza, creature club, and cosmetic shop area.
- Twelve original modular creature archetypes: Pip, Curl, Mallow, Sprig, Tock, Orbit, Peb, Fizz, Puddle, Nimbus, Lumen, and Crown.
- Deterministic server-generated mutation descriptors: rarity, seed, palette, horns, eye count, wings, tail, size, material, and rare glints. The full descriptor is saved.
- Shared procedural idle/hover, happy, sleep, reaction, mutation, blink, squash, and secondary-motion code. These are procedural part animations, not imported skeletal animation clips.
- Server-owned placement, collection, mutation, discoveries, six lab expansion tiers, ten capped mastery levels, and optional cosmetic research dedications.
- Daily gifts with capped catch-up, rotating daily objectives, discovery milestones, a visible Weekly Explorer lab badge, and a deterministic 15-minute event cycle.
- Eight UI sections: Creatures, Lab, Mutate, Explore, Goals, Index, Style, Settings. Scrollable content and navigation, creature viewport previews, notifications, onboarding, peaceful mode, reduced motion, and reduced graphics.
- Opt-in **DNA raids** with a carried sample, speed reduction, defender alarm and free defense action, cooldown, shield, movement checks, timeout, and disconnect cleanup. A successful run creates a new unique specimen. The defender's original is retained.
- Versioned profiles with validation, migration, UpdateAsync session leases, periodic saves, retries, pending-write protection, retained departure retries, lease-takeover guards, and idempotent receipt records stored with the grant. Successful progression actions wait for a save before returning success in durable mode; action saves are limited to one every two seconds per player.
- Configurable MarketplaceService pass/product adapters. The IDs are intentionally empty; no Robux product is currently offered.
- Structured `[MM]` analytics logs and a bounded 200-event server buffer.

## Project layout

| Studio path | Local source |
|---|---|
| ReplicatedStorage.MM.Shared | src/Shared |
| ReplicatedStorage.MM.Remotes | Action RemoteFunction; Update RemoteEvent |
| ServerScriptService.MM.Services | src/Services — 13 service modules |
| ServerScriptService.MM.Bootstrap | src/Bootstrap.server.luau |
| ServerScriptService.MM.MapBuilder | src/MapBuilder.luau |
| StarterPlayer.StarterPlayerScripts.MM | src/Client — UI and animation controllers |
| Workspace.MM_World | 923 edit-time descendants; 12 plots |
| ServerStorage.MM_OriginalContent | Preserved previous baseplate/utilities and superseded lighting effects |

The previous workspace content was archived instead of deleted. Archived executable scripts were disabled, with their previous Enabled value recorded in `MM_OriginalEnabled`. This is a content archive, not a complete settings rollback. The new place was saved separately in this deliverable folder.

## Validation

See `QA.md`, `CHECKLIST.md`, and the raw results in `tests/`. Screenshots are actual Studio captures, not concept renders.

The two-client interaction test and eight-client correctness test passed. The latter used eight distinct labs and 64 unique specimens, verified placement/daily/settings requests from every client, and checked an actual defender disconnect. Local request latency was high (969 ms mean, 2,976 ms maximum), so this is not a performance acceptance pass. Mutation determinism and pity passed over 100,000 sampled baseline seeds and 999 pity checks. Expanded persistence tests exercised a memory-only fault-injection adapter. They do **not** establish that published DataStores or real purchases are working.

## Release blockers and next steps

1. Publish a **private test place** and verify durable leave/rejoin, lease contention, crash recovery, failed autosaves, and purchases using owner-created IDs. Set the platform's maximum players to 12 in the experience configuration. The current platform property remained 30 and is read-only through the connector; the game itself admits only 12 allocated labs.

   Confirmed progression actions now save before acknowledging success. Uncollected passive income and other session-only state can still be lost after an abrupt process exit. An outage that lasts through shutdown can leave a pending, unconfirmed action unsaved. Real backend and reconnect behavior are not verified yet.
2. Connect Blender MCP. No Blender MCP was exposed and plugin discovery returned no match. Current creatures are original Roblox primitive models. No `.blend`, imported mesh, authored texture atlas, collision proxy export, or skeletal animation library is claimed.
3. Permanent theft remains disabled. Implement and verify a durable transfer journal/escrow and recovery protocol across both profiles before allowing the defender to lose ownership. DNA raids provide the tested non-destructive alternative in this build.
4. Test a real full 12-player server, physical mid-range phones, packet loss, and native controller input. Selection links, scrolling, focus restoration, Y/B and shoulder bindings are implemented; Return/arrow UI activation passed. The connector sends ButtonA as a keyboard event, so native controller acceptance remains pending. See `tests/controller-and-weekly-results.md`.
5. Finish custom sound design, audio assets, VIP presentation, richer map dressing, and production art polish. The weekly reward now creates a visible lab badge and passed its fourth-claim test.
6. Connect a durable analytics sink and compute retention/conversion only from real traffic. No D1/D7 or revenue results exist yet.

## References used for implementation

The profile/receipt design follows Roblox's [player data and purchasing guidance](https://create.roblox.com/docs/cloud-services/data-stores/player-data-purchasing): hold a session lock and acknowledge a purchase only after a durable grant. Multiplayer automation uses the documented [StudioTestService](https://create.roblox.com/docs/reference/engine/classes/StudioTestService). Device emulation is a layout test, not a measurement of physical mobile hardware.
