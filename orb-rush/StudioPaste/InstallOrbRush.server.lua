--[[
  Orb Rush ONE-PASTE INSTALLER (auto-generated)
  Run: python3 tools/generate_installer.py
  Studio: paste into a Script under ServerScriptService, Play once, delete installer.
]]

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
	return obj
end

print("[OrbRush] Installing...")
local shared = ensureFolder(RS, "Shared")

-- Config
do
	local source = [=[-- Shared game balance + monetization IDs.
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
]=]
	writeScript(shared, "ModuleScript", "Config", source)
end

-- Remotes
do
	local source = [[local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = {}

local folder = ReplicatedStorage:FindFirstChild("OrbRushRemotes")
if not folder then
	folder = Instance.new("Folder")
	folder.Name = "OrbRushRemotes"
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

-- Client → Server
Remotes.BuyUpgrade = getRemote("BuyUpgrade", "RemoteEvent")
Remotes.RequestRebirth = getRemote("RequestRebirth", "RemoteEvent")
Remotes.ClaimDaily = getRemote("ClaimDaily", "RemoteEvent")
Remotes.PromptProduct = getRemote("PromptProduct", "RemoteEvent")
Remotes.PromptGamePass = getRemote("PromptGamePass", "RemoteEvent")

-- Server → Client
Remotes.StateUpdate = getRemote("StateUpdate", "RemoteEvent")
Remotes.Toast = getRemote("Toast", "RemoteEvent")
Remotes.CashPop = getRemote("CashPop", "RemoteEvent")
Remotes.ShowShopNudge = getRemote("ShowShopNudge", "RemoteEvent")
Remotes.DismissNudge = getRemote("DismissNudge", "RemoteEvent")

return Remotes
]]
	writeScript(shared, "ModuleScript", "Remotes", source)
end

-- PlayerData
do
	local source = [=[local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local PlayerData = {}

local store = DataStoreService:GetDataStore(Config.DataStoreName)
local sessions = {}

local function defaultData()
	return {
		Cash = 0,
		Rebirths = 0,
		Upgrades = {
			MagnetRange = 0,
			MagnetPull = 0,
			OrbValue = 0,
			WalkSpeed = 0,
		},
		DailyStreak = 0,
		LastDailyDay = 0,
		TotalCollected = 0,
		HasRebirthedOnce = false,
		ShopNudgeShown = false,
		ProcessedReceipts = {},
	}
end

local function todayKey()
	local t = os.date("!*t")
	return t.year * 10000 + t.month * 100 + t.day
end

function PlayerData.Get(player)
	return sessions[player]
end

function PlayerData.Load(player)
	local data = defaultData()
	local ok, saved = pcall(function()
		return store:GetAsync("p_" .. player.UserId)
	end)
	if ok and typeof(saved) == "table" then
		for k, v in pairs(saved) do
			if k == "Upgrades" and typeof(v) == "table" then
				for uk, uv in pairs(v) do
					data.Upgrades[uk] = uv
				end
			elseif k == "ProcessedReceipts" and typeof(v) == "table" then
				data.ProcessedReceipts = v
			else
				data[k] = v
			end
		end
	end
	sessions[player] = data
	return data
end

function PlayerData.Save(player)
	local data = sessions[player]
	if not data then
		return
	end
	local receipts = data.ProcessedReceipts or {}
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

function PlayerData.CashMultiplier(player, ownsDoubleCash)
	local data = sessions[player]
	if not data then
		return 1
	end
	local mult = 1 + (data.Rebirths * Config.RebirthMultPer)
	if ownsDoubleCash then
		mult *= 2
	end
	return mult
end

function PlayerData.UpgradeCost(name, level)
	local def = Config.Upgrades[name]
	if not def then
		return math.huge
	end
	return math.floor(def.baseCost * (def.growth ^ level))
end

function PlayerData.RebirthCost(player)
	local data = sessions[player]
	if not data then
		return Config.RebirthBaseCash
	end
	return math.floor(Config.RebirthBaseCash * (Config.RebirthCostGrowth ^ data.Rebirths))
end

function PlayerData.StatSnapshot(player, passOwned)
	local data = sessions[player]
	if not data then
		return nil
	end
	local ups = {}
	for name, def in pairs(Config.Upgrades) do
		local lvl = data.Upgrades[name] or 0
		ups[name] = {
			level = lvl,
			max = def.max,
			cost = PlayerData.UpgradeCost(name, lvl),
		}
	end
	return {
		cash = data.Cash,
		rebirths = data.Rebirths,
		multiplier = PlayerData.CashMultiplier(player, passOwned and passOwned.DoubleCash),
		upgrades = ups,
		rebirthCost = PlayerData.RebirthCost(player),
		dailyStreak = data.DailyStreak,
		canClaimDaily = data.LastDailyDay ~= todayKey(),
		totalCollected = data.TotalCollected,
		passes = passOwned or { DoubleCash = false, VipMagnet = false },
		showShopNudge = Config.ShopNudgeEnabled
			and data.HasRebirthedOnce == true
			and data.ShopNudgeShown ~= true
			and not (passOwned and passOwned.DoubleCash),
	}
end

function PlayerData.TodayKey()
	return todayKey()
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

-- Monetization
do
	local source = [[local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))
local PlayerData = require(script.Parent:WaitForChild("PlayerData"))

local Monetization = {}

local passCache = {} -- [userId] = { DoubleCash = bool, VipMagnet = bool }

local function productKeyById(productId)
	for key, def in pairs(Config.DeveloperProducts) do
		if def.id ~= 0 and def.id == productId then
			return key, def
		end
	end
	return nil, nil
end

function Monetization.RefreshPasses(player)
	local owned = { DoubleCash = false, VipMagnet = false }
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
	-- Studio / unset IDs: treat as unowned (fair testing)
	passCache[player.UserId] = owned
	return owned
end

function Monetization.GetPasses(player)
	return passCache[player.UserId] or Monetization.RefreshPasses(player)
end

function Monetization.PushState(player)
	local passes = Monetization.GetPasses(player)
	local snap = PlayerData.StatSnapshot(player, passes)
	if snap then
		Remotes.StateUpdate:FireClient(player, snap)
	end
end

function Monetization.GrantCash(player, amount, reason)
	local data = PlayerData.Get(player)
	if not data then
		return
	end
	data.Cash += amount
	Remotes.Toast:FireClient(player, string.format("+%s cash (%s)", tostring(amount), reason or "reward"))
	Monetization.PushState(player)
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

	local _, def = productKeyById(receiptInfo.ProductId)
	if not def then
		-- Unknown product — grant to avoid stuck receipts in misconfig, but log
		warn("[OrbRush] Unknown product id", receiptInfo.ProductId)
		data.ProcessedReceipts[purchaseId] = true
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	data.Cash += def.cash
	data.ProcessedReceipts[purchaseId] = true
	PlayerData.Save(player)
	Remotes.Toast:FireClient(player, string.format("Purchased +%d cash!", def.cash))
	Remotes.CashPop:FireClient(player, def.cash)
	Monetization.PushState(player)
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

function Monetization.Init()
	MarketplaceService.ProcessReceipt = processReceipt

	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId, wasPurchased)
		if wasPurchased then
			Monetization.RefreshPasses(player)
			Monetization.PushState(player)
			Remotes.Toast:FireClient(player, "Game Pass unlocked!")
		end
	end)

	Remotes.PromptProduct.OnServerEvent:Connect(function(player, productKey)
		if typeof(productKey) ~= "string" then
			return
		end
		local def = Config.DeveloperProducts[productKey]
		if not def or def.id == 0 then
			Remotes.Toast:FireClient(player, "Set Developer Product IDs in Config.lua")
			return
		end
		MarketplaceService:PromptProductPurchase(player, def.id)
	end)

	Remotes.PromptGamePass.OnServerEvent:Connect(function(player, passKey)
		if typeof(passKey) ~= "string" then
			return
		end
		local passId = Config.GamePasses[passKey]
		if typeof(passId) ~= "number" or passId == 0 then
			Remotes.Toast:FireClient(player, "Set Game Pass IDs in Config.lua")
			return
		end
		MarketplaceService:PromptGamePassPurchase(player, passId)
	end)
