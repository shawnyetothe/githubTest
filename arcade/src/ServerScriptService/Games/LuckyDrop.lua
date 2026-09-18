local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
