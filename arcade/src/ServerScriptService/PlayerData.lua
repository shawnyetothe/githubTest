local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local PlayerData = {}
local store = DataStoreService:GetDataStore(Config.DataStoreName)
local sessions = {}

local function emptyGarden()
	local plots = {}
	for i = 1, Config.Garden.Plots do
		plots[i] = { crop = "", readyAt = 0, watered = false }
	end
	return plots
end

local function defaultData()
	return {
		Coins = Config.StartingCoins,
		DailyStreak = 0,
		LastDailyDay = 0,
		Visited = {},
		Endings = {},
		OrbCash = 0,
		OrbRebirths = 0,
		OrbUpgrades = { MagnetRange = 0, MagnetPull = 0, OrbValue = 0, WalkSpeed = 0 },
		OrbCollected = 0,
		OrbNudgeShown = false,
		TycoonCash = 0,
		TycoonLevel = 0,
		Garden = emptyGarden(),
		ObbyBest = 0,
		RhythmBest = 0,
		HoopBest = 0,
		StallBest = 0,
		LuckyLuck = 0,
		StoryNode = "start",
		ProcessedReceipts = {},
	}
end

local function todayKey()
	local t = os.date("!*t")
	return t.year * 10000 + t.month * 100 + t.day
end

local function copySaved(saved)
	local data = defaultData()
	if typeof(saved) ~= "table" then
		return data
	end
	local direct = {
		"Coins", "DailyStreak", "LastDailyDay", "OrbCash", "OrbRebirths", "OrbCollected",
		"OrbNudgeShown", "TycoonCash", "TycoonLevel", "ObbyBest", "RhythmBest", "HoopBest",
		"StallBest", "LuckyLuck", "StoryNode",
	}
	for _, k in ipairs(direct) do
		if saved[k] ~= nil then
			data[k] = saved[k]
		end
	end
	if typeof(saved.OrbUpgrades) == "table" then
		for k, v in pairs(saved.OrbUpgrades) do
			data.OrbUpgrades[k] = v
		end
	end
	if typeof(saved.Visited) == "table" then
		data.Visited = saved.Visited
	end
	if typeof(saved.Endings) == "table" then
		data.Endings = saved.Endings
	end
	if typeof(saved.ProcessedReceipts) == "table" then
		data.ProcessedReceipts = saved.ProcessedReceipts
	end
	if typeof(saved.Garden) == "table" then
		for i = 1, Config.Garden.Plots do
			local g = saved.Garden[i]
			if typeof(g) == "table" then
				data.Garden[i] = {
					crop = g.crop or "",
					readyAt = g.readyAt or 0,
					watered = g.watered == true,
				}
			end
		end
	end
	return data
end

function PlayerData.Get(player)
	return sessions[player]
end

function PlayerData.Load(player)
	local data = defaultData()
	local ok, saved = pcall(function()
		return store:GetAsync("p_" .. player.UserId)
	end)
	if ok then
		data = copySaved(saved)
	end
	sessions[player] = data
	return data
end

function PlayerData.Save(player)
	local data = sessions[player]
	if not data then
		return
	end
	local receipts = data.ProcessedReceipts
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

function PlayerData.TodayKey()
	return todayKey()
end

function PlayerData.OrbCost(name, level)
	local def = Config.Orb.Upgrades[name]
	if not def then
		return math.huge
	end
	return math.floor(def.baseCost * (def.growth ^ level))
end

function PlayerData.RebirthCost(data)
	return math.floor(Config.Orb.RebirthBase * (Config.Orb.RebirthGrowth ^ data.OrbRebirths))
end

function PlayerData.OrbMult(data)
	return 1 + data.OrbRebirths * Config.Orb.RebirthMult
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
