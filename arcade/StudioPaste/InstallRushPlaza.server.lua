--[[
  Rush Plaza installer. Run from the Command Bar in EDIT mode (not Play).
  Play mode throws this work away when you press Stop.
  View → Command Bar, paste this whole file, press Enter.
  Easier path: drag RushPlaza.rbxmx into Workspace, then run IMPORT.lua.
]]
local RunService = game:GetService("RunService")
if RunService:IsRunning() then
	error("Stop Play mode. Run this from the Command Bar while editing.")
end

local SSS = game:GetService("ServerScriptService")
local RS = game:GetService("ReplicatedStorage")
local SP = game:GetService("StarterPlayer")
local SPS = SP:WaitForChild("StarterPlayerScripts")

local function ensureFolder(parent, name)
	local f = parent:FindFirstChild(name)
	if not f then
		f = Instance.new("Folder")
		f.Name = name
		f.Parent = parent
	end
	return f
end

local function writeScript(parent, className, name, source)
	local existing = parent:FindFirstChild(name)
	if existing then existing:Destroy() end
	local obj = Instance.new(className)
	obj.Name = name
	obj.Source = source
	obj.Parent = parent
end

print("[RushPlaza] Installing...")
local sharedFolder = ensureFolder(RS, "Shared")
local gamesFolder = ensureFolder(SSS, "Games")

-- ReplicatedStorage/Shared/Config.lua
do
	local source = [[-- Rush Plaza balance + monetization IDs.
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
]]
	writeScript(sharedFolder, "ModuleScript", "Config", source)
end

-- ReplicatedStorage/Shared/Remotes.lua
do
	local source = [[local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = {}

local folder = ReplicatedStorage:FindFirstChild("RushRemotes")
if not folder then
	folder = Instance.new("Folder")
	folder.Name = "RushRemotes"
	folder.Parent = ReplicatedStorage
end

local function getRemote(name, className)
	local remote = folder:FindFirstChild(name)
	if not remote then
		remote = Instance.new(className)
		remote.Name = name
		remote.Parent = folder
	end
	return remote
end

Remotes.Action = getRemote("Action", "RemoteEvent")
Remotes.State = getRemote("State", "RemoteEvent")
Remotes.Toast = getRemote("Toast", "RemoteEvent")
Remotes.Fx = getRemote("Fx", "RemoteEvent")

return Remotes
]]
	writeScript(sharedFolder, "ModuleScript", "Remotes", source)
end

-- ServerScriptService/Monetization.lua
do
	local source = [[local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))
local PlayerData = require(script.Parent:WaitForChild("PlayerData"))
local Presence = require(script.Parent:WaitForChild("Presence"))
local WorldEvents = require(script.Parent:WaitForChild("WorldEvents"))
local StateBus = require(script.Parent:WaitForChild("StateBus"))

local Monetization = {}
local passCache = {}
local handlers = {}

local function productById(productId)
	for key, def in pairs(Config.DeveloperProducts) do
		if def.id ~= 0 and def.id == productId then
			return key, def
		end
	end
	return nil, nil
end

function Monetization.SetHandler(name, fn)
	handlers[name] = fn
end

function Monetization.RefreshPasses(player)
	local owned = { DoubleCoins = false, VipMagnet = false, TycoonDouble = false }
	for name, passId in pairs(Config.GamePasses) do
		if typeof(passId) == "number" and passId > 0 then
			local ok, result = pcall(function()
				return MarketplaceService:UserOwnsGamePassAsync(player.UserId, passId)
			end)
			if ok and result then
				owned[name] = true
			end
		end
	end
	passCache[player.UserId] = owned
	return owned
end

function Monetization.GetPasses(player)
	return passCache[player.UserId] or Monetization.RefreshPasses(player)
end

function Monetization.Owns(player, key)
	local passes = Monetization.GetPasses(player)
	return passes[key] == true
end

function Monetization.Multiplier(player, kind)
	local m = 1
	if Monetization.Owns(player, "DoubleCoins") then
		m *= 2
	end
	m *= WorldEvents.Multiplier()
	if Presence.Boost(player) then
		m *= (1 + Config.FriendBoost)
	end
	if kind == "tycoon" and Monetization.Owns(player, "TycoonDouble") then
		m *= 2
	end
	if kind == "orb" then
		local data = PlayerData.Get(player)
		if data then
			m *= PlayerData.OrbMult(data)
		end
	end
	return m
end

function Monetization.GrantCoins(player, amount, reason, toastIt)
	local data = PlayerData.Get(player)
	if not data then
		return 0
	end
	amount = math.floor(amount)
	if amount == 0 then
		return 0
	end
	data.Coins += amount
	if toastIt and amount > 0 then
		Remotes.Toast:FireClient(player, string.format("+%d coins%s", amount, reason and (" (" .. reason .. ")") or ""))
	end
	if amount >= 25 then
		Remotes.Fx:FireClient(player, { kind = "CashPop", amount = amount })
	end
	StateBus.Push(player, false)
	return amount
end

function Monetization.PromptPass(player, key)
	local id = Config.GamePasses[key]
	if typeof(id) ~= "number" or id == 0 then
		Remotes.Toast:FireClient(player, "Set Game Pass IDs in Config")
		return
	end
	MarketplaceService:PromptGamePassPurchase(player, id)
end

function Monetization.PromptProduct(player, key)
	local def = Config.DeveloperProducts[key]
	if not def or def.id == 0 then
		Remotes.Toast:FireClient(player, "Set Developer Product IDs in Config")
		return
	end
	MarketplaceService:PromptProductPurchase(player, def.id)
end

local function processReceipt(receiptInfo)
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	local data = PlayerData.Get(player)
	if not data then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	local purchaseId = tostring(receiptInfo.PurchaseId)
	if data.ProcessedReceipts[purchaseId] then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
	local _, def = productById(receiptInfo.ProductId)
	if not def then
		warn("[RushPlaza] Unknown product", receiptInfo.ProductId)
		data.ProcessedReceipts[purchaseId] = true
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
	if def.coins then
		data.Coins += def.coins
		Remotes.Toast:FireClient(player, string.format("Purchased +%d coins", def.coins))
		Remotes.Fx:FireClient(player, { kind = "CashPop", amount = def.coins })
	end
	if def.handler and handlers[def.handler] then
		handlers[def.handler](player)
	end
	data.ProcessedReceipts[purchaseId] = true
	PlayerData.Save(player)
	StateBus.Push(player, true)
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

function Monetization.Init()
	MarketplaceService.ProcessReceipt = processReceipt
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, _passId, wasPurchased)
		if wasPurchased then
			Monetization.RefreshPasses(player)
			Remotes.Toast:FireClient(player, "Game Pass unlocked")
			StateBus.Push(player, true)
		end
	end)
end

Players.PlayerRemoving:Connect(function(player)
	passCache[player.UserId] = nil
end)

return Monetization
]]
	writeScript(SSS, "ModuleScript", "Monetization", source)
end

-- ServerScriptService/PlayerData.lua
do
	local source = [=[local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local PlayerData = {}
local store = DataStoreService:GetDataStore(Config.DataStoreName)
local sessions = {}

local function emptyGarden()
	local plots = {}
	for i = 1, Config.Garden.Plots do
		plots[i] = { crop = "", readyAt = 0, watered = false }
	end
	return plots
end

local function defaultData()
	return {
		Coins = Config.StartingCoins,
		DailyStreak = 0,
		LastDailyDay = 0,
		Visited = {},
		Endings = {},
		OrbCash = 0,
		OrbRebirths = 0,
		OrbUpgrades = { MagnetRange = 0, MagnetPull = 0, OrbValue = 0, WalkSpeed = 0 },
		OrbCollected = 0,
		OrbNudgeShown = false,
		TycoonCash = 0,
		TycoonLevel = 0,
		Garden = emptyGarden(),
		ObbyBest = 0,
		RhythmBest = 0,
		HoopBest = 0,
		StallBest = 0,
		LuckyLuck = 0,
		StoryNode = "start",
		ProcessedReceipts = {},
	}
end

local function todayKey()
	local t = os.date("!*t")
	return t.year * 10000 + t.month * 100 + t.day
end

local function copySaved(saved)
	local data = defaultData()
	if typeof(saved) ~= "table" then
		return data
	end
	local direct = {
		"Coins", "DailyStreak", "LastDailyDay", "OrbCash", "OrbRebirths", "OrbCollected",
		"OrbNudgeShown", "TycoonCash", "TycoonLevel", "ObbyBest", "RhythmBest", "HoopBest",
		"StallBest", "LuckyLuck", "StoryNode",
	}
	for _, k in ipairs(direct) do
		if saved[k] ~= nil then
			data[k] = saved[k]
		end
	end
	if typeof(saved.OrbUpgrades) == "table" then
		for k, v in pairs(saved.OrbUpgrades) do
			data.OrbUpgrades[k] = v
		end
	end
	if typeof(saved.Visited) == "table" then
		data.Visited = saved.Visited
	end
	if typeof(saved.Endings) == "table" then
		data.Endings = saved.Endings
	end
	if typeof(saved.ProcessedReceipts) == "table" then
		data.ProcessedReceipts = saved.ProcessedReceipts
	end
	if typeof(saved.Garden) == "table" then
		for i = 1, Config.Garden.Plots do
			local g = saved.Garden[i]
			if typeof(g) == "table" then
				data.Garden[i] = {
					crop = g.crop or "",
					readyAt = g.readyAt or 0,
					watered = g.watered == true,
				}
			end
		end
	end
	return data
end

function PlayerData.Get(player)
	return sessions[player]
end

function PlayerData.Load(player)
	local data = defaultData()
	local ok, saved = pcall(function()
		return store:GetAsync("p_" .. player.UserId)
	end)
	if ok then
		data = copySaved(saved)
	end
	sessions[player] = data
	return data
end

function PlayerData.Save(player)
	local data = sessions[player]
	if not data then
		return
	end
	local receipts = data.ProcessedReceipts
	local keys = {}
	for id in pairs(receipts) do
		table.insert(keys, id)
	end
	if #keys > 80 then
		table.sort(keys)
		for i = 1, #keys - 80 do
			receipts[keys[i]] = nil
		end
	end
	pcall(function()
		store:SetAsync("p_" .. player.UserId, data)
	end)
end

function PlayerData.Unload(player)
	PlayerData.Save(player)
	sessions[player] = nil
end

function PlayerData.TodayKey()
	return todayKey()
end

function PlayerData.OrbCost(name, level)
	local def = Config.Orb.Upgrades[name]
	if not def then
		return math.huge
	end
	return math.floor(def.baseCost * (def.growth ^ level))
end

function PlayerData.RebirthCost(data)
	return math.floor(Config.Orb.RebirthBase * (Config.Orb.RebirthGrowth ^ data.OrbRebirths))
end

function PlayerData.OrbMult(data)
	return 1 + data.OrbRebirths * Config.Orb.RebirthMult
end

Players.PlayerRemoving:Connect(function(player)
	PlayerData.Unload(player)
end)

game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do
		PlayerData.Save(player)
	end
end)

return PlayerData
]=]
	writeScript(SSS, "ModuleScript", "PlayerData", source)
end

-- ServerScriptService/Presence.lua
do
	local source = [[local Players = game:GetService("Players")

local Presence = {}

function Presence.Count(gameId)
	local n = 0
	for _, p in ipairs(Players:GetPlayers()) do
		if p:GetAttribute("GameId") == gameId then
			n += 1
		end
	end
	return n
end

function Presence.Boost(player)
	local id = player:GetAttribute("GameId")
	if not id or id == "Hub" then
		return false
	end
	return Presence.Count(id) >= 2
end

return Presence
]]
	writeScript(SSS, "ModuleScript", "Presence", source)
end

-- ServerScriptService/RateLimit.lua
do
	local source = [[local RateLimit = {}

local buckets = {}

function RateLimit.Allow(player, key, cooldown)
	cooldown = cooldown or 0.15
	local map = buckets[player]
	if not map then
		map = {}
		buckets[player] = map
	end
	local now = os.clock()
	local last = map[key] or 0
	if now - last < cooldown then
		return false
	end
	map[key] = now
	return true
end

game:GetService("Players").PlayerRemoving:Connect(function(player)
	buckets[player] = nil
end)

return RateLimit
]]
	writeScript(SSS, "ModuleScript", "RateLimit", source)
end

-- ServerScriptService/Slots.lua
do
	local source = [[local Players = game:GetService("Players")

local Slots = {}
local used = {}

function Slots.Ensure(key, player, maxCount)
	local map = used[key]
	if not map then
		map = {}
		used[key] = map
	end
	for i, p in pairs(map) do
		if p == player then
			return i
		end
	end
	for i = 1, maxCount do
		if map[i] == nil then
			map[i] = player
			return i
		end
	end
	return nil
end

function Slots.Get(key, player)
	local map = used[key]
	if not map then
		return nil
	end
	for i, p in pairs(map) do
		if p == player then
			return i
		end
	end
	return nil
end

function Slots.Owner(key, index)
	local map = used[key]
	return map and map[index] or nil
end

Players.PlayerRemoving:Connect(function(player)
	for _, map in pairs(used) do
		for i, p in pairs(map) do
			if p == player then
				map[i] = nil
			end
		end
	end
end)

return Slots
]]
	writeScript(SSS, "ModuleScript", "Slots", source)
end

-- ServerScriptService/StateBus.lua
do
	local source = [[local StateBus = {}

local listener = nil

function StateBus.Set(fn)
	listener = fn
end

function StateBus.Push(player, immediate)
	if listener and player then
		listener(player, immediate == true)
	end
end

return StateBus
]]
	writeScript(SSS, "ModuleScript", "StateBus", source)
end

-- ServerScriptService/Util.lua
do
	local source = [[local Util = {}

function Util.model(parent, name)
	local m = Instance.new("Model")
	m.Name = name
	m.Parent = parent
	return m
end

function Util.part(parent, name, size, cf, color, material, canCollide, transparency)
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.Size = size
	p.CFrame = cf
	p.Color = color or Color3.fromRGB(30, 34, 48)
	p.Material = material or Enum.Material.SmoothPlastic
	p.CanCollide = canCollide ~= false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Transparency = transparency or 0
	p.Parent = parent
	return p
end

function Util.billboard(part, text, offset, size)
	local gui = Instance.new("BillboardGui")
	gui.Size = size or UDim2.fromOffset(180, 48)
	gui.StudsOffset = offset or Vector3.new(0, 4, 0)
	gui.AlwaysOnTop = true
	gui.MaxDistance = 200
	gui.Parent = part
	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.GothamBlack
	label.TextScaled = true
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.4
	label.Text = text
	label.Parent = gui
	return label
end

function Util.prompt(part, actionText, objectText)
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = actionText
	prompt.ObjectText = objectText or ""
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = part
	return prompt
end

function Util.spawnCf(origin, lookAt)
	local pos = origin + Vector3.new(0, 5, 0)
	if lookAt then
		return CFrame.lookAt(pos, lookAt)
	end
	return CFrame.new(pos)
end

return Util
]]
	writeScript(SSS, "ModuleScript", "Util", source)
