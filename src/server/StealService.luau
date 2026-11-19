-- StealService: carrying, placing and stealing. Touch a brainrot on the
-- conveyor to pick it up and carry it home (it rides above your head);
-- touch your own base pad to set it down and start earning. Touch a
-- brainrot on somebody else's base and hold still for the channel time to
-- steal it -- unless their base lock is up, in which case the steal is
-- refused, or they slap you, which knocks the carried brainrot loose.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BrainrotConfig"))
local EconomyService = require(script.Parent:WaitForChild("EconomyService"))

local StealService = {}

-- player -> { brainrot, mutation } while carrying
local carrying = {}
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local carryEvent = remotes:WaitForChild("CarryUpdate")
local slapEvent = remotes:WaitForChild("Slap")

local function ownerOfPlaced(model)
	for _, player in ipairs(Players:GetPlayers()) do
		local state = EconomyService.getState(player)
		if state then
			for _, owned in ipairs(state.owned) do
				if owned == model then
					return player
				end
			end
		end
	end
	return nil
end

function StealService.isCarrying(player)
	return carrying[player] ~= nil
end

-- Drop what a player is carrying where they stand (tsunami, slap, reset).
function StealService.dropCarried(player)
	local held = carrying[player]
	if not held then
		return
	end
	carrying[player] = nil
	local character = player.Character
	if character and character:FindFirstChild("HumanoidRootPart") then
		local root = character.HumanoidRootPart
		local model = require(script.Parent:WaitForChild("ModelFactory")).build(
			held.brainrot, held.mutation,
			CFrame.new(root.Position + Vector3.new(0, 1, 4)))
		model.Name = "Dropped_" .. held.brainrot.id
		model.Parent = Workspace:WaitForChild("ConveyorBrainrots")
	end
	carryEvent:FireClient(player, { carrying = false })
end

local function pickUp(player, model)
	if not model.Parent then
		return -- already bought, stolen or swept away
	end
	if carrying[player] then
		return
	end
	local idValue = model:FindFirstChild("BrainrotId")
	local mutValue = model:FindFirstChild("Mutation")
	if not idValue or not mutValue then
		return
	end
	local b = Config.getBrainrot(idValue.Value)
	local m = Config.getMutation(mutValue.Value)
	if not b or not m then
		return
	end
	-- A placed brainrot belongs to someone: stealing needs the channel.
	local owner = ownerOfPlaced(model)
	if owner then
		if owner == player then
			return -- your own brainrots stay put; sell them from the shop
		end
		if EconomyService.isLocked(owner) then
			return -- base lock up: this base cannot be stolen from
		end
		-- The steal channel: the thief must stay near the brainrot.
		local character = player.Character
		if not character or not character:FindFirstChild("HumanoidRootPart") then
			return
		end
		local startPos = character.HumanoidRootPart.Position
		local targetPos = model:GetPivot().Position
		task.spawn(function()
			local waited = 0
			while waited < Config.STEAL_CHANNEL_SECONDS do
				task.wait(0.25)
				waited += 0.25
				local c = player.Character
				if not c or not c:FindFirstChild("HumanoidRootPart") then
					return
				end
				if (c.HumanoidRootPart.Position - startPos).Magnitude > 6 then
					return -- moved away: the steal fails
				end
				if not model.Parent then
					return
				end
			end
			if EconomyService.isLocked(owner) then
				return
			end
			if EconomyService.removeFromBase(owner, model) then
				model:Destroy()
				carrying[player] = { brainrot = b, mutation = m }
				carryEvent:FireClient(player, { carrying = true, name = b.name })
				EconomyService.pushState(owner)
			end
		end)
		return
	end
	-- Loose on the conveyor or dropped: free to pick up, except a fresh
	-- conveyor brainrot costs its buy price -- the server charges here,
	-- so a catch can never happen without paying for it. A dropped one
	-- (already paid for, or already stolen) is free.
	if string.sub(model.Name, 1, 9) == "Conveyor_" then
		if not EconomyService.tryCharge(player, b.cost) then
			return -- cannot afford it: it keeps riding the belt
		end
	end
	model:Destroy()
	carrying[player] = { brainrot = b, mutation = m }
	carryEvent:FireClient(player, { carrying = true, name = b.name })
end

-- Set down what you carry: on your own base pad it starts earning.
local function placeCarried(player)
	local held = carrying[player]
	if not held then
		return
	end
	local state = EconomyService.getState(player)
	if not state then
		return
	end
	local character = player.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then
		return
	end
	local center = Config.PLOT_CENTERS[state.plotIndex]
	local pos = character.HumanoidRootPart.Position
	if math.abs(pos.X - center.X) > 14 or math.abs(pos.Z - center.Z) > 12 then
		return -- not standing on your own base
	end
	if EconomyService.placeOnBase(player, held.brainrot, held.mutation) then
		carrying[player] = nil
		carryEvent:FireClient(player, { carrying = false })
		EconomyService.pushState(player)
	end
end

-- A slap: knock a nearby carrier's brainrot loose. Short range, cooldown.
local lastSlap = {}
local function onSlap(player)
	local now = os.clock()
	if lastSlap[player] and now - lastSlap[player] < 2 then
		return
	end
	lastSlap[player] = now
	local character = player.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then
		return
	end
	local pos = character.HumanoidRootPart.Position
	for _, other in ipairs(Players:GetPlayers()) do
		if other ~= player and carrying[other] then
			local oc = other.Character
			if oc and oc:FindFirstChild("HumanoidRootPart") then
				if (oc.HumanoidRootPart.Position - pos).Magnitude < 8 then
					StealService.dropCarried(other)
					return
				end
			end
		end
	end
end

function StealService.init()
	slapEvent.OnServerEvent:Connect(onSlap)

	-- Touch handling: conveyor brainrots and placed brainrots are picked
	-- up by touching their body parts.
	local function watchFolder(folder)
		folder.ChildAdded:Connect(function(model)
			if not model:IsA("Model") then
				return
			end
			task.wait(0.2)
			for _, descendant in ipairs(model:GetDescendants()) do
				if descendant:IsA("BasePart") then
					descendant.Touched:Connect(function(hit)
						local player = Players:GetPlayerFromCharacter(hit.Parent)
						if player and not StealService.isCarrying(player) then
							pickUp(player, model)
						end
					end)
				end
			end
		end)
	end
	watchFolder(Workspace:WaitForChild("ConveyorBrainrots"))
	watchFolder(Workspace:WaitForChild("PlacedBrainrots"))

	-- Touching your own base pad while carrying sets the brainrot down.
	for _, center in ipairs(Config.PLOT_CENTERS) do
		local pad = Instance.new("Part")
		pad.Name = "PlaceTrigger"
		pad.Size = Vector3.new(24, 1, 20)
		pad.CFrame = CFrame.new(center.X, center.Y + 0.2, center.Z)
		pad.Transparency = 1
		pad.Anchored = true
		pad.CanCollide = false
		pad.CanQuery = true
		pad.Parent = Workspace
		pad.Touched:Connect(function(hit)
			local player = Players:GetPlayerFromCharacter(hit.Parent)
			if player then
				placeCarried(player)
			end
		end)
	end

	Players.PlayerRemoving:Connect(function(player)
		-- A leaver's carried brainrot washes back out to sea.
		StealService.dropCarried(player)
		carrying[player] = nil
	end)
end

return StealService
