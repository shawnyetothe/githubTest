local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))

local PlayerData = require(script.Parent:WaitForChild("PlayerData"))
local Monetization = require(script.Parent:WaitForChild("Monetization"))
local WorldEvents = require(script.Parent:WaitForChild("WorldEvents"))
local Presence = require(script.Parent:WaitForChild("Presence"))
local StateBus = require(script.Parent:WaitForChild("StateBus"))
local RateLimit = require(script.Parent:WaitForChild("RateLimit"))
local Util = require(script.Parent:WaitForChild("Util"))

local games = {}
for _, child in ipairs(script.Parent:WaitForChild("Games"):GetChildren()) do
	if child:IsA("ModuleScript") then
		local gameModule = require(child)
		if typeof(gameModule) == "table" and gameModule.Id then
			games[gameModule.Id] = gameModule
		end
	end
end

local COOLDOWN = {
	Teleport = 0.6,
	RhythmHit = 0.04,
	Shoot = 0.45,
	Drop = 2.4,
	Serve = 0.12,
	GardenPlot = 0.15,
	BuyUpgrade = 0.12,
	TycoonBuy = 0.35,
}

local pushQueued = {}

local function snapshot(player)
	local data = PlayerData.Get(player)
	if not data then
		return nil
	end
	local gameId = player:GetAttribute("GameId") or "Hub"
	local snap = {
		gameId = gameId,
		coins = data.Coins,
		friendBoost = Presence.Boost(player),
		event = WorldEvents.Current(),
		eventLeft = math.floor(WorldEvents.TimeLeft()),
		daily = {
			streak = data.DailyStreak,
			canClaim = data.LastDailyDay ~= PlayerData.TodayKey(),
		},
		passes = Monetization.GetPasses(player),
		counts = {},
		subtitle = "Pick a portal",
	}
	for _, info in ipairs(Config.Catalog) do
		snap.counts[info.id] = Presence.Count(info.id)
		local g = games[info.id]
		if g and g.Snapshot then
			snap[info.id] = g.Snapshot(player)
		end
	end
	local active = snap[gameId]
	if typeof(active) == "table" and active.subtitle then
		snap.subtitle = active.subtitle
	elseif gameId == "Hub" then
		snap.subtitle = "10 games · bring a friend for +15%"
	end
	return snap
end

local function pushNow(player)
	local snap = snapshot(player)
	if snap then
		Remotes.State:FireClient(player, snap)
	end
end

local function push(player, immediate)
	if not player or not player.Parent then
		return
	end
	if immediate then
		pushQueued[player] = nil
		pushNow(player)
		return
	end
	if pushQueued[player] then
		return
	end
	pushQueued[player] = true
	task.delay(0.25, function()
		pushQueued[player] = nil
		if player.Parent then
			pushNow(player)
		end
	end)
end

StateBus.Set(push)

local function placeCharacter(player)
	local gameId = player:GetAttribute("GameId") or "Hub"
	local g = games[gameId]
	local cf = CFrame.new((Config.Layout[gameId] or Config.Layout.Hub) + Vector3.new(0, 6, 0))
	if g and g.SpawnCFrame then
		local custom = g.SpawnCFrame(player)
		if typeof(custom) == "CFrame" then
			cf = custom
		end
	end
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
	root.CFrame = cf
end

local function teleport(player, gameId)
	if typeof(gameId) ~= "string" then
		return
	end
	if gameId ~= "Hub" and not Config.Layout[gameId] then
		return
	end
	if gameId ~= "Hub" and not games[gameId] then
		return
	end
	local prev = player:GetAttribute("GameId")
	if prev == gameId then
		placeCharacter(player)
		return
	end
	if prev and games[prev] and games[prev].OnLeave then
		games[prev].OnLeave(player)
	end
	player:SetAttribute("GameId", gameId)
	placeCharacter(player)
	if games[gameId] and games[gameId].OnEnter then
		games[gameId].OnEnter(player)
	end
	local info = Config.Info(gameId)
	Remotes.Toast:FireClient(player, info and ("Entered " .. info.name) or "Rush Plaza")
	if gameId ~= "Hub" then
		local data = PlayerData.Get(player)
		if data and data.Visited[gameId] ~= true then
			data.Visited[gameId] = true
			Monetization.GrantCoins(player, Config.FirstVisitBonus, "first visit", true)
		end
		if Presence.Count(gameId) >= 2 then
			Remotes.Toast:FireClient(player, "Friend boost +15% while you play together")
		end
	end
	push(player, true)
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
	local last = data.LastDailyDay or 0
	local continued = false
	if last > 0 then
		local lastTime = os.time({
			year = math.floor(last / 10000),
			month = math.floor(last / 100) % 100,
			day = last % 100,
			hour = 0,
		})
		continued = math.floor((os.time() - lastTime) / 86400) == 1
	end
	if continued then
		data.DailyStreak = math.min(Config.Daily.maxStreak, data.DailyStreak + 1)
	else
		data.DailyStreak = 1
	end
	data.LastDailyDay = today
	local reward = Config.Daily.base + (data.DailyStreak - 1) * Config.Daily.perStreak
	reward = math.floor(reward * Monetization.Multiplier(player, "coins"))
	Monetization.GrantCoins(player, reward, "daily x" .. data.DailyStreak, true)
	PlayerData.Save(player)
end