end

-- ServerScriptService/WorldEvents.lua
do
	local source = [[local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))

local WorldEvents = {}

local current = nil
local endsAt = 0

local CYCLE = {
	{ id = "GoldRush", text = "GOLD RUSH — all earnings x2", seconds = 40 },
	{ id = "OrbStorm", text = "ORB STORM — magnets go wild", seconds = 40 },
	{ id = "LuckyMinute", text = "LUCKY MINUTE — center bins pull harder", seconds = 35 },
}

function WorldEvents.Current()
	if current and os.clock() < endsAt then
		return current
	end
	return nil
end

function WorldEvents.Multiplier()
	if WorldEvents.Current() == "GoldRush" then
		return 2
	end
	return 1
end

function WorldEvents.TimeLeft()
	if not current then
		return 0
	end
	return math.max(0, endsAt - os.clock())
end

local function applyLight()
	local name = WorldEvents.Current()
	if name == "GoldRush" then
		Lighting.Ambient = Color3.fromRGB(90, 70, 30)
		Lighting.OutdoorAmbient = Color3.fromRGB(90, 70, 30)
		Lighting.ClockTime = 17.2
	elseif name == "OrbStorm" then
		Lighting.Ambient = Color3.fromRGB(20, 40, 90)
		Lighting.OutdoorAmbient = Color3.fromRGB(20, 30, 70)
		Lighting.ClockTime = 0
	elseif name == "LuckyMinute" then
		Lighting.Ambient = Color3.fromRGB(70, 40, 90)
		Lighting.OutdoorAmbient = Color3.fromRGB(50, 30, 70)
		Lighting.ClockTime = 19
	else
		Lighting.Ambient = Color3.fromRGB(40, 48, 70)
		Lighting.OutdoorAmbient = Color3.fromRGB(35, 40, 55)
		Lighting.ClockTime = 20.4
		Lighting.Brightness = 2
	end
end

function WorldEvents.Init()
	Lighting.ClockTime = 20.4
	task.spawn(function()
		local index = 1
		task.wait(20)
		while true do
			local ev = CYCLE[index]
			index = index % #CYCLE + 1
			current = ev.id
			endsAt = os.clock() + ev.seconds
			applyLight()
			for _, p in ipairs(Players:GetPlayers()) do
				Remotes.Toast:FireClient(p, ev.text)
			end
			task.wait(ev.seconds)
			current = nil
			applyLight()
			task.wait(100)
		end
	end)
end

return WorldEvents
]]
	writeScript(SSS, "ModuleScript", "WorldEvents", source)
end

-- ServerScriptService/Games/DuoExtract.lua
do
	local source = [[local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))
local Monetization = require(script.Parent.Parent:WaitForChild("Monetization"))
local StateBus = require(script.Parent.Parent:WaitForChild("StateBus"))
local Util = require(script.Parent.Parent:WaitForChild("Util"))

local DuoExtract = {}
DuoExtract.Id = "DuoExtract"

local cfg = Config.Extract
local carry = {}
local savedCarry = {}
local roundId = 0
local roundEnds = 0
local chests = {}
local taken = {}
local hazard
local spawnCf

local function origin()
	return Config.Layout.DuoExtract
end

local function inGame(player)
	return player:GetAttribute("GameId") == "DuoExtract"
end

function DuoExtract.SpawnCFrame()
	return spawnCf or Util.spawnCf(origin())
end

function DuoExtract.Snapshot(player)
	local key = taken[player]
	local got = key and key.round == roundId and key.count or 0
	return {
		carry = carry[player] or 0,
		timeLeft = math.max(0, roundEnds - os.clock()),
		looted = got,
		subtitle = string.format("Carry %d   extract %ds", carry[player] or 0, math.max(0, math.floor(roundEnds - os.clock()))),
	}
end

local function resetRound()
	roundId += 1
	roundEnds = os.clock() + cfg.RoundSeconds
	for _, chest in ipairs(chests) do
		chest.Transparency = 0
		chest.CanTouch = true
		chest:SetAttribute("Alive", true)
	end
	for _, player in ipairs(Players:GetPlayers()) do
		if (carry[player] or 0) > 0 then
			Remotes.Toast:FireClient(player, "Round over — unbanked loot lost")
		end
		carry[player] = 0
		taken[player] = { round = roundId, count = 0 }
		if inGame(player) then
			StateBus.Push(player, false)
		end
	end
	for _, player in ipairs(Players:GetPlayers()) do
		if inGame(player) then
			Remotes.Toast:FireClient(player, "New extract round — bank loot on the green pad")
		end
	end
end

function DuoExtract.Revive(player)
	local restore = savedCarry[player] or carry[player] or 0
	carry[player] = restore
	savedCarry[player] = 0
	local character = player.Character
	local hum = character and character:FindFirstChildOfClass("Humanoid")
	if hum and hum.Health > 0 then
		hum.Health = hum.MaxHealth
	else
		player:SetAttribute("GameId", "DuoExtract")
		player:LoadCharacter()
	end
	Remotes.Toast:FireClient(player, "Revived")
	StateBus.Push(player, true)
end

function DuoExtract.Build()
	local o = origin()
	local model = Util.model(Workspace, "DuoExtract")
	Util.part(model, "Floor", Vector3.new(90, 2, 90), CFrame.new(o), Color3.fromRGB(40, 28, 24), Enum.Material.Slate, true)
	spawnCf = CFrame.new(o + Vector3.new(0, 5, 32))
	local pad = Util.part(model, "Extract", Vector3.new(14, 1, 14), CFrame.new(o + Vector3.new(0, 1.2, 30)), Color3.fromRGB(80, 220, 120), Enum.Material.Neon, true)
	Util.billboard(pad, "EXTRACT", Vector3.new(0, 5, 0))
	pad.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if not player or not inGame(player) then
			return
		end
		local bag = carry[player] or 0
		if bag <= 0 then
			return
		end
		carry[player] = 0
		local payout = math.floor(bag * Monetization.Multiplier(player, "coins"))
		Monetization.GrantCoins(player, payout, "extract", true)
	end)

	for i = 1, cfg.Chests do
		local angle = (i / cfg.Chests) * math.pi * 2
		local pos = o + Vector3.new(math.cos(angle) * 28, 2, math.sin(angle) * 28)
		local chest = Util.part(model, "Chest" .. i, Vector3.new(3, 2, 3), CFrame.new(pos), Color3.fromRGB(255, 170, 60), Enum.Material.Neon, false)
		chest.CanTouch = true
		chest:SetAttribute("Value", 25 + (i % 3) * 20)
		chest:SetAttribute("Alive", true)
		chest.Touched:Connect(function(hit)
			local player = Players:GetPlayerFromCharacter(hit.Parent)
			if not player or not inGame(player) then
				return
			end
			if chest:GetAttribute("Alive") ~= true then
				return
			end
			local stamp = taken[player]
			if not stamp or stamp.round ~= roundId then
				stamp = { round = roundId, count = 0 }
				taken[player] = stamp
			end
			if stamp["c" .. i] then
				return
			end
			stamp["c" .. i] = true
			stamp.count += 1
			-- personal loot: chest stays for others, this player can't retake
			local value = chest:GetAttribute("Value") or 30
			carry[player] = (carry[player] or 0) + value
			Remotes.Toast:FireClient(player, "+" .. value .. " carry")
			StateBus.Push(player, true)
			-- if every current player has taken it, hide — keep simple: hide after 1 global take so it's tense
			chest:SetAttribute("Alive", false)
			chest.Transparency = 0.85
			chest.CanTouch = false
		end)
		table.insert(chests, chest)
	end

	hazard = Util.part(model, "Hazard", Vector3.new(6, 6, 6), CFrame.new(o + Vector3.new(0, 4, 0)), Color3.fromRGB(255, 50, 40), Enum.Material.Neon, false)
	hazard.Shape = Enum.PartType.Ball
	hazard.CanTouch = true
	local lastHit = {}
	hazard.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if not player or not inGame(player) then
			return
		end
		if (lastHit[player] or 0) + 0.8 > os.clock() then
			return
		end
		lastHit[player] = os.clock()
		local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if not hum or hum.Health <= 0 then
			return
		end
		savedCarry[player] = carry[player] or 0
		hum:TakeDamage(cfg.HazardDamage)
		Remotes.Toast:FireClient(player, "Hazard hit")
		if hum.Health <= 0 then
			carry[player] = 0
		end
	end)
	Util.billboard(hazard, "HAZARD", Vector3.new(0, 5, 0))
end

function DuoExtract.Init()
	Monetization.SetHandler("ExtractRevive", DuoExtract.Revive)
	resetRound()
	task.spawn(function()
		while true do
			if os.clock() >= roundEnds then
				resetRound()
			end
			local o = origin()
			local t = os.clock()
			if hazard then
				hazard.Position = o + Vector3.new(math.cos(t * 0.7) * 24, 4, math.sin(t * 0.45) * 24)
			end
			task.wait(0.1)
		end
	end)

	local function hook(player)
		player.CharacterAdded:Connect(function(character)
			local hum = character:WaitForChild("Humanoid", 5)
			if not hum then
				return
			end
			hum.Died:Connect(function()
				if inGame(player) then
					savedCarry[player] = savedCarry[player] or carry[player] or 0
					carry[player] = 0
				end
			end)
		end)
	end
	Players.PlayerAdded:Connect(hook)
	for _, p in ipairs(Players:GetPlayers()) do
		hook(p)
	end
end

Players.PlayerRemoving:Connect(function(player)
	carry[player] = nil
	savedCarry[player] = nil
	taken[player] = nil
end)

return DuoExtract
]]
	writeScript(gamesFolder, "ModuleScript", "DuoExtract", source)
end

-- ServerScriptService/Games/GardenPocket.lua
do
	local source = [[local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))
local PlayerData = require(script.Parent.Parent:WaitForChild("PlayerData"))
local Monetization = require(script.Parent.Parent:WaitForChild("Monetization"))
local Slots = require(script.Parent.Parent:WaitForChild("Slots"))
local StateBus = require(script.Parent.Parent:WaitForChild("StateBus"))
local Util = require(script.Parent.Parent:WaitForChild("Util"))

local GardenPocket = {}
GardenPocket.Id = "GardenPocket"

local soils = {}
local ownerLabels = {}

local function cropById(id)
	for _, c in ipairs(Config.Garden.Crops) do
		if c.id == id then
			return c
		end
	end
	return nil
end

local function origin()
	return Config.Layout.GardenPocket
end

local function slotOrigin(index)
	return origin() + Vector3.new(0, 0, (index - 3.5) * 28)
end

function GardenPocket.SpawnCFrame(player)
	local slot = Slots.Get("Garden", player) or 1
	return CFrame.new(slotOrigin(slot) + Vector3.new(-16, 5, 0))
end

function GardenPocket.OnEnter(player)
	if not Slots.Ensure("Garden", player, Config.Garden.Slots) then
		Remotes.Toast:FireClient(player, "Garden rows are full — use the HUD anyway if you already planted")
	end
end

local function plotState(plot)
	local now = os.time()
	if plot.crop == "" then
		return { crop = "", ready = false, left = 0, watered = false }
	end
	local left = math.max(0, (plot.readyAt or 0) - now)
	return { crop = plot.crop, ready = left <= 0, left = left, watered = plot.watered == true }
end

function GardenPocket.Snapshot(player)
	local data = PlayerData.Get(player)
	if not data then
		return nil
	end
	local plots = {}
	local ready = 0
	for i, plot in ipairs(data.Garden) do
		plots[i] = plotState(plot)
		if plots[i].ready then
			ready += 1
		end
	end
	return {
		plots = plots,
		crops = Config.Garden.Crops,
		subtitle = ready > 0 and (ready .. " ready to harvest") or "Plant, leave, come back",
	}
end

function GardenPocket.PlantOrHarvest(player, index, cropId)
	local data = PlayerData.Get(player)
	if not data then
		return
	end
	index = math.floor(tonumber(index) or 0)
	local plot = data.Garden[index]
	if not plot then
		return
	end
	local view = plotState(plot)
	if view.crop ~= "" and view.ready then
		local crop = cropById(plot.crop)
		local value = crop and crop.value or 10
		value = math.floor(value * Monetization.Multiplier(player, "coins"))
		plot.crop = ""
		plot.readyAt = 0
		plot.watered = false
		Monetization.GrantCoins(player, value, "harvest", true)
		return
	end
	if view.crop ~= "" then
		Remotes.Toast:FireClient(player, "Still growing (" .. view.left .. "s)")
		return
	end
	local crop = cropById(cropId)
	if not crop then
		Remotes.Toast:FireClient(player, "Pick a crop")
		return
	end
	if data.Coins < crop.cost then
		Remotes.Toast:FireClient(player, "Need " .. crop.cost .. " coins")
		return
	end
	data.Coins -= crop.cost
	plot.crop = crop.id
	plot.readyAt = os.time() + crop.time
	plot.watered = false
	Remotes.Toast:FireClient(player, "Planted " .. crop.name)
	StateBus.Push(player, true)
end

function GardenPocket.Water(player, index)
	local data = PlayerData.Get(player)
	index = math.floor(tonumber(index) or 0)
	local plot = data and data.Garden[index]
	if not plot or plot.crop == "" or plot.watered then
		Remotes.Toast:FireClient(player, "Nothing to water")
		return
	end
	local left = math.max(0, plot.readyAt - os.time())
	plot.readyAt = os.time() + math.floor(left * 0.7)
	plot.watered = true
	Remotes.Toast:FireClient(player, "Watered — 30% faster")
	StateBus.Push(player, true)
end

function GardenPocket.FinishAll(player)
	local data = PlayerData.Get(player)
	if not data then
		return
	end
	for _, plot in ipairs(data.Garden) do
		if plot.crop ~= "" then
			plot.readyAt = os.time()
		end
	end
	Remotes.Toast:FireClient(player, "Crops ready")
end

