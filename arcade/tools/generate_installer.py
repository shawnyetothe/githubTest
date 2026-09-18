#!/usr/bin/env python3
"""Build StudioPaste/InstallRushPlaza.server.lua from src/."""

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
OUT = ROOT / "StudioPaste" / "InstallRushPlaza.server.lua"


def lua_string(s: str) -> str:
    eq = 0
    while True:
        close = "]" + ("=" * eq) + "]"
        open_ = "[" + ("=" * eq) + "["
        if close not in s:
            return open_ + s + close
        eq += 1


def class_for(path: Path) -> str:
    name = path.name
    if name.endswith(".server.lua"):
        return "Script"
    if name.endswith(".client.lua"):
        return "LocalScript"
    return "ModuleScript"


def script_name(path: Path) -> str:
    name = path.name
    for suffix in (".server.lua", ".client.lua", ".lua"):
        if name.endswith(suffix):
            return name[: -len(suffix)]
    return path.stem


def main() -> None:
    shared = sorted((SRC / "ReplicatedStorage" / "Shared").glob("*.lua"))
    server = sorted(p for p in (SRC / "ServerScriptService").glob("*.lua") if not p.name.endswith(".server.lua"))
    games = sorted((SRC / "ServerScriptService" / "Games").glob("*.lua"))
    mains = sorted((SRC / "ServerScriptService").glob("*.server.lua"))
    clients = sorted((SRC / "StarterPlayerScripts").glob("*.client.lua"))

    lines = [
        "--[[",
        "  Rush Plaza installer. Run from the Command Bar in EDIT mode (not Play).",
        "  Play mode throws this work away when you press Stop.",
        "  View → Command Bar, paste this whole file, press Enter.",
        "  Easier path: drag RushPlaza.rbxmx into Workspace, then run IMPORT.lua.",
        "]]",
        'local RunService = game:GetService("RunService")',
        "if RunService:IsRunning() then",
        '\terror("Stop Play mode. Run this from the Command Bar while editing.")',
        "end",
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
        "end",
        "",
        'print("[RushPlaza] Installing...")',
        'local sharedFolder = ensureFolder(RS, "Shared")',
        'local gamesFolder = ensureFolder(SSS, "Games")',
        "",
    ]

    def emit(parent_expr: str, path: Path) -> None:
        src = path.read_text()
        lines.append(f"-- {path.relative_to(SRC)}")
        lines.append("do")
        lines.append(f"\tlocal source = {lua_string(src)}")
        lines.append(f'\twriteScript({parent_expr}, "{class_for(path)}", "{script_name(path)}", source)')
        lines.append("end")
        lines.append("")

    for path in shared:
        emit("sharedFolder", path)
    for path in server:
        emit("SSS", path)
    for path in games:
        emit("gamesFolder", path)
    for path in clients:
        emit("SPS", path)
    for path in mains:
        emit("SSS", path)

    lines.append('print("[RushPlaza] Installed. Press Play.")')
    lines.append("if script ~= nil then")
    lines.append("\tscript.Disabled = true")
    lines.append('\tscript.Name = "RushPlazaInstaller_DONE"')
    lines.append("end")
    lines.append("")
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text("\n".join(lines))
    print(f"Wrote {OUT} ({OUT.stat().st_size} bytes)")


if __name__ == "__main__":
    main()
