"""Exercise actual HUD/controller sources with a small UI API double.
This verifies callbacks/state/focus, not Roblox rendering or physical gamepad input.
"""
from pathlib import Path
root=Path(__file__).resolve().parents[2]
paths={
 "Theme":"outputs/MutantMayhem/src/Shared/UI/Theme.luau",
 "Skin":"outputs/MutantMayhem/src/Shared/UI/HUDSkin.luau",
 "Layout":"outputs/MutantMayhem/src/Shared/UI/HUDLayout.luau",
 "HUD":"outputs/MutantMayhem/src/Client/UI/HUDController.luau",
 "Navigation":"outputs/MutantMayhem/src/Client/UI/NavigationController.luau",
}
sources="local sources={\n"
for key,path in paths.items():
 text=(root/path).read_text()
 assert "]====]" not in text
 sources+=key+"=[====["+text+"]====],\n"
sources+="}\n"
harness=(root/"ui-clean/tests/hud_harness.luau").read_text()
Path("/tmp/clean-hud-harness.luau").write_text(sources+harness)
