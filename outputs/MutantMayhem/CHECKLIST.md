# Living implementation checklist

Last updated: 18 October 2026. **Implemented** means source/instances exist; **tested** describes the actual scope observed. Unlisted acceptance is not implied.

| Area | Implemented | Tested | Blocked / pending |
|---|---|---|---|
| Phase 1: inspection/architecture | Connected Studio inspected; prior content archived; modular source installed | Startup and source presence | Blender MCP unavailable |
| Phase 2: map/art | 12 labs, six named gameplay locations, original 12-species primitive catalog | Studio map/preview captures, all catalog entries present | Blender production meshes, texture atlas, skeletal rigs, final dressing |
| Phase 3: collection/mutation | Starter, inventory, placement, discovery, income, mutations, pity | Real mouse placement; server remote flow; 100k mutation samples | Extended live UX playtest |
| Phase 4: multiplayer | Auto-allocation, opt-in DNA sampling, defender alert, free shield/pulse, cooldown and carry cleanup | Eight actual clients and distinct labs; 64 unique GUIDs; client placement/rewards/settings; actual defender disconnect cleanup; prior two-client raid/defense/completion | Permanent theft/atomic cross-profile transfer disabled; safe-zone theft rules need implementation if enabled |
| Phase 5: UI/animation | Eight UI sections, species details, touch targets, focus graph, focus scrolling/restoration, Y/B and shoulder bindings, shared procedural motions | Desktop/phone placement and layout; Return/arrow activation; eight-page bindings; last species reachable; settings retain focus | Native gamepad activation/reconnect; authored animation clips; custom audio |
| Phase 6: progression | Six tiers, ten mastery levels, daily/catch-up gifts, missions, milestones, visible Weekly Explorer lab badge, events, research sink | Core progression; daily replay rejected; fourth weekly claim creates badge; 1/10/100h simulations | Long-duration live balancing |
| Phase 6: persistence | Validated versioned profiles, leases, retry queue, durable action acknowledgments, retained failed departures, autosave, shutdown saves | Faulted writes/acknowledgments; replay; departure recovery; stale writer/takeover rejection; exact mutation round-trip; nine malformed profiles rejected | Real published leave/rejoin, backend outages and crash recovery |
| Phase 7: commerce | Central pass/product config and MarketplaceService adapters; durable receipt grant design | Receipt commit path under mocked faults | Real IDs, real receipt integration, catalog names/prices and VIP visuals; no products currently offered |
| Phase 7: analytics | Structured taxonomy and bounded server log | Real emitted startup/action/session/roll logs | Durable ingestion, dashboard, real D1/D7/conversion |
| Phase 8: QA/performance | Smoke tests, fault tests, balance simulations, screenshots and profiles saved | Eight-client correctness pass; 96 synthetic creatures on 12 labs; local render timing | Real 12 clients, physical mobile, network faults, full exploit audit; eight-client RPC latency was high |
| Delivery | Separate local .rbxl, editable source, tests, evidence | File exists and Studio runs the installed build | Publishing not performed |

## Original acceptance criteria

- [x] A fresh local player receives a plot and starter, places it, collects income, mutates, and upgrades.
- [x] Twelve creature archetypes exist with modular mutations.
- [x] The playable path needs no Robux purchase.
- [x] Specific malformed/foreign-ID/repeated-reward/rate-limit checks passed.
- [x] Two-client DNA interaction retains originals and creates unique specimen IDs.
- [ ] Durable leave/rejoin verified against the real Roblox backend.
- [ ] Permanent ownership theft verified with crash-safe atomic transfer.
- [ ] All essential console controls verified.
- [ ] Full twelve-player / physical mobile performance accepted.
- [ ] Blender asset and animation requirements complete.
- [ ] Full polished production game ready to release.