end

Players.PlayerRemoving:Connect(function(player)
	passCache[player.UserId] = nil
end)

return Monetization
]]
	writeScript(SSS, "ModuleScript", "Monetization", source)
end

-- OrbWorld
do
	local source = [[local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))
local PlayerData = require(script.Parent:WaitForChild("PlayerData"))
local Monetization = require(script.Parent:WaitForChild("Monetization"))

local OrbWorld = {}

local folder
local orbs = {} -- [part] = meta
local orbCount = 0
local combos = {} -- [player] = { count = n, expires = clock }

local function pickTier()
	local total = 0
	for _, t in ipairs(Config.OrbTiers) do
		total += t.weight
	end
	local roll = math.random() * total
	local acc = 0
	for _, t in ipairs(Config.OrbTiers) do
		acc += t.weight
		if roll <= acc then
			return t
		end
	end
	return Config.OrbTiers[1]
end

local function ensureArena()
	local arena = Workspace:FindFirstChild("OrbRushArena")
	if arena then
		return arena
	end

	arena = Instance.new("Model")
	arena.Name = "OrbRushArena"
	arena.Parent = Workspace

	local floor = Instance.new("Part")
	floor.Name = "Floor"
	floor.Anchored = true
	floor.Size = Vector3.new(Config.ArenaRadius * 2.2, 1, Config.ArenaRadius * 2.2)
	floor.Position = Vector3.new(0, 0, 0)
	floor.Material = Enum.Material.SmoothPlastic
	floor.Color = Color3.fromRGB(28, 34, 48)
	floor.Parent = arena

	-- Grid accent strips
	for i = -2, 2 do
		local strip = Instance.new("Part")
		strip.Anchored = true
		strip.CanCollide = false
		strip.Size = Vector3.new(Config.ArenaRadius * 2, 0.15, 0.6)
		strip.Position = Vector3.new(0, 0.6, i * 18)
		strip.Material = Enum.Material.Neon
		strip.Color = Color3.fromRGB(40, 90, 140)
		strip.Transparency = 0.55
		strip.Parent = arena
	end

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "Spawn"
	spawn.Anchored = true
	spawn.Size = Vector3.new(8, 1, 8)
	spawn.Position = Vector3.new(0, 1, 0)
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.Material = Enum.Material.Neon
	spawn.Color = Color3.fromRGB(80, 200, 255)
	spawn.Parent = arena

	local ring = Instance.new("Part")
	ring.Name = "Boundary"
	ring.Anchored = true
	ring.CanCollide = false
	ring.Transparency = 0.7
	ring.Material = Enum.Material.Neon
	ring.Color = Color3.fromRGB(60, 140, 255)
	ring.Size = Vector3.new(Config.ArenaRadius * 2, 0.4, Config.ArenaRadius * 2)
	ring.Position = Vector3.new(0, 0.6, 0)
	ring.Parent = arena

	local decalHint = Instance.new("BillboardGui")
	decalHint.Size = UDim2.fromOffset(220, 40)
	decalHint.StudsOffset = Vector3.new(0, 6, 0)
	decalHint.Parent = spawn
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = "ORB RUSH"
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBlack
	label.Parent = decalHint

	-- Lighting mood (best-effort)
	local lighting = game:GetService("Lighting")
	lighting.Ambient = Color3.fromRGB(40, 50, 70)
	lighting.Brightness = 2
	lighting.ClockTime = 20.5

	return arena
