local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"))
local PlayerData = require(script.Parent:WaitForChild("PlayerData"))

local Leaderboard = {}

local cashStore = DataStoreService:GetOrderedDataStore(Config.DataStoreName .. "_Cash")
local rebirthStore = DataStoreService:GetOrderedDataStore(Config.DataStoreName .. "_Rebirths")

local function ensureBoard(name, titleText, position)
	local existing = Workspace:FindFirstChild(name)
	if existing then
		return existing
	end

	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.CanCollide = false
	part.Size = Vector3.new(8, 10, 0.4)
	part.Position = position
	part.Color = Color3.fromRGB(20, 24, 36)
	part.Material = Enum.Material.SmoothPlastic
	part.Parent = Workspace

	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.CanvasSize = Vector2.new(400, 500)
	gui.Parent = part

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0, 48)
	title.BackgroundColor3 = Color3.fromRGB(40, 90, 180)
	title.BorderSizePixel = 0
	title.Font = Enum.Font.GothamBlack
	title.TextSize = 28
	title.TextColor3 = Color3.new(1, 1, 1)
	title.Text = titleText
	title.Parent = gui

	local list = Instance.new("TextLabel")
	list.Name = "List"
	list.Size = UDim2.new(1, -16, 1, -56)
	list.Position = UDim2.fromOffset(8, 52)
	list.BackgroundTransparency = 1
	list.Font = Enum.Font.GothamMedium
	list.TextSize = 20
	list.TextXAlignment = Enum.TextXAlignment.Left
	list.TextYAlignment = Enum.TextYAlignment.Top
	list.TextColor3 = Color3.fromRGB(220, 230, 255)
	list.Text = "Loading..."
	list.Parent = gui

	return part
end

local function formatLines(pages)
	local lines = {}
	for i, entry in ipairs(pages) do
		if i > 10 then
			break
		end
		local name = "Player"
		local userId = tonumber(entry.key) or 0
		local ok, result = pcall(function()
			return Players:GetNameFromUserIdAsync(userId)
		end)
		if ok and result then
			name = result
		end
		table.insert(lines, string.format("%d. %s — %s", i, name, tostring(entry.value)))
	end
	if #lines == 0 then
		return "No scores yet — be first!"
	end
	return table.concat(lines, "\n")
end

local function refreshBoard(part, store)
	local gui = part:FindFirstChildWhichIsA("SurfaceGui")
	if not gui then
		return
	end
	local list = gui:FindFirstChild("List")
	if not list then
		return
	end
	local ok, page = pcall(function()
		return store:GetSortedAsync(false, 10):GetCurrentPage()
	end)
	if ok and page then
		list.Text = formatLines(page)
	else
		list.Text = "Leaderboard unavailable\n(Enable API Services)"
	end
end

function Leaderboard.Submit(player)
	local data = PlayerData.Get(player)
	if not data then
		return
	end
	local uid = tostring(player.UserId)
	pcall(function()
		cashStore:SetAsync(uid, math.floor(math.max(0, data.Cash)))
	end)
	pcall(function()
		rebirthStore:SetAsync(uid, math.floor(math.max(0, data.Rebirths)))
	end)
end

function Leaderboard.Init()
	local cashBoard = ensureBoard("CashBoard", "TOP CASH", Vector3.new(-18, 6, -30))
	local rebirthBoard = ensureBoard("RebirthBoard", "TOP REBIRTHS", Vector3.new(18, 6, -30))

	task.spawn(function()
		while true do
			refreshBoard(cashBoard, cashStore)
			refreshBoard(rebirthBoard, rebirthStore)
			task.wait(30)
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		Leaderboard.Submit(player)
	end)
end

return Leaderboard
