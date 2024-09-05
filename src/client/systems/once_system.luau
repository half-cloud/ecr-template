local client_state = require("@client/utils/client_state")
local std = require("@shared/std")

type ClientState = client_state.ClientState
type System<T> = std.System<T>

local exports: System<ClientState> = {
	run_once = true,
	system = function()
		print("I run once when started!")
	end,
}

return exports