end

local function spawnOrb()
	if orbCount >= Config.MaxOrbs then
		return
	end

	local tier = pickTier()
	local angle = math.random() * math.pi * 2
	local dist = math.random() * (Config.ArenaRadius * 0.9)
	local pos = Vector3.new(math.cos(angle) * dist, 2.2, math.sin(angle) * dist)

	local part = Instance.new("Part")
	part.Name = "Orb"
	part.Shape = Enum.PartType.Ball
	part.Material = Enum.Material.Neon
	part.Color = Config.OrbColors[tier.colorIndex]
	part.Size = Vector3.new(tier.size, tier.size, tier.size)
	part.Anchored = true
	part.CanCollide = false
	part.Position = pos
	part.Parent = folder

	local light = Instance.new("PointLight")
	light.Brightness = tier.colorIndex >= 3 and 2 or 1.2
	light.Range = tier.colorIndex >= 3 and 14 or 10
	light.Color = part.Color
	light.Parent = part

	orbs[part] = { tier = tier, valueMult = tier.mult, colorIndex = tier.colorIndex }
	orbCount += 1
	Debris:AddItem(part, Config.OrbLifetime)

	part.AncestryChanged:Connect(function(_, parent)
		if not parent and orbs[part] ~= nil then
			orbs[part] = nil
			orbCount = math.max(0, orbCount - 1)
		end
	end)
end

local function magnetStats(player)
	local data = PlayerData.Get(player)
	if not data then
		return Config.BaseMagnetRange, Config.BaseMagnetPull, Config.BaseOrbValue, Config.BaseWalkSpeed
	end
	local ups = Config.Upgrades
	local range = Config.BaseMagnetRange + (data.Upgrades.MagnetRange * ups.MagnetRange.perLevel)
	local pull = Config.BaseMagnetPull + (data.Upgrades.MagnetPull * ups.MagnetPull.perLevel)
	local value = Config.BaseOrbValue + (data.Upgrades.OrbValue * ups.OrbValue.perLevel)
	local speed = Config.BaseWalkSpeed + (data.Upgrades.WalkSpeed * ups.WalkSpeed.perLevel)

	local passes = Monetization.GetPasses(player)
	if passes.VipMagnet then
		range += Config.VipMagnetRangeBonus
		pull += Config.VipMagnetPullBonus
	end
	return range, pull, value, speed
end

local function updateMagnetAura(character, range)
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end
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
		aura.Transparency = 0.75
		aura.Parent = character
		local weld = Instance.new("Weld")
		weld.Part0 = root
		weld.Part1 = aura
		weld.C0 = CFrame.Angles(0, 0, math.rad(90))
		weld.Parent = aura
	end
	local diameter = range * 2
	aura.Size = Vector3.new(0.3, diameter, diameter)
end

local function bumpCombo(player)
	local now = os.clock()
	local c = combos[player]
	if not c or now > c.expires then
		c = { count = 0, expires = now }
		combos[player] = c
	end
	c.count += 1
	c.expires = now + (Config.ComboWindow or 1.25)
	return c.count
end

local function collectOrb(player, part)
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

	local _, _, orbValue = magnetStats(player)
	local passes = Monetization.GetPasses(player)
	local combo = bumpCombo(player)
	local comboMult = 1 + math.min(0.5, (combo - 1) * 0.02)
	local gain = math.max(1, math.floor(orbValue * meta.valueMult * PlayerData.CashMultiplier(player, passes.DoubleCash) * comboMult))
	data.Cash += gain
	data.TotalCollected += 1

	if meta.colorIndex >= 4 then
		Remotes.Toast:FireClient(player, "EPIC ORB!")
	elseif meta.colorIndex >= 3 then
		Remotes.Toast:FireClient(player, "Rare orb!")
	end
	if combo > 0 and combo % 25 == 0 then
		Remotes.Toast:FireClient(player, string.format("%dx COMBO!", combo))
	end

	Remotes.CashPop:FireClient(player, gain)
	-- Push state every collect so HUD cash stays live (player count is small for MVP)
	Monetization.PushState(player)
