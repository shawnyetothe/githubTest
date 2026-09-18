# Rush Plaza

Ten Roblox mini-games in **one place**, picked from the genres that actually pay and the ones that are still underserved. One coin wallet, one daily streak, friend boost, and rotating server events so a clip has something to show.

This does not replace [`orb-rush/`](../orb-rush/). That kit is the single-game magnet sim. This is the plaza.

## Games

| Game | Why it is here | Loop |
| --- | --- | --- |
| **Orb Rush** | Simulation is the #1 revenue genre | Magnet pull, upgrades, rebirth |
| **Pocket Garden** | Grow-a-Garden style retention | Plant, leave, harvest later |
| **Button Tycoon** | Classic converter | Buy droppers, income ticks |
| **Lucky Drop** | Party / casual clips | Peg board, luck upgrades |
| **Stall Rush** | Shopping is tiny and high-median-visits | Serve the requested item before they leave |
| **60s Run** | Obby discovery | 10 pads, lava, 60s bonus |
| **Duo Extract** | Co-op survival wave | Loot chests, bank on the pad, dodge the hazard |
| **Hoop Rush** | Sports is still underserved | Hold to set power, make streaks |
| **Beat Wire** | Rhythm, almost no competition | 4-lane taps, server-checked timing |
| **Night Market** | Narrative demand, low supply | 3 endings, each pays once |

Organic piece: **+15% coins when 2+ players are in the same game**, plus plaza-wide **Gold Rush / Orb Storm / Lucky Minute** so a full server is worth recording.

## Install in Studio

Play mode discards anything a script creates when you hit Stop. Install in **edit mode**.

**Easiest**

1. In Studio, open a new baseplate (do not press Play).
2. Drag [`RushPlaza.rbxmx`](./RushPlaza.rbxmx) into **Workspace**.
3. View → Command Bar. Paste [`IMPORT.lua`](./IMPORT.lua) and press Enter.
4. Game Settings → Security → **Enable Studio Access to API Services**.
5. Press Play. You spawn in the plaza. Use a portal or the left-hand list.

**Alternate:** paste [`StudioPaste/InstallRushPlaza.server.lua`](./StudioPaste/InstallRushPlaza.server.lua) into the Command Bar (edit mode, not a Play test).

Regen both files after code changes:

```bash
python3 tools/generate_rbxmx.py
python3 tools/generate_installer.py
```

Rojo: `rojo serve` with `default.project.json`.

## Monetization (set IDs in `src/ReplicatedStorage/Shared/Config.lua`)

| Kind | Key | Suggested price | Effect |
| --- | --- | --- | --- |
| Pass | `DoubleCoins` | 149 | 2× coin earns everywhere |
| Pass | `VipMagnet` | 199 | Orb Rush range + pull |
| Pass | `TycoonDouble` | 199 | 2× tycoon income |
| Product | `CoinsSmall` / `Med` / `Large` | 25 / 99 / 399 | +500 / +3,000 / +20,000 coins |
| Product | `GardenFinish` | 49 | Ripen every growing plot |
| Product | `ExtractRevive` | 25 | Heal and keep carried loot |

IDs of `0` show a toast instead of charging. `ProcessReceipt` is idempotent.

## Publish

- Title: `Rush Plaza`
- Description: `10 mini-games. One plaza. Bring a friend for +15% coins. Magnet, garden, tycoon, hoops, extract, and a 3-ending story.`
- Tags: Simulation, Casual, Tycoon, Obby

Post one clip of **Orb Storm** or a **Night Market** ending. The friend boost is the reason a viewer joins a specific server instead of a dead copy.

Studio was not available in this environment, so play once in Studio before you publish and watch the output window.
