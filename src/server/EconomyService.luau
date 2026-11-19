-- EconomyService: one place holds every player's money. Cash ticks once
-- a second from the brainrots standing on that player's base, at each
-- brainrot's rate times its mutation multiplier times the player's
-- rebirth bonus. Buying, selling and rebirthing all validate here on the
-- server; the client only ever asks, it never decides.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BrainrotConfig"))
local ModelFactory = require(script.Parent:WaitForChild("ModelFactory"))

local EconomyService = {}

-- player -> { cash, rebirths, owned = { Model,... }, plotIndex, lockedUntil }
local states = {}
local plotOwner = {} -- plot index -> player

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local sellEvent = remotes:WaitForChild("SellBrainrot")
local rebirthEvent = remotes:WaitForChild("Rebirth")
local lockEvent = remotes:WaitForChild("ToggleLock")
local stateEvent = remotes:WaitForChild("StateUpdate")

function EconomyService.getState(player)
	return states[player]
end

function EconomyService.getPlotOwner(plotIndex)
	return plotOwner[plotIndex]
end

function EconomyService.incomePerSecond(player)
	local state = states[player]
	if not state then
		return 0
	end
	local total = 0
	for _, model in ipairs(state.owned) do
		local idValue = model:FindFirstChild("BrainrotId")
		local mutValue = model:FindFirstChild("Mutation")
		if idValue and mutValue then
			local b = Config.getBrainrot(idValue.Value)
			local m = Config.getMutation(mutValue.Value)
			if b and m then
				total += b.rate * m.multiplier
			end
		end
	end
	return math.floor(total * (1 + state.rebirths * Config.REBIRTH_BONUS))
end

function EconomyService.tryCharge(player, amount)
	local state = states[player]
	if not state or state.cash < amount then
		return false
	end
	state.cash -= amount
	state.cashValue.Value = state.cash
	EconomyService.pushState(player)
	return true
end

function EconomyService.slotPosition(plotIndex, slot)
	local center = Config.PLOT_CENTERS[plotIndex]
	local x = center.X - 9 + (slot - 1) * 3.6
	return CFrame.new(x, center.Y + 0.6, center.Z + 3)
end

function EconomyService.placeOnBase(player, brainrot, mutation)
	local state = states[player]
	if not state or #state.owned >= Config.MAX_SLOTS_PER_PLOT then
		return false
	end
	local rate = math.floor(brainrot.rate * mutation.multiplier
		* (1 + state.rebirths * Config.REBIRTH_BONUS))
	local model = ModelFactory.build(brainrot, mutation,
		EconomyService.slotPosition(state.plotIndex, #state.owned + 1), rate)
	model.Parent = Workspace:WaitForChild("PlacedBrainrots")
	table.insert(state.owned, model)
	return true
end

function EconomyService.removeFromBase(player, model)
	local state = states[player]
	if not state then
		return false
	end
	for i, owned in ipairs(state.owned) do
		if owned == model then
			table.remove(state.owned, i)
			-- Close the gap: shift the later brainrots one slot forward.
			for j = i, #state.owned do
				state.owned[j]:PivotTo(EconomyService.slotPosition(state.plotIndex, j))
			end
			return true
		end
	end
	return false
end

-- Buying happens by touch: the player touches a brainrot on the conveyor
-- (StealService.pickUp) and this service charges the price there, so the
-- buy can never happen without the cash check. Selling and rebirthing
-- are the RemoteEvents below.
local function onSell(player, brainrotId)
	local state = states[player]
	if not state then
		return
	end
	-- "__first__" is the shop's Sell button: sell the first brainrot on
	-- the player's base.
	local targetId = brainrotId
	if brainrotId == "__first__" then
		local first = state.owned[1]
		if not first then
			return
		end
		local firstId = first:FindFirstChild("BrainrotId")
		if not firstId then
			return
		end
		targetId = firstId.Value
	end
	for _, model in ipairs(state.owned) do
		local idValue = model:FindFirstChild("BrainrotId")
		if idValue and idValue.Value == targetId then
			local b = Config.getBrainrot(brainrotId)
			if b then
				state.cash += math.floor(b.cost * Config.SELL_FRACTION)
			end
			EconomyService.removeFromBase(player, model)
			model:Destroy()
			EconomyService.pushState(player)
			return
		end
	end
end

local function onRebirth(player)
	local state = states[player]
	if not state then
		return
	end
	local cost = Config.rebirthCost(state.rebirths)
	if state.cash < cost then
		return
	end
	state.cash = Config.START_CASH
	state.rebirths += 1
	for _, model in ipairs(state.owned) do
		model:Destroy()
	end
	state.owned = {}
	EconomyService.pushState(player)
end

local function onToggleLock(player)
	local state = states[player]
	if not state then
		return
	end
	if os.time() < state.lockedUntil then
		state.lockedUntil = 0
	else
		state.lockedUntil = os.time() + Config.BASE_LOCK_SECONDS
	end
	EconomyService.pushState(player)
end

function EconomyService.isLocked(player)
	local state = states[player]
	return state and os.time() < state.lockedUntil
end

function EconomyService.pushState(player)
	local state = states[player]
	if not state then
		return
	end
	stateEvent:FireClient(player, {
		cash = state.cash,
		income = EconomyService.incomePerSecond(player),
		rebirths = state.rebirths,
		rebirthCost = Config.rebirthCost(state.rebirths),
		owned = #state.owned,
		maxSlots = Config.MAX_SLOTS_PER_PLOT,
		plotIndex = state.plotIndex,
		lockedUntil = state.lockedUntil,
	})
end

local function onPlayerAdded(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player
	local cashValue = Instance.new("IntValue")
	cashValue.Name = "Cash"
	cashValue.Value = Config.START_CASH
	cashValue.Parent = leaderstats
	local rebirthValue = Instance.new("IntValue")
	rebirthValue.Name = "Rebirths"
	rebirthValue.Value = 0
	rebirthValue.Parent = leaderstats

	-- First free plot wins: players claim plots in join order.
	local plotIndex = 1
	for i = 1, Config.PLOT_COUNT do
		if not plotOwner[i] then
			plotIndex = i
			break
		end
	end
	plotOwner[plotIndex] = player
	states[player] = {
		cash = Config.START_CASH,
		rebirths = 0,
		owned = {},
		plotIndex = plotIndex,
		lockedUntil = 0,
		cashValue = cashValue,
		rebirthValue = rebirthValue,
	}
	EconomyService.pushState(player)
end

local function onPlayerRemoving(player)
	local state = states[player]
	if state then
		for _, model in ipairs(state.owned) do
			model:Destroy()
		end
		plotOwner[state.plotIndex] = nil
		states[player] = nil
	end
end

-- The money tick: once a second, every brainrot on a base pays out.
function EconomyService.startTick()
	task.spawn(function()
		while true do
			task.wait(1)
			for player, state in pairs(states) do
				local income = EconomyService.incomePerSecond(player)
				if income > 0 then
					state.cash += income
					state.cashValue.Value = state.cash
					EconomyService.pushState(player)
				end
			end
		end
	end)
end

function EconomyService.init()
	local placed = Instance.new("Folder")
	placed.Name = "PlacedBrainrots"
	placed.Parent = Workspace
	sellEvent.OnServerEvent:Connect(onSell)
	rebirthEvent.OnServerEvent:Connect(onRebirth)
	lockEvent.OnServerEvent:Connect(onToggleLock)
	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)
	for _, player in ipairs(Players:GetPlayers()) do
		onPlayerAdded(player)
	end
	EconomyService.startTick()
end

return EconomyService
