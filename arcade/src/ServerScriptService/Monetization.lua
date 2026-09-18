local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))
local PlayerData = require(script.Parent:WaitForChild("PlayerData"))
local Presence = require(script.Parent:WaitForChild("Presence"))
local WorldEvents = require(script.Parent:WaitForChild("WorldEvents"))
local StateBus = require(script.Parent:WaitForChild("StateBus"))

local Monetization = {}
local passCache = {}
local handlers = {}

local function productById(productId)
	for key, def in pairs(Config.DeveloperProducts) do
		if def.id ~= 0 and def.id == productId then
			return key, def
		end
	end
	return nil, nil
end

function Monetization.SetHandler(name, fn)
	handlers[name] = fn
end

function Monetization.RefreshPasses(player)
	local owned = { DoubleCoins = false, VipMagnet = false, TycoonDouble = false }
	for name, passId in pairs(Config.GamePasses) do
		if typeof(passId) == "number" and passId > 0 then
			local ok, result = pcall(function()
				return MarketplaceService:UserOwnsGamePassAsync(player.UserId, passId)
			end)
			if ok and result then
				owned[name] = true
			end
		end
	end
	passCache[player.UserId] = owned
	return owned
end

function Monetization.GetPasses(player)
	return passCache[player.UserId] or Monetization.RefreshPasses(player)
end

function Monetization.Owns(player, key)
	local passes = Monetization.GetPasses(player)
	return passes[key] == true
end

function Monetization.Multiplier(player, kind)
	local m = 1
	if Monetization.Owns(player, "DoubleCoins") then
		m *= 2
	end
	m *= WorldEvents.Multiplier()
	if Presence.Boost(player) then
		m *= (1 + Config.FriendBoost)
	end
	if kind == "tycoon" and Monetization.Owns(player, "TycoonDouble") then
		m *= 2
	end
	if kind == "orb" then
		local data = PlayerData.Get(player)
		if data then
			m *= PlayerData.OrbMult(data)
		end
	end
	return m
end

function Monetization.GrantCoins(player, amount, reason, toastIt)
	local data = PlayerData.Get(player)
	if not data then
		return 0
	end
	amount = math.floor(amount)
	if amount == 0 then
		return 0
	end
	data.Coins += amount
	if toastIt and amount > 0 then
		Remotes.Toast:FireClient(player, string.format("+%d coins%s", amount, reason and (" (" .. reason .. ")") or ""))
	end
	if amount >= 25 then
		Remotes.Fx:FireClient(player, { kind = "CashPop", amount = amount })
	end
	StateBus.Push(player, false)
	return amount
end

function Monetization.PromptPass(player, key)
	local id = Config.GamePasses[key]
	if typeof(id) ~= "number" or id == 0 then
		Remotes.Toast:FireClient(player, "Set Game Pass IDs in Config")
		return
	end
	MarketplaceService:PromptGamePassPurchase(player, id)
end

function Monetization.PromptProduct(player, key)
	local def = Config.DeveloperProducts[key]
	if not def or def.id == 0 then
		Remotes.Toast:FireClient(player, "Set Developer Product IDs in Config")
		return
	end
	MarketplaceService:PromptProductPurchase(player, def.id)
end

local function processReceipt(receiptInfo)
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	local data = PlayerData.Get(player)
	if not data then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	local purchaseId = tostring(receiptInfo.PurchaseId)
	if data.ProcessedReceipts[purchaseId] then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
	local _, def = productById(receiptInfo.ProductId)
	if not def then
		warn("[RushPlaza] Unknown product", receiptInfo.ProductId)
		data.ProcessedReceipts[purchaseId] = true
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
	if def.coins then
		data.Coins += def.coins
		Remotes.Toast:FireClient(player, string.format("Purchased +%d coins", def.coins))
		Remotes.Fx:FireClient(player, { kind = "CashPop", amount = def.coins })
	end
	if def.handler and handlers[def.handler] then
		handlers[def.handler](player)
	end
	data.ProcessedReceipts[purchaseId] = true
	PlayerData.Save(player)
	StateBus.Push(player, true)
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

function Monetization.Init()
	MarketplaceService.ProcessReceipt = processReceipt
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, _passId, wasPurchased)
		if wasPurchased then
			Monetization.RefreshPasses(player)
			Remotes.Toast:FireClient(player, "Game Pass unlocked")
			StateBus.Push(player, true)
		end
	end)
end

Players.PlayerRemoving:Connect(function(player)
	passCache[player.UserId] = nil
end)

return Monetization
