local ecr = require("@packages/ecr")

type EntityId = number
type Registry = ecr.Registry

local function find<T>(registry: Registry, ctype: T, value: T): EntityId?
	for id, cval in registry:view(ctype):iter() do
		if value == cval then
			return id
		end
	end

	return nil
end

return find
