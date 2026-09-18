local Players = game:GetService("Players")
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
