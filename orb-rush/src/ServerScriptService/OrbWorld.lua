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
local orbs = {} -- [part] = { tier = table, value = number }

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

	-- Soft boundary ring
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

	return arena
end

local function spawnOrb()
	if #orbs >= Config.MaxOrbs then
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
	light.Brightness = 1.2
	light.Range = 10
	light.Color = part.Color
	light.Parent = part

	orbs[part] = { tier = tier, valueMult = tier.mult }
	Debris:AddItem(part, Config.OrbLifetime)

	part.AncestryChanged:Connect(function(_, parent)
		if not parent then
			orbs[part] = nil
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

local function collectOrb(player, part)
	local meta = orbs[part]
	if not meta then
		return
	end
	orbs[part] = nil
	part:Destroy()

	local data = PlayerData.Get(player)
	if not data then
		return
	end

	local _, _, orbValue = magnetStats(player)
	local passes = Monetization.GetPasses(player)
	local gain = math.max(1, math.floor(orbValue * meta.valueMult * PlayerData.CashMultiplier(player, passes.DoubleCash)))
	data.Cash += gain
	data.TotalCollected += 1
	Remotes.CashPop:FireClient(player, gain)
	Monetization.PushState(player)
end

function OrbWorld.ApplyCharacterStats(player, character)
	local hum = character:WaitForChild("Humanoid", 5)
	if not hum then
		return
	end
	local _, _, _, speed = magnetStats(player)
	hum.WalkSpeed = speed
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

return OrbWorld
