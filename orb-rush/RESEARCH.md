# Roblox Mini-Game Research — Ship Today Playbook

*Sources: Metav3rse Instagram (Sep 15, 2026 / RDC26), profitable.app genre map (Sep 16, 2026), ROLearn Q2 2026 emerging genres, creator monetization guides 2025–2026.*

## What the Instagram post actually says

Roblox is an economy, not just a game platform — but **income is extremely top-heavy**:

| Cohort | Avg / year (claimed) |
| --- | --- |
| Top 10 creators | ~$65.7M |
| Top 100 | ~$10.8M |
| Top 1,000 | ~$1.4M |
| Ecosystem payouts (12 mo) | ~$1.7B |
| DevEx creators | ~42,000 (+~70% YoY) |
| **Median DevEx creator** | **~$1,500 / year** |

**Translation for “a small amount every day”:** median ≈ **$4/day**. That is achievable without a hit studio — but only with a game that has a *retention loop + impulse monetization*, not a one-and-done obby.

## Highest-probability genres (2026)

| Priority | Genre | Why | Ship-today fit |
| --- | --- | --- | --- |
| **1** | **Simulation / idle collector** | #1 total revenue (~$3B est.); proven collect → upgrade → prestige → spend loop | **Best** |
| 2 | Roleplay / avatar | Huge median visits; needs content + social design | Weak for day-1 solo |
| 3 | Survival / co-op survival | Rising (Lethal Company wave); needs polish + matchmaking | Weak for day-1 |
| 4 | Party / casual mini-games | Fun, TikTokable; monetization weaker unless hubbed | Medium |
| 5 | Obby | Easy to ship; low like-ratio (~80%); skip-pass only | Easy but low ARPU |
| Emerging | Narrative, rhythm, sports sim | Underserved; longer builds | Not today |

**Verdict:** For *solo + ship today + daily micro-revenue*, build a **compressed simulator**: magnet/collect orbs → buy upgrades → rebirth for multipliers → sell 2× cash + cash packs.

## Why this loop prints small daily money

1. **Session length** → Premium payouts + more shop impressions  
2. **Soft walls** (upgrade cost curves) → Game Pass impulse buys (49–99 R$)  
3. **Repeatable desire** (cash packs, luck boosts) → Developer Products (recurring)  
4. **Rebirth fireworks** → shareable moments for TikTok/IG Reels  
5. **Daily streak** → players return; you earn every day they do  

Typical healthy mix (2025–26 reports): ~55% Game Passes, ~30% Dev Products, rest Premium/other.

## Realistic money math (not cope)

Assume DevEx ≈ **$0.0035–$0.0038 / Robux** after you clear eligibility.

| Daily earned Robux (your share) | ≈ USD / day |
| --- | --- |
| 50 | ~$0.18 |
| 250 | ~$0.90 |
| 1,000 | ~$3.50–$3.80 |
| 5,000 | ~$17–$19 |

Path to “a little every day”:

1. **Ship** a fun 2-minute loop this week  
2. **Wire** 2 Game Passes + 3 cash packs before traffic  
3. **Post** 1 vertical clip/day (rare drop, rebirth, “I got VIP magnet”)  
4. **Update** every 2–3 days (new orb type, event weekend)  

Do **not** optimize for Top 10. Optimize for *above-median consistency*.

## What NOT to build first

- Full Grow a Garden clone (saturated; art/econ heavy)  
- Narrative-only (retention cliff; hard ARPU)  
- Complex sports/physics (6–12 month builds)  
- Pay-to-win PvP without cosmetics-first (likes tank, discovery dies)

## Today’s product: Orb Rush

A single-place **magnet orb collector** with:

- Auto-pull magnet + walk collect  
- Four upgrades + rebirth multiplier  
- Daily streak bonus  
- 2× Cash + VIP Magnet Game Passes  
- Small / Med / Large cash Developer Products  
- Soft shop prompt after first rebirth  

Copy the `src/` tree into Roblox Studio (or sync with Rojo) and publish.
