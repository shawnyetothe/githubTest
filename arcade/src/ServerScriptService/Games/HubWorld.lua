local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Util = require(script.Parent.Parent:WaitForChild("Util"))

local HubWorld = {}
HubWorld.Id = "Hub"

local countLabels = {}

function HubWorld.SpawnCFrame()
	return CFrame.new(Config.Layout.Hub + Vector3.new(0, 5, 0))
end

function HubWorld.Build()
	local origin = Config.Layout.Hub
	local model = Util.model(Workspace, "Hub")
	Util.part(model, "Floor", Vector3.new(220, 2, 220), CFrame.new(origin + Vector3.new(0, 0, 0)), Color3.fromRGB(22, 26, 38), Enum.Material.SmoothPlastic, true)

	local monument = Util.part(model, "Monument", Vector3.new(10, 18, 10), CFrame.new(origin + Vector3.new(0, 10, 0)), Color3.fromRGB(80, 200, 255), Enum.Material.Neon, true)
	Util.billboard(monument, "RUSH PLAZA\n10 games  •  +15% with a friend", Vector3.new(0, 12, 0), UDim2.fromOffset(280, 80))

	local n = #Config.Catalog
	for i, info in ipairs(Config.Catalog) do
		local angle = ((i - 1) / n) * math.pi * 2
		local pos = origin + Vector3.new(math.cos(angle) * 78, 2, math.sin(angle) * 78)
		local pad = Util.part(model, "Portal_" .. info.id, Vector3.new(10, 1, 10), CFrame.new(pos), info.color, Enum.Material.Neon, true)
		local label = Util.billboard(pad, info.name .. "\n" .. info.blurb, Vector3.new(0, 5, 0), UDim2.fromOffset(200, 70))
		countLabels[info.id] = label
		local prompt = Util.prompt(pad, "Play", info.name)
		prompt:SetAttribute("Dest", info.id)
		CollectionService:AddTag(prompt, "RushPortal")
	end

	local board = Util.part(model, "EventBoard", Vector3.new(14, 8, 1), CFrame.new(origin + Vector3.new(0, 6, -28)), Color3.fromRGB(16, 18, 28), Enum.Material.SmoothPlastic, false)
	local sg = Instance.new("SurfaceGui")
	sg.Face = Enum.NormalId.Front
	sg.CanvasSize = Vector2.new(400, 240)
	sg.Parent = board
	local title = Instance.new("TextLabel")
	title.Name = "EventText"
	title.Size = UDim2.fromScale(1, 1)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBlack
	title.TextSize = 28
	title.TextWrapped = true
	title.TextColor3 = Color3.fromRGB(255, 220, 120)
	title.Text = "Events cycle every few minutes.\nGold Rush  •  Orb Storm  •  Lucky Minute"
	title.Parent = sg
	HubWorld.EventLabel = title
end

function HubWorld.SetCount(id, n, name)
	local label = countLabels[id]
	if label then
		label.Text = string.format("%s\n%d playing", name, n)
	end
end

function HubWorld.Init() end

return HubWorld
