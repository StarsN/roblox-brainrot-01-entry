-- SpawnService: the conveyor is the heart of the game. Every few seconds
-- a new brainrot washes up on the north beach and rides the belt from west
-- to east. Rarity and mutation are rolled here, on the server, so the
-- client can never fake a Secret. A brainrot that rides off the end of
-- the belt without being bought is swept back out to sea.

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BrainrotConfig"))
local ModelFactory = require(script.Parent:WaitForChild("ModelFactory"))

local SpawnService = {}
local counter = 0

function SpawnService.spawnOne()
	local folder = Workspace:WaitForChild("ConveyorBrainrots")
	local brainrot = Config.rollBrainrot()
	local mutation = Config.rollMutation()
	counter += 1
	local model = ModelFactory.build(brainrot, mutation,
		CFrame.new(Config.CONVEYOR_START), brainrot.rate * mutation.multiplier)
	model.Name = "Conveyor_" .. counter .. "_" .. brainrot.id
	model.Parent = folder
	return model
end

-- The belt loop: spawn on a timer, then walk every live brainrot along
-- the belt until it is bought, stolen off the belt, or rides off the end.
function SpawnService.init()
	local folder = Instance.new("Folder")
	folder.Name = "ConveyorBrainrots"
	folder.Parent = Workspace

	task.spawn(function()
		while true do
			task.wait(Config.SPAWN_INTERVAL)
			SpawnService.spawnOne()
		end
	end)

	task.spawn(function()
		local last = os.clock()
		while true do
			task.wait(0.1)
			local now = os.clock()
			local dt = now - last
			last = now
			for _, model in ipairs(folder:GetChildren()) do
				if model:IsA("Model") and model.PrimaryPart then
					local pos = model:GetPivot().Position
					local nextX = pos.X + Config.CONVEYOR_SPEED * dt
					if nextX >= Config.CONVEYOR_END.X then
						model:Destroy()
					else
						model:PivotTo(CFrame.new(nextX, pos.Y, pos.Z))
					end
				end
			end
		end
	end)
end

return SpawnService
