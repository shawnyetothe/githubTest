local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local function corner(parent, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 8)
	c.Parent = parent
	return c
end

local function label(parent, name, text, size, pos, fontSize)
	local l = Instance.new("TextLabel")
	l.Name = name
	l.BackgroundTransparency = 1
	l.Size = size
	l.Position = pos
	l.Font = Enum.Font.GothamBold
	l.TextSize = fontSize or 16
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextColor3 = Color3.new(1, 1, 1)
	l.Text = text or ""
	l.Parent = parent
	return l
end

local function button(parent, name, text, color)
	local b = Instance.new("TextButton")
	b.Name = name
	b.Size = UDim2.new(1, -8, 0, 32)
	b.BackgroundColor3 = color or Color3.fromRGB(45, 90, 180)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 14
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Text = text
	b.AutoButtonColor = true
	b.Parent = parent
	corner(b, 8)
	return b
end

local function act(name, a, b)
	Remotes.Action:FireServer(name, a, b)
end

local gui = Instance.new("ScreenGui")
gui.Name = "RushPlaza"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 62)
top.BackgroundColor3 = Color3.fromRGB(10, 12, 20)
top.BackgroundTransparency = 0.15
top.BorderSizePixel = 0
top.Parent = gui

local coinsLabel = label(top, "Coins", "$0", UDim2.new(0.4, 0, 0, 30), UDim2.fromOffset(16, 6), 26)
coinsLabel.Font = Enum.Font.GothamBlack
coinsLabel.TextColor3 = Color3.fromRGB(130, 255, 170)

local subLabel = label(top, "Sub", "Rush Plaza", UDim2.new(0.7, 0, 0, 20), UDim2.fromOffset(16, 36), 14)
subLabel.TextColor3 = Color3.fromRGB(190, 200, 220)
subLabel.Font = Enum.Font.Gotham

local eventLabel = label(top, "Event", "", UDim2.new(0.4, -16, 1, 0), UDim2.new(0.6, 0, 0, 0), 16)
eventLabel.TextXAlignment = Enum.TextXAlignment.Right
eventLabel.TextColor3 = Color3.fromRGB(255, 210, 90)

