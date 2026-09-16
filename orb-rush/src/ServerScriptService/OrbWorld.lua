local Debris = game:GetService("Debris")
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
