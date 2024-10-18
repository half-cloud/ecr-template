local ecr = require("@packages/ecr")

type Array<T> = { [number]: T }
type EntityId = number
type Registry = ecr.Registry

local function remove<T>(world: Registry, id: EntityId, ctype: Array<T>, value: T)
	local cval = world:try_get(id, ctype)

	if cval then
		local index = table.find(cval, value)
		if index == nil then
			return
		end

		table.remove(cval, index)
		world:set(id, ctype, cval)
	end
end

return remove
