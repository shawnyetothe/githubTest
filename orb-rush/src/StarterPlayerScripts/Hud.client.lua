local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local function corner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 10)
	c.Parent = parent
	return c
end

local function mkButton(parent, name, text, color)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Size = UDim2.new(1, -16, 0, 34)
	btn.BackgroundColor3 = color or Color3.fromRGB(45, 110, 220)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Text = text
	btn.AutoButtonColor = true
	btn.Parent = parent
	corner(btn, 8)
	return btn
end

local gui = Instance.new("ScreenGui")
gui.Name = "OrbRushHud"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local top = Instance.new("Frame")
top.Name = "TopBar"
top.Size = UDim2.new(1, 0, 0, 64)
top.BackgroundColor3 = Color3.fromRGB(12, 16, 28)
top.BackgroundTransparency = 0.25
top.BorderSizePixel = 0
top.Parent = gui

local cashLabel = Instance.new("TextLabel")
cashLabel.Name = "Cash"
cashLabel.Size = UDim2.new(0.5, -20, 0.6, 0)
cashLabel.Position = UDim2.new(0, 16, 0, 8)
cashLabel.BackgroundTransparency = 1
cashLabel.Font = Enum.Font.GothamBlack
cashLabel.TextSize = 28
cashLabel.TextXAlignment = Enum.TextXAlignment.Left
cashLabel.TextColor3 = Color3.fromRGB(120, 255, 170)
cashLabel.Text = "$0"
cashLabel.Parent = top

local multLabel = Instance.new("TextLabel")
multLabel.Name = "Mult"
multLabel.Size = UDim2.new(0.5, -20, 0.35, 0)
multLabel.Position = UDim2.new(0, 16, 0.58, 0)
multLabel.BackgroundTransparency = 1
multLabel.Font = Enum.Font.GothamMedium
multLabel.TextSize = 14
multLabel.TextXAlignment = Enum.TextXAlignment.Left
multLabel.TextColor3 = Color3.fromRGB(200, 210, 230)
multLabel.Text = "x1.00"
multLabel.Parent = top

local brand = Instance.new("TextLabel")
brand.Size = UDim2.new(0.4, 0, 1, 0)
brand.Position = UDim2.new(0.6, 0, 0, 0)
brand.BackgroundTransparency = 1
brand.Font = Enum.Font.GothamBlack
brand.TextSize = 22
brand.TextColor3 = Color3.fromRGB(90, 210, 255)
brand.Text = "ORB RUSH"
brand.Parent = top

local toastLabel = Instance.new("TextLabel")
toastLabel.Name = "Toast"
toastLabel.Size = UDim2.new(0.7, 0, 0, 36)
toastLabel.Position = UDim2.new(0.15, 0, 0, 76)
toastLabel.BackgroundTransparency = 1
toastLabel.Font = Enum.Font.GothamBold
toastLabel.TextSize = 18
toastLabel.TextColor3 = Color3.new(1, 1, 1)
toastLabel.TextStrokeTransparency = 0.5
toastLabel.Text = ""
toastLabel.Parent = gui

local popFolder = Instance.new("Folder")
popFolder.Name = "Pops"
popFolder.Parent = gui

local toggleBtn = mkButton(gui, "ToggleShop", "Hide Shop", Color3.fromRGB(40, 48, 68))
toggleBtn.Size = UDim2.fromOffset(120, 36)
toggleBtn.Position = UDim2.new(1, -136, 0, 76)

local shop = Instance.new("Frame")
shop.Name = "Shop"
shop.Size = UDim2.fromOffset(280, 460)
shop.Position = UDim2.new(1, -296, 0, 120)
shop.BackgroundColor3 = Color3.fromRGB(18, 22, 34)
shop.BackgroundTransparency = 0.08
shop.BorderSizePixel = 0
shop.Parent = gui
corner(shop, 14)

local shopTitle = Instance.new("TextLabel")
shopTitle.Size = UDim2.new(1, -16, 0, 28)
shopTitle.Position = UDim2.fromOffset(8, 8)
shopTitle.BackgroundTransparency = 1
shopTitle.Font = Enum.Font.GothamBlack
shopTitle.TextSize = 18
shopTitle.TextColor3 = Color3.new(1, 1, 1)
shopTitle.TextXAlignment = Enum.TextXAlignment.Left
shopTitle.Text = "Upgrades & Shop"
shopTitle.Parent = shop

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 6)
list.SortOrder = Enum.SortOrder.LayoutOrder
list.Parent = shop

local pad = Instance.new("UIPadding")
pad.PaddingTop = UDim.new(0, 40)
pad.PaddingLeft = UDim.new(0, 8)
pad.PaddingRight = UDim.new(0, 8)
pad.Parent = shop

