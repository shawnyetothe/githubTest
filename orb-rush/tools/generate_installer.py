#!/usr/bin/env python3
"""Regenerate StudioPaste/InstallOrbRush.server.lua from src/."""

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "StudioPaste" / "InstallOrbRush.server.lua"

MODULES = [
    ("ReplicatedStorage", "Config", "ModuleScript", ROOT / "src/ReplicatedStorage/Shared/Config.lua"),
    ("ReplicatedStorage", "Remotes", "ModuleScript", ROOT / "src/ReplicatedStorage/Shared/Remotes.lua"),
    ("ServerScriptService", "PlayerData", "ModuleScript", ROOT / "src/ServerScriptService/PlayerData.lua"),
    ("ServerScriptService", "Monetization", "ModuleScript", ROOT / "src/ServerScriptService/Monetization.lua"),
    ("ServerScriptService", "OrbWorld", "ModuleScript", ROOT / "src/ServerScriptService/OrbWorld.lua"),
    ("ServerScriptService", "Leaderboard", "ModuleScript", ROOT / "src/ServerScriptService/Leaderboard.lua"),
    ("ServerScriptService", "RateLimit", "ModuleScript", ROOT / "src/ServerScriptService/RateLimit.lua"),
    ("ServerScriptService", "Main", "Script", ROOT / "src/ServerScriptService/Main.server.lua"),
    ("StarterPlayerScripts", "Hud", "LocalScript", ROOT / "src/StarterPlayerScripts/Hud.client.lua"),
]


def lua_string(s: str) -> str:
    eq = 0
    while True:
        close = "]" + ("=" * eq) + "]"
        open_ = "[" + ("=" * eq) + "["
        if close not in s:
            return open_ + s + close
        eq += 1


def main() -> None:
    lines = [
        "--[[",
        "  Orb Rush ONE-PASTE INSTALLER (auto-generated)",
        "  Run: python3 tools/generate_installer.py",
        "  Studio: paste into a Script under ServerScriptService, Play once, delete installer.",
        "]]",
        "",
        'local SSS = game:GetService("ServerScriptService")',
        'local RS = game:GetService("ReplicatedStorage")',
        'local SP = game:GetService("StarterPlayer")',
        'local SPS = SP:WaitForChild("StarterPlayerScripts")',
        "",
        "local function ensureFolder(parent, name)",
        "\tlocal f = parent:FindFirstChild(name)",
        "\tif not f then",
        '\t\tf = Instance.new("Folder")',
        "\t\tf.Name = name",
        "\t\tf.Parent = parent",
        "\tend",
        "\treturn f",
        "end",
        "",
        "local function writeScript(parent, className, name, source)",
        "\tlocal existing = parent:FindFirstChild(name)",
        "\tif existing then existing:Destroy() end",
        "\tlocal obj = Instance.new(className)",
        "\tobj.Name = name",
        "\tobj.Source = source",
        "\tobj.Parent = parent",
        "\treturn obj",
        "end",
        "",
        'print("[OrbRush] Installing...")',
        'local shared = ensureFolder(RS, "Shared")',
        "",
    ]

    for service, name, class_name, path in MODULES:
        src = path.read_text()
        lit = lua_string(src)
        lines.append(f"-- {name}")
        lines.append("do")
        lines.append(f"\tlocal source = {lit}")
        if service == "ReplicatedStorage":
            lines.append(f'\twriteScript(shared, "{class_name}", "{name}", source)')
        elif service == "ServerScriptService":
            lines.append(f'\twriteScript(SSS, "{class_name}", "{name}", source)')
        else:
            lines.append(f'\twriteScript(SPS, "{class_name}", "{name}", source)')
        lines.append("end")
        lines.append("")

    lines.append('print("[OrbRush] Install complete. Stop Play, delete this Installer script, Play again.")')
    lines.append("script.Disabled = true")
    lines.append('script.Name = "OrbRushInstaller_DONE"')
    lines.append("")

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text("\n".join(lines))
    print(f"Wrote {OUT} ({OUT.stat().st_size} bytes)")


if __name__ == "__main__":
    main()
