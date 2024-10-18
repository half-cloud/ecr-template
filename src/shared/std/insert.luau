local ecr = require("@packages/ecr")

type Array<T> = { [number]: T }
type EntityId = number
type Registry = ecr.Registry

local function insert<T>(world: Registry, id: EntityId, ctype: Array<T>, value: T)
	local cval = world:try_get(id, ctype)

	if cval then
		table.insert(cval, value)
		world:set(id, ctype, cval)
	else
		world:set(id, ctype, { value })
	end
end

return insert
