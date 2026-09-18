#!/usr/bin/env python3
"""Write RushPlaza.rbxmx — drag into Studio Workspace, then run IMPORT.lua."""

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
OUT = ROOT / "RushPlaza.rbxmx"

REF = 0


def next_ref() -> str:
    global REF
    REF += 1
    return f"RBX{REF}"


def cdata(text: str) -> str:
    return "<![CDATA[" + text.replace("]]>", "]]]]><![CDATA[>") + "]]>"


def script_item(class_name: str, name: str, source: str, indent: str) -> str:
    ref = next_ref()
    src = cdata(source)
    return (
        f'{indent}<Item class="{class_name}" referent="{ref}">\n'
        f"{indent}\t<Properties>\n"
        f'{indent}\t\t<string name="Name">{name}</string>\n'
        f'{indent}\t\t<ProtectedString name="Source">{src}</ProtectedString>\n'
        f"{indent}\t</Properties>\n"
        f"{indent}</Item>\n"
    )


def folder_open(name: str, indent: str) -> str:
    ref = next_ref()
    return (
        f'{indent}<Item class="Folder" referent="{ref}">\n'
        f"{indent}\t<Properties>\n"
        f'{indent}\t\t<string name="Name">{name}</string>\n'
        f"{indent}\t</Properties>\n"
    )


def classify(path: Path) -> tuple[str, str]:
    name = path.name
    if name.endswith(".server.lua"):
        return name[: -len(".server.lua")], "Script"
    if name.endswith(".client.lua"):
        return name[: -len(".client.lua")], "LocalScript"
    return path.stem, "ModuleScript"


def main() -> None:
    parts = ['<roblox version="4">\n', folder_open("RushPlazaImport", "\t")]

    parts.append(folder_open("Shared", "\t\t"))
    for path in sorted((SRC / "ReplicatedStorage" / "Shared").glob("*.lua")):
        name, cls = classify(path)
        parts.append(script_item(cls, name, path.read_text(), "\t\t\t"))
    parts.append("\t\t</Item>\n")

    parts.append(folder_open("Server", "\t\t"))
    for path in sorted((SRC / "ServerScriptService").glob("*.lua")):
        name, cls = classify(path)
        parts.append(script_item(cls, name, path.read_text(), "\t\t\t"))
    parts.append(folder_open("Games", "\t\t\t"))
    for path in sorted((SRC / "ServerScriptService" / "Games").glob("*.lua")):
        name, cls = classify(path)
        parts.append(script_item(cls, name, path.read_text(), "\t\t\t\t"))
    parts.append("\t\t\t</Item>\n")
    parts.append("\t\t</Item>\n")

    parts.append(folder_open("Client", "\t\t"))
    for path in sorted((SRC / "StarterPlayerScripts").glob("*.client.lua")):
        name, cls = classify(path)
        parts.append(script_item(cls, name, path.read_text(), "\t\t\t"))
    parts.append("\t\t</Item>\n")

    parts.append("\t</Item>\n</roblox>\n")
    OUT.write_text("".join(parts))
    print(f"Wrote {OUT} ({OUT.stat().st_size} bytes)")


if __name__ == "__main__":
    main()
