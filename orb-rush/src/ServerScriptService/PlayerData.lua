local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local PlayerData = {}

local store = DataStoreService:GetDataStore(Config.DataStoreName)
local sessions = {}

local function defaultData()
	return {
		Cash = 0,
		Rebirths = 0,
		Upgrades = {
			MagnetRange = 0,
			MagnetPull = 0,
			OrbValue = 0,
			WalkSpeed = 0,
		},
		DailyStreak = 0,
		LastDailyDay = 0,
		TotalCollected = 0,
		HasRebirthedOnce = false,
		ShopNudgeShown = false,
		ProcessedReceipts = {},
	}
end

local function todayKey()
	local t = os.date("!*t")
	return t.year * 10000 + t.month * 100 + t.day
end

function PlayerData.Get(player)
	return sessions[player]
end

function PlayerData.Load(player)
	local data = defaultData()
	local ok, saved = pcall(function()
		return store:GetAsync("p_" .. player.UserId)
	end)
	if ok and typeof(saved) == "table" then
		for k, v in pairs(saved) do
			if k == "Upgrades" and typeof(v) == "table" then
				for uk, uv in pairs(v) do
					data.Upgrades[uk] = uv
				end
			elseif k == "ProcessedReceipts" and typeof(v) == "table" then
				data.ProcessedReceipts = v
			else
				data[k] = v
			end
		end
	end
	sessions[player] = data
	return data
end

function PlayerData.Save(player)
	local data = sessions[player]
	if not data then
		return
	end
	local receipts = data.ProcessedReceipts or {}
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

function PlayerData.CashMultiplier(player, ownsDoubleCash)
	local data = sessions[player]
	if not data then
		return 1
	end
	local mult = 1 + (data.Rebirths * Config.RebirthMultPer)
	if ownsDoubleCash then
		mult *= 2
	end
	return mult
end

function PlayerData.UpgradeCost(name, level)
	local def = Config.Upgrades[name]
	if not def then
		return math.huge
	end
	return math.floor(def.baseCost * (def.growth ^ level))
end

function PlayerData.RebirthCost(player)
	local data = sessions[player]
	if not data then
		return Config.RebirthBaseCash
	end
	return math.floor(Config.RebirthBaseCash * (Config.RebirthCostGrowth ^ data.Rebirths))
end

function PlayerData.StatSnapshot(player, passOwned)
	local data = sessions[player]
	if not data then
		return nil
	end
	local ups = {}
	for name, def in pairs(Config.Upgrades) do
		local lvl = data.Upgrades[name] or 0
		ups[name] = {
			level = lvl,
			max = def.max,
			cost = PlayerData.UpgradeCost(name, lvl),
		}
	end
	return {
		cash = data.Cash,
		rebirths = data.Rebirths,
		multiplier = PlayerData.CashMultiplier(player, passOwned and passOwned.DoubleCash),
		upgrades = ups,
		rebirthCost = PlayerData.RebirthCost(player),
		dailyStreak = data.DailyStreak,
		canClaimDaily = data.LastDailyDay ~= todayKey(),
		totalCollected = data.TotalCollected,
		passes = passOwned or { DoubleCash = false, VipMagnet = false },
		showShopNudge = Config.ShopNudgeEnabled
			and data.HasRebirthedOnce == true
			and data.ShopNudgeShown ~= true
			and not (passOwned and passOwned.DoubleCash),
	}
end

function PlayerData.TodayKey()
	return todayKey()
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
