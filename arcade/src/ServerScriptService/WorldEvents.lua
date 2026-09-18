local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))

local WorldEvents = {}

local current = nil
local endsAt = 0

local CYCLE = {
	{ id = "GoldRush", text = "GOLD RUSH — all earnings x2", seconds = 40 },
	{ id = "OrbStorm", text = "ORB STORM — magnets go wild", seconds = 40 },
	{ id = "LuckyMinute", text = "LUCKY MINUTE — center bins pull harder", seconds = 35 },
}

function WorldEvents.Current()
	if current and os.clock() < endsAt then
		return current
	end
	return nil
end

function WorldEvents.Multiplier()
	if WorldEvents.Current() == "GoldRush" then
		return 2
	end
	return 1
end

function WorldEvents.TimeLeft()
	if not current then
		return 0
	end
	return math.max(0, endsAt - os.clock())
end

local function applyLight()
	local name = WorldEvents.Current()
	if name == "GoldRush" then
		Lighting.Ambient = Color3.fromRGB(90, 70, 30)
		Lighting.OutdoorAmbient = Color3.fromRGB(90, 70, 30)
		Lighting.ClockTime = 17.2
	elseif name == "OrbStorm" then
		Lighting.Ambient = Color3.fromRGB(20, 40, 90)
		Lighting.OutdoorAmbient = Color3.fromRGB(20, 30, 70)
		Lighting.ClockTime = 0
	elseif name == "LuckyMinute" then
		Lighting.Ambient = Color3.fromRGB(70, 40, 90)
		Lighting.OutdoorAmbient = Color3.fromRGB(50, 30, 70)
		Lighting.ClockTime = 19
	else
		Lighting.Ambient = Color3.fromRGB(40, 48, 70)
		Lighting.OutdoorAmbient = Color3.fromRGB(35, 40, 55)
		Lighting.ClockTime = 20.4
		Lighting.Brightness = 2
	end
end

function WorldEvents.Init()
	Lighting.ClockTime = 20.4
	task.spawn(function()
		local index = 1
		task.wait(20)
		while true do
			local ev = CYCLE[index]
			index = index % #CYCLE + 1
			current = ev.id
			endsAt = os.clock() + ev.seconds
			applyLight()
			for _, p in ipairs(Players:GetPlayers()) do
				Remotes.Toast:FireClient(p, ev.text)
			end
			task.wait(ev.seconds)
			current = nil
			applyLight()
			task.wait(100)
		end
	end)
end

return WorldEvents
