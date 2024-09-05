local client_state = require("@client/utils/client_state")
local std = require("@shared/std")

type ClientState = client_state.ClientState
type System<T> = std.System<T>

local exports: System<ClientState> = {
	stateful = true,
	system = function()
		print("I run once when started!")
		return function()
			print("I run every frame!")
		end
	end,
}

return exports
