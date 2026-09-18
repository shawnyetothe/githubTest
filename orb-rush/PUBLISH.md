# Publish kit — Orb Rush

## One-hour publish plan

### 0–15 min — Studio install
1. New Baseplate → File → Game Settings → **Security → Enable Studio Access to API Services**
2. Paste modules (or run `tools/generate_installer.py` then paste `StudioPaste/InstallOrbRush.server.lua` once into ServerScriptService and press Play once)
3. Play Solo → confirm orbs spawn, shop works, magnet aura visible

### 15–30 min — Monetization IDs
Creator Dashboard → Experience → Monetization:

| Item | Price | Config field |
| --- | --- | --- |
| Game Pass `2x Cash` | 99 | `GamePasses.DoubleCash` |
| Game Pass `VIP Magnet` | 199 | `GamePasses.VipMagnet` |
| Product `Cash Small` | 25 | `DeveloperProducts.CashSmall.id` |
| Product `Cash Med` | 99 | `CashMed.id` |
| Product `Cash Large` | 399 | `CashLarge.id` |

### 30–45 min — Listing
**Title:** `Orb Rush - Magnet Simulator`

**Description (copy):**
```
Collect glowing orbs with your magnet. Upgrade Range, Pull, Value & Speed.
Rebirth for permanent multipliers. Daily streaks. Leaderboards.

NEW? Tip: buy Range first, then Value, then Rebirth.

Passes: 2x Cash · VIP Magnet
```

**Tags:** Simulation, Idle, Collecting, Magnet, Casual

**Icon prompt (for AI image or designer):**
> Top-down dark arena, single cyan neon orb glowing in center, subtle blue magnet ring, high contrast mobile thumbnail, no text

**Thumbnail prompt:**
> Roblox-style avatar running through field of neon cyan/pink orbs at night, motion blur, cinematic, 16:9, no UI text

### 45–60 min — First traffic
1. Publish (Public)
2. Record 12–18s phone clip: walk → rare/epic orb → rebirth toast → shop nudge
3. Post TikTok / IG Reels / Shorts with:
   - Hook: “I rebirthed and my magnet went crazy”
   - Link in bio / comments
4. Join 2–3 Roblox Discord servers’ “share your game” channels (follow their rules)

## Daily ops (15 min)

| Day | Action |
| --- | --- |
| Every day | Claim daily in-game (QA) + 1 vertical clip |
| Day 2 | Buff epic orb weight slightly if players say “too rare” |
| Day 3 | Weekend event: 2x spawn rate (change `OrbSpawnInterval` to 0.22) |
| Day 7 | Add 1 new upgrade or cosmetic trail if CCU > 5 |

## Success metrics (week 1)

| Metric | Good early signal |
| --- | --- |
| Session length | > 4 minutes average |
| Like ratio | > 70% |
| Robux/day | Any recurring amount |
| Returning users | Daily streak claims rising |

If likes < 50% after 100 visits: slow upgrade costs 10–15%, not ads.
