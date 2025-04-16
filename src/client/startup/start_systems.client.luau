local RunService = game:GetService("RunService")

local client_state = require("@client/utils/client_state")
local heartbeat_systems = require("@client/utils/heartbeat_systems")
local renderstep_systems = require("@client/utils/renderstep_systems")
local std = require("@shared/std")

std.registry = std.create_registry()

local heartbeat = std.create_scheduler(std.registry, client_state, heartbeat_systems)
local renderstep = std.create_scheduler(std.registry, client_state, renderstep_systems)

RunService.PreSimulation:Connect(heartbeat)
RunService.PreRender:Connect(renderstep)