end

function OrbWorld.ApplyCharacterStats(player, character)
	local hum = character:WaitForChild("Humanoid", 5)
	if not hum then
		return
	end
	local range, _, _, speed = magnetStats(player)
	hum.WalkSpeed = speed
	updateMagnetAura(character, range)
end

function OrbWorld.Init()
	ensureArena()
	folder = Workspace:FindFirstChild("OrbRushOrbs")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "OrbRushOrbs"
		folder.Parent = Workspace
	end

	task.spawn(function()
		while true do
			spawnOrb()
			task.wait(Config.OrbSpawnInterval)
		end
	end)

	-- Periodic aura refresh (upgrade changes)
	task.spawn(function()
		while true do
			task.wait(1)
			for _, player in ipairs(Players:GetPlayers()) do
				if player.Character then
					local range = magnetStats(player)
					updateMagnetAura(player.Character, range)
				end
			end
		end
	end)

	RunService.Heartbeat:Connect(function(dt)
		for _, player in ipairs(Players:GetPlayers()) do
			local character = player.Character
			if not character then
				continue
			end
			local root = character:FindFirstChild("HumanoidRootPart")
			if not root then
				continue
			end

			local range, pull = magnetStats(player)
			for part in pairs(orbs) do
				if part.Parent then
					local offset = root.Position - part.Position
					local dist = offset.Magnitude
					if dist <= 2.5 then
						collectOrb(player, part)
					elseif dist <= range then
						local step = math.min(dist, pull * dt)
						part.Position = part.Position + offset.Unit * step
					end
				end
			end
		end
	end)
end

Players.PlayerRemoving:Connect(function(player)
	combos[player] = nil
end)

return OrbWorld
]]
	writeScript(SSS, "ModuleScript", "OrbWorld", source)
end

-- Leaderboard
do
	local source = [[local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"))
local PlayerData = require(script.Parent:WaitForChild("PlayerData"))

local Leaderboard = {}

local cashStore = DataStoreService:GetOrderedDataStore(Config.DataStoreName .. "_Cash")
local rebirthStore = DataStoreService:GetOrderedDataStore(Config.DataStoreName .. "_Rebirths")

local function ensureBoard(name, titleText, position)
	local existing = Workspace:FindFirstChild(name)
	if existing then
		return existing
	end

	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.CanCollide = false
	part.Size = Vector3.new(8, 10, 0.4)
	part.Position = position
	part.Color = Color3.fromRGB(20, 24, 36)
	part.Material = Enum.Material.SmoothPlastic
	part.Parent = Workspace

	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.CanvasSize = Vector2.new(400, 500)
	gui.Parent = part

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0, 48)
	title.BackgroundColor3 = Color3.fromRGB(40, 90, 180)
	title.BorderSizePixel = 0
	title.Font = Enum.Font.GothamBlack
	title.TextSize = 28
	title.TextColor3 = Color3.new(1, 1, 1)
	title.Text = titleText
	title.Parent = gui

	local list = Instance.new("TextLabel")
	list.Name = "List"
	list.Size = UDim2.new(1, -16, 1, -56)
	list.Position = UDim2.fromOffset(8, 52)
	list.BackgroundTransparency = 1
	list.Font = Enum.Font.GothamMedium
	list.TextSize = 20
	list.TextXAlignment = Enum.TextXAlignment.Left
	list.TextYAlignment = Enum.TextYAlignment.Top
	list.TextColor3 = Color3.fromRGB(220, 230, 255)
	list.Text = "Loading..."
	list.Parent = gui

	return part
end

local function formatLines(pages)
	local lines = {}
	for i, entry in ipairs(pages) do
		if i > 10 then
			break
		end
		local name = "Player"
		local userId = tonumber(entry.key) or 0
		local ok, result = pcall(function()
			return Players:GetNameFromUserIdAsync(userId)
		end)
		if ok and result then
			name = result
		end
		table.insert(lines, string.format("%d. %s — %s", i, name, tostring(entry.value)))
	end
	if #lines == 0 then
		return "No scores yet — be first!"
	end
	return table.concat(lines, "\n")
end

local function refreshBoard(part, store)
	local gui = part:FindFirstChildWhichIsA("SurfaceGui")
	if not gui then
		return
	end
	local list = gui:FindFirstChild("List")
	if not list then
		return
	end
	local ok, page = pcall(function()
		return store:GetSortedAsync(false, 10):GetCurrentPage()
	end)
	if ok and page then
		list.Text = formatLines(page)
	else
		list.Text = "Leaderboard unavailable\n(Enable API Services)"
	end
end

function Leaderboard.Submit(player)
	local data = PlayerData.Get(player)
	if not data then
		return
	end
	local uid = tostring(player.UserId)
	pcall(function()
		cashStore:SetAsync(uid, math.floor(math.max(0, data.Cash)))
	end)
	pcall(function()
		rebirthStore:SetAsync(uid, math.floor(math.max(0, data.Rebirths)))
	end)
end

function Leaderboard.Init()
	local cashBoard = ensureBoard("CashBoard", "TOP CASH", Vector3.new(-18, 6, -30))
	local rebirthBoard = ensureBoard("RebirthBoard", "TOP REBIRTHS", Vector3.new(18, 6, -30))

	task.spawn(function()
		while true do
			refreshBoard(cashBoard, cashStore)
			refreshBoard(rebirthBoard, rebirthStore)
			task.wait(30)
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		Leaderboard.Submit(player)
	end)
end

return Leaderboard
]]
	writeScript(SSS, "ModuleScript", "Leaderboard", source)
