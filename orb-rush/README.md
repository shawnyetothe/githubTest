# Orb Rush — ship-today Roblox mini simulator

Magnet-collect orbs → upgrade → rebirth → monetize. Built for **daily micro-revenue**, not Top-10 fantasy.

## Read first

1. [`RESEARCH.md`](./RESEARCH.md) — Instagram/RDC26 income reality + genre odds  
2. This README — Studio install in ~15 minutes  

## Why this game

| Signal | Choice |
| --- | --- |
| #1 revenue genre | Simulation / idle collector |
| Ship today | One arena, no map art required |
| Daily login | Streak bonus |
| Impulse spend | 2× Cash pass (~99 R$) |
| Repeat spend | Cash packs (Dev Products) |
| Shareable clip | Rebirth + rare neon orbs |

## Studio install (fastest: one paste)

1. Roblox Studio → **New Baseplate**
2. **Game Settings → Security → Enable Studio Access to API Services**
3. Insert a **Script** into `ServerScriptService`
4. Paste the entire contents of [`StudioPaste/InstallOrbRush.server.lua`](./StudioPaste/InstallOrbRush.server.lua)
5. Press **Play** once (installer writes all modules, then disables itself)
6. Stop → **delete** the installer script → Play again

Regenerate the installer after code changes:

```bash
python3 tools/generate_installer.py
```

### Manual / Rojo install

See module list below, or `rojo serve` with `default.project.json`.


## Monetization setup (required for real Robux)

In [Creator Dashboard](https://create.roblox.com) → your experience → **Monetization**:

| Type | Suggested name | Price | Config key |
| --- | --- | --- | --- |
| Game Pass | 2× Cash | 99 R$ | `GamePasses.DoubleCash` |
| Game Pass | VIP Magnet | 199 R$ | `GamePasses.VipMagnet` |
| Dev Product | Cash Small | 25 R$ | `DeveloperProducts.CashSmall.id` (+500) |
| Dev Product | Cash Med | 99 R$ | `CashMed` (+3000) |
| Dev Product | Cash Large | 399 R$ | `CashLarge` (+20000) |

Paste the numeric IDs into `Config.lua`. Until IDs are set, shop buttons show a toast instead of charging.

**ProcessReceipt** is already wired once on the server (idempotent via saved purchase IDs).

## Publish checklist (today)

Follow **[`PUBLISH.md`](./PUBLISH.md)** for listing copy, thumbnail prompts, and the 60-minute launch plan.

Social captions: [`marketing/SOCIAL_COPY.md`](./marketing/SOCIAL_COPY.md)

Quick checks:
- [ ] One-paste install works in Solo Play
- [ ] Magnet aura visible; leaderboards spawn near arena
- [ ] Pass/product IDs in `Config.lua`
- [ ] First rebirth shows 2× Cash nudge
- [ ] Publish + one 15s clip 

## Growth loop (daily money)

1. **Morning:** claim your own daily (QA) + tweak one number (spawn rate, rare weight).  
2. **Afternoon:** one short vertical video (epic orb / rebirth).  
3. **Night:** read likes + Robux chart; buff whatever players complain is slow.  

Aim first for **any** consistent Robux day. Median DevEx creators clear roughly **~$1.5k/year** — small daily totals compound if the loop stays sticky.

## Next mini-games (after Orb Rush earns)

1. **Party hub** wrapping Orb Rush + 1 obby + 1 luck game (playlist retention).  
2. **Garden lite** (plant → wait → sell) if you want Grow-a-Garden adjacent traffic.  
3. **Co-op extract** (emerging genre) once you have a small team.

## Disclaimer

Roblox discovery is competitive. This kit maximizes *probability per hour of work*; it does not guarantee income. Never promise players real-world returns.