function GardenPocket.Build()
	local model = Util.model(Workspace, "GardenPocket")
	Util.part(model, "Floor", Vector3.new(90, 2, 200), CFrame.new(origin()), Color3.fromRGB(28, 40, 28), Enum.Material.Grass, true)
	for s = 1, Config.Garden.Slots do
		local o = slotOrigin(s)
		soils[s] = {}
		local sign = Util.part(model, "Sign" .. s, Vector3.new(4, 4, 1), CFrame.new(o + Vector3.new(-18, 3, 0)), Color3.fromRGB(90, 60, 30), Enum.Material.Wood, true)
		ownerLabels[s] = Util.billboard(sign, "Garden row", Vector3.new(0, 4, 0))
		for p = 1, Config.Garden.Plots do
			local soil = Util.part(model, "Soil", Vector3.new(5, 1, 5), CFrame.new(o + Vector3.new((p - 3.5) * 7, 1, 0)), Color3.fromRGB(96, 64, 40), Enum.Material.Ground, true)
			soils[s][p] = soil
		end
	end
	Util.billboard(model.Floor, "POCKET GARDEN", Vector3.new(0, 8, 0), UDim2.fromOffset(240, 40))
end

function GardenPocket.Init()
	Monetization.SetHandler("GardenFinish", GardenPocket.FinishAll)
	task.spawn(function()
		while true do
			for s = 1, Config.Garden.Slots do
				local owner = Slots.Owner("Garden", s)
				if ownerLabels[s] then
					ownerLabels[s].Text = owner and (owner.DisplayName .. "'s garden") or "Empty row"
				end
				local data = owner and PlayerData.Get(owner)
				for p = 1, Config.Garden.Plots do
					local soil = soils[s][p]
					if soil and data then
						local view = plotState(data.Garden[p])
						if view.crop == "" then
							soil.Color = Color3.fromRGB(96, 64, 40)
						elseif view.ready then
							soil.Color = Color3.fromRGB(255, 210, 70)
						else
							soil.Color = Color3.fromRGB(70, 160, 80)
						end
					elseif soil then
						soil.Color = Color3.fromRGB(96, 64, 40)
					end
				end
			end
			task.wait(1)
		end
	end)
end

Players.PlayerRemoving:Connect(function() end)

return GardenPocket
]]
	writeScript(gamesFolder, "ModuleScript", "GardenPocket", source)
end

-- ServerScriptService/Games/HoopShot.lua
do
	local source = [[local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))
local PlayerData = require(script.Parent.Parent:WaitForChild("PlayerData"))
local Monetization = require(script.Parent.Parent:WaitForChild("Monetization"))
local StateBus = require(script.Parent.Parent:WaitForChild("StateBus"))
local Util = require(script.Parent.Parent:WaitForChild("Util"))

local HoopShot = {}
HoopShot.Id = "HoopShot"

local streak = {}
local hoopPos
local spawnCf

local function origin()
	return Config.Layout.HoopShot
end

function HoopShot.SpawnCFrame()
	return spawnCf or CFrame.new(origin() + Vector3.new(0, 5, 24))
end

function HoopShot.Snapshot(player)
	local data = PlayerData.Get(player)
	return {
		streak = streak[player] or 0,
		best = data and data.HoopBest or 0,
		subtitle = string.format("Streak %d   best %d", streak[player] or 0, data and data.HoopBest or 0),
	}
end

function HoopShot.Shoot(player, power)
	if player:GetAttribute("GameId") ~= "HoopShot" then
		return
	end
	power = tonumber(power) or 0.6
	if power ~= power then
		power = 0.6
	end
	power = math.clamp(power, 0.15, 1)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root or not hoopPos then
		return
	end
	local look = root.CFrame.LookVector
	look = Vector3.new(look.X, 0, look.Z)
	if look.Magnitude < 0.2 then
		look = Vector3.new(0, 0, -1)
	end
	look = look.Unit
	local pos = root.Position + Vector3.new(0, 2, 0) + look * 2
	local vel = look * (55 + power * 80) + Vector3.new(0, 36 + power * 55, 0)
	local ball = Util.part(Workspace, "Shot", Vector3.new(2, 2, 2), CFrame.new(pos), Color3.fromRGB(255, 140, 40), Enum.Material.SmoothPlastic, false)
	ball.Shape = Enum.PartType.Ball
	local scored = false
	local g = Vector3.new(0, -workspace.Gravity, 0)
	task.spawn(function()
		local p = pos
		local v = vel
		for _ = 1, 50 do
			local dt = 0.05
			v += g * dt
			local nextP = p + v * dt
			if not scored and v.Y < 0 then
				local mid = (p + nextP) * 0.5
				if (Vector3.new(mid.X, hoopPos.Y, mid.Z) - hoopPos).Magnitude < 2.2 and math.abs(mid.Y - hoopPos.Y) < 2.5 then
					scored = true
				end
			end
			p = nextP
			if ball.Parent then
				ball.Position = p
			end
			if p.Y < origin().Y then
				break
			end
			task.wait(dt)
		end
		if ball.Parent then
			ball:Destroy()
		end
		local data = PlayerData.Get(player)
		if scored then
			streak[player] = (streak[player] or 0) + 1
			if data and streak[player] > data.HoopBest then
				data.HoopBest = streak[player]
			end
			local reward = math.floor(Config.Hoop.Reward * streak[player] * Monetization.Multiplier(player, "coins"))
			Monetization.GrantCoins(player, reward, "bucket x" .. streak[player], true)
		else
			streak[player] = 0
			Remotes.Toast:FireClient(player, "Brick")
			StateBus.Push(player, true)
		end
	end)
end

function HoopShot.Build()
	local o = origin()
	local model = Util.model(Workspace, "HoopShot")
	Util.part(model, "Court", Vector3.new(40, 2, 56), CFrame.new(o + Vector3.new(0, 0, 6)), Color3.fromRGB(180, 90, 40), Enum.Material.WoodPlanks, true)
	hoopPos = o + Vector3.new(0, 12, -8)
	spawnCf = CFrame.lookAt(o + Vector3.new(0, 4, 22), hoopPos)
	local pole = Util.part(model, "Pole", Vector3.new(1, 14, 1), CFrame.new(o + Vector3.new(0, 8, -12)), Color3.fromRGB(40, 40, 48), Enum.Material.Metal, true)
	Util.part(model, "Board", Vector3.new(8, 5, 0.5), CFrame.new(o + Vector3.new(0, 13, -11)), Color3.fromRGB(240, 240, 245), Enum.Material.SmoothPlastic, true)
	local rim = Util.part(model, "Rim", Vector3.new(0.4, 3.2, 3.2), CFrame.new(hoopPos) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(255, 80, 40), Enum.Material.Neon, false)
	rim.Shape = Enum.PartType.Cylinder
	Util.billboard(pole, "HOOP RUSH\nHold shoot, release", Vector3.new(0, 10, 0), UDim2.fromOffset(200, 60))
end

function HoopShot.Init() end

game:GetService("Players").PlayerRemoving:Connect(function(player)
	streak[player] = nil
end)

return HoopShot
]]
	writeScript(gamesFolder, "ModuleScript", "HoopShot", source)
end

-- ServerScriptService/Games/HubWorld.lua
do
	local source = [[local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Util = require(script.Parent.Parent:WaitForChild("Util"))

local HubWorld = {}
HubWorld.Id = "Hub"

local countLabels = {}

function HubWorld.SpawnCFrame()
	return CFrame.new(Config.Layout.Hub + Vector3.new(0, 5, 0))
end

function HubWorld.Build()
	local origin = Config.Layout.Hub
	local model = Util.model(Workspace, "Hub")
	Util.part(model, "Floor", Vector3.new(220, 2, 220), CFrame.new(origin + Vector3.new(0, 0, 0)), Color3.fromRGB(22, 26, 38), Enum.Material.SmoothPlastic, true)

	local monument = Util.part(model, "Monument", Vector3.new(10, 18, 10), CFrame.new(origin + Vector3.new(0, 10, 0)), Color3.fromRGB(80, 200, 255), Enum.Material.Neon, true)
	Util.billboard(monument, "RUSH PLAZA\n10 games  •  +15% with a friend", Vector3.new(0, 12, 0), UDim2.fromOffset(280, 80))

	local n = #Config.Catalog
	for i, info in ipairs(Config.Catalog) do
		local angle = ((i - 1) / n) * math.pi * 2
		local pos = origin + Vector3.new(math.cos(angle) * 78, 2, math.sin(angle) * 78)
		local pad = Util.part(model, "Portal_" .. info.id, Vector3.new(10, 1, 10), CFrame.new(pos), info.color, Enum.Material.Neon, true)
		local label = Util.billboard(pad, info.name .. "\n" .. info.blurb, Vector3.new(0, 5, 0), UDim2.fromOffset(200, 70))
		countLabels[info.id] = label
		local prompt = Util.prompt(pad, "Play", info.name)
		prompt:SetAttribute("Dest", info.id)
		CollectionService:AddTag(prompt, "RushPortal")
	end

	local board = Util.part(model, "EventBoard", Vector3.new(14, 8, 1), CFrame.new(origin + Vector3.new(0, 6, -28)), Color3.fromRGB(16, 18, 28), Enum.Material.SmoothPlastic, false)
	local sg = Instance.new("SurfaceGui")
	sg.Face = Enum.NormalId.Front
	sg.CanvasSize = Vector2.new(400, 240)
	sg.Parent = board
	local title = Instance.new("TextLabel")
	title.Name = "EventText"
	title.Size = UDim2.fromScale(1, 1)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBlack
	title.TextSize = 28
	title.TextWrapped = true
	title.TextColor3 = Color3.fromRGB(255, 220, 120)
	title.Text = "Events cycle every few minutes.\nGold Rush  •  Orb Storm  •  Lucky Minute"
	title.Parent = sg
	HubWorld.EventLabel = title
end

function HubWorld.SetCount(id, n, name)
	local label = countLabels[id]
	if label then
		label.Text = string.format("%s\n%d playing", name, n)
	end
end

function HubWorld.Init() end

return HubWorld
]]
	writeScript(gamesFolder, "ModuleScript", "HubWorld", source)
end

-- ServerScriptService/Games/LuckyDrop.lua
do
	local source = [[local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))
local PlayerData = require(script.Parent.Parent:WaitForChild("PlayerData"))
local Monetization = require(script.Parent.Parent:WaitForChild("Monetization"))
local WorldEvents = require(script.Parent.Parent:WaitForChild("WorldEvents"))
local StateBus = require(script.Parent.Parent:WaitForChild("StateBus"))
local Util = require(script.Parent.Parent:WaitForChild("Util"))

local LuckyDrop = {}
LuckyDrop.Id = "LuckyDrop"

local cfg = Config.Lucky
local busy = {}

local function origin()
	return Config.Layout.LuckyDrop
end

local function binX(col)
	return (col - 4) * 7
end

function LuckyDrop.SpawnCFrame()
	return CFrame.lookAt(origin() + Vector3.new(0, 5, 28), origin())
end

function LuckyDrop.Snapshot(player)
	local data = PlayerData.Get(player)
	if not data then
		return nil
	end
	local cost = math.floor(cfg.LuckBase * (cfg.LuckGrowth ^ data.LuckyLuck))
	return {
		luck = data.LuckyLuck,
		luckCost = cost,
		entry = cfg.Entry,
		maxed = data.LuckyLuck >= cfg.LuckMax,
		subtitle = string.format("Luck Lv %d   drop %d coins", data.LuckyLuck, cfg.Entry),
	}
end

function LuckyDrop.Upgrade(player)
	local data = PlayerData.Get(player)
	if not data then
		return
	end
	if data.LuckyLuck >= cfg.LuckMax then
		Remotes.Toast:FireClient(player, "Luck maxed")
		return
	end
	local cost = math.floor(cfg.LuckBase * (cfg.LuckGrowth ^ data.LuckyLuck))
	if data.Coins < cost then
		Remotes.Toast:FireClient(player, "Not enough coins")
		return
	end
	data.Coins -= cost
	data.LuckyLuck += 1
	Remotes.Toast:FireClient(player, "Luck " .. data.LuckyLuck)
	StateBus.Push(player, true)
end

function LuckyDrop.Drop(player)
	if busy[player] then
		return
	end
	local data = PlayerData.Get(player)
	if not data then
		return
	end
	if player:GetAttribute("GameId") ~= "LuckyDrop" then
		Remotes.Toast:FireClient(player, "Stand in Lucky Drop")
		return
	end
	if data.Coins < cfg.Entry then
		Remotes.Toast:FireClient(player, "Need " .. cfg.Entry .. " coins")
		return
	end
	data.Coins -= cfg.Entry
	busy[player] = true
	StateBus.Push(player, true)

	local luck = data.LuckyLuck
	if WorldEvents.Current() == "LuckyMinute" then
		luck += 8
	end
	local col = 4
	local path = { col }
	for _ = 1, 8 do
		local toward = col < 4 and 1 or (col > 4 and -1 or (math.random() < 0.5 and 1 or -1))
		local bias = math.clamp(0.5 + luck * 0.03, 0.5, 0.85)
		local step = (math.random() < bias) and toward or -toward
		if step == 0 then
			step = 1
		end
		col = math.clamp(col + step, 1, 7)
		table.insert(path, col)
	end

	local ball = Util.part(Workspace, "LuckyBall", Vector3.new(1.4, 1.4, 1.4), CFrame.new(origin() + Vector3.new(0, 22, 0)), Color3.fromRGB(255, 230, 120), Enum.Material.Neon, false)
	ball.Shape = Enum.PartType.Ball
	for row, c in ipairs(path) do
		local target = origin() + Vector3.new(binX(c), 20 - row * 2, 0)
		for _ = 1, 4 do
			if ball.Parent then
				ball.Position = ball.Position:Lerp(target, 0.45)
			end
			task.wait(0.03)
		end
	end
	if ball.Parent then
		ball:Destroy()
	end

	local mult = cfg.Bins[col] or 0
	local payout = math.floor(cfg.Entry * mult * Monetization.Multiplier(player, "coins"))
	if payout > 0 then
		Monetization.GrantCoins(player, payout, mult .. "x bin", true)
	else
		Remotes.Toast:FireClient(player, "Miss — 0x")
	end
	busy[player] = nil
	StateBus.Push(player, true)
end