local list = Instance.new("ScrollingFrame")
list.Name = "Games"
list.Size = UDim2.new(0, 200, 1, -78)
list.Position = UDim2.fromOffset(8, 70)
list.BackgroundColor3 = Color3.fromRGB(16, 18, 28)
list.BackgroundTransparency = 0.1
list.BorderSizePixel = 0
list.ScrollBarThickness = 4
list.CanvasSize = UDim2.fromOffset(0, 40 + (#Config.Catalog + 1) * 40)
list.Parent = gui
corner(list, 12)
local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 4)
listLayout.Parent = list
local listPad = Instance.new("UIPadding")
listPad.PaddingTop = UDim.new(0, 6)
listPad.PaddingLeft = UDim.new(0, 6)
listPad.PaddingRight = UDim.new(0, 6)
listPad.Parent = list

local plazaBtn = button(list, "Hub", "Rush Plaza", Color3.fromRGB(40, 48, 70))
plazaBtn.MouseButton1Click:Connect(function()
	act("Teleport", "Hub")
end)

local gameButtons = { Hub = plazaBtn }
for _, info in ipairs(Config.Catalog) do
	local b = button(list, info.id, info.name, info.color:Lerp(Color3.fromRGB(20, 20, 28), 0.45))
	b.MouseButton1Click:Connect(function()
		act("Teleport", info.id)
	end)
	gameButtons[info.id] = b
end

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.fromOffset(300, 520)
panel.Position = UDim2.new(1, -312, 0, 70)
panel.BackgroundColor3 = Color3.fromRGB(16, 18, 28)
panel.BackgroundTransparency = 0.06
panel.BorderSizePixel = 0
panel.Parent = gui
corner(panel, 12)

local panelTitle = label(panel, "Title", "Plaza", UDim2.new(1, -16, 0, 28), UDim2.fromOffset(10, 8), 18)
panelTitle.Font = Enum.Font.GothamBlack

local body = Instance.new("ScrollingFrame")
body.Name = "Body"
body.Position = UDim2.fromOffset(8, 40)
body.Size = UDim2.new(1, -16, 1, -48)
body.BackgroundTransparency = 1
body.BorderSizePixel = 0
body.ScrollBarThickness = 5
body.CanvasSize = UDim2.fromOffset(0, 0)
body.AutomaticCanvasSize = Enum.AutomaticSize.Y
body.Parent = panel

local toast = label(gui, "Toast", "", UDim2.new(0.6, 0, 0, 32), UDim2.new(0.2, 0, 0, 70), 18)
toast.TextXAlignment = Enum.TextXAlignment.Center
toast.Font = Enum.Font.GothamBlack
toast.TextStrokeTransparency = 0.5

local pops = Instance.new("Folder")
pops.Parent = gui

local story = Instance.new("Frame")
story.Name = "Story"
story.Visible = false
story.Size = UDim2.fromOffset(460, 220)
story.Position = UDim2.new(0.5, -160, 1, -240)
story.BackgroundColor3 = Color3.fromRGB(18, 14, 28)
story.Parent = gui
corner(story, 12)
local storyText = label(story, "Text", "", UDim2.new(1, -20, 0, 110), UDim2.fromOffset(10, 10), 16)
storyText.TextWrapped = true
storyText.TextYAlignment = Enum.TextYAlignment.Top
local storyChoices = Instance.new("Frame")
storyChoices.BackgroundTransparency = 1
storyChoices.Position = UDim2.fromOffset(8, 120)
storyChoices.Size = UDim2.new(1, -16, 0, 90)
storyChoices.Parent = story
local storyLayout = Instance.new("UIListLayout")
storyLayout.Padding = UDim.new(0, 4)
storyLayout.Parent = storyChoices

local nudge = Instance.new("Frame")
nudge.Visible = false
nudge.Size = UDim2.fromOffset(320, 150)
nudge.Position = UDim2.fromScale(0.5, 0.45)
nudge.AnchorPoint = Vector2.new(0.5, 0.5)
nudge.BackgroundColor3 = Color3.fromRGB(14, 16, 26)
nudge.Parent = gui
corner(nudge, 12)
label(nudge, "T", "Double every game?", UDim2.new(1, -16, 0, 28), UDim2.fromOffset(10, 10), 18).Font = Enum.Font.GothamBlack
label(nudge, "B", "You rebirthed. 2x Coins boosts the whole plaza.", UDim2.new(1, -16, 0, 40), UDim2.fromOffset(10, 40), 14).TextWrapped = true
local nudgeBuy = button(nudge, "Buy", "Get 2x Coins", Color3.fromRGB(220, 160, 40))
nudgeBuy.Size = UDim2.new(0.48, 0, 0, 34)
nudgeBuy.Position = UDim2.fromOffset(10, 100)
local nudgeNo = button(nudge, "No", "Later", Color3.fromRGB(50, 54, 70))
nudgeNo.Size = UDim2.new(0.4, 0, 0, 34)
nudgeNo.Position = UDim2.new(0.52, 0, 0, 100)
nudgeBuy.MouseButton1Click:Connect(function()
	nudge.Visible = false
	act("PromptPass", "DoubleCoins")
end)
nudgeNo.MouseButton1Click:Connect(function()
	nudge.Visible = false
end)

local rhythm = Instance.new("Frame")
rhythm.Visible = false
rhythm.Size = UDim2.fromOffset(280, 320)
rhythm.Position = UDim2.new(0.5, -140, 1, -340)
rhythm.BackgroundColor3 = Color3.fromRGB(10, 14, 24)
rhythm.BackgroundTransparency = 0.15
rhythm.Parent = gui
corner(rhythm, 12)
local rhythmLanes = Instance.new("Frame")
rhythmLanes.Size = UDim2.new(1, -10, 1, -50)
rhythmLanes.Position = UDim2.fromOffset(5, 5)
rhythmLanes.BackgroundTransparency = 1
rhythmLanes.ClipsDescendants = true
rhythmLanes.Parent = rhythm
local hitLine = Instance.new("Frame")
hitLine.Size = UDim2.new(1, 0, 0, 2)
hitLine.Position = UDim2.new(0, 0, 0.78, 0)
hitLine.BackgroundColor3 = Color3.new(1, 1, 1)
hitLine.BorderSizePixel = 0
hitLine.Parent = rhythmLanes

local lastState = nil
local selectedCrop = "sprout"
local chart = nil
local noteFrames = {}
local localHits = {}
local builtGame = nil
local refs = {}

local function showToast(text)
	toast.Text = text
	toast.TextTransparency = 0
	task.delay(2.2, function()
		if toast.Text == text then
			TweenService:Create(toast, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
		end
	end)
end

local function cashPop(amount)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Size = UDim2.fromOffset(100, 28)
	l.Position = UDim2.new(0.5, math.random(-30, 30), 0.5, 0)
	l.Font = Enum.Font.GothamBlack
	l.TextSize = 22
	l.TextColor3 = Color3.fromRGB(130, 255, 170)
	l.Text = "+" .. tostring(amount)
	l.Parent = pops
	local tw = TweenService:Create(l, TweenInfo.new(0.7), {
		Position = l.Position - UDim2.fromOffset(0, 50),
		TextTransparency = 1,
	})
	tw:Play()
	tw.Completed:Connect(function()
		l:Destroy()
	end)
end

local function clearBody()
	for _, child in ipairs(body:GetChildren()) do
		child:Destroy()
	end
	refs = {}
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 6)
	layout.Parent = body
end

local function infoLine(name, text)
	local l = label(body, name, text, UDim2.new(1, 0, 0, 22), UDim2.fromOffset(0, 0), 14)
	l.TextWrapped = true
	refs[name] = l
	return l
end

local function buildPanel(state)
	clearBody()
	local id = state.gameId
	builtGame = id
	if id == "Hub" then
		panelTitle.Text = "Rush Plaza"
		infoLine("Hint", "Walk a portal or tap a game. Daily bonus is here.")
		local daily = button(body, "Daily", "Claim daily", Color3.fromRGB(40, 140, 90))
		daily.MouseButton1Click:Connect(function()
			act("ClaimDaily")
		end)
		refs.Daily = daily
		infoLine("Boost", "Two players in the same game: +15% coins.")
	elseif id == "OrbRush" then
		panelTitle.Text = "Orb Rush"
		infoLine("Stats", "")
		local order = { "MagnetRange", "MagnetPull", "OrbValue", "WalkSpeed" }
		local names = { MagnetRange = "Range", MagnetPull = "Pull", OrbValue = "Value", WalkSpeed = "Speed" }
		for _, name in ipairs(order) do
			local b = button(body, name, names[name], Color3.fromRGB(36, 64, 110))
			b.MouseButton1Click:Connect(function()
				act("BuyUpgrade", name)
			end)
			refs[name] = b
		end
		local rebirth = button(body, "Rebirth", "Rebirth", Color3.fromRGB(150, 60, 180))
		rebirth.MouseButton1Click:Connect(function()
			act("Rebirth")
		end)
		refs.Rebirth = rebirth
	elseif id == "LuckyDrop" then
		panelTitle.Text = "Lucky Drop"
		infoLine("Stats", "")
		local drop = button(body, "Drop", "Drop", Color3.fromRGB(120, 70, 200))
		drop.MouseButton1Click:Connect(function()
			act("Drop")
		end)
		local luck = button(body, "Luck", "Upgrade luck", Color3.fromRGB(70, 50, 110))
		luck.MouseButton1Click:Connect(function()
			act("LuckyUpgrade")
		end)
		refs.Luck = luck
	elseif id == "ObbyRace" then
		panelTitle.Text = "60s Run"
		infoLine("Stats", "Jump the pads. Lava sends you back. Beat 60s for bonus coins.")
	elseif id == "TycoonLite" then
		panelTitle.Text = "Button Tycoon"
		infoLine("Stats", "")
		local buy = button(body, "Buy", "Buy next dropper", Color3.fromRGB(180, 120, 30))
		buy.MouseButton1Click:Connect(function()
			act("TycoonBuy")
		end)
		refs.Buy = buy
	elseif id == "GardenPocket" then
		panelTitle.Text = "Pocket Garden"
		infoLine("Stats", "Plant, play something else, come back.")
		for _, crop in ipairs(Config.Garden.Crops) do
			local b = button(body, crop.id, crop.name, Color3.fromRGB(40, 110, 60))
			b.MouseButton1Click:Connect(function()
				selectedCrop = crop.id
			end)
			refs[crop.id] = b
		end
		for i = 1, Config.Garden.Plots do
			local b = button(body, "Plot" .. i, "Plot " .. i, Color3.fromRGB(70, 50, 30))
			b.MouseButton1Click:Connect(function()
				act("GardenPlot", i, selectedCrop)
			end)
			refs["Plot" .. i] = b
		end
		local water = button(body, "Water", "Water oldest growing plot", Color3.fromRGB(40, 90, 160))
		water.MouseButton1Click:Connect(function()
			local g = lastState and lastState.GardenPocket
			if not g then
				return
			end
			for i, plot in ipairs(g.plots) do
				if plot.crop ~= "" and not plot.ready and not plot.watered then
					act("GardenWater", i)
					return
				end
			end
			showToast("Nothing to water")
		end)
	elseif id == "DuoExtract" then
		panelTitle.Text = "Duo Extract"
		infoLine("Stats", "Grab chests, bank on the green pad before the round ends. Red ball hurts.")
		local revive = button(body, "Revive", "Buy revive", Color3.fromRGB(180, 60, 40))
		revive.MouseButton1Click:Connect(function()
			act("PromptProduct", "ExtractRevive")
		end)
	elseif id == "StoryBeat" then
		panelTitle.Text = "Night Market"
		infoLine("Stats", "Choices are on the card. Three endings, paid once each.")
		local replay = button(body, "Replay", "Replay story", Color3.fromRGB(90, 70, 140))
		replay.MouseButton1Click:Connect(function()
			act("StoryReplay")
		end)
	elseif id == "RhythmTap" then
		panelTitle.Text = "Beat Wire"
		infoLine("Stats", "")
		local start = button(body, "Start", "Start song", Color3.fromRGB(40, 110, 200))
		start.MouseButton1Click:Connect(function()
			act("RhythmStart")
		end)
	elseif id == "HoopShot" then
		panelTitle.Text = "Hoop Rush"
		infoLine("Stats", "Face the rim. Hold Shoot, release.")
		local shoot = button(body, "Shoot", "Shoot", Color3.fromRGB(200, 100, 30))
		refs.Shoot = shoot
		local holding = false
		local holdAt = 0
		shoot.MouseButton1Down:Connect(function()
			holding = true
			holdAt = os.clock()
		end)
		shoot.MouseButton1Up:Connect(function()
			if not holding then
				return
			end
			holding = false
			local power = math.clamp((os.clock() - holdAt) / 1.1, 0.2, 1)
			act("Shoot", power)
		end)
	elseif id == "StallRush" then
		panelTitle.Text = "Stall Rush"
		infoLine("Stats", "")
		for _, item in ipairs({ "orb", "seed", "hoop", "star" }) do
			local b = button(body, item, item, Color3.fromRGB(120, 50, 80))
			b.MouseButton1Click:Connect(function()
				act("Serve", item)
			end)
			refs[item] = b
		end
	end

	infoLine("ShopHeader", "— Shop —")
	local pass2 = button(body, "Pass2", "2x Coins pass", Color3.fromRGB(200, 150, 40))
	pass2.MouseButton1Click:Connect(function()
		act("PromptPass", "DoubleCoins")
	end)
	refs.Pass2 = pass2
	local vip = button(body, "Vip", "VIP Magnet", Color3.fromRGB(40, 120, 200))
	vip.MouseButton1Click:Connect(function()
		act("PromptPass", "VipMagnet")
	end)
	refs.Vip = vip
	local t2 = button(body, "T2", "2x Tycoon pass", Color3.fromRGB(180, 120, 40))
	t2.MouseButton1Click:Connect(function()
		act("PromptPass", "TycoonDouble")
	end)
	local packs = { { "CoinsSmall", "Coin pack S" }, { "CoinsMed", "Coin pack M" }, { "CoinsLarge", "Coin pack L" }, { "GardenFinish", "Ripen garden" } }
	for _, pack in ipairs(packs) do
		local b = button(body, pack[1], pack[2], Color3.fromRGB(48, 52, 68))
		b.MouseButton1Click:Connect(function()
			act("PromptProduct", pack[1])
		end)
	end
end

local function refresh(state)
	lastState = state
	coinsLabel.Text = tostring(math.floor(state.coins or 0)) .. " coins"
	if state.friendBoost then
		coinsLabel.Text ..= "  +15%"
	end
	subLabel.Text = state.subtitle or ""
	if state.event then
		eventLabel.Text = state.event .. "  " .. tostring(state.eventLeft) .. "s"
	else
		eventLabel.Text = ""
	end
	for id, b in pairs(gameButtons) do
		if id == "Hub" then
			b.Text = state.gameId == "Hub" and "Rush Plaza  •" or "Rush Plaza"
		else
			local n = state.counts and state.counts[id] or 0
			local info = Config.Info(id)
			b.Text = (info and info.name or id) .. (n > 0 and ("  " .. n) or "") .. (state.gameId == id and "  •" or "")
		end
	end
	if builtGame ~= state.gameId then
		buildPanel(state)
	end
	story.Visible = state.gameId == "StoryBeat"
	if state.gameId == "OrbRush" and state.OrbRush and refs.MagnetRange then
		local o = state.OrbRush
		if refs.Stats then
			refs.Stats.Text = string.format("x%.2f   rebirth %d   combo %d", o.mult or 1, o.rebirths or 0, o.combo or 0)
		end
		for name, info in pairs(o.upgrades or {}) do
			if refs[name] then
				refs[name].Text = string.format("%s  %d/%d  $%d", name, info.level, info.max, info.cost)
			end
		end
		if refs.Rebirth then
			refs.Rebirth.Text = "Rebirth (" .. tostring(o.rebirthCost) .. ")"
		end
	elseif state.gameId == "LuckyDrop" and state.LuckyDrop and refs.Luck then
		local l = state.LuckyDrop
		if refs.Stats then
			refs.Stats.Text = "Entry " .. l.entry .. "   luck " .. l.luck
		end
		refs.Luck.Text = l.maxed and "Luck maxed" or ("Luck " .. l.luck .. " (" .. l.luckCost .. ")")
	elseif state.gameId == "TycoonLite" and state.TycoonLite and refs.Buy then
		local t = state.TycoonLite
		if refs.Stats then
			refs.Stats.Text = string.format("$%d   +%d/s", t.cash, t.rate)
		end
		refs.Buy.Text = t.nextCost and ("Buy dropper " .. (t.level + 1) .. " (" .. t.nextCost .. ")") or "Maxed"
	elseif state.gameId == "GardenPocket" and state.GardenPocket then
		local g = state.GardenPocket
		for i, plot in ipairs(g.plots or {}) do
			local b = refs["Plot" .. i]
			if b then
				if plot.crop == "" then
					b.Text = "Plot " .. i .. " empty — plant " .. selectedCrop
				elseif plot.ready then
					b.Text = "Plot " .. i .. " HARVEST"
				else
					b.Text = "Plot " .. i .. " " .. plot.crop .. " " .. plot.left .. "s"
				end
			end
		end
	elseif state.gameId == "StallRush" and state.StallRush and refs.Stats then
		local s = state.StallRush
		refs.Stats.Text = string.format("Want %s   %.1fs   streak %d", s.wantName, s.left or 0, s.streak or 0)
	elseif state.gameId == "RhythmTap" and state.RhythmTap and refs.Stats then
		refs.Stats.Text = "Score " .. tostring(state.RhythmTap.score or 0) .. "   best " .. tostring(state.RhythmTap.best or 0)
	elseif state.gameId == "HoopShot" and state.HoopShot and refs.Stats then
		refs.Stats.Text = "Streak " .. tostring(state.HoopShot.streak or 0) .. "   best " .. tostring(state.HoopShot.best or 0)
	elseif state.gameId == "DuoExtract" and state.DuoExtract and refs.Stats then
		local e = state.DuoExtract
		refs.Stats.Text = string.format("Carry %d   %ds left", e.carry or 0, math.floor(e.timeLeft or 0))
	elseif state.gameId == "ObbyRace" and state.ObbyRace and refs.Stats then
		local o = state.ObbyRace
		refs.Stats.Text = string.format("Stage %d/%d   best %.1fs", o.stage or 0, o.stages or 10, o.best or 0)
	elseif state.gameId == "Hub" and refs.Daily and state.daily then
		refs.Daily.Text = state.daily.canClaim and ("Claim daily (streak " .. state.daily.streak .. ")") or "Daily claimed"
	end

	if state.passes then
		if refs.Pass2 then
			refs.Pass2.Text = state.passes.DoubleCoins and "2x Coins owned" or "2x Coins pass"
		end
		if refs.Vip then
			refs.Vip.Text = state.passes.VipMagnet and "VIP Magnet owned" or "VIP Magnet"
		end
	end

	if state.gameId == "StoryBeat" and state.StoryBeat then
		local s = state.StoryBeat
		storyText.Text = s.text or ""
		for _, child in ipairs(storyChoices:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end
		if s.ending then
			local b = button(storyChoices, "Replay", "Play again", Color3.fromRGB(90, 70, 140))
			b.Size = UDim2.new(1, 0, 0, 32)
			b.MouseButton1Click:Connect(function()
				act("StoryReplay")
			end)
		else
			for _, choice in ipairs(s.choices or {}) do
				local b = button(storyChoices, choice.id, choice.label, Color3.fromRGB(70, 60, 120))
				b.Size = UDim2.new(1, 0, 0, 28)
				b.MouseButton1Click:Connect(function()
					act("StoryChoice", choice.id)
				end)
			end
		end
	end
end

for i = 1, 4 do
	local b = button(rhythm, "Lane" .. i, tostring(i), Color3.fromRGB(30 + i * 25, 70, 150))
	b.Size = UDim2.new(0.22, 0, 0, 32)
	b.Position = UDim2.new((i - 1) * 0.25, 4, 1, -38)
	b.MouseButton1Click:Connect(function()
		if not chart then
			return
		end
		local now = workspace:GetServerTimeNow()
		local best, bestD = nil, nil
		for idx, beat in ipairs(chart.beats) do
			if beat.lane == i and not localHits[idx] then
				local d = math.abs(now - (chart.startTime + beat.t))
				if not bestD or d < bestD then
					best = idx
					bestD = d
				end
			end
		end
		if best and bestD < 0.35 then
			localHits[best] = true
			act("RhythmHit", best)
		end
	end)
end

RunService.RenderStepped:Connect(function()
	if not chart then
		rhythm.Visible = false
		return
	end
	rhythm.Visible = true
	local now = workspace:GetServerTimeNow()
	for idx, beat in ipairs(chart.beats) do
		local frame = noteFrames[idx]
		if frame then
			local remain = (chart.startTime + beat.t) - now
			frame.Position = UDim2.new((beat.lane - 1) * 0.25, 6, 0.78, -remain * 140)
			frame.Visible = not localHits[idx] and remain < 2.2 and remain > -0.3
		end
	end
	if now > chart.startTime + chart.beats[#chart.beats].t + 1.5 then
		chart = nil
	end
end)

Remotes.State.OnClientEvent:Connect(refresh)
Remotes.Toast.OnClientEvent:Connect(showToast)
Remotes.Fx.OnClientEvent:Connect(function(fx)
	if typeof(fx) ~= "table" then
		return
	end
	if fx.kind == "CashPop" then
		cashPop(fx.amount)
	elseif fx.kind == "ShopNudge" then
		nudge.Visible = true
	elseif fx.kind == "RhythmChart" then
		chart = fx
		localHits = {}
		for _, frame in pairs(noteFrames) do
			frame:Destroy()
		end
		noteFrames = {}
		for idx, beat in ipairs(fx.beats or {}) do
			local n = Instance.new("Frame")
			n.Size = UDim2.new(0.2, 0, 0, 14)
			n.BackgroundColor3 = Color3.fromRGB(120, 220, 255)
			n.BorderSizePixel = 0
			n.Parent = rhythmLanes
			corner(n, 4)
			noteFrames[idx] = n
			local _ = beat
		end
	elseif fx.kind == "RhythmEnd" then
		chart = nil
		showToast("Song over")
	end
end)

showToast("Rush Plaza")
