local Players = game:GetService("Players")
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
