-- Run in the Studio Command Bar AFTER dragging RushPlaza.rbxmx into Workspace.
-- Edit mode only. Do not press Play first.

local model = workspace:FindFirstChild("RushPlazaImport")
if not model then
	error("Drag arcade/RushPlaza.rbxmx into Workspace first")
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayerScripts = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")

local shared = ReplicatedStorage:FindFirstChild("Shared")
if not shared then
	shared = Instance.new("Folder")
	shared.Name = "Shared"
	shared.Parent = ReplicatedStorage
end

local function take(folderName, parent)
	local folder = model:FindFirstChild(folderName)
	if not folder then
		error("Missing " .. folderName)
	end
	for _, child in ipairs(folder:GetChildren()) do
		local existing = parent:FindFirstChild(child.Name)
		if existing then
			existing:Destroy()
		end
		child.Parent = parent
	end
end

take("Shared", shared)
take("Server", ServerScriptService)
take("Client", StarterPlayerScripts)
model:Destroy()
print("Rush Plaza installed. Enable API Services, then Play.")
