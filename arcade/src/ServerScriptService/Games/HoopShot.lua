local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))
local PlayerData = require(script.Parent.Parent:WaitForChild("PlayerData"))
local Monetization = require(script.Parent.Parent:WaitForChild("Monetization"))
local StateBus = require(script.Parent.Parent:WaitForChild("StateBus"))
local Util = require(script.Parent.Parent:WaitForChild("Util"))

local HoopShot = {}
HoopShot.Id = "HoopShot"

local streak = {}
local hoopPos
local spawnCf

local function origin()
	return Config.Layout.HoopShot
end

function HoopShot.SpawnCFrame()
	return spawnCf or CFrame.new(origin() + Vector3.new(0, 5, 24))
end

function HoopShot.Snapshot(player)
	local data = PlayerData.Get(player)
	return {
		streak = streak[player] or 0,
		best = data and data.HoopBest or 0,
		subtitle = string.format("Streak %d   best %d", streak[player] or 0, data and data.HoopBest or 0),
	}
end

function HoopShot.Shoot(player, power)
	if player:GetAttribute("GameId") ~= "HoopShot" then
		return
	end
	power = tonumber(power) or 0.6
	if power ~= power then
		power = 0.6
	end
	power = math.clamp(power, 0.15, 1)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root or not hoopPos then
		return
	end
	local look = root.CFrame.LookVector
	look = Vector3.new(look.X, 0, look.Z)
	if look.Magnitude < 0.2 then
		look = Vector3.new(0, 0, -1)
	end
	look = look.Unit
	local pos = root.Position + Vector3.new(0, 2, 0) + look * 2
	local vel = look * (55 + power * 80) + Vector3.new(0, 36 + power * 55, 0)
	local ball = Util.part(Workspace, "Shot", Vector3.new(2, 2, 2), CFrame.new(pos), Color3.fromRGB(255, 140, 40), Enum.Material.SmoothPlastic, false)
	ball.Shape = Enum.PartType.Ball
	local scored = false
	local g = Vector3.new(0, -workspace.Gravity, 0)
	task.spawn(function()
		local p = pos
		local v = vel
		for _ = 1, 50 do
			local dt = 0.05
			v += g * dt
			local nextP = p + v * dt
			if not scored and v.Y < 0 then
				local mid = (p + nextP) * 0.5
				if (Vector3.new(mid.X, hoopPos.Y, mid.Z) - hoopPos).Magnitude < 2.2 and math.abs(mid.Y - hoopPos.Y) < 2.5 then
					scored = true
				end
			end
			p = nextP
			if ball.Parent then
				ball.Position = p
			end
			if p.Y < origin().Y then
				break
			end
			task.wait(dt)
		end
		if ball.Parent then
			ball:Destroy()
		end
		local data = PlayerData.Get(player)
		if scored then
			streak[player] = (streak[player] or 0) + 1
			if data and streak[player] > data.HoopBest then
				data.HoopBest = streak[player]
			end
			local reward = math.floor(Config.Hoop.Reward * streak[player] * Monetization.Multiplier(player, "coins"))
			Monetization.GrantCoins(player, reward, "bucket x" .. streak[player], true)
		else
			streak[player] = 0
			Remotes.Toast:FireClient(player, "Brick")
			StateBus.Push(player, true)
		end
	end)
end

function HoopShot.Build()
	local o = origin()
	local model = Util.model(Workspace, "HoopShot")
	Util.part(model, "Court", Vector3.new(40, 2, 56), CFrame.new(o + Vector3.new(0, 0, 6)), Color3.fromRGB(180, 90, 40), Enum.Material.WoodPlanks, true)
	hoopPos = o + Vector3.new(0, 12, -8)
	spawnCf = CFrame.lookAt(o + Vector3.new(0, 4, 22), hoopPos)
	local pole = Util.part(model, "Pole", Vector3.new(1, 14, 1), CFrame.new(o + Vector3.new(0, 8, -12)), Color3.fromRGB(40, 40, 48), Enum.Material.Metal, true)
	Util.part(model, "Board", Vector3.new(8, 5, 0.5), CFrame.new(o + Vector3.new(0, 13, -11)), Color3.fromRGB(240, 240, 245), Enum.Material.SmoothPlastic, true)
	local rim = Util.part(model, "Rim", Vector3.new(0.4, 3.2, 3.2), CFrame.new(hoopPos) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(255, 80, 40), Enum.Material.Neon, false)
	rim.Shape = Enum.PartType.Cylinder
	Util.billboard(pole, "HOOP RUSH\nHold shoot, release", Vector3.new(0, 10, 0), UDim2.fromOffset(200, 60))
end

function HoopShot.Init() end

game:GetService("Players").PlayerRemoving:Connect(function(player)
	streak[player] = nil
end)

return HoopShot
