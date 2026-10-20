# Input and weekly reward checks — 18 October 2026

Tests ran in the actual client UI, using the connector's keyboard input tool. Return and arrow keys use Roblox's GUI selection/activation path; no button callback was called directly.

Passed:

- ButtonY code opens Lab and selects an action. ButtonR1/ButtonL1 codes cycle all eight pages in both directions. ButtonB closes and clears selection.
- Every content button has explicit up/down/left/right selection links. The dock wraps horizontally and links back into content.
- Keyboard Return placed Pip, mutated it once (100 → 25 coins), collected one earned coin, claimed +200 daily coins, and enabled reduced motion.
- The reduced-motion button remained selected after the menu was rebuilt, using the stable key `Reduce motion`.
- Down navigation scrolled the Lab to the shield action (canvas Y ≈ 62).
- Eleven Down presses reached the twelfth species, Crown (canvas Y = 516). Its full button was within the visible scroll area. Return opened its preview and selected Back to all species.
- The fourth weekly claim changed Weekly.Count to 4 and WeeklyGlow to true, and created a server-replicated WeeklyBadge with the label WEEKLY EXPLORER. Test state was seeded only in the disposable Play session.

Important input limitation:

The input probe recorded `UserInputType.Keyboard` for ButtonY, ButtonR1, ButtonA and DPadDown. ButtonA and DPadDown therefore did not exercise native gamepad GUI activation/navigation. ContextActionService bindings responded to their key codes; Return/arrows independently verified the selection graph and real activation. This is **not** a native-controller acceptance pass.

Native controller checklist still pending:

1. Open Studio's Controller Emulator or connect a physical gamepad. Confirm GamepadEnabled and Gamepad1 input events.
2. Y opens Lab; D-pad reaches every action; A activates once; LB/RB changes tabs; B clears focus and returns to walking.
3. Verify controller reconnect, Roblox menu focus, no accidental jump on UI confirmation, and moving through the map after closing UI.
4. Check Xbox and PlayStation button labeling and TV safe areas.

The native desktop mouse automation returned `SendInput ... GetLastError=87`, preventing automated opening of the emulator widget. No physical controller was present in the observed client (`GamepadEnabled=false`).
