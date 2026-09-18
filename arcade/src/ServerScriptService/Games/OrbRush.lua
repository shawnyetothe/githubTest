local Debris = game:GetService("Debris")
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
