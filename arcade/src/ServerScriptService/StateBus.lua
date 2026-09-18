local StateBus = {}

local listener = nil

function StateBus.Set(fn)
	listener = fn
end

function StateBus.Push(player, immediate)
	if listener and player then
		listener(player, immediate == true)
	end
end

return StateBus
