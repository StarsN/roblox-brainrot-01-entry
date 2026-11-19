-- Effects.client: juice. The camera shakes when the tsunami hits, a burst
-- of confetti parts pops when a rare brainrot is caught, and the sky
-- flashes during the warning. All purely visual, all client-side, so a
-- slow client never stalls the server.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local waveEvent = remotes:WaitForChild("TsunamiWave")
local carryEvent = remotes:WaitForChild("CarryUpdate")

local camera = Workspace.CurrentCamera
local shaking = 0

-- Camera shake: a decaying wobble applied after the camera updates.
RunService.RenderStepped:Connect(function()
	if shaking > 0 then
		shaking -= 0.02
		if camera then
			local cf = camera.CFrame
			local wobble = Vector3.new(
				(math.random() - 0.5) * shaking,
				(math.random() - 0.5) * shaking,
				0
			)
			camera.CFrame = cf + wobble
		end
	end
end)

-- Confetti: a burst of small bright parts above the player, then gone.
local function confetti(color)
	local character = player.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then
		return
	end
	local origin = character.HumanoidRootPart.Position + Vector3.new(0, 4, 0)
	for i = 1, 24 do
		local p = Instance.new("Part")
		p.Size = Vector3.new(0.4, 0.4, 0.4)
		p.Color = color or Color3.fromRGB(255, 210, 60)
		p.Material = Enum.Material.Neon
		p.Anchored = false
		p.CanCollide = false
		p.CFrame = CFrame.new(origin)
		p.Parent = Workspace
		local velocity = Vector3.new(
			(math.random() - 0.5) * 24,
			math.random() * 18 + 6,
			(math.random() - 0.5) * 24
		)
		p.AssemblyLinearVelocity = velocity
		task.delay(1.2, function()
			p:Destroy()
		end)
	end
end

waveEvent.OnClientEvent:Connect(function(info)
	if info.phase == "warning" and info.seconds and info.seconds <= 5 then
		shaking = math.max(shaking, 0.25)
	elseif info.phase == "wave" then
		shaking = 1.2
	end
end)

-- Picking a brainrot up is a little celebration; a Secret is a big one.
carryEvent.OnClientEvent:Connect(function(info)
	if info.carrying then
		confetti(Color3.fromRGB(255, 210, 60))
	end
end)
