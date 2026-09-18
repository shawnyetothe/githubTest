local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
