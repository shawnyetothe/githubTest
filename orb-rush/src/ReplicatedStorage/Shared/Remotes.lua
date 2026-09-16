local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = {}

local folder = ReplicatedStorage:FindFirstChild("OrbRushRemotes")
if not folder then
	folder = Instance.new("Folder")
	folder.Name = "OrbRushRemotes"
	folder.Parent = ReplicatedStorage
end

local function getRemote(name, className)
	local remote = folder:FindFirstChild(name)
	if not remote then
		remote = Instance.new(className)
		remote.Name = name
		remote.Parent = folder
	end
	return remote
end

-- Client → Server
Remotes.BuyUpgrade = getRemote("BuyUpgrade", "RemoteEvent")
Remotes.RequestRebirth = getRemote("RequestRebirth", "RemoteEvent")
Remotes.ClaimDaily = getRemote("ClaimDaily", "RemoteEvent")
Remotes.PromptProduct = getRemote("PromptProduct", "RemoteEvent")
Remotes.PromptGamePass = getRemote("PromptGamePass", "RemoteEvent")

-- Server → Client
Remotes.StateUpdate = getRemote("StateUpdate", "RemoteEvent")
Remotes.Toast = getRemote("Toast", "RemoteEvent")
Remotes.CashPop = getRemote("CashPop", "RemoteEvent")
Remotes.ShowShopNudge = getRemote("ShowShopNudge", "RemoteEvent")
Remotes.DismissNudge = getRemote("DismissNudge", "RemoteEvent")

return Remotes
