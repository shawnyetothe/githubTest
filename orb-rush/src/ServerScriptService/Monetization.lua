local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))
local PlayerData = require(script.Parent:WaitForChild("PlayerData"))

local Monetization = {}

local passCache = {} -- [userId] = { DoubleCash = bool, VipMagnet = bool }

local function productKeyById(productId)
	for key, def in pairs(Config.DeveloperProducts) do
		if def.id ~= 0 and def.id == productId then
			return key, def
		end
	end
	return nil, nil
end

function Monetization.RefreshPasses(player)
	local owned = { DoubleCash = false, VipMagnet = false }
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
	-- Studio / unset IDs: treat as unowned (fair testing)
	passCache[player.UserId] = owned
	return owned
end

function Monetization.GetPasses(player)
	return passCache[player.UserId] or Monetization.RefreshPasses(player)
end

function Monetization.PushState(player)
	local passes = Monetization.GetPasses(player)
	local snap = PlayerData.StatSnapshot(player, passes)
	if snap then
		Remotes.StateUpdate:FireClient(player, snap)
	end
end

function Monetization.GrantCash(player, amount, reason)
	local data = PlayerData.Get(player)
	if not data then
		return
	end
	data.Cash += amount
	Remotes.Toast:FireClient(player, string.format("+%s cash (%s)", tostring(amount), reason or "reward"))
	Monetization.PushState(player)
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

	local _, def = productKeyById(receiptInfo.ProductId)
	if not def then
		-- Unknown product — grant to avoid stuck receipts in misconfig, but log
		warn("[OrbRush] Unknown product id", receiptInfo.ProductId)
		data.ProcessedReceipts[purchaseId] = true
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	data.Cash += def.cash
	data.ProcessedReceipts[purchaseId] = true
	PlayerData.Save(player)
	Remotes.Toast:FireClient(player, string.format("Purchased +%d cash!", def.cash))
	Remotes.CashPop:FireClient(player, def.cash)
	Monetization.PushState(player)
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

function Monetization.Init()
	MarketplaceService.ProcessReceipt = processReceipt

	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId, wasPurchased)
		if wasPurchased then
			Monetization.RefreshPasses(player)
			Monetization.PushState(player)
			Remotes.Toast:FireClient(player, "Game Pass unlocked!")
		end
	end)

	Remotes.PromptProduct.OnServerEvent:Connect(function(player, productKey)
		if typeof(productKey) ~= "string" then
			return
		end
		local def = Config.DeveloperProducts[productKey]
		if not def or def.id == 0 then
			Remotes.Toast:FireClient(player, "Set Developer Product IDs in Config.lua")
			return
		end
		MarketplaceService:PromptProductPurchase(player, def.id)
	end)

	Remotes.PromptGamePass.OnServerEvent:Connect(function(player, passKey)
		if typeof(passKey) ~= "string" then
			return
		end
		local passId = Config.GamePasses[passKey]
		if typeof(passId) ~= "number" or passId == 0 then
			Remotes.Toast:FireClient(player, "Set Game Pass IDs in Config.lua")
			return
		end
		MarketplaceService:PromptGamePassPurchase(player, passId)
	end)
end

Players.PlayerRemoving:Connect(function(player)
	passCache[player.UserId] = nil
end)

return Monetization
