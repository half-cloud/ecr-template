local RunService = game:GetService("RunService")

local client_state = require("@client/utils/client_state")
local heartbeat_systems = require("@client/utils/heartbeat_systems")
local renderstepped_systems = require("@client/utils/renderstepped_systems")
local std = require("@shared/std")

std.registry = std.create_registry()

local heartbeat = std.create_scheduler(std.registry, client_state, heartbeat_systems)
local renderstepped = std.create_scheduler(std.registry, client_state, renderstepped_systems)

RunService.PostSimulation:Connect(heartbeat)
RunService.PreRender:Connect(renderstepped)
