local RunService = game:GetService("RunService")

local heartbeat_systems = require("@server/utils/heartbeat_systems")
local server_state = require("@server/utils/server_state")
local std = require("@shared/std")

std.registry = std.create_registry()

local heartbeat = std.create_scheduler(std.registry, server_state, heartbeat_systems)

RunService.PreSimulation:Connect(heartbeat)
