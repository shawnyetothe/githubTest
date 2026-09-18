local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = {}

local folder = ReplicatedStorage:FindFirstChild("RushRemotes")
if not folder then
	folder = Instance.new("Folder")
	folder.Name = "RushRemotes"
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

Remotes.Action = getRemote("Action", "RemoteEvent")
Remotes.State = getRemote("State", "RemoteEvent")
Remotes.Toast = getRemote("Toast", "RemoteEvent")
Remotes.Fx = getRemote("Fx", "RemoteEvent")

return Remotes