end

-- RateLimit
do
	local source = [[local RateLimit = {}

local buckets = {} -- [player] = { [key] = lastClock }

function RateLimit.Allow(player, key, cooldown)
	cooldown = cooldown or 0.2
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

-- Main
do
	local source = [[local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))

local PlayerData = require(script.Parent:WaitForChild("PlayerData"))
local Monetization = require(script.Parent:WaitForChild("Monetization"))
local OrbWorld = require(script.Parent:WaitForChild("OrbWorld"))
local Leaderboard = require(script.Parent:WaitForChild("Leaderboard"))
local RateLimit = require(script.Parent:WaitForChild("RateLimit"))

Monetization.Init()
OrbWorld.Init()
Leaderboard.Init()

local function buyUpgrade(player, upgradeName)
	if not RateLimit.Allow(player, "upgrade", 0.15) then
		return
	end
	if typeof(upgradeName) ~= "string" or not Config.Upgrades[upgradeName] then
		return
	end
	local data = PlayerData.Get(player)
	if not data then
		return
	end
	local def = Config.Upgrades[upgradeName]
	local level = data.Upgrades[upgradeName] or 0
	if level >= def.max then
		Remotes.Toast:FireClient(player, "Max level!")
		return
	end
	local cost = PlayerData.UpgradeCost(upgradeName, level)
	if data.Cash < cost then
		Remotes.Toast:FireClient(player, "Not enough cash")
		return
	end
	data.Cash -= cost
	data.Upgrades[upgradeName] = level + 1
	if player.Character then
		OrbWorld.ApplyCharacterStats(player, player.Character)
	end
	Monetization.PushState(player)
end

local function doRebirth(player)
	if not RateLimit.Allow(player, "rebirth", 0.5) then
		return
	end
	local data = PlayerData.Get(player)
	if not data then
		return
	end
	local cost = PlayerData.RebirthCost(player)
	if data.Cash < cost then
		Remotes.Toast:FireClient(player, "Need $" .. tostring(cost) .. " to rebirth")
		return
	end
	data.Cash = 0
	data.Upgrades = {
		MagnetRange = 0,
		MagnetPull = 0,
		OrbValue = 0,
		WalkSpeed = 0,
	}
	data.Rebirths += 1
	data.HasRebirthedOnce = true
	if player.Character then
		OrbWorld.ApplyCharacterStats(player, player.Character)
	end
	Remotes.Toast:FireClient(player, "REBIRTH! Multiplier increased")
	Monetization.PushState(player)
	PlayerData.Save(player)
	Leaderboard.Submit(player)

	-- Soft monetization beat: after first rebirth, nudge 2x cash if unowned
	task.delay(1.2, function()
		if player.Parent then
			local snap = PlayerData.StatSnapshot(player, Monetization.GetPasses(player))
			if snap and snap.showShopNudge then
				Remotes.ShowShopNudge:FireClient(player)
			end
		end
	end)
end

local function claimDaily(player)
	if not RateLimit.Allow(player, "daily", 1) then
		return
	end
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
	local lastY, lastM, lastD = math.floor(last / 10000), math.floor(last / 100) % 100, last % 100
	local continued = false
	if last > 0 then
		local lastTime = os.time({ year = lastY, month = lastM, day = lastD, hour = 0 })
		local dayDiff = math.floor((os.time() - lastTime) / 86400)
		continued = dayDiff == 1
	end
	if continued then
		data.DailyStreak = math.min(Config.MaxDailyStreak, data.DailyStreak + 1)
	else
		data.DailyStreak = 1
	end
	data.LastDailyDay = today
	local reward = Config.DailyBonusBase + (data.DailyStreak - 1) * Config.DailyBonusPerStreak
	local passes = Monetization.GetPasses(player)
	reward = math.floor(reward * PlayerData.CashMultiplier(player, passes.DoubleCash))
	data.Cash += reward
	Remotes.Toast:FireClient(player, string.format("Daily x%d: +%d cash", data.DailyStreak, reward))
	Remotes.CashPop:FireClient(player, reward)
	Monetization.PushState(player)
	PlayerData.Save(player)
end

Remotes.BuyUpgrade.OnServerEvent:Connect(buyUpgrade)
Remotes.RequestRebirth.OnServerEvent:Connect(doRebirth)
Remotes.ClaimDaily.OnServerEvent:Connect(claimDaily)

Remotes.DismissNudge.OnServerEvent:Connect(function(player)
	if not RateLimit.Allow(player, "nudge", 0.5) then
		return
	end
	local data = PlayerData.Get(player)
	if data then
		data.ShopNudgeShown = true
		Monetization.PushState(player)
	end
end)

local function onPlayer(player)
	PlayerData.Load(player)
	Monetization.RefreshPasses(player)

	player.CharacterAdded:Connect(function(character)
		OrbWorld.ApplyCharacterStats(player, character)
	end)
	if player.Character then
		OrbWorld.ApplyCharacterStats(player, player.Character)
	end

	task.wait(0.5)
	Monetization.PushState(player)
	Remotes.Toast:FireClient(player, "Collect glowing orbs. Upgrade. Rebirth. Earn.")

	-- Tip sequence for first session feel
	task.delay(8, function()
		if player.Parent then
			Remotes.Toast:FireClient(player, "Tip: buy Range first, then Value")
		end
	end)
end

Players.PlayerAdded:Connect(onPlayer)
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayer, player)
end

task.spawn(function()
	while true do
		task.wait(60)
		for _, player in ipairs(Players:GetPlayers()) do
			PlayerData.Save(player)
			Leaderboard.Submit(player)
		end
	end
end)

print("[OrbRush] Server online —", Config.PlaceName)
]]
	writeScript(SSS, "Script", "Main", source)
