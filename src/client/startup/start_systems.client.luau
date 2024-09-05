local RunService = game:GetService("RunService")

local client_state = require("@client/utils/client_state")
local heartbeat_systems = require("@client/utils/heartbeat_systems")
local std = require("@shared/std")

local registry = std.create_registry()
local scheduler = std.create_scheduler(registry, client_state, heartbeat_systems)

RunService.Heartbeat:Connect(scheduler)
