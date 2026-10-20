# MUTANT MAYHEM — Neon UI delivery

Implemented in the connected Studio place 129621048489588 on 2026-10-19. The icon sheet guides categories and shapes; the screen collage guides HUD placement, panels, inventory and mutation composition. No reference bitmap was cropped into the game.

## Structure

- `src/Shared/UI`: Theme, Icons and Components.
- `src/Client/UI`: UIApp, DataAdapter, NavigationController, HUDController, InventoryController, PetDetailsController, MutationController, ShopController, BaseUpgradeController, MapController, MissionsController, SocialController, UtilityController, Overlays and TooltipController.
- `src/Client/Main.client.luau`: one-line bootstrap. Networking is isolated in DataAdapter.
- Runtime `PlayerGui/MutantMayhemUI`: MainHUD, Menus/ScreenContent, Overlays, Popups, Notifications, Tooltip, Templates.
- Server changes: Bootstrap validates owned-pet Favorite/Locked actions and saves them; PlayerDataService validates optional booleans; MutationService rejects locked pets without charging.
- Existing client/server sources were backed up in Studio under `ServerStorage/MM_PreNeonUI_Backup`. Local previous sources remain in the workspace `work/ui-v2-backup`.

## Screens and actual status

| Screen | Implemented | Validation |
|---|---|---|
| HUD | Native icon shapes, currency/income, left navigation, right utilities, event timer, active-pet shortcuts, temporary-progress label | Desktop and portrait visually inspected; bound to live state |
| Pets | Search, rarity ordering, all/placed/favorite filters, 24-card incremental paging, 3D cards, selection, equip/store, lock, inspection | 60-pet temporary fixture: first 24, load 48, search 5 matches, empty state, 20 favorites verified |
| Pet details | Model preview with fitted camera, optional rotation, rarity, production, multiplier, placement, favorite, mutation lock | Opened and visually inspected; flags/placement tested against server |
| Mutation | Selected pet, chamber, server odds, cost, pity meter, confirmation and server result | Mouse opened confirmation and confirmed one roll: exactly 75 coins charged; locked roll rejected without charge |
| Shop | Tabs, Aurora earned-currency offer, configured-product/pass adapter, unavailable category cards | Opened and visually inspected; real-money prompts not exercised because no product/pass IDs are configured |
| Laboratory | Current tier/capacity/income, next space, collect, upgrade, free shield, mastery, research, decoration link | Screen opened; tier upgrade tested through real handler |
| Map | Six actual destinations, clickable schematic island nodes, discovery and missions links | Screen opened; travel/discovery used by integration tests |
| Missions | Daily/weekly/achievement tabs, progress, gift and reward claim controls | Screen opened; daily reward and duplicate rejection tested |
| Social | Actual server roster plus friends/clan unavailable states | Screen opened; no simulated friends or clans |
| Events | Live event timer, visit, DNA sample/defend controls | Screen opened; existing raid backend retained |
| Settings/utilities | Peaceful, reduced motion, low graphics; controls help; unavailable care/evolution/trade/skin states | Screen opened; setting toggle and respawn continuity tested |

## Reusable presentation

Rounded frames and buttons, border highlights, gradients, labels/titles, native semantic icons, scroll/list layouts, pet cards, viewports, progress bars, section/reward cards, navigation buttons, confirmation overlay, notification deduplication and tooltips. UI state is not used to grant rewards or trust inventory ownership.

Responsive widths were checked at actual simulated viewports 388×762, 749×388, 1179×819 and 1919×1079. All 11 windows stayed within the viewport. Portrait previews were visually rechecked after camera fitting. Small screens use scrollable content. Reduced-motion settings disable preview rotation and UI tweens. Y/M open Lab, B returns, shoulder bindings change pages; native controller certification remains pending.

## Explicit placeholders / remaining dependencies

- Semantic registry has empty Roblox image IDs. Ten major icons are native GUI shape compositions; other categories use fallback glyphs. Individual polished cartoon image assets remain to be supplied/uploaded.
- No Gems, mutagen wallet, pet XP/level, feeding, evolution, pet selling/trading, personal pet skins, clans, friend invitations or remote player visits exist in the backend. Their capabilities are absent or marked unavailable; no fictional balances or transactions are shown.
- The mutation backend uses Common/Uncommon/Rare/Epic/Legendary/Mythic, not the reference's Normal/Neon/Crystal/Golden/Void/Celestial naming. UI uses the actual backend's translated rarity names and percentages.
- Shop prices are confirmed through Roblox prompts once real configured IDs exist. No invented Robux or cash prices.
- Lab preview is a native icon and map is schematic, not rendered environment artwork. Existing original creature models remain in use.
- Physical mobile/controller usability, production DataStore round trips, live purchases and final art polish still need acceptance testing.
- An unrelated `MM_TrioAssets.TrioBuilder` module reports that EditableMesh API access is disabled. This UI does not change that permission or replace those assets.

## Evidence and saving

`tests/neon-ui-results.json` records the results. Persistence fault suite passed with 20 mock writes, 11 rejected corrupt profiles and exact Favorite/Locked round trips. Studio runtime fixtures and test scripts were removed by stopping Play. `screenshots/neon-inventory.jpg` is an actual Studio capture using temporary test pets.

Source changes are saved locally and applied to Studio Edit mode. Native `.rbxl` export could not be confirmed because Windows UI input failed (`SendInput ... GetLastError=87`). Existing v2 `.rbxl` files are older checkpoints and are deliberately excluded from the new Neon UI delivery archive. Use Studio File → Save to Roblox / Download a Copy to persist the current full place. `default.project.json` maps the complete code package for Rojo rebuilds; MapBuilder creates the world when it is absent.

The interface is implemented and tested to the scope above; this is not a claim that missing game services or final reference-quality artwork are complete.
