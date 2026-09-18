local Players = game:GetService("Players")

local Slots = {}
local used = {}

function Slots.Ensure(key, player, maxCount)
	local map = used[key]
	if not map then
		map = {}
		used[key] = map
	end
	for i, p in pairs(map) do
		if p == player then
			return i
		end
	end
	for i = 1, maxCount do
		if map[i] == nil then
			map[i] = player
			return i
		end
	end
	return nil
end

function Slots.Get(key, player)
	local map = used[key]
	if not map then
		return nil
	end
	for i, p in pairs(map) do
		if p == player then
			return i
		end
	end
	return nil
end

function Slots.Owner(key, index)
	local map = used[key]
	return map and map[index] or nil
end

Players.PlayerRemoving:Connect(function(player)
	for _, map in pairs(used) do
		for i, p in pairs(map) do
			if p == player then
				map[i] = nil
			end
		end
	end
end)

return Slots
