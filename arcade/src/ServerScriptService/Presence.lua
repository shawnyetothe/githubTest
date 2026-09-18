local Players = game:GetService("Players")

local Presence = {}

function Presence.Count(gameId)
	local n = 0
	for _, p in ipairs(Players:GetPlayers()) do
		if p:GetAttribute("GameId") == gameId then
			n += 1
		end
	end
	return n
end

function Presence.Boost(player)
	local id = player:GetAttribute("GameId")
	if not id or id == "Hub" then
		return false
	end
	return Presence.Count(id) >= 2
end

return Presence
