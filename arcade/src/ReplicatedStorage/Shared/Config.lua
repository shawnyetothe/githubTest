-- Rush Plaza balance + monetization IDs.
-- Replace 0 IDs in Creator Dashboard before charging real Robux.

local Config = {}

Config.PlaceName = "Rush Plaza"
Config.DataStoreName = "RushPlaza_v1"
Config.StartingCoins = 75
Config.FriendBoost = 0.15
Config.FirstVisitBonus = 25

Config.Layout = {
	Hub = Vector3.new(0, 0, 0),
	OrbRush = Vector3.new(0, 0, 700),
	LuckyDrop = Vector3.new(700, 0, 0),
	ObbyRace = Vector3.new(-700, 0, 0),
	TycoonLite = Vector3.new(0, 0, -700),
	GardenPocket = Vector3.new(700, 0, 700),
	DuoExtract = Vector3.new(-700, 0, 700),
	StoryBeat = Vector3.new(700, 0, -700),
	RhythmTap = Vector3.new(-700, 0, -700),
	HoopShot = Vector3.new(1200, 0, 0),
	StallRush = Vector3.new(-1200, 0, 0),
}

-- Ordered for the plaza ring and HUD.
Config.Catalog = {
	{ id = "OrbRush", name = "Orb Rush", blurb = "Magnet sim", color = Color3.fromRGB(80, 220, 255) },
	{ id = "GardenPocket", name = "Pocket Garden", blurb = "Plant and bounce", color = Color3.fromRGB(120, 255, 140) },
	{ id = "TycoonLite", name = "Button Tycoon", blurb = "Buy income", color = Color3.fromRGB(255, 196, 70) },
	{ id = "LuckyDrop", name = "Lucky Drop", blurb = "Peg payouts", color = Color3.fromRGB(180, 120, 255) },
	{ id = "StallRush", name = "Stall Rush", blurb = "Serve the line", color = Color3.fromRGB(255, 140, 180) },
	{ id = "ObbyRace", name = "60s Run", blurb = "Jump the gap", color = Color3.fromRGB(255, 90, 90) },
	{ id = "DuoExtract", name = "Duo Extract", blurb = "Loot and leave", color = Color3.fromRGB(255, 120, 60) },
	{ id = "HoopShot", name = "Hoop Rush", blurb = "Hold to shoot", color = Color3.fromRGB(255, 150, 40) },
	{ id = "RhythmTap", name = "Beat Wire", blurb = "Tap the lane", color = Color3.fromRGB(90, 180, 255) },
	{ id = "StoryBeat", name = "Night Market", blurb = "Three endings", color = Color3.fromRGB(200, 180, 255) },
}

Config.Orb = {
	ArenaRadius = 70,
	SpawnInterval = 0.35,
	MaxOrbs = 90,
	Lifetime = 40,
	BaseRange = 8,
	BasePull = 28,
	BaseValue = 1,
	BaseSpeed = 18,
	ComboWindow = 1.25,
	RebirthBase = 500,
	RebirthGrowth = 1.8,
	RebirthMult = 0.25,
	VipRange = 12,
	VipPull = 20,
	Upgrades = {
		MagnetRange = { max = 25, baseCost = 25, growth = 1.35, perLevel = 1.5 },
		MagnetPull = { max = 25, baseCost = 30, growth = 1.38, perLevel = 4 },
		OrbValue = { max = 30, baseCost = 40, growth = 1.42, perLevel = 0.35 },
		WalkSpeed = { max = 15, baseCost = 50, growth = 1.45, perLevel = 1.2 },
	},
	Colors = {
		Color3.fromRGB(80, 220, 255),
		Color3.fromRGB(120, 255, 140),
		Color3.fromRGB(255, 210, 70),
		Color3.fromRGB(255, 90, 200),
	},
	Tiers = {
		{ weight = 70, mult = 1, colorIndex = 1, size = 1.2 },
		{ weight = 20, mult = 3, colorIndex = 2, size = 1.5 },
		{ weight = 8, mult = 8, colorIndex = 3, size = 1.9 },
		{ weight = 2, mult = 25, colorIndex = 4, size = 2.4 },
	},
}

Config.Lucky = {
	Entry = 15,
	LuckBase = 80,
	LuckGrowth = 1.7,
	LuckMax = 10,
	Bins = { 0, 0.5, 2, 8, 2, 0.5, 0 },
}

Config.Tycoon = {
	Costs = { 0, 200, 800, 3000, 12000, 50000 },
	Rates = { 0, 5, 14, 35, 90, 220, 600 },
	Plots = 6,
}

Config.Garden = {
	Plots = 6,
	Slots = 6,
	Crops = {
		{ id = "sprout", name = "Sprout", cost = 10, time = 20, value = 22 },
		{ id = "glow", name = "Glowberry", cost = 40, time = 45, value = 95 },
		{ id = "moon", name = "Moonmelon", cost = 120, time = 90, value = 320 },
		{ id = "void", name = "Voidfruit", cost = 400, time = 180, value = 1200 },
	},
}

Config.Obby = {
	Stages = 10,
	FinishReward = 200,
	SpeedBonus = 150,
	SpeedTime = 60,
}

Config.Extract = {
	RoundSeconds = 75,
	Chests = 8,
	HazardDamage = 20,
}

Config.Hoop = {
	Reward = 12,
}

Config.Rhythm = {
	Beats = 24,
	Window = 0.28,
	MaxCoins = 80,
}

Config.Stall = {
	Window = 4,
}

Config.StoryReward = {
	LanternKeeper = 300,
	DealMaker = 220,
	QuietGate = 180,
}

Config.Daily = { base = 40, perStreak = 20, maxStreak = 14 }

Config.GamePasses = {
	DoubleCoins = 0, -- 149 R$ suggested
	VipMagnet = 0, -- 199 R$
	TycoonDouble = 0, -- 199 R$
}

Config.DeveloperProducts = {
	CoinsSmall = { id = 0, coins = 500 },
	CoinsMed = { id = 0, coins = 3000 },
	CoinsLarge = { id = 0, coins = 20000 },
	GardenFinish = { id = 0, handler = "GardenFinish" },
	ExtractRevive = { id = 0, handler = "ExtractRevive" },
}

function Config.Info(id)
	for _, g in ipairs(Config.Catalog) do
		if g.id == id then
			return g
		end
	end
	return nil
end

return Config
