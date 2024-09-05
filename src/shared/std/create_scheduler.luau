local ecr = require("@packages/ecr")
local types = require("./types")

type Array<T> = { [number]: T }
type Registry = ecr.Registry
type SystemFn<T> = types.SystemFn<T>
type System<T> = types.System<T>

local function create_scheduler<T>(
	registry: Registry,
	state: T,
	systems: Array<SystemFn<T> | System<T>>
): (delta_time: number) -> ()
	local scheduled: Array<System<T>> = {}
	local frame_count = 0

	for _, system in systems do
		if typeof(system) == "function" then
			table.insert(scheduled, {
				system = system,
			})
			continue
		end

		if system.run_once == true then
			system.system(registry, state, 0)
			continue
		end

		if system.stateful == true then
			system.system = system.system(registry, state, 0)
		end

		table.insert(scheduled, system)
	end

	return function(delta_time: number)
		frame_count += 1

		for _, system in scheduled do
			if system.run_interval ~= nil and frame_count % system.run_interval > 0 then
				continue
			end

			system.system(registry, state, delta_time)
		end
	end
end

return create_scheduler
