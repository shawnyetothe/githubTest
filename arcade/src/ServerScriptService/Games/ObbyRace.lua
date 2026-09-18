local Players = game:GetService("Players")
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
