local RunService = game:GetService("RunService")

local heartbeat_systems = require("@server/utils/heartbeat_systems")
local server_state = require("@server/utils/server_state")
local std = require("@shared/std")
local stepped_systems = require("@server/utils/stepped_systems")

std.registry = std.create_registry()

local heartbeat = std.create_scheduler(std.registry, server_state, heartbeat_systems)
local stepped = std.create_scheduler(std.registry, server_state, stepped_systems)

RunService.PostSimulation:Connect(heartbeat)
RunService.PreSimulation:Connect(stepped)