local upgradesFrame = Instance.new("Frame")
upgradesFrame.Name = "Upgrades"
upgradesFrame.Size = UDim2.new(1, 0, 0, 168)
upgradesFrame.BackgroundTransparency = 1
upgradesFrame.LayoutOrder = 1
upgradesFrame.Parent = shop

local upList = Instance.new("UIListLayout")
upList.Padding = UDim.new(0, 4)
upList.Parent = upgradesFrame

local rebirthBtn = mkButton(shop, "Rebirth", "Rebirth", Color3.fromRGB(180, 70, 200))
rebirthBtn.LayoutOrder = 2

local dailyBtn = mkButton(shop, "Daily", "Claim Daily Bonus", Color3.fromRGB(50, 150, 90))
dailyBtn.LayoutOrder = 3

local passDouble = mkButton(shop, "PassDouble", "Buy 2× Cash Pass", Color3.fromRGB(220, 160, 40))
passDouble.LayoutOrder = 4

local passVip = mkButton(shop, "PassVip", "Buy VIP Magnet", Color3.fromRGB(70, 130, 230))
passVip.LayoutOrder = 5

local buySmall = mkButton(shop, "BuySmall", "Cash Pack S (500)", Color3.fromRGB(55, 65, 90))
buySmall.LayoutOrder = 6
local buyMed = mkButton(shop, "BuyMed", "Cash Pack M (3K)", Color3.fromRGB(55, 65, 90))
buyMed.LayoutOrder = 7
local buyLarge = mkButton(shop, "BuyLarge", "Cash Pack L (20K)", Color3.fromRGB(55, 65, 90))
buyLarge.LayoutOrder = 8

local shopOpen = true
local lastState

local UPGRADE_ORDER = { "MagnetRange", "MagnetPull", "OrbValue", "WalkSpeed" }
local UPGRADE_LABELS = {
	MagnetRange = "Range",
	MagnetPull = "Pull",
	OrbValue = "Value",
	WalkSpeed = "Speed",
}

local function formatCash(n)
	n = math.floor(n or 0)
	if n >= 1e9 then
		return string.format("$%.2fB", n / 1e9)
	elseif n >= 1e6 then
		return string.format("$%.2fM", n / 1e6)
	elseif n >= 1e3 then
		return string.format("$%.1fK", n / 1e3)
	end
	return "$" .. tostring(n)
end

local function showToast(text)
	toastLabel.Text = text
	toastLabel.TextTransparency = 0
	task.delay(2.4, function()
		if toastLabel.Text == text then
			TweenService:Create(toastLabel, TweenInfo.new(0.4), { TextTransparency = 1 }):Play()
		end
	end)
end

local function cashPop(amount)
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromOffset(120, 36)
	label.Position = UDim2.new(0.5, math.random(-40, 40), 0.55, math.random(-20, 20))
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 22
	label.TextColor3 = Color3.fromRGB(120, 255, 160)
	label.TextStrokeTransparency = 0.4
	label.Text = "+" .. tostring(amount)
	label.Parent = popFolder
	local tw = TweenService:Create(label, TweenInfo.new(0.8), {
		Position = label.Position - UDim2.fromOffset(0, 60),
		TextTransparency = 1,
		TextStrokeTransparency = 1,
	})
	tw:Play()
	tw.Completed:Connect(function()
		label:Destroy()
	end)
end