function LuckyDrop.Build()
	local o = origin()
	local model = Util.model(Workspace, "LuckyDrop")
	Util.part(model, "Floor", Vector3.new(80, 2, 80), CFrame.new(o + Vector3.new(0, 0, 10)), Color3.fromRGB(28, 22, 40), Enum.Material.SmoothPlastic, true)
	for col = 1, 7 do
		local mult = cfg.Bins[col]
		local color = mult >= 8 and Color3.fromRGB(255, 210, 70) or (mult > 0 and Color3.fromRGB(120, 90, 200) or Color3.fromRGB(60, 60, 70))
		local bin = Util.part(model, "Bin" .. col, Vector3.new(6, 3, 6), CFrame.new(o + Vector3.new(binX(col), 1.5, 0)), color, Enum.Material.Neon, true)
		Util.billboard(bin, tostring(mult) .. "x", Vector3.new(0, 3, 0))
	end
	for row = 1, 6 do
		for peg = 1, 6 do
			local x = (peg - 3.5) * 7 + (row % 2 == 0 and 3.5 or 0)
			Util.part(model, "Peg", Vector3.new(0.8, 0.8, 0.8), CFrame.new(o + Vector3.new(x, 6 + row * 2, 0)), Color3.fromRGB(200, 200, 255), Enum.Material.Neon, false)
		end
	end
	Util.billboard(model.Bin4, "LUCKY DROP", Vector3.new(0, 16, 0), UDim2.fromOffset(220, 40))
end

function LuckyDrop.Init() end

game:GetService("Players").PlayerRemoving:Connect(function(player)
	busy[player] = nil
end)

return LuckyDrop
]]
	writeScript(gamesFolder, "ModuleScript", "LuckyDrop", source)
end

-- ServerScriptService/Games/ObbyRace.lua
do
	local source = [[local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))
local PlayerData = require(script.Parent.Parent:WaitForChild("PlayerData"))
local Monetization = require(script.Parent.Parent:WaitForChild("Monetization"))
local Util = require(script.Parent.Parent:WaitForChild("Util"))

local ObbyRace = {}
ObbyRace.Id = "ObbyRace"

local stageOf = {}
local startedAt = {}
local checkpoints = {}
local finished = {}
local pads = {}
local defaultCf

local function origin()
	return Config.Layout.ObbyRace
end

local function inGame(player)
	return player:GetAttribute("GameId") == "ObbyRace"
end

function ObbyRace.SpawnCFrame(player)
	return checkpoints[player] or defaultCf or Util.spawnCf(origin())
end

function ObbyRace.OnEnter(player)
	stageOf[player] = 0
	startedAt[player] = nil
	finished[player] = false
	checkpoints[player] = defaultCf
end

function ObbyRace.Snapshot(player)
	local data = PlayerData.Get(player)
	local elapsed = 0
	if startedAt[player] then
		elapsed = os.clock() - startedAt[player]
	end
	return {
		stage = stageOf[player] or 0,
		stages = Config.Obby.Stages,
		best = data and data.ObbyBest or 0,
		elapsed = elapsed,
		subtitle = string.format("Stage %d/%d", stageOf[player] or 0, Config.Obby.Stages),
	}
end

local function reach(player, stage, cf)
	if not inGame(player) or finished[player] then
		return
	end
	local current = stageOf[player] or 0
	if stage ~= current + 1 then
		return
	end
	stageOf[player] = stage
	checkpoints[player] = cf
	if stage == 1 then
		startedAt[player] = os.clock()
	end
	if stage >= Config.Obby.Stages then
		finished[player] = true
		local data = PlayerData.Get(player)
		local elapsed = os.clock() - (startedAt[player] or os.clock())
		local reward = Config.Obby.FinishReward
		if elapsed <= Config.Obby.SpeedTime then
			reward += Config.Obby.SpeedBonus
		end
		reward = math.floor(reward * Monetization.Multiplier(player, "coins"))
		Monetization.GrantCoins(player, reward, string.format("finish %.1fs", elapsed), true)
		if data and (data.ObbyBest == 0 or elapsed < data.ObbyBest) then
			data.ObbyBest = elapsed
			Remotes.Toast:FireClient(player, string.format("New best %.1fs", elapsed))
		end
	end
	local StateBus = require(script.Parent.Parent:WaitForChild("StateBus"))
	StateBus.Push(player, true)
end

function ObbyRace.Build()
	local o = origin()
	local model = Util.model(Workspace, "ObbyRace")
	defaultCf = CFrame.new(o + Vector3.new(0, 6, 0))
	Util.part(model, "Start", Vector3.new(12, 1, 12), CFrame.new(o + Vector3.new(0, 3, 0)), Color3.fromRGB(80, 220, 140), Enum.Material.Neon, true)
	Util.billboard(model.Start, "60s RUN", Vector3.new(0, 5, 0))

	local lava = Util.part(model, "Lava", Vector3.new(220, 1, 40), CFrame.new(o + Vector3.new(80, 0, 0)), Color3.fromRGB(180, 40, 30), Enum.Material.Neon, false)
	local lavaAt = {}
	lava.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if not player or not inGame(player) then
			return
		end
		if (lavaAt[player] or 0) + 0.6 > os.clock() then
			return
		end
		lavaAt[player] = os.clock()
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if root then
			root.CFrame = ObbyRace.SpawnCFrame(player)
			root.AssemblyLinearVelocity = Vector3.zero
		end
	end)

	for i = 1, Config.Obby.Stages do
		local y = 3 + (i % 3) * 3
		local cf = CFrame.new(o + Vector3.new(i * 16, y, (i % 2 == 0) and 4 or -4))
		local pad = Util.part(model, "Stage" .. i, Vector3.new(9, 1, 9), cf, i == Config.Obby.Stages and Color3.fromRGB(255, 210, 70) or Color3.fromRGB(70, 130, 220), Enum.Material.SmoothPlastic, true)
		pad:SetAttribute("Stage", i)
		pads[i] = { part = pad, base = cf }
		local stand = cf + Vector3.new(0, 4, 0)
		pad.Touched:Connect(function(hit)
			local player = Players:GetPlayerFromCharacter(hit.Parent)
			if player then
				reach(player, i, stand)
			end
		end)
	end
end

function ObbyRace.Init()
	task.spawn(function()
		while true do
			local t = os.clock()
			for _, idx in ipairs({ 4, 8 }) do
				local info = pads[idx]
				if info then
					info.part.CFrame = info.base + Vector3.new(0, 0, math.sin(t * 1.4 + idx) * 7)
				end
			end
			task.wait(0.05)
		end
	end)
end

Players.PlayerRemoving:Connect(function(player)
	stageOf[player] = nil
	startedAt[player] = nil
	checkpoints[player] = nil
	finished[player] = nil
end)

return ObbyRace
]]
	writeScript(gamesFolder, "ModuleScript", "ObbyRace", source)
end

-- ServerScriptService/Games/OrbRush.lua
do
	local source = [[local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))
local PlayerData = require(script.Parent.Parent:WaitForChild("PlayerData"))
local Monetization = require(script.Parent.Parent:WaitForChild("Monetization"))
local WorldEvents = require(script.Parent.Parent:WaitForChild("WorldEvents"))
local StateBus = require(script.Parent.Parent:WaitForChild("StateBus"))
local Util = require(script.Parent.Parent:WaitForChild("Util"))

local OrbRush = {}
OrbRush.Id = "OrbRush"

local cfg = Config.Orb
local folder
local orbs = {}
local orbCount = 0
local combos = {}

local function origin()
	return Config.Layout.OrbRush
end

local function inGame(player)
	return player:GetAttribute("GameId") == "OrbRush"
end

local function pickTier()
	local total = 0
	for _, t in ipairs(cfg.Tiers) do
		total += t.weight
	end
	local roll = math.random() * total
	local acc = 0
	for _, t in ipairs(cfg.Tiers) do
		acc += t.weight
		if roll <= acc then
			return t
		end
	end
	return cfg.Tiers[1]
end

local function stats(player)
	local data = PlayerData.Get(player)
	if not data then
		return cfg.BaseRange, cfg.BasePull, cfg.BaseValue, cfg.BaseSpeed
	end
	local ups = cfg.Upgrades
	local range = cfg.BaseRange + data.OrbUpgrades.MagnetRange * ups.MagnetRange.perLevel
	local pull = cfg.BasePull + data.OrbUpgrades.MagnetPull * ups.MagnetPull.perLevel
	local value = cfg.BaseValue + data.OrbUpgrades.OrbValue * ups.OrbValue.perLevel
	local speed = cfg.BaseSpeed + data.OrbUpgrades.WalkSpeed * ups.WalkSpeed.perLevel
	if Monetization.Owns(player, "VipMagnet") then
		range += cfg.VipRange
		pull += cfg.VipPull
	end
	if WorldEvents.Current() == "OrbStorm" then
		range += 10
		pull += 18
	end
	return range, pull, value, speed
end

local function updateAura(player)
	local character = player.Character
	if not character then
		return
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	local hum = character:FindFirstChildOfClass("Humanoid")
	if not root or not hum then
		return
	end
	if not inGame(player) then
		local old = character:FindFirstChild("MagnetAura")
		if old then
			old:Destroy()
		end
		hum.WalkSpeed = 16
		return
	end
	local range, _, _, speed = stats(player)
	hum.WalkSpeed = speed
	local aura = character:FindFirstChild("MagnetAura")
	if not aura then
		aura = Instance.new("Part")
		aura.Name = "MagnetAura"
		aura.Shape = Enum.PartType.Cylinder
		aura.Anchored = false
		aura.CanCollide = false
		aura.CanQuery = false
		aura.CanTouch = false
		aura.Massless = true
		aura.Material = Enum.Material.ForceField
		aura.Color = Color3.fromRGB(80, 200, 255)
		aura.Transparency = 0.78
		aura.Parent = character
		local weld = Instance.new("Weld")
		weld.Part0 = root
		weld.Part1 = aura
		weld.C0 = CFrame.Angles(0, 0, math.rad(90))
		weld.Parent = aura
	end
	aura.Size = Vector3.new(0.25, range * 2, range * 2)
end

local function bumpCombo(player)
	local now = os.clock()
	local c = combos[player]
	if not c or now > c.expires then
		c = { count = 0, expires = now }
		combos[player] = c
	end
	c.count += 1
	c.expires = now + cfg.ComboWindow
	return c.count
end

local function collect(player, part)
	local meta = orbs[part]
	if not meta then
		return
	end
	orbs[part] = nil
	orbCount = math.max(0, orbCount - 1)
	part:Destroy()
	local data = PlayerData.Get(player)
	if not data then
		return
	end
	local _, _, value = stats(player)
	local combo = bumpCombo(player)
	local comboMult = 1 + math.min(0.5, (combo - 1) * 0.02)
	local gain = math.max(1, math.floor(value * meta.mult * Monetization.Multiplier(player, "orb") * comboMult))
	data.OrbCash += gain
	data.OrbCollected += 1
	if meta.colorIndex >= 4 then
		Remotes.Toast:FireClient(player, "EPIC ORB")
	elseif meta.colorIndex == 3 then
		Remotes.Toast:FireClient(player, "Rare orb")
	end
	if combo > 0 and combo % 25 == 0 then
		Remotes.Toast:FireClient(player, combo .. "x COMBO")
	end
	StateBus.Push(player, false)
end

function OrbRush.SpawnCFrame()
	return Util.spawnCf(origin())
end

function OrbRush.BuyUpgrade(player, name)
	local def = cfg.Upgrades[name]
	local data = PlayerData.Get(player)
	if not def or not data then
		return
	end
	local level = data.OrbUpgrades[name] or 0
	if level >= def.max then
		Remotes.Toast:FireClient(player, "Max level")
		return
	end
	local cost = PlayerData.OrbCost(name, level)
	if data.OrbCash < cost then
		Remotes.Toast:FireClient(player, "Not enough orb cash")
		return
	end
	data.OrbCash -= cost
	data.OrbUpgrades[name] = level + 1
	updateAura(player)
	StateBus.Push(player, true)
end

function OrbRush.Rebirth(player)
	local data = PlayerData.Get(player)
	if not data then
		return
	end
	local cost = PlayerData.RebirthCost(data)
	if data.OrbCash < cost then
		Remotes.Toast:FireClient(player, "Need " .. cost .. " orb cash to rebirth")
		return
	end
	data.OrbCash = 0
	data.OrbUpgrades = { MagnetRange = 0, MagnetPull = 0, OrbValue = 0, WalkSpeed = 0 }
	data.OrbRebirths += 1
	updateAura(player)
	Remotes.Toast:FireClient(player, "REBIRTH — multiplier up")
	StateBus.Push(player, true)
	PlayerData.Save(player)
	if not data.OrbNudgeShown and not Monetization.Owns(player, "DoubleCoins") then
		data.OrbNudgeShown = true
		task.delay(1, function()
			if player.Parent then
				Remotes.Fx:FireClient(player, { kind = "ShopNudge" })
			end
		end)
	end
end

function OrbRush.Snapshot(player)
	local data = PlayerData.Get(player)
	if not data then
		return nil
	end
	local ups = {}
	for name, def in pairs(cfg.Upgrades) do
		local level = data.OrbUpgrades[name] or 0
		ups[name] = { level = level, max = def.max, cost = PlayerData.OrbCost(name, level) }
	end
	local combo = 0
	if combos[player] and os.clock() <= combos[player].expires then
		combo = combos[player].count
	end
	return {
		cash = data.OrbCash,
		rebirths = data.OrbRebirths,
		mult = Monetization.Multiplier(player, "orb"),
		rebirthCost = PlayerData.RebirthCost(data),
		upgrades = ups,
		combo = combo,
		subtitle = string.format("Orb $%d   x%.2f   R%d   combo %d", data.OrbCash, Monetization.Multiplier(player, "orb"), data.OrbRebirths, combo),
	}
end

function OrbRush.OnLeave(player)
	updateAura(player)
end

function OrbRush.Build()
	local o = origin()
	local model = Util.model(Workspace, "OrbRush")
	Util.part(model, "Floor", Vector3.new(cfg.ArenaRadius * 2.2, 2, cfg.ArenaRadius * 2.2), CFrame.new(o), Color3.fromRGB(24, 30, 46), Enum.Material.SmoothPlastic, true)
	local spawn = Util.part(model, "SpawnPad", Vector3.new(8, 1, 8), CFrame.new(o + Vector3.new(0, 1.5, 0)), Color3.fromRGB(80, 200, 255), Enum.Material.Neon, true)
	Util.billboard(spawn, "ORB RUSH", Vector3.new(0, 5, 0))
	folder = Instance.new("Folder")
	folder.Name = "Orbs"
	folder.Parent = model
end

