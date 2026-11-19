-- init.server: boots Tung Tung Bay. The server owns the world, the money,
-- the conveyor, the stealing and the tsunami; the client only ever asks.
-- Services start in dependency order: world first (plots the economy
-- needs), then economy, spawner, stealing, tsunami, leaderboard.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local WorldBuilder = require(script:WaitForChild("WorldBuilder"))
local EconomyService = require(script:WaitForChild("EconomyService"))
local SpawnService = require(script:WaitForChild("SpawnService"))
local StealService = require(script:WaitForChild("StealService"))
local TsunamiService = require(script:WaitForChild("TsunamiService"))
local LeaderboardService = require(script:WaitForChild("LeaderboardService"))

-- RemoteEvents the client uses to ask the server for things. All
-- validation happens server-side in the services above.
local remotes = Instance.new("Folder")
remotes.Name = "Remotes"
remotes.Parent = ReplicatedStorage
for _, name in ipairs({
	"SellBrainrot", "Rebirth", "ToggleLock",
	"Slap", "CarryUpdate", "StateUpdate", "TsunamiWave",
}) do
	local event = Instance.new("RemoteEvent")
	event.Name = name
	event.Parent = remotes
end

WorldBuilder.build()
EconomyService.init()
SpawnService.init()
StealService.init()
TsunamiService.init()
LeaderboardService.init()

print("Tung Tung Bay is live: 8 plots, 12 brainrots, tsunami every 90s.")