end

-- Hud
do
	local source = [[local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local function corner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 10)
	c.Parent = parent
	return c
end

local function mkButton(parent, name, text, color)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Size = UDim2.new(1, -16, 0, 34)
	btn.BackgroundColor3 = color or Color3.fromRGB(45, 110, 220)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Text = text
	btn.AutoButtonColor = true
	btn.Parent = parent
	corner(btn, 8)
	return btn
end

local gui = Instance.new("ScreenGui")
gui.Name = "OrbRushHud"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local top = Instance.new("Frame")
top.Name = "TopBar"
top.Size = UDim2.new(1, 0, 0, 64)
top.BackgroundColor3 = Color3.fromRGB(12, 16, 28)
top.BackgroundTransparency = 0.25
top.BorderSizePixel = 0
top.Parent = gui

local cashLabel = Instance.new("TextLabel")
cashLabel.Name = "Cash"
cashLabel.Size = UDim2.new(0.5, -20, 0.6, 0)
cashLabel.Position = UDim2.new(0, 16, 0, 8)
cashLabel.BackgroundTransparency = 1
cashLabel.Font = Enum.Font.GothamBlack
cashLabel.TextSize = 28
cashLabel.TextXAlignment = Enum.TextXAlignment.Left
cashLabel.TextColor3 = Color3.fromRGB(120, 255, 170)
cashLabel.Text = "$0"
cashLabel.Parent = top

local multLabel = Instance.new("TextLabel")
multLabel.Name = "Mult"
multLabel.Size = UDim2.new(0.5, -20, 0.35, 0)
multLabel.Position = UDim2.new(0, 16, 0.58, 0)
multLabel.BackgroundTransparency = 1
multLabel.Font = Enum.Font.GothamMedium
multLabel.TextSize = 14
multLabel.TextXAlignment = Enum.TextXAlignment.Left
multLabel.TextColor3 = Color3.fromRGB(200, 210, 230)
multLabel.Text = "x1.00"
multLabel.Parent = top

local brand = Instance.new("TextLabel")
brand.Size = UDim2.new(0.4, 0, 1, 0)
brand.Position = UDim2.new(0.6, 0, 0, 0)
brand.BackgroundTransparency = 1
brand.Font = Enum.Font.GothamBlack
brand.TextSize = 22
brand.TextColor3 = Color3.fromRGB(90, 210, 255)
brand.Text = "ORB RUSH"
brand.Parent = top

local toastLabel = Instance.new("TextLabel")
toastLabel.Name = "Toast"
toastLabel.Size = UDim2.new(0.7, 0, 0, 36)
toastLabel.Position = UDim2.new(0.15, 0, 0, 76)
toastLabel.BackgroundTransparency = 1
toastLabel.Font = Enum.Font.GothamBold
toastLabel.TextSize = 18
toastLabel.TextColor3 = Color3.new(1, 1, 1)
toastLabel.TextStrokeTransparency = 0.5
toastLabel.Text = ""
toastLabel.Parent = gui

local popFolder = Instance.new("Folder")
popFolder.Name = "Pops"
popFolder.Parent = gui

local toggleBtn = mkButton(gui, "ToggleShop", "Hide Shop", Color3.fromRGB(40, 48, 68))
toggleBtn.Size = UDim2.fromOffset(120, 36)
toggleBtn.Position = UDim2.new(1, -136, 0, 76)

local shop = Instance.new("Frame")
shop.Name = "Shop"
shop.Size = UDim2.fromOffset(280, 460)
shop.Position = UDim2.new(1, -296, 0, 120)
shop.BackgroundColor3 = Color3.fromRGB(18, 22, 34)
shop.BackgroundTransparency = 0.08
shop.BorderSizePixel = 0
shop.Parent = gui
corner(shop, 14)

local shopTitle = Instance.new("TextLabel")
shopTitle.Size = UDim2.new(1, -16, 0, 28)
shopTitle.Position = UDim2.fromOffset(8, 8)
shopTitle.BackgroundTransparency = 1
shopTitle.Font = Enum.Font.GothamBlack
shopTitle.TextSize = 18
shopTitle.TextColor3 = Color3.new(1, 1, 1)
shopTitle.TextXAlignment = Enum.TextXAlignment.Left
shopTitle.Text = "Upgrades & Shop"
shopTitle.Parent = shop

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 6)
list.SortOrder = Enum.SortOrder.LayoutOrder
list.Parent = shop

