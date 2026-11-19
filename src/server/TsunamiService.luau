-- TsunamiService: the threat that forces the dash home. Every
-- TSUNAMI_PERIOD seconds a wave rolls in from the ocean: ten seconds of
-- warning (the sky darkens, the HUD siren counts down, the wave wall
-- rises), then the wave sweeps the whole map from north to south. Anyone
-- caught outside their base is knocked back toward spawn and drops
-- whatever they are carrying. Inside your base, you are safe.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BrainrotConfig"))
local StealService = require(script.Parent:WaitForChild("StealService"))

local TsunamiService = {}

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local waveEvent = remotes:WaitForChild("TsunamiWave")

local waveWall = nil

function TsunamiService.isSafeSpot(position)
	-- Safe: standing on your own base plot, or on the spawn pad.
	for _, center in ipairs(Config.PLOT_CENTERS) do
		if math.abs(position.X - center.X) <= 13 and math.abs(position.Z - center.Z) <= 11 then
			return true
		end
	end
	if math.abs(position.X) <= 10 and math.abs(position.Z - 96) <= 8 then
		return true
	end
	return false
end

local function sweep()
	-- The wave wall rises out of the ocean and rolls south.
	if waveWall then
		waveWall.Transparency = 0.3
	end
	waveEvent:FireAllClients({ phase = "wave" })
	task.wait(1.5)
	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		if character and character:FindFirstChild("HumanoidRootPart") then
			local root = character.HumanoidRootPart
			if not TsunamiService.isSafeSpot(root.Position) then
				-- Knocked back toward the spawn, and the catch is dropped.
				StealService.dropCarried(player)
				root.CFrame = CFrame.new(root.Position.X, root.Position.Y, root.Position.Z + 25)
				root.AssemblyLinearVelocity = Vector3.new(0, 30, 60)
			end
		end
	end
	task.wait(3)
	if waveWall then
		waveWall.Transparency = 1
	end
	Lighting.Ambient = Color3.fromRGB(70, 70, 70)
	waveEvent:FireAllClients({ phase = "clear" })
end

function TsunamiService.init()
	-- The wave wall: a translucent blue wall across the ocean edge,
	-- invisible until a wave comes.
	waveWall = Instance.new("Part")
	waveWall.Name = "TsunamiWall"
	waveWall.Size = Vector3.new(260, 30, 4)
	waveWall.CFrame = CFrame.new(0, 12, -95)
	waveWall.Color = Color3.fromRGB(40, 120, 255)
	waveWall.Material = Enum.Material.Neon
	waveWall.Transparency = 1
	waveWall.Anchored = true
	waveWall.CanCollide = false
	waveWall.Parent = Workspace

	task.spawn(function()
		while true do
			-- Countdown to the next wave, told to every client each second.
			for remaining = Config.TSUNAMI_PERIOD, 1, -1 do
				if remaining <= Config.TSUNAMI_WARNING then
					waveEvent:FireAllClients({ phase = "warning", seconds = remaining })
				end
				task.wait(1)
			end
			Lighting.Ambient = Color3.fromRGB(20, 20, 50)
			sweep()
		end
	end)
end

return TsunamiService
