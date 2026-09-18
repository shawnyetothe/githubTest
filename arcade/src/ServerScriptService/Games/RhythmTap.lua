local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
