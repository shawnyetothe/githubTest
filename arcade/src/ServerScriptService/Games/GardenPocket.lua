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

local GardenPocket = {}
GardenPocket.Id = "GardenPocket"

local soils = {}
local ownerLabels = {}

local function cropById(id)
	for _, c in ipairs(Config.Garden.Crops) do
		if c.id == id then
			return c
		end
	end
	return nil
end

local function origin()
	return Config.Layout.GardenPocket
end

local function slotOrigin(index)
	return origin() + Vector3.new(0, 0, (index - 3.5) * 28)
end

function GardenPocket.SpawnCFrame(player)
	local slot = Slots.Get("Garden", player) or 1
	return CFrame.new(slotOrigin(slot) + Vector3.new(-16, 5, 0))
end

function GardenPocket.OnEnter(player)
	if not Slots.Ensure("Garden", player, Config.Garden.Slots) then
		Remotes.Toast:FireClient(player, "Garden rows are full — use the HUD anyway if you already planted")
	end
end

local function plotState(plot)
	local now = os.time()
	if plot.crop == "" then
		return { crop = "", ready = false, left = 0, watered = false }
	end
	local left = math.max(0, (plot.readyAt or 0) - now)
	return { crop = plot.crop, ready = left <= 0, left = left, watered = plot.watered == true }
end

function GardenPocket.Snapshot(player)
	local data = PlayerData.Get(player)
	if not data then
		return nil
	end
	local plots = {}
	local ready = 0
	for i, plot in ipairs(data.Garden) do
		plots[i] = plotState(plot)
		if plots[i].ready then
			ready += 1
		end
	end
	return {
		plots = plots,
		crops = Config.Garden.Crops,
		subtitle = ready > 0 and (ready .. " ready to harvest") or "Plant, leave, come back",
	}
end

function GardenPocket.PlantOrHarvest(player, index, cropId)
	local data = PlayerData.Get(player)
	if not data then
		return
	end
	index = math.floor(tonumber(index) or 0)
	local plot = data.Garden[index]
	if not plot then
		return
	end
	local view = plotState(plot)
	if view.crop ~= "" and view.ready then
		local crop = cropById(plot.crop)
		local value = crop and crop.value or 10
		value = math.floor(value * Monetization.Multiplier(player, "coins"))
		plot.crop = ""
		plot.readyAt = 0
		plot.watered = false
		Monetization.GrantCoins(player, value, "harvest", true)
		return
	end
	if view.crop ~= "" then
		Remotes.Toast:FireClient(player, "Still growing (" .. view.left .. "s)")
		return
	end
	local crop = cropById(cropId)
	if not crop then
		Remotes.Toast:FireClient(player, "Pick a crop")
		return
	end
	if data.Coins < crop.cost then
		Remotes.Toast:FireClient(player, "Need " .. crop.cost .. " coins")
		return
	end
	data.Coins -= crop.cost
	plot.crop = crop.id
	plot.readyAt = os.time() + crop.time
	plot.watered = false
	Remotes.Toast:FireClient(player, "Planted " .. crop.name)
	StateBus.Push(player, true)
end

function GardenPocket.Water(player, index)
	local data = PlayerData.Get(player)
	index = math.floor(tonumber(index) or 0)
	local plot = data and data.Garden[index]
	if not plot or plot.crop == "" or plot.watered then
		Remotes.Toast:FireClient(player, "Nothing to water")
		return
	end
	local left = math.max(0, plot.readyAt - os.time())
	plot.readyAt = os.time() + math.floor(left * 0.7)
	plot.watered = true
	Remotes.Toast:FireClient(player, "Watered — 30% faster")
	StateBus.Push(player, true)
end

function GardenPocket.FinishAll(player)
	local data = PlayerData.Get(player)
	if not data then
		return
	end
	for _, plot in ipairs(data.Garden) do
		if plot.crop ~= "" then
			plot.readyAt = os.time()
		end
	end
	Remotes.Toast:FireClient(player, "Crops ready")
end

function GardenPocket.Build()
	local model = Util.model(Workspace, "GardenPocket")
	Util.part(model, "Floor", Vector3.new(90, 2, 200), CFrame.new(origin()), Color3.fromRGB(28, 40, 28), Enum.Material.Grass, true)
	for s = 1, Config.Garden.Slots do
		local o = slotOrigin(s)
		soils[s] = {}
		local sign = Util.part(model, "Sign" .. s, Vector3.new(4, 4, 1), CFrame.new(o + Vector3.new(-18, 3, 0)), Color3.fromRGB(90, 60, 30), Enum.Material.Wood, true)
		ownerLabels[s] = Util.billboard(sign, "Garden row", Vector3.new(0, 4, 0))
		for p = 1, Config.Garden.Plots do
			local soil = Util.part(model, "Soil", Vector3.new(5, 1, 5), CFrame.new(o + Vector3.new((p - 3.5) * 7, 1, 0)), Color3.fromRGB(96, 64, 40), Enum.Material.Ground, true)
			soils[s][p] = soil
		end
	end
	Util.billboard(model.Floor, "POCKET GARDEN", Vector3.new(0, 8, 0), UDim2.fromOffset(240, 40))
end

function GardenPocket.Init()
	Monetization.SetHandler("GardenFinish", GardenPocket.FinishAll)
	task.spawn(function()
		while true do
			for s = 1, Config.Garden.Slots do
				local owner = Slots.Owner("Garden", s)
				if ownerLabels[s] then
					ownerLabels[s].Text = owner and (owner.DisplayName .. "'s garden") or "Empty row"
				end
				local data = owner and PlayerData.Get(owner)
				for p = 1, Config.Garden.Plots do
					local soil = soils[s][p]
					if soil and data then
						local view = plotState(data.Garden[p])
						if view.crop == "" then
							soil.Color = Color3.fromRGB(96, 64, 40)
						elseif view.ready then
							soil.Color = Color3.fromRGB(255, 210, 70)
						else
							soil.Color = Color3.fromRGB(70, 160, 80)
						end
					elseif soil then
						soil.Color = Color3.fromRGB(96, 64, 40)
					end
				end
			end
			task.wait(1)
		end
	end)
end

Players.PlayerRemoving:Connect(function() end)

return GardenPocket