function OrbRush.Init()
	task.spawn(function()
		while true do
			local interval = cfg.SpawnInterval
			if WorldEvents.Current() == "OrbStorm" then
				interval = 0.15
			end
			if orbCount < cfg.MaxOrbs then
				local tier = pickTier()
				local angle = math.random() * math.pi * 2
				local dist = math.random() * (cfg.ArenaRadius * 0.9)
				local pos = origin() + Vector3.new(math.cos(angle) * dist, 3, math.sin(angle) * dist)
				local part = Util.part(folder, "Orb", Vector3.new(tier.size, tier.size, tier.size), CFrame.new(pos), cfg.Colors[tier.colorIndex], Enum.Material.Neon, false)
				part.Shape = Enum.PartType.Ball
				local light = Instance.new("PointLight")
				light.Color = part.Color
				light.Range = 10
				light.Brightness = 1.2
				light.Parent = part
				orbs[part] = { mult = tier.mult, colorIndex = tier.colorIndex }
				orbCount += 1
				Debris:AddItem(part, cfg.Lifetime)
				part.AncestryChanged:Connect(function(_, parent)
					if not parent and orbs[part] then
						orbs[part] = nil
						orbCount = math.max(0, orbCount - 1)
					end
				end)
			end
			task.wait(interval)
		end
	end)

	task.spawn(function()
		while true do
			for _, player in ipairs(Players:GetPlayers()) do
				if inGame(player) then
					updateAura(player)
				end
			end
			task.wait(1)
		end
	end)

	RunService.Heartbeat:Connect(function(dt)
		for _, player in ipairs(Players:GetPlayers()) do
			if not inGame(player) then
				continue
			end
			local character = player.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			if not root then
				continue
			end
			local range, pull = stats(player)
			local batch = {}
			for part in pairs(orbs) do
				table.insert(batch, part)
			end
			for _, part in ipairs(batch) do
				local meta = orbs[part]
				if meta and part.Parent then
					local offset = root.Position - part.Position
					local dist = offset.Magnitude
					if dist <= 2.6 then
						collect(player, part)
					elseif dist <= range and dist > 0.05 then
						part.Position += offset.Unit * math.min(dist, pull * dt)
					end
				end
			end
		end
	end)
end

Players.PlayerRemoving:Connect(function(player)
	combos[player] = nil
end)

return OrbRush
]]
	writeScript(gamesFolder, "ModuleScript", "OrbRush", source)
end

-- ServerScriptService/Games/RhythmTap.lua
do
	local source = [[local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))
local PlayerData = require(script.Parent.Parent:WaitForChild("PlayerData"))
local Monetization = require(script.Parent.Parent:WaitForChild("Monetization"))
local StateBus = require(script.Parent.Parent:WaitForChild("StateBus"))
local Util = require(script.Parent.Parent:WaitForChild("Util"))

local RhythmTap = {}
RhythmTap.Id = "RhythmTap"

local sessions = {}

local function origin()
	return Config.Layout.RhythmTap
end

local function chart()
	local beats = {}
	local t = 1.2
	for i = 1, Config.Rhythm.Beats do
		table.insert(beats, { t = t, lane = (i % 4) + 1 })
		t += (i % 5 == 0) and 0.32 or 0.48
	end
	return beats
end

function RhythmTap.SpawnCFrame()
	return CFrame.new(origin() + Vector3.new(0, 5, 10))
end

function RhythmTap.Snapshot(player)
	local data = PlayerData.Get(player)
	local s = sessions[player]
	return {
		playing = s ~= nil,
		score = s and s.score or 0,
		best = data and data.RhythmBest or 0,
		subtitle = s and ("Score " .. s.score) or "Tap lanes on the beat",
	}
end

function RhythmTap.Start(player)
	if sessions[player] then
		return
	end
	if player:GetAttribute("GameId") ~= "RhythmTap" then
		return
	end
	local beats = chart()
	local startTime = workspace:GetServerTimeNow() + 0.4
	sessions[player] = { beats = beats, startTime = startTime, hit = {}, score = 0, coins = 0 }
	Remotes.Fx:FireClient(player, { kind = "RhythmChart", startTime = startTime, beats = beats })
	StateBus.Push(player, true)
	local length = beats[#beats].t + 2
	task.delay(length, function()
		local s = sessions[player]
		if not s or s.startTime ~= startTime then
			return
		end
		local data = PlayerData.Get(player)
		if data and s.score > data.RhythmBest then
			data.RhythmBest = s.score
		end
		local payout = math.floor(math.min(Config.Rhythm.MaxCoins, s.score / 8) * Monetization.Multiplier(player, "coins"))
		sessions[player] = nil
		Remotes.Fx:FireClient(player, { kind = "RhythmEnd", score = s.score })
		if payout > 0 then
			Monetization.GrantCoins(player, payout, "beat wire", true)
		else
			Remotes.Toast:FireClient(player, "Score " .. s.score)
			StateBus.Push(player, true)
		end
	end)
end

function RhythmTap.Hit(player, index)
	local s = sessions[player]
	index = math.floor(tonumber(index) or 0)
	if not s or index < 1 or index > #s.beats or s.hit[index] then
		return
	end
	local beat = s.beats[index]
	local now = workspace:GetServerTimeNow()
	local delta = math.abs(now - (s.startTime + beat.t))
	if delta > Config.Rhythm.Window then
		return
	end
	s.hit[index] = true
	local acc = 1 - (delta / Config.Rhythm.Window)
	s.score += math.floor(50 + acc * 50)
	StateBus.Push(player, false)
end

function RhythmTap.Build()
	local o = origin()
	local model = Util.model(Workspace, "RhythmTap")
	Util.part(model, "Floor", Vector3.new(40, 2, 40), CFrame.new(o), Color3.fromRGB(16, 24, 40), Enum.Material.SmoothPlastic, true)
	for i = 1, 4 do
		Util.part(model, "Lane" .. i, Vector3.new(3, 0.4, 16), CFrame.new(o + Vector3.new(-6 + i * 3, 1.2, -2)), Color3.fromRGB(40 + i * 30, 80, 180), Enum.Material.Neon, false)
	end
	Util.billboard(model.Floor, "BEAT WIRE", Vector3.new(0, 8, 0))
end

function RhythmTap.Init() end

game:GetService("Players").PlayerRemoving:Connect(function(player)
	sessions[player] = nil
end)

return RhythmTap
]]
	writeScript(gamesFolder, "ModuleScript", "RhythmTap", source)
end

-- ServerScriptService/Games/StallRush.lua
do
	local source = [[local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))
local PlayerData = require(script.Parent.Parent:WaitForChild("PlayerData"))
local Monetization = require(script.Parent.Parent:WaitForChild("Monetization"))
local StateBus = require(script.Parent.Parent:WaitForChild("StateBus"))
local Util = require(script.Parent.Parent:WaitForChild("Util"))

local StallRush = {}
StallRush.Id = "StallRush"

local ITEMS = {
	{ id = "orb", name = "Orb", color = Color3.fromRGB(80, 220, 255) },
	{ id = "seed", name = "Seed", color = Color3.fromRGB(120, 255, 140) },
	{ id = "hoop", name = "Hoop", color = Color3.fromRGB(255, 150, 40) },
	{ id = "star", name = "Star", color = Color3.fromRGB(255, 90, 200) },
}

local orders = {}

local function origin()
	return Config.Layout.StallRush
end

local function itemById(id)
	for _, item in ipairs(ITEMS) do
		if item.id == id then
			return item
		end
	end
	return nil
end

local function nextOrder(player, keepStreak)
	local item = ITEMS[math.random(1, #ITEMS)]
	local prev = orders[player]
	orders[player] = {
		want = item.id,
		name = item.name,
		expires = os.clock() + Config.Stall.Window,
		streak = keepStreak and prev and prev.streak or 0,
	}
end

function StallRush.SpawnCFrame()
	return CFrame.new(origin() + Vector3.new(0, 5, 12))
end

function StallRush.OnEnter(player)
	if not orders[player] or os.clock() > orders[player].expires then
		nextOrder(player, true)
	end
end

function StallRush.Snapshot(player)
	local order = orders[player]
	local data = PlayerData.Get(player)
	local left = 0
	if order then
		left = math.max(0, order.expires - os.clock())
	end
	return {
		want = order and order.want or "",
		wantName = order and order.name or "—",
		left = left,
		streak = order and order.streak or 0,
		best = data and data.StallBest or 0,
		items = ITEMS,
		subtitle = order and ("They want " .. order.name) or "Serve the stall",
	}
end

function StallRush.Serve(player, itemId)
	if player:GetAttribute("GameId") ~= "StallRush" then
		return
	end
	if typeof(itemId) ~= "string" or not itemById(itemId) then
		return
	end
	local order = orders[player]
	if not order or os.clock() > order.expires then
		if order then
			order.streak = 0
		end
		nextOrder(player, false)
		Remotes.Toast:FireClient(player, "Too slow")
		StateBus.Push(player, true)
		return
	end
	if itemId ~= order.want then
		order.streak = 0
		nextOrder(player, false)
		Remotes.Toast:FireClient(player, "Wrong item")
		StateBus.Push(player, true)
		return
	end
	order.streak += 1
	local data = PlayerData.Get(player)
	if data and order.streak > (data.StallBest or 0) then
		data.StallBest = order.streak
	end
	local reward = math.floor((4 + order.streak * 2) * Monetization.Multiplier(player, "coins"))
	local streakNow = order.streak
	nextOrder(player, true)
	orders[player].streak = streakNow
	Monetization.GrantCoins(player, reward, "served", false)
	if streakNow % 5 == 0 then
		Remotes.Toast:FireClient(player, streakNow .. " customer streak")
	end
	StateBus.Push(player, true)
end

function StallRush.Build()
	local o = origin()
	local model = Util.model(Workspace, "StallRush")
	Util.part(model, "Floor", Vector3.new(40, 2, 36), CFrame.new(o), Color3.fromRGB(48, 32, 36), Enum.Material.WoodPlanks, true)
	local counter = Util.part(model, "Counter", Vector3.new(16, 4, 3), CFrame.new(o + Vector3.new(0, 2, -4)), Color3.fromRGB(130, 80, 50), Enum.Material.Wood, true)
	Util.billboard(counter, "STALL RUSH", Vector3.new(0, 5, 0))
	for i, item in ipairs(ITEMS) do
		local crate = Util.part(model, item.id, Vector3.new(3, 3, 3), CFrame.new(o + Vector3.new(-6 + (i - 1) * 4, 2, 4)), item.color, Enum.Material.Neon, true)
		Util.billboard(crate, item.name, Vector3.new(0, 3, 0))
	end
end

function StallRush.Init()
	task.spawn(function()
		while true do
			task.wait(0.5)
			for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
				local order = orders[player]
				if order and player:GetAttribute("GameId") == "StallRush" and os.clock() > order.expires then
					order.streak = 0
					nextOrder(player, false)
					Remotes.Toast:FireClient(player, "Customer left")
					StateBus.Push(player, false)
				end
			end
		end
	end)
end

game:GetService("Players").PlayerRemoving:Connect(function(player)
	orders[player] = nil
end)

return StallRush
]]
	writeScript(gamesFolder, "ModuleScript", "StallRush", source)
end

-- ServerScriptService/Games/StoryBeat.lua
do
	local source = [[local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))
local PlayerData = require(script.Parent.Parent:WaitForChild("PlayerData"))
local Monetization = require(script.Parent.Parent:WaitForChild("Monetization"))
local StateBus = require(script.Parent.Parent:WaitForChild("StateBus"))
local Util = require(script.Parent.Parent:WaitForChild("Util"))

local StoryBeat = {}
StoryBeat.Id = "StoryBeat"

local NODES = {
	start = {
		text = "The night market is closed, but your hands are full of light. A kid whispers: don't let the guard take it. A lamp swings by the far gate.",
		choices = {
			{ id = "hide", label = "Hide with the kid", next = "stall" },
			{ id = "guard", label = "Walk to the guard", next = "gate" },
		},
	},
	stall = {
		text = "She pulls you under a tarp. That orb grows if you plant it. Or we sell it and eat tonight. Footsteps stop outside.",
		choices = {
			{ id = "plant", label = "Plant it in the cracked pot", next = "keeper" },
			{ id = "sell", label = "Sell it and split the cash", next = "deal" },
			{ id = "run", label = "Burst into the alley", next = "alley" },
		},
	},
	gate = {
		text = "The guard sighs. Third orb this week. Hand it over and I forget your face. Run, and I don't.",
		choices = {
			{ id = "hand", label = "Hand it over", next = "order" },
			{ id = "run", label = "Run the alley", next = "alley" },
		},
	},
	alley = {
		text = "The alley splits. One way smells like rain and soil. The other smells like coins.",
		choices = {
			{ id = "soil", label = "Follow the soil", next = "keeper" },
			{ id = "coins", label = "Follow the coins", next = "deal" },
		},
	},
	keeper = {
		ending = true,
		title = "LanternKeeper",
		text = "You plant the orb. By morning the stall is a garden. The kid laughs. The market opens late, and bright.",
	},
	deal = {
		ending = true,
		title = "DealMaker",
		text = "You split the light into money. It spends. It doesn't grow back. The kid still waves the next night.",
	},
	order = {
		ending = true,
		title = "QuietGate",
		text = "The guard pockets the orb and nods. You leave with empty hands and a safe name. Somewhere a garden does not start.",
	},
}

local function origin()
	return Config.Layout.StoryBeat
end

local function viewNode(id)
	local node = NODES[id] or NODES.start
	local choices = {}
	if node.choices then
		for _, c in ipairs(node.choices) do
			table.insert(choices, { id = c.id, label = c.label })
		end
	end
	return {
		id = id,
		text = node.text,
		choices = choices,
		ending = node.ending == true,
		title = node.title,
	}
end

function StoryBeat.SpawnCFrame()
	return CFrame.new(origin() + Vector3.new(0, 5, 8))
end

function StoryBeat.Snapshot(player)
	local data = PlayerData.Get(player)
	if not data then
		return nil
	end
	local node = viewNode(data.StoryNode or "start")
	node.seen = data.Endings or {}
	node.subtitle = node.ending and ("Ending: " .. (node.title or "")) or "Night Market"
	return node
end

function StoryBeat.Choose(player, choiceId)
	local data = PlayerData.Get(player)
	if not data or typeof(choiceId) ~= "string" then
		return
	end
	local node = NODES[data.StoryNode or "start"] or NODES.start
	if not node.choices then
		return
	end
	local nextId = nil
	for _, c in ipairs(node.choices) do
		if c.id == choiceId then
			nextId = c.next
			break
		end
	end
	if not nextId or not NODES[nextId] then
		return
	end
	data.StoryNode = nextId
	local landed = NODES[nextId]
	if landed.ending then
		local title = landed.title
		if data.Endings[title] then
			Remotes.Toast:FireClient(player, "You already lived this ending")
		else
			data.Endings[title] = true
			local reward = Config.StoryReward[title] or 150
			reward = math.floor(reward * Monetization.Multiplier(player, "coins"))
			Monetization.GrantCoins(player, reward, title, true)
		end
		PlayerData.Save(player)
	end
	StateBus.Push(player, true)
