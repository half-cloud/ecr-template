local ecr = require("@packages/ecr")

type Registry = ecr.Registry

local function create_registry(): Registry
	local registry = ecr.registry()
	registry:context()

	return registry
end

return create_registry
