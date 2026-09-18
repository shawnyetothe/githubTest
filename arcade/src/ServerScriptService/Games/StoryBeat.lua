local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))
local PlayerData = require(script.Parent.Parent:WaitForChild("PlayerData"))
local Monetization = require(script.Parent.Parent:WaitForChild("Monetization"))
local StateBus = require(script.Parent.Parent:WaitForChild("StateBus"))
local Util = require(script.Parent.Parent:WaitForChild("Util"))

local StoryBeat = {}
StoryBeat.Id = "StoryBeat"

local NODES = {
	start = {
		text = "The night market is closed, but your hands are full of light. A kid whispers: don't let the guard take it. A lamp swings by the far gate.",
		choices = {
			{ id = "hide", label = "Hide with the kid", next = "stall" },
			{ id = "guard", label = "Walk to the guard", next = "gate" },
		},
	},
	stall = {
		text = "She pulls you under a tarp. That orb grows if you plant it. Or we sell it and eat tonight. Footsteps stop outside.",
		choices = {
			{ id = "plant", label = "Plant it in the cracked pot", next = "keeper" },
			{ id = "sell", label = "Sell it and split the cash", next = "deal" },
			{ id = "run", label = "Burst into the alley", next = "alley" },
		},
	},
	gate = {
		text = "The guard sighs. Third orb this week. Hand it over and I forget your face. Run, and I don't.",
		choices = {
			{ id = "hand", label = "Hand it over", next = "order" },
			{ id = "run", label = "Run the alley", next = "alley" },
		},
	},
	alley = {
		text = "The alley splits. One way smells like rain and soil. The other smells like coins.",
		choices = {
			{ id = "soil", label = "Follow the soil", next = "keeper" },
			{ id = "coins", label = "Follow the coins", next = "deal" },
		},
	},
	keeper = {
		ending = true,
		title = "LanternKeeper",
		text = "You plant the orb. By morning the stall is a garden. The kid laughs. The market opens late, and bright.",
	},
	deal = {
		ending = true,
		title = "DealMaker",
		text = "You split the light into money. It spends. It doesn't grow back. The kid still waves the next night.",
	},
	order = {
		ending = true,
		title = "QuietGate",
		text = "The guard pockets the orb and nods. You leave with empty hands and a safe name. Somewhere a garden does not start.",
	},
}

local function origin()
	return Config.Layout.StoryBeat
end

local function viewNode(id)
	local node = NODES[id] or NODES.start
	local choices = {}
	if node.choices then
		for _, c in ipairs(node.choices) do
			table.insert(choices, { id = c.id, label = c.label })
		end
	end
	return {
		id = id,
		text = node.text,
		choices = choices,
		ending = node.ending == true,
		title = node.title,
	}
end

function StoryBeat.SpawnCFrame()
	return CFrame.new(origin() + Vector3.new(0, 5, 8))
end

function StoryBeat.Snapshot(player)
	local data = PlayerData.Get(player)
	if not data then
		return nil
	end
	local node = viewNode(data.StoryNode or "start")
	node.seen = data.Endings or {}
	node.subtitle = node.ending and ("Ending: " .. (node.title or "")) or "Night Market"
	return node
end

function StoryBeat.Choose(player, choiceId)
	local data = PlayerData.Get(player)
	if not data or typeof(choiceId) ~= "string" then
		return
	end
	local node = NODES[data.StoryNode or "start"] or NODES.start
	if not node.choices then
		return
	end
	local nextId = nil
	for _, c in ipairs(node.choices) do
		if c.id == choiceId then
			nextId = c.next
			break
		end
	end
	if not nextId or not NODES[nextId] then
		return
	end
	data.StoryNode = nextId
	local landed = NODES[nextId]
	if landed.ending then
		local title = landed.title
		if data.Endings[title] then
			Remotes.Toast:FireClient(player, "You already lived this ending")
		else
			data.Endings[title] = true
			local reward = Config.StoryReward[title] or 150
			reward = math.floor(reward * Monetization.Multiplier(player, "coins"))
			Monetization.GrantCoins(player, reward, title, true)
		end
		PlayerData.Save(player)
	end
	StateBus.Push(player, true)
end

function StoryBeat.Replay(player)
	local data = PlayerData.Get(player)
	if not data then
		return
	end
	data.StoryNode = "start"
	Remotes.Toast:FireClient(player, "The market closes again")
	StateBus.Push(player, true)
end

function StoryBeat.Build()
	local o = origin()
	local model = Util.model(Workspace, "StoryBeat")
	Util.part(model, "Floor", Vector3.new(50, 2, 50), CFrame.new(o), Color3.fromRGB(28, 24, 36), Enum.Material.WoodPlanks, true)
	local stall = Util.part(model, "Stall", Vector3.new(10, 6, 8), CFrame.new(o + Vector3.new(-8, 4, -6)), Color3.fromRGB(120, 70, 50), Enum.Material.Wood, true)
	Util.billboard(stall, "NIGHT MARKET", Vector3.new(0, 6, 0))
	local guard = Util.part(model, "Guard", Vector3.new(3, 6, 3), CFrame.new(o + Vector3.new(10, 4, -8)), Color3.fromRGB(40, 70, 140), Enum.Material.SmoothPlastic, true)
	Util.billboard(guard, "GUARD", Vector3.new(0, 5, 0))
	local kid = Util.part(model, "Kid", Vector3.new(2, 3.5, 2), CFrame.new(o + Vector3.new(-4, 3, 2)), Color3.fromRGB(255, 180, 90), Enum.Material.SmoothPlastic, true)
	Util.billboard(kid, "KID", Vector3.new(0, 4, 0))
end

function StoryBeat.Init() end

return StoryBeat