end

function StoryBeat.Replay(player)
	local data = PlayerData.Get(player)
	if not data then
		return
	end
	data.StoryNode = "start"
	Remotes.Toast:FireClient(player, "The market closes again")
	StateBus.Push(player, true)
end

function StoryBeat.Build()
	local o = origin()
	local model = Util.model(Workspace, "StoryBeat")
	Util.part(model, "Floor", Vector3.new(50, 2, 50), CFrame.new(o), Color3.fromRGB(28, 24, 36), Enum.Material.WoodPlanks, true)
	local stall = Util.part(model, "Stall", Vector3.new(10, 6, 8), CFrame.new(o + Vector3.new(-8, 4, -6)), Color3.fromRGB(120, 70, 50), Enum.Material.Wood, true)
	Util.billboard(stall, "NIGHT MARKET", Vector3.new(0, 6, 0))
	local guard = Util.part(model, "Guard", Vector3.new(3, 6, 3), CFrame.new(o + Vector3.new(10, 4, -8)), Color3.fromRGB(40, 70, 140), Enum.Material.SmoothPlastic, true)
	Util.billboard(guard, "GUARD", Vector3.new(0, 5, 0))
	local kid = Util.part(model, "Kid", Vector3.new(2, 3.5, 2), CFrame.new(o + Vector3.new(-4, 3, 2)), Color3.fromRGB(255, 180, 90), Enum.Material.SmoothPlastic, true)
	Util.billboard(kid, "KID", Vector3.new(0, 4, 0))
end

function StoryBeat.Init() end

return StoryBeat
]]
	writeScript(gamesFolder, "ModuleScript", "StoryBeat", source)
end

-- ServerScriptService/Games/TycoonLite.lua
do
	local source = [[local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))
local PlayerData = require(script.Parent.Parent:WaitForChild("PlayerData"))
local Monetization = require(script.Parent.Parent:WaitForChild("Monetization"))
local Slots = require(script.Parent.Parent:WaitForChild("Slots"))
local StateBus = require(script.Parent.Parent:WaitForChild("StateBus"))
local Util = require(script.Parent.Parent:WaitForChild("Util"))

local TycoonLite = {}
TycoonLite.Id = "TycoonLite"

local cfg = Config.Tycoon
local pads = {}
local ownerLabels = {}
local lastBuy = {}

local function origin()
	return Config.Layout.TycoonLite
end

local function plotOrigin(index)
	return origin() + Vector3.new((index - 3.5) * 42, 0, 0)
end

function TycoonLite.SpawnCFrame(player)
	local slot = Slots.Get("Tycoon", player) or 1
	return CFrame.new(plotOrigin(slot) + Vector3.new(0, 5, 12))
end

function TycoonLite.OnEnter(player)
	local slot = Slots.Ensure("Tycoon", player, cfg.Plots)
	if not slot then
		Remotes.Toast:FireClient(player, "All tycoon plots are taken")
	end
	TycoonLite.RefreshBoards()
end

function TycoonLite.Snapshot(player)
	local data = PlayerData.Get(player)
	if not data then
		return nil
	end
	local level = data.TycoonLevel
	local nextCost = cfg.Costs[level + 1]
	local rate = cfg.Rates[level + 1] or 0
	rate = math.floor(rate * Monetization.Multiplier(player, "tycoon"))
	return {
		cash = data.TycoonCash,
		level = level,
		max = #cfg.Costs,
		nextCost = nextCost,
		rate = rate,
		subtitle = string.format("Tycoon $%d   +%d/s   Lv %d", data.TycoonCash, rate, level),
	}
end

function TycoonLite.Buy(player)
	if (lastBuy[player] or 0) + 0.4 > os.clock() then
		return
	end
	lastBuy[player] = os.clock()
	local data = PlayerData.Get(player)
	if not data then
		return
	end
	local level = data.TycoonLevel
	local cost = cfg.Costs[level + 1]
	if not cost then
		Remotes.Toast:FireClient(player, "Tycoon maxed")
		return
	end
	if data.TycoonCash < cost then
		Remotes.Toast:FireClient(player, "Need " .. cost .. " tycoon cash")
		return
	end
	data.TycoonCash -= cost
	data.TycoonLevel += 1
	Remotes.Toast:FireClient(player, "Dropper " .. data.TycoonLevel .. " online")
	TycoonLite.RefreshBoards()
	StateBus.Push(player, true)
end

function TycoonLite.RefreshBoards()
	for i = 1, cfg.Plots do
		local owner = Slots.Owner("Tycoon", i)
		local label = ownerLabels[i]
		if label then
			if owner then
				local data = PlayerData.Get(owner)
				label.Text = owner.DisplayName .. "\nLv " .. (data and data.TycoonLevel or 0)
			else
				label.Text = "Empty plot"
			end
		end
		local data = owner and PlayerData.Get(owner)
		local level = data and data.TycoonLevel or 0
		for b = 1, #cfg.Costs do
			local pad = pads[i] and pads[i][b]
			if pad then
				pad.Color = b <= level and Color3.fromRGB(255, 196, 70) or Color3.fromRGB(50, 54, 68)
			end
		end
	end
end

function TycoonLite.Build()
	local model = Util.model(Workspace, "TycoonLite")
	Util.part(model, "Floor", Vector3.new(280, 2, 80), CFrame.new(origin()), Color3.fromRGB(32, 28, 22), Enum.Material.SmoothPlastic, true)
	for i = 1, cfg.Plots do
		local o = plotOrigin(i)
		pads[i] = {}
		local sign = Util.part(model, "Sign" .. i, Vector3.new(8, 6, 1), CFrame.new(o + Vector3.new(0, 5, 16)), Color3.fromRGB(20, 20, 24), Enum.Material.SmoothPlastic, false)
		ownerLabels[i] = Util.billboard(sign, "Empty plot", Vector3.new(0, 5, 0))
		for b = 1, #cfg.Costs do
			local pad = Util.part(model, "B" .. i .. "_" .. b, Vector3.new(6, 1, 6), CFrame.new(o + Vector3.new(0, 1, -4 - (b - 1) * 0)), Color3.fromRGB(50, 54, 68), Enum.Material.Neon, true)
			-- line them on X within the plot
			pad.CFrame = CFrame.new(o + Vector3.new(-10 + (b - 1) * 4, 1.2, -6))
			pad.Size = Vector3.new(3.5, 1, 6)
			pads[i][b] = pad
		end
		local collector = Util.part(model, "Collector" .. i, Vector3.new(10, 1, 8), CFrame.new(o + Vector3.new(0, 1, 8)), Color3.fromRGB(80, 200, 120), Enum.Material.Neon, true)
		collector.Touched:Connect(function(hit)
			local player = Players:GetPlayerFromCharacter(hit.Parent)
			if player and Slots.Get("Tycoon", player) == i then
				TycoonLite.Buy(player)
			end
		end)
		Util.billboard(collector, "Step on pad to buy next", Vector3.new(0, 4, 0), UDim2.fromOffset(180, 40))
	end
end

function TycoonLite.Init()
	task.spawn(function()
		while true do
			task.wait(1)
			for _, player in ipairs(Players:GetPlayers()) do
				local data = PlayerData.Get(player)
				if data and data.TycoonLevel > 0 then
					local rate = cfg.Rates[data.TycoonLevel + 1] or 0
					rate = math.floor(rate * Monetization.Multiplier(player, "tycoon"))
					if rate > 0 then
						data.TycoonCash += rate
						if player:GetAttribute("GameId") == "TycoonLite" then
							StateBus.Push(player, false)
						end
					end
				end
			end
		end
	end)
end

return TycoonLite
]]
	writeScript(gamesFolder, "ModuleScript", "TycoonLite", source)
end

