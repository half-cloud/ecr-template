local server_state = require("@server/utils/server_state")
local std = require("@shared/std")

type ServerState = server_state.ServerState
type System<T> = std.System<T>

local exports: System<ServerState> = {
	run_once = true,
	system = function()
		print("I run once when started!")
	end,
}

return exports
