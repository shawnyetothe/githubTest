-- Shared game balance + monetization IDs.
-- Replace PASS_* and PRODUCT_* with your Creator Dashboard IDs before publishing.

local Config = {}

Config.PlaceName = "Orb Rush"
Config.DataStoreName = "OrbRush_v1"

-- Arena
Config.ArenaRadius = 80
Config.OrbSpawnInterval = 0.35
Config.MaxOrbs = 120
Config.OrbLifetime = 45

-- Magnet defaults
Config.BaseMagnetRange = 8
Config.BaseMagnetPull = 28
Config.BaseWalkSpeed = 18
Config.BaseOrbValue = 1

-- Upgrade costs: cost = Base * (Growth ^ level)
Config.Upgrades = {
	MagnetRange = { max = 25, baseCost = 25, growth = 1.35, perLevel = 1.5 },
	MagnetPull = { max = 25, baseCost = 30, growth = 1.38, perLevel = 4 },
	OrbValue = { max = 30, baseCost = 40, growth = 1.42, perLevel = 0.35 },
	WalkSpeed = { max = 15, baseCost = 50, growth = 1.45, perLevel = 1.2 },
}

-- Rebirth: cash threshold * (1.8 ^ rebirths)
Config.RebirthBaseCash = 500
Config.RebirthCostGrowth = 1.8
Config.RebirthMultPer = 0.25 -- +25% permanent cash per rebirth

-- Daily streak
Config.DailyBonusBase = 50
Config.DailyBonusPerStreak = 25
Config.MaxDailyStreak = 14

-- Combo window (seconds between collects to keep streak)
Config.ComboWindow = 1.25

-- Soft shop nudge: show once after first rebirth until dismissed this session
Config.ShopNudgeEnabled = true

--[[
	MONETIZATION — create these in Creator Dashboard → Monetization
	Game Passes (one-time):
	  DoubleCash   — 99 Robux   (impulse)
	  VipMagnet    — 199 Robux  (range+pull bonus)
	Developer Products (repeatable):
	  CashSmall    — 25 Robux  → 500 cash
	  CashMed      — 99 Robux  → 3,000 cash (+bonus)
	  CashLarge    — 399 Robux → 20,000 cash (+bonus)
]]
Config.GamePasses = {
	DoubleCash = 0, -- TODO: replace with real Game Pass ID
	VipMagnet = 0,
}

Config.DeveloperProducts = {
	-- productId = grant function key
	CashSmall = { id = 0, cash = 500 },
	CashMed = { id = 0, cash = 3000 },
	CashLarge = { id = 0, cash = 20000 },
}

Config.VipMagnetRangeBonus = 12
Config.VipMagnetPullBonus = 20

Config.OrbColors = {
	Color3.fromRGB(80, 220, 255), -- common
	Color3.fromRGB(120, 255, 140), -- uncommon
	Color3.fromRGB(255, 210, 70), -- rare
	Color3.fromRGB(255, 90, 200), -- epic
}

Config.OrbTiers = {
	{ weight = 70, mult = 1, colorIndex = 1, size = 1.2 },
	{ weight = 20, mult = 3, colorIndex = 2, size = 1.5 },
	{ weight = 8, mult = 8, colorIndex = 3, size = 1.9 },
	{ weight = 2, mult = 25, colorIndex = 4, size = 2.4 },
}

return Config