local function num(value)
	if typeof(value) ~= "number" then
		return nil
	end
	if value ~= value or value > 1e6 or value < -1e6 then
		return nil
	end
	return value
end

local function shortString(value)
	if typeof(value) ~= "string" or #value > 32 then
		return nil
	end
	return value
end

local handlers = {
	Teleport = function(player, id)
		teleport(player, id)
	end,
	BuyUpgrade = function(player, name)
		name = shortString(name)
		if name and games.OrbRush then
			games.OrbRush.BuyUpgrade(player, name)
		end
	end,
	Rebirth = function(player)
		games.OrbRush.Rebirth(player)
	end,
	Drop = function(player)
		games.LuckyDrop.Drop(player)
	end,
	LuckyUpgrade = function(player)
		games.LuckyDrop.Upgrade(player)
	end,
	TycoonBuy = function(player)
		games.TycoonLite.Buy(player)
	end,
	GardenPlot = function(player, index, cropId)
		games.GardenPocket.PlantOrHarvest(player, num(index), shortString(cropId))
	end,
	GardenWater = function(player, index)
		games.GardenPocket.Water(player, num(index))
	end,
	StoryChoice = function(player, choiceId)
		games.StoryBeat.Choose(player, shortString(choiceId))
	end,
	StoryReplay = function(player)
		games.StoryBeat.Replay(player)
	end,
	RhythmStart = function(player)
		games.RhythmTap.Start(player)
	end,
	RhythmHit = function(player, index)
		games.RhythmTap.Hit(player, num(index))
	end,
	Shoot = function(player, power)
		games.HoopShot.Shoot(player, num(power))
	end,
	Serve = function(player, itemId)
		games.StallRush.Serve(player, shortString(itemId))
	end,
	ClaimDaily = function(player)
		claimDaily(player)
	end,
	PromptPass = function(player, key)
		key = shortString(key)
		if key then
			Monetization.PromptPass(player, key)
		end
	end,
	PromptProduct = function(player, key)
		key = shortString(key)
		if key then
			Monetization.PromptProduct(player, key)
		end
	end,
}

local baseplate = Workspace:FindFirstChild("Baseplate")
if baseplate then
	baseplate:Destroy()
end

Monetization.Init()
WorldEvents.Init()

for _, g in pairs(games) do
	if g.Build then
		g.Build()
	end
end
for _, g in pairs(games) do
	if g.Init then
		g.Init()
	end
end

for _, prompt in ipairs(CollectionService:GetTagged("RushPortal")) do
	prompt.Triggered:Connect(function(player)
		teleport(player, prompt:GetAttribute("Dest"))
	end)
end

local void = Util.part(Workspace, "VoidReturn", Vector3.new(5000, 2, 5000), CFrame.new(0, -50, 0), Color3.fromRGB(0, 0, 0), Enum.Material.SmoothPlastic, false, 1)
local voidAt = {}
void.Touched:Connect(function(hit)
	local player = Players:GetPlayerFromCharacter(hit.Parent)
	if not player then
		return
	end
	if (voidAt[player] or 0) + 1 > os.clock() then
		return
	end
	voidAt[player] = os.clock()
	placeCharacter(player)
end)

local function onPlayer(player)
	PlayerData.Load(player)
	Monetization.RefreshPasses(player)
	player:SetAttribute("GameId", "Hub")
	player.CharacterAdded:Connect(function()
		task.defer(function()
			if player.Parent then
				placeCharacter(player)
			end
		end)
	end)
	if player.Character then
		task.defer(function()
			placeCharacter(player)
		end)
	end
	task.delay(0.6, function()
		if player.Parent then
			push(player, true)
			Remotes.Toast:FireClient(player, "Welcome to Rush Plaza — pick a portal")
		end
	end)
end

Players.PlayerAdded:Connect(onPlayer)
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayer, player)
end

Remotes.Action.OnServerEvent:Connect(function(player, action, a, b)
	if typeof(action) ~= "string" or #action > 32 then
		return
	end
	local fn = handlers[action]
	if not fn then
		return
	end
	if not RateLimit.Allow(player, action, COOLDOWN[action] or 0.15) then
		return
	end
	fn(player, a, b)
end)

task.spawn(function()
	while true do
		task.wait(2)
		local hub = games.Hub
		for _, info in ipairs(Config.Catalog) do
			if hub and hub.SetCount then
				hub.SetCount(info.id, Presence.Count(info.id), info.name)
			end
		end
		if hub and hub.EventLabel then
			local ev = WorldEvents.Current()
			if ev then
				hub.EventLabel.Text = ev .. "\n" .. math.floor(WorldEvents.TimeLeft()) .. "s left"
			else
				hub.EventLabel.Text = "Next plaza event soon\nGold Rush · Orb Storm · Lucky Minute"
			end
		end
		for _, player in ipairs(Players:GetPlayers()) do
			if player:GetAttribute("GameId") == "Hub" or player:GetAttribute("GameId") == "StallRush" or player:GetAttribute("GameId") == "DuoExtract" then
				push(player, false)
			end
		end
	end
end)

task.spawn(function()
	while true do
		task.wait(60)
		for _, player in ipairs(Players:GetPlayers()) do
			PlayerData.Save(player)
		end
	end
end)

print("[RushPlaza] online —", Config.PlaceName, "games", #Config.Catalog)
