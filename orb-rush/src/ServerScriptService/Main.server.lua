local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))

local PlayerData = require(script.Parent:WaitForChild("PlayerData"))
local Monetization = require(script.Parent:WaitForChild("Monetization"))
local OrbWorld = require(script.Parent:WaitForChild("OrbWorld"))

Monetization.Init()
OrbWorld.Init()

local function buyUpgrade(player, upgradeName)
	if typeof(upgradeName) ~= "string" or not Config.Upgrades[upgradeName] then
		return
	end
	local data = PlayerData.Get(player)
	if not data then
		return
	end
	local def = Config.Upgrades[upgradeName]
	local level = data.Upgrades[upgradeName] or 0
	if level >= def.max then
		Remotes.Toast:FireClient(player, "Max level!")
		return
	end
	local cost = PlayerData.UpgradeCost(upgradeName, level)
	if data.Cash < cost then
		Remotes.Toast:FireClient(player, "Not enough cash")
		return
	end
	data.Cash -= cost
	data.Upgrades[upgradeName] = level + 1
	if player.Character then
		OrbWorld.ApplyCharacterStats(player, player.Character)
	end
	Monetization.PushState(player)
end

local function doRebirth(player)
	local data = PlayerData.Get(player)
	if not data then
		return
	end
	local cost = PlayerData.RebirthCost(player)
	if data.Cash < cost then
		Remotes.Toast:FireClient(player, "Need $" .. tostring(cost) .. " to rebirth")
		return
	end
	data.Cash = 0
	data.Upgrades = {
		MagnetRange = 0,
		MagnetPull = 0,
		OrbValue = 0,
		WalkSpeed = 0,
	}
	data.Rebirths += 1
	data.HasRebirthedOnce = true
	if player.Character then
		OrbWorld.ApplyCharacterStats(player, player.Character)
	end
	Remotes.Toast:FireClient(player, "REBIRTH! Multiplier increased")
	Monetization.PushState(player)
	PlayerData.Save(player)
end

local function claimDaily(player)
	local data = PlayerData.Get(player)
	if not data then
		return
	end
	local today = PlayerData.TodayKey()
	if data.LastDailyDay == today then
		Remotes.Toast:FireClient(player, "Daily already claimed")
		return
	end
	-- Streak if last claim was the previous UTC calendar day
	local last = data.LastDailyDay or 0
	local lastY, lastM, lastD = math.floor(last / 10000), math.floor(last / 100) % 100, last % 100
	local continued = false
	if last > 0 then
		local lastTime = os.time({ year = lastY, month = lastM, day = lastD, hour = 0 })
		local dayDiff = math.floor((os.time() - lastTime) / 86400)
		continued = dayDiff == 1
	end
	if continued then
		data.DailyStreak = math.min(Config.MaxDailyStreak, data.DailyStreak + 1)
	else
		data.DailyStreak = 1
	end
	data.LastDailyDay = today
	local reward = Config.DailyBonusBase + (data.DailyStreak - 1) * Config.DailyBonusPerStreak
	local passes = Monetization.GetPasses(player)
	reward = math.floor(reward * PlayerData.CashMultiplier(player, passes.DoubleCash))
	data.Cash += reward
	Remotes.Toast:FireClient(player, string.format("Daily x%d: +%d cash", data.DailyStreak, reward))
	Remotes.CashPop:FireClient(player, reward)
	Monetization.PushState(player)
	PlayerData.Save(player)
end

Remotes.BuyUpgrade.OnServerEvent:Connect(buyUpgrade)
Remotes.RequestRebirth.OnServerEvent:Connect(doRebirth)
Remotes.ClaimDaily.OnServerEvent:Connect(claimDaily)

local function onPlayer(player)
	PlayerData.Load(player)
	Monetization.RefreshPasses(player)

	player.CharacterAdded:Connect(function(character)
		OrbWorld.ApplyCharacterStats(player, character)
	end)
	if player.Character then
		OrbWorld.ApplyCharacterStats(player, player.Character)
	end

	task.wait(0.5)
	Monetization.PushState(player)
	Remotes.Toast:FireClient(player, "Collect glowing orbs. Upgrade. Rebirth. Earn.")
end

Players.PlayerAdded:Connect(onPlayer)
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayer, player)
end

-- Autosave every 60s
task.spawn(function()
	while true do
		task.wait(60)
		for _, player in ipairs(Players:GetPlayers()) do
			PlayerData.Save(player)
		end
	end
end)

print("[OrbRush] Server online —", Config.PlaceName)