local pad = Instance.new("UIPadding")
pad.PaddingTop = UDim.new(0, 40)
pad.PaddingLeft = UDim.new(0, 8)
pad.PaddingRight = UDim.new(0, 8)
pad.Parent = shop

local upgradesFrame = Instance.new("Frame")
upgradesFrame.Name = "Upgrades"
upgradesFrame.Size = UDim2.new(1, 0, 0, 168)
upgradesFrame.BackgroundTransparency = 1
upgradesFrame.LayoutOrder = 1
upgradesFrame.Parent = shop

local upList = Instance.new("UIListLayout")
upList.Padding = UDim.new(0, 4)
upList.Parent = upgradesFrame

local rebirthBtn = mkButton(shop, "Rebirth", "Rebirth", Color3.fromRGB(180, 70, 200))
rebirthBtn.LayoutOrder = 2

local dailyBtn = mkButton(shop, "Daily", "Claim Daily Bonus", Color3.fromRGB(50, 150, 90))
dailyBtn.LayoutOrder = 3

local passDouble = mkButton(shop, "PassDouble", "Buy 2× Cash Pass", Color3.fromRGB(220, 160, 40))
passDouble.LayoutOrder = 4

local passVip = mkButton(shop, "PassVip", "Buy VIP Magnet", Color3.fromRGB(70, 130, 230))
passVip.LayoutOrder = 5

local buySmall = mkButton(shop, "BuySmall", "Cash Pack S (500)", Color3.fromRGB(55, 65, 90))
buySmall.LayoutOrder = 6
local buyMed = mkButton(shop, "BuyMed", "Cash Pack M (3K)", Color3.fromRGB(55, 65, 90))
buyMed.LayoutOrder = 7
local buyLarge = mkButton(shop, "BuyLarge", "Cash Pack L (20K)", Color3.fromRGB(55, 65, 90))
buyLarge.LayoutOrder = 8

local shopOpen = true
local lastState

local UPGRADE_ORDER = { "MagnetRange", "MagnetPull", "OrbValue", "WalkSpeed" }
local UPGRADE_LABELS = {
	MagnetRange = "Range",
	MagnetPull = "Pull",
	OrbValue = "Value",
	WalkSpeed = "Speed",
}

local function formatCash(n)
	n = math.floor(n or 0)
	if n >= 1e9 then
		return string.format("$%.2fB", n / 1e9)
	elseif n >= 1e6 then
		return string.format("$%.2fM", n / 1e6)
	elseif n >= 1e3 then
		return string.format("$%.1fK", n / 1e3)
	end
	return "$" .. tostring(n)
end

local function showToast(text)
	toastLabel.Text = text
	toastLabel.TextTransparency = 0
	task.delay(2.4, function()
		if toastLabel.Text == text then
			TweenService:Create(toastLabel, TweenInfo.new(0.4), { TextTransparency = 1 }):Play()
		end
	end)
end

local function cashPop(amount)
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromOffset(120, 36)
	label.Position = UDim2.new(0.5, math.random(-40, 40), 0.55, math.random(-20, 20))
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 22
	label.TextColor3 = Color3.fromRGB(120, 255, 160)
	label.TextStrokeTransparency = 0.4
	label.Text = "+" .. tostring(amount)
	label.Parent = popFolder
	local tw = TweenService:Create(label, TweenInfo.new(0.8), {
		Position = label.Position - UDim2.fromOffset(0, 60),
		TextTransparency = 1,
		TextStrokeTransparency = 1,
	})
	tw:Play()
	tw.Completed:Connect(function()
		label:Destroy()
	end)
end

