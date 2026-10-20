# QA evidence and practical limits

18 October 2026 — local Roblox Studio, unpublished place, explicitly labeled session-only demo data.

## Gameplay smoke test

The initial runtime log emitted session start, plot allocation, and first creature in the same recorded second. A real simulated mouse click on **Place in lab** changed Pip to placed and the production rate from 0 to 1 coin/second. The phone-emulated mouse click independently passed after the layout correction.

An actual client RemoteFunction sequence produced these results:

| Check | Observed result |
|---|---|
| Collect stored income | 54 coins transferred; balance 100 → 154 |
| Submit an arbitrary client currency value | Did not grant it; collection used server storage only |
| Daily claim | +200 coins |
| Repeat daily claim | Rejected |
| Buy first upgrade | 150 coins deducted; tier 1; capacity 3 |
| Mutate another/unknown creature ID | Rejected; balance unchanged |
| Submit a table instead of creature ID | Rejected as invalid creature |
| Valid mutation at reactor | 75 coins deducted; full deterministic descriptor returned |
| Collect while standing at reactor | Rejected by proximity check |
| Discover at meadow | 60 coins deducted; Curl added as a new GUID |
| Activate shield at own lab | Accepted |
| Raid in peaceful mode | Rejected |
| Burst of 25 state requests | 21 rate-limited in the measured burst |
| Reduced-motion / low-graphics settings | Both accepted and reflected to client |
| Keyboard M | Opened Lab |
| Simulated controller ButtonA | No collection occurred; console acceptance remains pending |

These checks are not a complete adversarial security audit. Client network ownership and teleport/speed edge cases need further testing before any destructive ownership transfer is enabled.

## Two-client test

`tests/Multiplayer.server.luau` was installed temporarily, run through StudioTestService with two actual local clients, and removed from the delivered place afterward. Raw result: `tests/multiplayer-result.txt`.

Passed: separate plot allocation, one starter each, income, opt-in DNA raid start, defender cancellation, cleanup routine used on disconnect, and completion creating a unique new GUID while the defender retains the original. Cross-player placement was rejected. All 12 plot IDs were unique.

The cleanup assertion called the disconnect cleanup routine directly; it was not a socket-drop or machine-crash test. Successful completion was accelerated with server-only test state and position changes; the test does not validate a human's entire escape route. No test remote or test currency grant remains installed.

## Eight-client follow-up

An additional eight-client test passed later in the session. `EightClients.server.luau` and `EightClients.client.luau` were installed temporarily, then removed along with their reporting remote. All eight clients submitted successful placement, daily gift, and settings actions. Eight distinct labs and 64 unique creature GUIDs were verified. A real `Player:Kick` during a raid removed the defender's session, freed its plot, cleared displayed pets, and canceled the carry; seven clients remained. The 64-creature fill used server-only test setup after remote-action checks.

The first runs timed out waiting for client reports. The final harness added startup-stage reporting, an explicit server readiness signal, and a 120-second startup allowance. The final run returned Success=true. State request round-trip time on this heavily loaded local host was **969.42 ms mean / 2,976.50 ms maximum**, so performance is not accepted. This is neither a 12-client test nor a physical-phone result. The harness's UI-wait result is not eight visual inspections. Raw result: `tests/eight-client-results.json`.

## Persistence and receipt fault injection

`tests/PersistenceFaults.luau` cloned the actual PlayerDataService source into an isolated temporary folder and substituted a memory-only UpdateAsync adapter. No live player DataStore was written.

Passed: three pre-write failures followed by retry; three lost acknowledgments after the write; duplicate receipt replay; concurrent session-lock rejection; lock release and reload; version-1 migration; future-schema refusal. The starting 100 coins plus two 500-coin grants finished at exactly 1,100. Replay granted no extra coins. Gameplay was blocked while the outcome of a write was uncertain. Raw result: `tests/persistence-tests.json`.

The expanded pass additionally verified retained departure drafts followed by autosave recovery, rejection of a lost-acknowledgment retry after another server takes the lease, pending receipt resolution before lease release, exact mutation descriptor and setting round-trip, a new module/token recovering an expired lease, revision conflicts, and nine malformed-profile refusals. It finished at exactly 2,234 coins over 20 mock writes. See `tests/persistence-expanded-results.json`; the earlier 1,100-coin result remains as historical evidence.

Successful progression actions now call Save before returning success in durable mode, with a two-second action-save interval. DNA completion also queues a save and distinguishes confirmed from pending grants. Departure failures retain the session for retry. Lease loss is terminal and cannot overwrite a newer owner. The read-only state builder no longer changes live quest data during saves.