-- StarterPlayerScripts/Hud.client.lua
do
	local source = [[local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local function corner(parent, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 8)
	c.Parent = parent
	return c
end

local function label(parent, name, text, size, pos, fontSize)
	local l = Instance.new("TextLabel")
	l.Name = name
	l.BackgroundTransparency = 1
	l.Size = size
	l.Position = pos
	l.Font = Enum.Font.GothamBold
	l.TextSize = fontSize or 16
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextColor3 = Color3.new(1, 1, 1)
	l.Text = text or ""
	l.Parent = parent
	return l
end

local function button(parent, name, text, color)
	local b = Instance.new("TextButton")
	b.Name = name
	b.Size = UDim2.new(1, -8, 0, 32)
	b.BackgroundColor3 = color or Color3.fromRGB(45, 90, 180)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 14
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Text = text
	b.AutoButtonColor = true
	b.Parent = parent
	corner(b, 8)
	return b
end

local function act(name, a, b)
	Remotes.Action:FireServer(name, a, b)
end

local gui = Instance.new("ScreenGui")
gui.Name = "RushPlaza"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 62)
top.BackgroundColor3 = Color3.fromRGB(10, 12, 20)
top.BackgroundTransparency = 0.15
top.BorderSizePixel = 0
top.Parent = gui

local coinsLabel = label(top, "Coins", "$0", UDim2.new(0.4, 0, 0, 30), UDim2.fromOffset(16, 6), 26)
coinsLabel.Font = Enum.Font.GothamBlack
coinsLabel.TextColor3 = Color3.fromRGB(130, 255, 170)

local subLabel = label(top, "Sub", "Rush Plaza", UDim2.new(0.7, 0, 0, 20), UDim2.fromOffset(16, 36), 14)
subLabel.TextColor3 = Color3.fromRGB(190, 200, 220)
subLabel.Font = Enum.Font.Gotham

local eventLabel = label(top, "Event", "", UDim2.new(0.4, -16, 1, 0), UDim2.new(0.6, 0, 0, 0), 16)
eventLabel.TextXAlignment = Enum.TextXAlignment.Right
eventLabel.TextColor3 = Color3.fromRGB(255, 210, 90)

local list = Instance.new("ScrollingFrame")
list.Name = "Games"
list.Size = UDim2.new(0, 200, 1, -78)
list.Position = UDim2.fromOffset(8, 70)
list.BackgroundColor3 = Color3.fromRGB(16, 18, 28)
list.BackgroundTransparency = 0.1
list.BorderSizePixel = 0
list.ScrollBarThickness = 4
list.CanvasSize = UDim2.fromOffset(0, 40 + (#Config.Catalog + 1) * 40)
list.Parent = gui
corner(list, 12)
local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 4)
listLayout.Parent = list
local listPad = Instance.new("UIPadding")
listPad.PaddingTop = UDim.new(0, 6)
listPad.PaddingLeft = UDim.new(0, 6)
listPad.PaddingRight = UDim.new(0, 6)
listPad.Parent = list

local plazaBtn = button(list, "Hub", "Rush Plaza", Color3.fromRGB(40, 48, 70))
plazaBtn.MouseButton1Click:Connect(function()
	act("Teleport", "Hub")
end)

local gameButtons = { Hub = plazaBtn }
for _, info in ipairs(Config.Catalog) do
	local b = button(list, info.id, info.name, info.color:Lerp(Color3.fromRGB(20, 20, 28), 0.45))
	b.MouseButton1Click:Connect(function()
		act("Teleport", info.id)
	end)
	gameButtons[info.id] = b
end

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.fromOffset(300, 520)
panel.Position = UDim2.new(1, -312, 0, 70)
panel.BackgroundColor3 = Color3.fromRGB(16, 18, 28)
panel.BackgroundTransparency = 0.06
panel.BorderSizePixel = 0
panel.Parent = gui
corner(panel, 12)

local panelTitle = label(panel, "Title", "Plaza", UDim2.new(1, -16, 0, 28), UDim2.fromOffset(10, 8), 18)
panelTitle.Font = Enum.Font.GothamBlack

local body = Instance.new("ScrollingFrame")
body.Name = "Body"
body.Position = UDim2.fromOffset(8, 40)
body.Size = UDim2.new(1, -16, 1, -48)
body.BackgroundTransparency = 1
body.BorderSizePixel = 0
body.ScrollBarThickness = 5
body.CanvasSize = UDim2.fromOffset(0, 0)
body.AutomaticCanvasSize = Enum.AutomaticSize.Y
body.Parent = panel

local toast = label(gui, "Toast", "", UDim2.new(0.6, 0, 0, 32), UDim2.new(0.2, 0, 0, 70), 18)
toast.TextXAlignment = Enum.TextXAlignment.Center
toast.Font = Enum.Font.GothamBlack
toast.TextStrokeTransparency = 0.5

local pops = Instance.new("Folder")
pops.Parent = gui

local story = Instance.new("Frame")
story.Name = "Story"
story.Visible = false
story.Size = UDim2.fromOffset(460, 220)
story.Position = UDim2.new(0.5, -160, 1, -240)
story.BackgroundColor3 = Color3.fromRGB(18, 14, 28)
story.Parent = gui
corner(story, 12)
local storyText = label(story, "Text", "", UDim2.new(1, -20, 0, 110), UDim2.fromOffset(10, 10), 16)
storyText.TextWrapped = true
storyText.TextYAlignment = Enum.TextYAlignment.Top
local storyChoices = Instance.new("Frame")
storyChoices.BackgroundTransparency = 1
storyChoices.Position = UDim2.fromOffset(8, 120)
storyChoices.Size = UDim2.new(1, -16, 0, 90)
storyChoices.Parent = story
local storyLayout = Instance.new("UIListLayout")
storyLayout.Padding = UDim.new(0, 4)
storyLayout.Parent = storyChoices

local nudge = Instance.new("Frame")
nudge.Visible = false
nudge.Size = UDim2.fromOffset(320, 150)
nudge.Position = UDim2.fromScale(0.5, 0.45)
nudge.AnchorPoint = Vector2.new(0.5, 0.5)
nudge.BackgroundColor3 = Color3.fromRGB(14, 16, 26)
nudge.Parent = gui
corner(nudge, 12)
label(nudge, "T", "Double every game?", UDim2.new(1, -16, 0, 28), UDim2.fromOffset(10, 10), 18).Font = Enum.Font.GothamBlack
label(nudge, "B", "You rebirthed. 2x Coins boosts the whole plaza.", UDim2.new(1, -16, 0, 40), UDim2.fromOffset(10, 40), 14).TextWrapped = true
local nudgeBuy = button(nudge, "Buy", "Get 2x Coins", Color3.fromRGB(220, 160, 40))
nudgeBuy.Size = UDim2.new(0.48, 0, 0, 34)
nudgeBuy.Position = UDim2.fromOffset(10, 100)
local nudgeNo = button(nudge, "No", "Later", Color3.fromRGB(50, 54, 70))
nudgeNo.Size = UDim2.new(0.4, 0, 0, 34)
nudgeNo.Position = UDim2.new(0.52, 0, 0, 100)
nudgeBuy.MouseButton1Click:Connect(function()
	nudge.Visible = false
	act("PromptPass", "DoubleCoins")
end)
nudgeNo.MouseButton1Click:Connect(function()
	nudge.Visible = false
end)

local rhythm = Instance.new("Frame")
rhythm.Visible = false
rhythm.Size = UDim2.fromOffset(280, 320)
rhythm.Position = UDim2.new(0.5, -140, 1, -340)
rhythm.BackgroundColor3 = Color3.fromRGB(10, 14, 24)
rhythm.BackgroundTransparency = 0.15
rhythm.Parent = gui
corner(rhythm, 12)
local rhythmLanes = Instance.new("Frame")
rhythmLanes.Size = UDim2.new(1, -10, 1, -50)
rhythmLanes.Position = UDim2.fromOffset(5, 5)
rhythmLanes.BackgroundTransparency = 1
rhythmLanes.ClipsDescendants = true
rhythmLanes.Parent = rhythm
local hitLine = Instance.new("Frame")
hitLine.Size = UDim2.new(1, 0, 0, 2)
hitLine.Position = UDim2.new(0, 0, 0.78, 0)
hitLine.BackgroundColor3 = Color3.new(1, 1, 1)
hitLine.BorderSizePixel = 0
hitLine.Parent = rhythmLanes

local lastState = nil
local selectedCrop = "sprout"
local chart = nil
local noteFrames = {}
local localHits = {}
local builtGame = nil
local refs = {}

local function showToast(text)
	toast.Text = text
	toast.TextTransparency = 0
	task.delay(2.2, function()
		if toast.Text == text then
			TweenService:Create(toast, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
		end
	end)
end

local function cashPop(amount)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Size = UDim2.fromOffset(100, 28)
	l.Position = UDim2.new(0.5, math.random(-30, 30), 0.5, 0)
	l.Font = Enum.Font.GothamBlack
	l.TextSize = 22
	l.TextColor3 = Color3.fromRGB(130, 255, 170)
	l.Text = "+" .. tostring(amount)
	l.Parent = pops
	local tw = TweenService:Create(l, TweenInfo.new(0.7), {
		Position = l.Position - UDim2.fromOffset(0, 50),
		TextTransparency = 1,
	})
	tw:Play()
	tw.Completed:Connect(function()
		l:Destroy()
	end)
end

local function clearBody()
	for _, child in ipairs(body:GetChildren()) do
		child:Destroy()
	end
	refs = {}
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 6)
	layout.Parent = body
end

local function infoLine(name, text)
	local l = label(body, name, text, UDim2.new(1, 0, 0, 22), UDim2.fromOffset(0, 0), 14)
	l.TextWrapped = true
	refs[name] = l
	return l
end

local function buildPanel(state)
	clearBody()
	local id = state.gameId
	builtGame = id
	if id == "Hub" then
		panelTitle.Text = "Rush Plaza"
		infoLine("Hint", "Walk a portal or tap a game. Daily bonus is here.")
		local daily = button(body, "Daily", "Claim daily", Color3.fromRGB(40, 140, 90))
		daily.MouseButton1Click:Connect(function()
			act("ClaimDaily")
		end)
		refs.Daily = daily
		infoLine("Boost", "Two players in the same game: +15% coins.")
	elseif id == "OrbRush" then
		panelTitle.Text = "Orb Rush"
		infoLine("Stats", "")
		local order = { "MagnetRange", "MagnetPull", "OrbValue", "WalkSpeed" }
		local names = { MagnetRange = "Range", MagnetPull = "Pull", OrbValue = "Value", WalkSpeed = "Speed" }
		for _, name in ipairs(order) do
			local b = button(body, name, names[name], Color3.fromRGB(36, 64, 110))
			b.MouseButton1Click:Connect(function()
				act("BuyUpgrade", name)
			end)
			refs[name] = b
		end
		local rebirth = button(body, "Rebirth", "Rebirth", Color3.fromRGB(150, 60, 180))
		rebirth.MouseButton1Click:Connect(function()
			act("Rebirth")
		end)
		refs.Rebirth = rebirth
	elseif id == "LuckyDrop" then
		panelTitle.Text = "Lucky Drop"
		infoLine("Stats", "")
		local drop = button(body, "Drop", "Drop", Color3.fromRGB(120, 70, 200))
		drop.MouseButton1Click:Connect(function()
			act("Drop")
		end)
		local luck = button(body, "Luck", "Upgrade luck", Color3.fromRGB(70, 50, 110))
		luck.MouseButton1Click:Connect(function()
			act("LuckyUpgrade")
		end)
		refs.Luck = luck
	elseif id == "ObbyRace" then
		panelTitle.Text = "60s Run"
		infoLine("Stats", "Jump the pads. Lava sends you back. Beat 60s for bonus coins.")
	elseif id == "TycoonLite" then
		panelTitle.Text = "Button Tycoon"
		infoLine("Stats", "")
		local buy = button(body, "Buy", "Buy next dropper", Color3.fromRGB(180, 120, 30))
		buy.MouseButton1Click:Connect(function()
			act("TycoonBuy")
		end)
		refs.Buy = buy
	elseif id == "GardenPocket" then
		panelTitle.Text = "Pocket Garden"
		infoLine("Stats", "Plant, play something else, come back.")
		for _, crop in ipairs(Config.Garden.Crops) do
			local b = button(body, crop.id, crop.name, Color3.fromRGB(40, 110, 60))
			b.MouseButton1Click:Connect(function()
				selectedCrop = crop.id
			end)
			refs[crop.id] = b
		end
		for i = 1, Config.Garden.Plots do
			local b = button(body, "Plot" .. i, "Plot " .. i, Color3.fromRGB(70, 50, 30))
			b.MouseButton1Click:Connect(function()
				act("GardenPlot", i, selectedCrop)
			end)
			refs["Plot" .. i] = b
		end
		local water = button(body, "Water", "Water oldest growing plot", Color3.fromRGB(40, 90, 160))
		water.MouseButton1Click:Connect(function()
			local g = lastState and lastState.GardenPocket
			if not g then
				return
			end
			for i, plot in ipairs(g.plots) do
				if plot.crop ~= "" and not plot.ready and not plot.watered then
					act("GardenWater", i)
					return
				end
			end
			showToast("Nothing to water")
		end)
	elseif id == "DuoExtract" then
		panelTitle.Text = "Duo Extract"
		infoLine("Stats", "Grab chests, bank on the green pad before the round ends. Red ball hurts.")
		local revive = button(body, "Revive", "Buy revive", Color3.fromRGB(180, 60, 40))
		revive.MouseButton1Click:Connect(function()
			act("PromptProduct", "ExtractRevive")
		end)
	elseif id == "StoryBeat" then
		panelTitle.Text = "Night Market"
		infoLine("Stats", "Choices are on the card. Three endings, paid once each.")
		local replay = button(body, "Replay", "Replay story", Color3.fromRGB(90, 70, 140))
		replay.MouseButton1Click:Connect(function()
			act("StoryReplay")
		end)
	elseif id == "RhythmTap" then
		panelTitle.Text = "Beat Wire"
		infoLine("Stats", "")
		local start = button(body, "Start", "Start song", Color3.fromRGB(40, 110, 200))
		start.MouseButton1Click:Connect(function()
			act("RhythmStart")
		end)
	elseif id == "HoopShot" then
		panelTitle.Text = "Hoop Rush"
		infoLine("Stats", "Face the rim. Hold Shoot, release.")
		local shoot = button(body, "Shoot", "Shoot", Color3.fromRGB(200, 100, 30))
		refs.Shoot = shoot
		local holding = false
		local holdAt = 0
		shoot.MouseButton1Down:Connect(function()
			holding = true
			holdAt = os.clock()
		end)
		shoot.MouseButton1Up:Connect(function()
			if not holding then
				return
			end
			holding = false
			local power = math.clamp((os.clock() - holdAt) / 1.1, 0.2, 1)
			act("Shoot", power)
		end)
	elseif id == "StallRush" then
		panelTitle.Text = "Stall Rush"
		infoLine("Stats", "")
		for _, item in ipairs({ "orb", "seed", "hoop", "star" }) do
			local b = button(body, item, item, Color3.fromRGB(120, 50, 80))
			b.MouseButton1Click:Connect(function()
				act("Serve", item)
			end)
			refs[item] = b
		end
	end

	infoLine("ShopHeader", "— Shop —")
	local pass2 = button(body, "Pass2", "2x Coins pass", Color3.fromRGB(200, 150, 40))
	pass2.MouseButton1Click:Connect(function()
		act("PromptPass", "DoubleCoins")
	end)
	refs.Pass2 = pass2
	local vip = button(body, "Vip", "VIP Magnet", Color3.fromRGB(40, 120, 200))
	vip.MouseButton1Click:Connect(function()
		act("PromptPass", "VipMagnet")
	end)
	refs.Vip = vip
	local t2 = button(body, "T2", "2x Tycoon pass", Color3.fromRGB(180, 120, 40))
	t2.MouseButton1Click:Connect(function()
		act("PromptPass", "TycoonDouble")
	end)
	local packs = { { "CoinsSmall", "Coin pack S" }, { "CoinsMed", "Coin pack M" }, { "CoinsLarge", "Coin pack L" }, { "GardenFinish", "Ripen garden" } }
	for _, pack in ipairs(packs) do
		local b = button(body, pack[1], pack[2], Color3.fromRGB(48, 52, 68))
		b.MouseButton1Click:Connect(function()
			act("PromptProduct", pack[1])
		end)
	end
end

local function refresh(state)
	lastState = state
	coinsLabel.Text = tostring(math.floor(state.coins or 0)) .. " coins"
	if state.friendBoost then
		coinsLabel.Text ..= "  +15%"
	end
	subLabel.Text = state.subtitle or ""
	if state.event then
		eventLabel.Text = state.event .. "  " .. tostring(state.eventLeft) .. "s"
	else
		eventLabel.Text = ""
	end
	for id, b in pairs(gameButtons) do
		if id == "Hub" then
			b.Text = state.gameId == "Hub" and "Rush Plaza  •" or "Rush Plaza"
		else
			local n = state.counts and state.counts[id] or 0
			local info = Config.Info(id)
			b.Text = (info and info.name or id) .. (n > 0 and ("  " .. n) or "") .. (state.gameId == id and "  •" or "")
		end
	end
	if builtGame ~= state.gameId then
		buildPanel(state)
	end
	story.Visible = state.gameId == "StoryBeat"
	if state.gameId == "OrbRush" and state.OrbRush and refs.MagnetRange then
		local o = state.OrbRush
		if refs.Stats then
			refs.Stats.Text = string.format("x%.2f   rebirth %d   combo %d", o.mult or 1, o.rebirths or 0, o.combo or 0)
		end
		for name, info in pairs(o.upgrades or {}) do
			if refs[name] then
				refs[name].Text = string.format("%s  %d/%d  $%d", name, info.level, info.max, info.cost)
			end
		end
		if refs.Rebirth then
			refs.Rebirth.Text = "Rebirth (" .. tostring(o.rebirthCost) .. ")"
		end
	elseif state.gameId == "LuckyDrop" and state.LuckyDrop and refs.Luck then
		local l = state.LuckyDrop
		if refs.Stats then
			refs.Stats.Text = "Entry " .. l.entry .. "   luck " .. l.luck
		end
		refs.Luck.Text = l.maxed and "Luck maxed" or ("Luck " .. l.luck .. " (" .. l.luckCost .. ")")
	elseif state.gameId == "TycoonLite" and state.TycoonLite and refs.Buy then
		local t = state.TycoonLite
		if refs.Stats then
			refs.Stats.Text = string.format("$%d   +%d/s", t.cash, t.rate)
		end
		refs.Buy.Text = t.nextCost and ("Buy dropper " .. (t.level + 1) .. " (" .. t.nextCost .. ")") or "Maxed"
	elseif state.gameId == "GardenPocket" and state.GardenPocket then
		local g = state.GardenPocket
		for i, plot in ipairs(g.plots or {}) do
			local b = refs["Plot" .. i]
			if b then
				if plot.crop == "" then
					b.Text = "Plot " .. i .. " empty — plant " .. selectedCrop
				elseif plot.ready then
					b.Text = "Plot " .. i .. " HARVEST"
				else
					b.Text = "Plot " .. i .. " " .. plot.crop .. " " .. plot.left .. "s"
				end
			end
		end
	elseif state.gameId == "StallRush" and state.StallRush and refs.Stats then
		local s = state.StallRush
		refs.Stats.Text = string.format("Want %s   %.1fs   streak %d", s.wantName, s.left or 0, s.streak or 0)
	elseif state.gameId == "RhythmTap" and state.RhythmTap and refs.Stats then
		refs.Stats.Text = "Score " .. tostring(state.RhythmTap.score or 0) .. "   best " .. tostring(state.RhythmTap.best or 0)
	elseif state.gameId == "HoopShot" and state.HoopShot and refs.Stats then
		refs.Stats.Text = "Streak " .. tostring(state.HoopShot.streak or 0) .. "   best " .. tostring(state.HoopShot.best or 0)
	elseif state.gameId == "DuoExtract" and state.DuoExtract and refs.Stats then
		local e = state.DuoExtract
		refs.Stats.Text = string.format("Carry %d   %ds left", e.carry or 0, math.floor(e.timeLeft or 0))
	elseif state.gameId == "ObbyRace" and state.ObbyRace and refs.Stats then
		local o = state.ObbyRace
		refs.Stats.Text = string.format("Stage %d/%d   best %.1fs", o.stage or 0, o.stages or 10, o.best or 0)
	elseif state.gameId == "Hub" and refs.Daily and state.daily then
		refs.Daily.Text = state.daily.canClaim and ("Claim daily (streak " .. state.daily.streak .. ")") or "Daily claimed"
	end

	if state.passes then
		if refs.Pass2 then
			refs.Pass2.Text = state.passes.DoubleCoins and "2x Coins owned" or "2x Coins pass"
		end
		if refs.Vip then
			refs.Vip.Text = state.passes.VipMagnet and "VIP Magnet owned" or "VIP Magnet"
		end
	end

	if state.gameId == "StoryBeat" and state.StoryBeat then
		local s = state.StoryBeat
		storyText.Text = s.text or ""
		for _, child in ipairs(storyChoices:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end
		if s.ending then
			local b = button(storyChoices, "Replay", "Play again", Color3.fromRGB(90, 70, 140))
			b.Size = UDim2.new(1, 0, 0, 32)
			b.MouseButton1Click:Connect(function()
				act("StoryReplay")
			end)
		else
			for _, choice in ipairs(s.choices or {}) do
				local b = button(storyChoices, choice.id, choice.label, Color3.fromRGB(70, 60, 120))
				b.Size = UDim2.new(1, 0, 0, 28)
				b.MouseButton1Click:Connect(function()
					act("StoryChoice", choice.id)
				end)
			end
		end
	end
end

for i = 1, 4 do
	local b = button(rhythm, "Lane" .. i, tostring(i), Color3.fromRGB(30 + i * 25, 70, 150))
	b.Size = UDim2.new(0.22, 0, 0, 32)
	b.Position = UDim2.new((i - 1) * 0.25, 4, 1, -38)
	b.MouseButton1Click:Connect(function()
		if not chart then
			return
		end
		local now = workspace:GetServerTimeNow()
		local best, bestD = nil, nil
		for idx, beat in ipairs(chart.beats) do
			if beat.lane == i and not localHits[idx] then
				local d = math.abs(now - (chart.startTime + beat.t))
				if not bestD or d < bestD then
					best = idx
					bestD = d
				end
			end
		end
		if best and bestD < 0.35 then
			localHits[best] = true
			act("RhythmHit", best)
		end
	end)
end

RunService.RenderStepped:Connect(function()
	if not chart then
		rhythm.Visible = false
		return
	end
	rhythm.Visible = true
	local now = workspace:GetServerTimeNow()
	for idx, beat in ipairs(chart.beats) do
		local frame = noteFrames[idx]
		if frame then
			local remain = (chart.startTime + beat.t) - now
			frame.Position = UDim2.new((beat.lane - 1) * 0.25, 6, 0.78, -remain * 140)
			frame.Visible = not localHits[idx] and remain < 2.2 and remain > -0.3
		end
	end
	if now > chart.startTime + chart.beats[#chart.beats].t + 1.5 then
		chart = nil
	end
end)

Remotes.State.OnClientEvent:Connect(refresh)
Remotes.Toast.OnClientEvent:Connect(showToast)
Remotes.Fx.OnClientEvent:Connect(function(fx)
	if typeof(fx) ~= "table" then
		return
	end
	if fx.kind == "CashPop" then
		cashPop(fx.amount)
	elseif fx.kind == "ShopNudge" then
		nudge.Visible = true
	elseif fx.kind == "RhythmChart" then
		chart = fx
		localHits = {}
		for _, frame in pairs(noteFrames) do
			frame:Destroy()
		end
		noteFrames = {}
		for idx, beat in ipairs(fx.beats or {}) do
			local n = Instance.new("Frame")
			n.Size = UDim2.new(0.2, 0, 0, 14)
			n.BackgroundColor3 = Color3.fromRGB(120, 220, 255)
			n.BorderSizePixel = 0
			n.Parent = rhythmLanes
			corner(n, 4)
			noteFrames[idx] = n
			local _ = beat
		end
	elseif fx.kind == "RhythmEnd" then
		chart = nil
		showToast("Song over")
	end
end)

showToast("Rush Plaza")
]]
	writeScript(SPS, "LocalScript", "Hud", source)
end

-- ServerScriptService/Main.server.lua
do
	local source = [[local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))

local PlayerData = require(script.Parent:WaitForChild("PlayerData"))
local Monetization = require(script.Parent:WaitForChild("Monetization"))
local WorldEvents = require(script.Parent:WaitForChild("WorldEvents"))
local Presence = require(script.Parent:WaitForChild("Presence"))
local StateBus = require(script.Parent:WaitForChild("StateBus"))
local RateLimit = require(script.Parent:WaitForChild("RateLimit"))
local Util = require(script.Parent:WaitForChild("Util"))

local games = {}
for _, child in ipairs(script.Parent:WaitForChild("Games"):GetChildren()) do
	if child:IsA("ModuleScript") then
		local gameModule = require(child)
		if typeof(gameModule) == "table" and gameModule.Id then
			games[gameModule.Id] = gameModule
		end
	end
end

local COOLDOWN = {
	Teleport = 0.6,
	RhythmHit = 0.04,
	Shoot = 0.45,
	Drop = 2.4,
	Serve = 0.12,
	GardenPlot = 0.15,
	BuyUpgrade = 0.12,
	TycoonBuy = 0.35,
}

local pushQueued = {}

local function snapshot(player)
	local data = PlayerData.Get(player)
	if not data then
		return nil
	end
	local gameId = player:GetAttribute("GameId") or "Hub"
	local snap = {
		gameId = gameId,
		coins = data.Coins,
		friendBoost = Presence.Boost(player),
		event = WorldEvents.Current(),
		eventLeft = math.floor(WorldEvents.TimeLeft()),
		daily = {
			streak = data.DailyStreak,
			canClaim = data.LastDailyDay ~= PlayerData.TodayKey(),
		},
		passes = Monetization.GetPasses(player),
		counts = {},
		subtitle = "Pick a portal",
	}
	for _, info in ipairs(Config.Catalog) do
		snap.counts[info.id] = Presence.Count(info.id)
		local g = games[info.id]
		if g and g.Snapshot then
			snap[info.id] = g.Snapshot(player)
		end
	end
	local active = snap[gameId]
	if typeof(active) == "table" and active.subtitle then
		snap.subtitle = active.subtitle
	elseif gameId == "Hub" then
		snap.subtitle = "10 games · bring a friend for +15%"
	end
	return snap
end

local function pushNow(player)
	local snap = snapshot(player)
	if snap then
		Remotes.State:FireClient(player, snap)
	end
end

local function push(player, immediate)
	if not player or not player.Parent then
		return
	end
	if immediate then
		pushQueued[player] = nil
		pushNow(player)
		return
	end
	if pushQueued[player] then
		return
	end
	pushQueued[player] = true
	task.delay(0.25, function()
		pushQueued[player] = nil
		if player.Parent then
			pushNow(player)
		end
	end)
end

StateBus.Set(push)

local function placeCharacter(player)
	local gameId = player:GetAttribute("GameId") or "Hub"
	local g = games[gameId]
	local cf = CFrame.new((Config.Layout[gameId] or Config.Layout.Hub) + Vector3.new(0, 6, 0))
	if g and g.SpawnCFrame then
		local custom = g.SpawnCFrame(player)
		if typeof(custom) == "CFrame" then
			cf = custom
		end
	end
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
	root.CFrame = cf
end

local function teleport(player, gameId)
	if typeof(gameId) ~= "string" then
		return
	end
	if gameId ~= "Hub" and not Config.Layout[gameId] then
		return
	end
	if gameId ~= "Hub" and not games[gameId] then
		return
	end
	local prev = player:GetAttribute("GameId")
	if prev == gameId then
		placeCharacter(player)
		return
	end
	if prev and games[prev] and games[prev].OnLeave then
		games[prev].OnLeave(player)
	end
	player:SetAttribute("GameId", gameId)
	placeCharacter(player)
	if games[gameId] and games[gameId].OnEnter then
		games[gameId].OnEnter(player)
	end
	local info = Config.Info(gameId)
	Remotes.Toast:FireClient(player, info and ("Entered " .. info.name) or "Rush Plaza")
	if gameId ~= "Hub" then
		local data = PlayerData.Get(player)
		if data and data.Visited[gameId] ~= true then
			data.Visited[gameId] = true
			Monetization.GrantCoins(player, Config.FirstVisitBonus, "first visit", true)
		end
		if Presence.Count(gameId) >= 2 then
			Remotes.Toast:FireClient(player, "Friend boost +15% while you play together")
		end
	end
	push(player, true)
end

local function claimDaily(player)
	local data = PlayerData.Get(player)
	if not data then
		return
	end
	local today = PlayerData.TodayKey()
	if data.LastDailyDay == today then
		Remotes.Toast:FireClient(player, "Daily already claimed")
		return
	end
	local last = data.LastDailyDay or 0
	local continued = false
	if last > 0 then
		local lastTime = os.time({
			year = math.floor(last / 10000),
			month = math.floor(last / 100) % 100,
			day = last % 100,
			hour = 0,
		})
		continued = math.floor((os.time() - lastTime) / 86400) == 1
	end
	if continued then
		data.DailyStreak = math.min(Config.Daily.maxStreak, data.DailyStreak + 1)
	else
		data.DailyStreak = 1
	end
	data.LastDailyDay = today
	local reward = Config.Daily.base + (data.DailyStreak - 1) * Config.Daily.perStreak
	reward = math.floor(reward * Monetization.Multiplier(player, "coins"))
	Monetization.GrantCoins(player, reward, "daily x" .. data.DailyStreak, true)
	PlayerData.Save(player)
end

local function num(value)
	if typeof(value) ~= "number" then
		return nil
	end
	if value ~= value or value > 1e6 or value < -1e6 then
		return nil
	end
	return value
end

local function shortString(value)
	if typeof(value) ~= "string" or #value > 32 then
		return nil
	end
	return value
end

local handlers = {
	Teleport = function(player, id)
		teleport(player, id)
	end,
	BuyUpgrade = function(player, name)
		name = shortString(name)
		if name and games.OrbRush then
			games.OrbRush.BuyUpgrade(player, name)
		end
	end,
	Rebirth = function(player)
		games.OrbRush.Rebirth(player)
	end,
	Drop = function(player)
		games.LuckyDrop.Drop(player)
	end,
	LuckyUpgrade = function(player)
		games.LuckyDrop.Upgrade(player)
	end,
	TycoonBuy = function(player)
		games.TycoonLite.Buy(player)
	end,
	GardenPlot = function(player, index, cropId)
		games.GardenPocket.PlantOrHarvest(player, num(index), shortString(cropId))
	end,
	GardenWater = function(player, index)
		games.GardenPocket.Water(player, num(index))
	end,
	StoryChoice = function(player, choiceId)
		games.StoryBeat.Choose(player, shortString(choiceId))
	end,
	StoryReplay = function(player)
		games.StoryBeat.Replay(player)
	end,
	RhythmStart = function(player)
		games.RhythmTap.Start(player)
	end,
	RhythmHit = function(player, index)
		games.RhythmTap.Hit(player, num(index))
	end,
	Shoot = function(player, power)
		games.HoopShot.Shoot(player, num(power))
	end,
	Serve = function(player, itemId)
		games.StallRush.Serve(player, shortString(itemId))
	end,
	ClaimDaily = function(player)
		claimDaily(player)
	end,
	PromptPass = function(player, key)
		key = shortString(key)
		if key then
			Monetization.PromptPass(player, key)
		end
	end,
	PromptProduct = function(player, key)
		key = shortString(key)
		if key then
			Monetization.PromptProduct(player, key)
		end
	end,
}

local baseplate = Workspace:FindFirstChild("Baseplate")
if baseplate then
	baseplate:Destroy()
end

Monetization.Init()
WorldEvents.Init()

for _, g in pairs(games) do
	if g.Build then
		g.Build()
	end
end
for _, g in pairs(games) do
	if g.Init then
		g.Init()
	end
end

for _, prompt in ipairs(CollectionService:GetTagged("RushPortal")) do
	prompt.Triggered:Connect(function(player)
		teleport(player, prompt:GetAttribute("Dest"))
	end)
end

local void = Util.part(Workspace, "VoidReturn", Vector3.new(5000, 2, 5000), CFrame.new(0, -50, 0), Color3.fromRGB(0, 0, 0), Enum.Material.SmoothPlastic, false, 1)
local voidAt = {}
void.Touched:Connect(function(hit)
	local player = Players:GetPlayerFromCharacter(hit.Parent)
	if not player then
		return
	end
	if (voidAt[player] or 0) + 1 > os.clock() then
		return
	end
	voidAt[player] = os.clock()
	placeCharacter(player)
end)

local function onPlayer(player)
	PlayerData.Load(player)
	Monetization.RefreshPasses(player)
	player:SetAttribute("GameId", "Hub")
	player.CharacterAdded:Connect(function()
		task.defer(function()
			if player.Parent then
				placeCharacter(player)
			end
		end)
	end)
	if player.Character then
		task.defer(function()
			placeCharacter(player)
		end)
	end
	task.delay(0.6, function()
		if player.Parent then
			push(player, true)
			Remotes.Toast:FireClient(player, "Welcome to Rush Plaza — pick a portal")
		end
	end)
end

Players.PlayerAdded:Connect(onPlayer)
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayer, player)
end

Remotes.Action.OnServerEvent:Connect(function(player, action, a, b)
	if typeof(action) ~= "string" or #action > 32 then
		return
	end
	local fn = handlers[action]
	if not fn then
		return
	end
	if not RateLimit.Allow(player, action, COOLDOWN[action] or 0.15) then
		return
	end
	fn(player, a, b)
end)

task.spawn(function()
	while true do
		task.wait(2)
		local hub = games.Hub
		for _, info in ipairs(Config.Catalog) do
			if hub and hub.SetCount then
				hub.SetCount(info.id, Presence.Count(info.id), info.name)
			end
		end
		if hub and hub.EventLabel then
			local ev = WorldEvents.Current()
			if ev then
				hub.EventLabel.Text = ev .. "\n" .. math.floor(WorldEvents.TimeLeft()) .. "s left"
			else
				hub.EventLabel.Text = "Next plaza event soon\nGold Rush · Orb Storm · Lucky Minute"
			end
		end
		for _, player in ipairs(Players:GetPlayers()) do
			if player:GetAttribute("GameId") == "Hub" or player:GetAttribute("GameId") == "StallRush" or player:GetAttribute("GameId") == "DuoExtract" then
				push(player, false)
			end
		end
	end
end)

task.spawn(function()
	while true do
		task.wait(60)
		for _, player in ipairs(Players:GetPlayers()) do
			PlayerData.Save(player)
		end
	end
end)

print("[RushPlaza] online —", Config.PlaceName, "games", #Config.Catalog)
]]
	writeScript(SSS, "Script", "Main", source)
end

print("[RushPlaza] Installed. Press Play.")
if script ~= nil then
	script.Disabled = true
	script.Name = "RushPlazaInstaller_DONE"
end
