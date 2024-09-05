local RunService = game:GetService("RunService")

local heartbeat_systems = require("@server/utils/heartbeat_systems")
local server_state = require("@server/utils/server_state")
local std = require("@shared/std")

local registry = std.create_registry()
local scheduler = std.create_scheduler(registry, server_state, heartbeat_systems)

RunService.Heartbeat:Connect(scheduler)
