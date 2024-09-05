local server_state = require("@server/utils/server_state")
local std = require("@shared/std")

type ServerState = server_state.ServerState
type System<T> = std.System<T>

local exports: System<ServerState> = {
	stateful = true,
	system = function()
		print("I run once when started!")
		return function()
			print("I run every frame!")
		end
	end,
}

return exports