local function refreshUpgrades(state)
	for _, child in ipairs(upgradesFrame:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
	for _, name in ipairs(UPGRADE_ORDER) do
		local info = state.upgrades[name]
		if info then
			local btn = Instance.new("TextButton")
			btn.Name = name
			btn.Size = UDim2.new(1, 0, 0, 36)
			btn.BackgroundColor3 = Color3.fromRGB(36, 44, 62)
			btn.Font = Enum.Font.GothamMedium
			btn.TextSize = 14
			btn.TextColor3 = Color3.new(1, 1, 1)
			btn.TextXAlignment = Enum.TextXAlignment.Left
			local maxed = info.level >= info.max
			btn.Text = string.format(
				"  %s  Lv %d/%d   %s",
				UPGRADE_LABELS[name],
				info.level,
				info.max,
				maxed and "MAX" or formatCash(info.cost)
			)
			btn.Parent = upgradesFrame
			corner(btn, 8)
			btn.MouseButton1Click:Connect(function()
				Remotes.BuyUpgrade:FireServer(name)
			end)
		end
	end
end

local function applyState(state)
	lastState = state
	cashLabel.Text = formatCash(state.cash)
	multLabel.Text = string.format("x%.2f | R%d | streak %d", state.multiplier, state.rebirths, state.dailyStreak)
	rebirthBtn.Text = string.format("Rebirth (%s)", formatCash(state.rebirthCost))
	dailyBtn.Text = state.canClaimDaily and "Claim Daily Bonus" or "Daily Claimed"
	passDouble.Text = state.passes.DoubleCash and "2x Cash owned" or "Buy 2x Cash Pass"
	passVip.Text = state.passes.VipMagnet and "VIP Magnet owned" or "Buy VIP Magnet"
	refreshUpgrades(state)
end

Remotes.StateUpdate.OnClientEvent:Connect(applyState)
Remotes.Toast.OnClientEvent:Connect(showToast)
Remotes.CashPop.OnClientEvent:Connect(cashPop)

toggleBtn.MouseButton1Click:Connect(function()
	shopOpen = not shopOpen
	shop.Visible = shopOpen
	toggleBtn.Text = shopOpen and "Hide Shop" or "Shop"
end)

rebirthBtn.MouseButton1Click:Connect(function()
	Remotes.RequestRebirth:FireServer()
end)
dailyBtn.MouseButton1Click:Connect(function()
	Remotes.ClaimDaily:FireServer()
end)
passDouble.MouseButton1Click:Connect(function()
	if lastState and lastState.passes.DoubleCash then
		return
	end
	Remotes.PromptGamePass:FireServer("DoubleCash")
end)
passVip.MouseButton1Click:Connect(function()
	if lastState and lastState.passes.VipMagnet then
		return
	end
	Remotes.PromptGamePass:FireServer("VipMagnet")
end)
buySmall.MouseButton1Click:Connect(function()
	Remotes.PromptProduct:FireServer("CashSmall")
end)
buyMed.MouseButton1Click:Connect(function()
	Remotes.PromptProduct:FireServer("CashMed")
end)
buyLarge.MouseButton1Click:Connect(function()
	Remotes.PromptProduct:FireServer("CashLarge")
end)

-- Soft shop nudge modal (after first rebirth)
local nudge = Instance.new("Frame")
nudge.Name = "ShopNudge"
nudge.Visible = false
nudge.Size = UDim2.fromOffset(320, 180)
nudge.Position = UDim2.fromScale(0.5, 0.5)
nudge.AnchorPoint = Vector2.new(0.5, 0.5)
nudge.BackgroundColor3 = Color3.fromRGB(16, 20, 32)
nudge.Parent = gui
corner(nudge, 14)

local nudgeTitle = Instance.new("TextLabel")
nudgeTitle.Size = UDim2.new(1, -24, 0, 36)
nudgeTitle.Position = UDim2.fromOffset(12, 12)
nudgeTitle.BackgroundTransparency = 1
nudgeTitle.Font = Enum.Font.GothamBlack
nudgeTitle.TextSize = 20
nudgeTitle.TextColor3 = Color3.new(1, 1, 1)
nudgeTitle.TextXAlignment = Enum.TextXAlignment.Left
nudgeTitle.Text = "Double your grind?"
nudgeTitle.Parent = nudge

local nudgeBody = Instance.new("TextLabel")
nudgeBody.Size = UDim2.new(1, -24, 0, 48)
nudgeBody.Position = UDim2.fromOffset(12, 52)
nudgeBody.BackgroundTransparency = 1
nudgeBody.Font = Enum.Font.Gotham
nudgeBody.TextSize = 15
nudgeBody.TextColor3 = Color3.fromRGB(200, 210, 230)
nudgeBody.TextXAlignment = Enum.TextXAlignment.Left
nudgeBody.TextWrapped = true
nudgeBody.Text = "You just rebirthed. 2x Cash permanently doubles every orb — best first purchase."
nudgeBody.Parent = nudge

local nudgeBuy = mkButton(nudge, "NudgeBuy", "Get 2x Cash", Color3.fromRGB(220, 160, 40))
nudgeBuy.Position = UDim2.fromOffset(12, 118)
nudgeBuy.Size = UDim2.new(0.55, -16, 0, 40)

local nudgeSkip = mkButton(nudge, "NudgeSkip", "Maybe later", Color3.fromRGB(50, 56, 72))
nudgeSkip.Position = UDim2.fromOffset(12 + nudgeBuy.AbsoluteSize.X, 118)
nudgeSkip.Size = UDim2.new(0.45, -8, 0, 40)
nudgeSkip.Position = UDim2.new(0.55, 0, 0, 118)

local function hideNudge()
	nudge.Visible = false
	Remotes.DismissNudge:FireServer()
end

nudgeBuy.MouseButton1Click:Connect(function()
	nudge.Visible = false
	Remotes.PromptGamePass:FireServer("DoubleCash")
	Remotes.DismissNudge:FireServer()
end)
nudgeSkip.MouseButton1Click:Connect(hideNudge)

Remotes.ShowShopNudge.OnClientEvent:Connect(function()
	nudge.Visible = true
	shop.Visible = true
	shopOpen = true
	toggleBtn.Text = "Hide Shop"
end)

showToast("Welcome to Orb Rush — collect orbs!")
