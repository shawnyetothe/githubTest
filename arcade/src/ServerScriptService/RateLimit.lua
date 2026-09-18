local RateLimit = {}

local buckets = {}

function RateLimit.Allow(player, key, cooldown)
	cooldown = cooldown or 0.15
	local map = buckets[player]
	if not map then
		map = {}
		buckets[player] = map
	end
	local now = os.clock()
	local last = map[key] or 0
	if now - last < cooldown then
		return false
	end
	map[key] = now
	return true
end

game:GetService("Players").PlayerRemoving:Connect(function(player)
	buckets[player] = nil
end)

return RateLimit
