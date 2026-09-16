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

## Studio install (no Rojo required)

1. Open Roblox Studio → **New Baseplate** (delete the baseplate part if you want; the game spawns its own arena).  
2. In **ReplicatedStorage**, create Folder `Shared`, add ModuleScripts:
   - `Config` ← paste `src/ReplicatedStorage/Shared/Config.lua`
   - `Remotes` ← paste `src/ReplicatedStorage/Shared/Remotes.lua`
3. In **ServerScriptService**, add:
   - ModuleScript `PlayerData`
   - ModuleScript `Monetization`
   - ModuleScript `OrbWorld`
   - Script `Main` ← paste `Main.server.lua` (name it `Main`)
4. In **StarterPlayer → StarterPlayerScripts**, add LocalScript `Hud` ← paste `Hud.client.lua`.  
5. **Game Settings → Security**: enable **Allow HTTP** only if needed later; enable **API Services** (DataStores) for published game.  
6. Press **Play**. Walk into glowing orbs; open the shop on the right.

### Rojo (optional)

```bash
cd orb-rush
rojo serve
```

Connect from the Rojo Studio plugin.

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

- [ ] Place name: `Orb Rush` (or your brand)  
- [ ] Icon: bright neon orb on dark ground (reads at mobile thumbnail size)  
- [ ] Description: `Collect orbs. Upgrade your magnet. Rebirth for insane multipliers!`  
- [ ] Genre tags: Simulation, Casual  
- [ ] Enable paid access **off**; use passes/products only  
- [ ] Create passes/products → paste IDs  
- [ ] Publish → play on phone once  
- [ ] Record 15s rebirth clip → post to TikTok / IG Reels / YouTube Shorts with link  

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