local function refreshUpgrades(state)
	for _, child in ipairs(upgradesFrame:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
	for _, name in ipairs(UPGRADE_ORDER) do
		local info = state.upgrades[name]
		if info then
			local btn = Instance.new("TextButton")
			btn.Name = name
			btn.Size = UDim2.new(1, 0, 0, 36)
			btn.BackgroundColor3 = Color3.fromRGB(36, 44, 62)
			btn.Font = Enum.Font.GothamMedium
			btn.TextSize = 14
			btn.TextColor3 = Color3.new(1, 1, 1)
			btn.TextXAlignment = Enum.TextXAlignment.Left
			local maxed = info.level >= info.max
			btn.Text = string.format(
				"  %s  Lv %d/%d   %s",
				UPGRADE_LABELS[name],
				info.level,
				info.max,
				maxed and "MAX" or formatCash(info.cost)
			)
			btn.Parent = upgradesFrame
			corner(btn, 8)
			btn.MouseButton1Click:Connect(function()
				Remotes.BuyUpgrade:FireServer(name)
			end)
		end
	end
end

local function applyState(state)
	lastState = state
	cashLabel.Text = formatCash(state.cash)
	multLabel.Text = string.format("x%.2f | R%d | streak %d", state.multiplier, state.rebirths, state.dailyStreak)
	rebirthBtn.Text = string.format("Rebirth (%s)", formatCash(state.rebirthCost))
	dailyBtn.Text = state.canClaimDaily and "Claim Daily Bonus" or "Daily Claimed"
	passDouble.Text = state.passes.DoubleCash and "2x Cash owned" or "Buy 2x Cash Pass"
	passVip.Text = state.passes.VipMagnet and "VIP Magnet owned" or "Buy VIP Magnet"
	refreshUpgrades(state)
end

Remotes.StateUpdate.OnClientEvent:Connect(applyState)
Remotes.Toast.OnClientEvent:Connect(showToast)
Remotes.CashPop.OnClientEvent:Connect(cashPop)

toggleBtn.MouseButton1Click:Connect(function()
	shopOpen = not shopOpen
	shop.Visible = shopOpen
	toggleBtn.Text = shopOpen and "Hide Shop" or "Shop"
end)

rebirthBtn.MouseButton1Click:Connect(function()
	Remotes.RequestRebirth:FireServer()
end)
dailyBtn.MouseButton1Click:Connect(function()
	Remotes.ClaimDaily:FireServer()
end)
passDouble.MouseButton1Click:Connect(function()
	if lastState and lastState.passes.DoubleCash then
		return
	end
	Remotes.PromptGamePass:FireServer("DoubleCash")
end)
passVip.MouseButton1Click:Connect(function()
	if lastState and lastState.passes.VipMagnet then
		return
	end
	Remotes.PromptGamePass:FireServer("VipMagnet")
end)
buySmall.MouseButton1Click:Connect(function()
	Remotes.PromptProduct:FireServer("CashSmall")
end)
buyMed.MouseButton1Click:Connect(function()
	Remotes.PromptProduct:FireServer("CashMed")
end)
buyLarge.MouseButton1Click:Connect(function()
	Remotes.PromptProduct:FireServer("CashLarge")
end)

-- Soft shop nudge modal (after first rebirth)
local nudge = Instance.new("Frame")
nudge.Name = "ShopNudge"
nudge.Visible = false
nudge.Size = UDim2.fromOffset(320, 180)
nudge.Position = UDim2.fromScale(0.5, 0.5)
nudge.AnchorPoint = Vector2.new(0.5, 0.5)
nudge.BackgroundColor3 = Color3.fromRGB(16, 20, 32)
nudge.Parent = gui
corner(nudge, 14)

local nudgeTitle = Instance.new("TextLabel")
nudgeTitle.Size = UDim2.new(1, -24, 0, 36)
nudgeTitle.Position = UDim2.fromOffset(12, 12)
nudgeTitle.BackgroundTransparency = 1
nudgeTitle.Font = Enum.Font.GothamBlack
nudgeTitle.TextSize = 20
nudgeTitle.TextColor3 = Color3.new(1, 1, 1)
nudgeTitle.TextXAlignment = Enum.TextXAlignment.Left
nudgeTitle.Text = "Double your grind?"
nudgeTitle.Parent = nudge

local nudgeBody = Instance.new("TextLabel")
nudgeBody.Size = UDim2.new(1, -24, 0, 48)
nudgeBody.Position = UDim2.fromOffset(12, 52)
nudgeBody.BackgroundTransparency = 1
nudgeBody.Font = Enum.Font.Gotham
nudgeBody.TextSize = 15
nudgeBody.TextColor3 = Color3.fromRGB(200, 210, 230)
nudgeBody.TextXAlignment = Enum.TextXAlignment.Left
nudgeBody.TextWrapped = true
nudgeBody.Text = "You just rebirthed. 2x Cash permanently doubles every orb — best first purchase."
nudgeBody.Parent = nudge

local nudgeBuy = mkButton(nudge, "NudgeBuy", "Get 2x Cash", Color3.fromRGB(220, 160, 40))
nudgeBuy.Position = UDim2.fromOffset(12, 118)
nudgeBuy.Size = UDim2.new(0.55, -16, 0, 40)

local nudgeSkip = mkButton(nudge, "NudgeSkip", "Maybe later", Color3.fromRGB(50, 56, 72))
nudgeSkip.Position = UDim2.fromOffset(12 + nudgeBuy.AbsoluteSize.X, 118)
nudgeSkip.Size = UDim2.new(0.45, -8, 0, 40)
nudgeSkip.Position = UDim2.new(0.55, 0, 0, 118)

local function hideNudge()
	nudge.Visible = false
	Remotes.DismissNudge:FireServer()
end

nudgeBuy.MouseButton1Click:Connect(function()
	nudge.Visible = false
	Remotes.PromptGamePass:FireServer("DoubleCash")
	Remotes.DismissNudge:FireServer()
end)
nudgeSkip.MouseButton1Click:Connect(hideNudge)

Remotes.ShowShopNudge.OnClientEvent:Connect(function()
	nudge.Visible = true
	shop.Visible = true
	shopOpen = true
	toggleBtn.Text = "Hide Shop"
end)

showToast("Welcome to Orb Rush — collect orbs!")
]]
	writeScript(SPS, "LocalScript", "Hud", source)
end

print("[OrbRush] Install complete. Stop Play, delete this Installer script, Play again.")
script.Disabled = true
script.Name = "OrbRushInstaller_DONE"