These tests cover local transaction logic, not Roblox's real DataStore availability, receipt callback delivery, process crashes, or the user-facing reconnect experience. Product IDs remain empty and no real transaction was attempted. Confirmed actions require a successful write; a shutdown during a sustained outage can still lose pending, unconfirmed data and uncollected income.

## Controller and weekly reward follow-up

Actual client UI checks passed for all eight page bindings, selection links, focus scrolling, keyboard Return activation, focus preservation after settings rebuild, closing/clearing focus, and reaching/opening the twelfth species. A fourth weekly claim created the replicated Weekly Explorer badge. Detailed sequences and limitations are in `tests/controller-and-weekly-results.md`.

The input probe proved that the connector emits `UserInputType.Keyboard` even when supplied ButtonA or DPadDown codes. Native gamepad acceptance is still pending. The actual Y/B/shoulder ContextActionService bindings worked; Return/arrows independently exercised the real GUI activation/navigation path.

## Economy and mutation simulation

`tests/EconomySimulation.luau` uses the shipped shared configs and Roblox Random. Two active-player strategies collect every 30 or 90 seconds, prioritize capacity/creatures, mutate every three minutes, then buy mastery and optional research. Events provide +25% income for three minutes out of every fifteen. Daily rewards, quest payouts, paid boosts, offline time, and travel time are excluded.

| Elapsed active time | 30-sec collector | 90-sec collector |
|---|---|---|
| 5 minutes | Tier 2, 4 pets, 245 coins | Tier 1, 3 pets, 295 coins |
| 15 minutes | Tier 4, 6 pets, 532 coins | Tier 3, 5 pets, 1,326 coins |
| 30 minutes | Tier 6, 8 pets, 1,082 coins | Tier 5, 7 pets, 3,163 coins |
| 1 hour | Mastery 1, 79 coins | Mastery 0, 16,453 coins |
| 10 hours | Mastery 10, research 39, 4,428 coins | Mastery 10, research 39, 1,737 coins |
| 100 hours | Research 511, 6,553 coins | Research 511, 3,862 coins |

The first simulation accumulated about five million unspent coins at 100 hours. The revised economy includes optional research dedications, with a cost starting at 2,500 and capped at 10,000; rank 5 grants gold lab trim. A player who chooses not to use this optional sink can still accumulate currency. There is no tradable player market in this slice. These projections are synthetic, not observed engagement or retention.

100,000 baseline mutation samples: Common 54,938; Uncommon 25,146; Rare 11,927; Epic 6,029; Legendary 1,681; Mythic 279. Seed replay matched every descriptor field for the tested deterministic cases. All 999 tests with 19 prior misses returned Rare or better. Raw data: `tests/economy-results.json`.

## Visual and performance checks

Actual captures are in `screenshots/`. The initial blank 3D captures were resolved by restoring the minimized Studio window. The world and viewport creatures rendered normally afterward.

Desktop viewport: 812×635. Samsung Galaxy A06 emulation: 705×338 camera viewport. iPhone 17 Pro portrait emulation: 401×778. Core UI safe insets are used, with a clipped device-safe area. The landscape primary action was verified at 398×48 logical pixels. Portrait navigation was raised above the jump control; the final screenshot shows the separation. The panel fits within the portrait viewport.

| Scenario on this desktop host | Samples | Mean frame interval | p95 | Worst |
|---|---:|---:|---:|---:|
| Single player, desktop view | 120 | 16.55 ms | 17.77 ms | 21.79 ms |
| Phone portrait emulation, low graphics + reduced motion | 120 | 16.54 ms | 17.96 ms | 18.37 ms |
| 96 synthetic creatures across 12 labs, one actual client | 180 | 16.57 ms | 17.73 ms | 18.94 ms |

The synthetic creature load was created only in Play mode and was removed when the session ended. It does not simulate 12 avatars, 12 clients, server economy load from 12 users, network latency, or a physical phone GPU. Short frame samples are not a stability guarantee.

Desktop view: 68,589 triangles and 21 draw calls excluding the shadow pass. Synthetic load view: 144,660 triangles and 17 draw calls excluding shadows; including shadows the tool reported 1,051,369 triangles and 55 calls. These are viewpoint-dependent engine reports. MM client Main/Animation heap measurements were 62,440 / 22,834 bytes in the recorded sample. The full raw profiles are saved in `tests/`.

## Remaining validation

Published backend persistence and receipts, 12-player occupancy, live disconnect/reconnect under packet loss, physical phones, controller activation, sustained resource usage, accessibility review, and production balancing remain open. Custom sounds and Blender imports were not completed. The implementation is a playable vertical slice and does not meet every original release criterion.
