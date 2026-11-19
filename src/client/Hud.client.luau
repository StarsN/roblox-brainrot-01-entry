-- Hud.client: the ScreenGui over the 3D world. Top bar: cash, income per
-- second, rebirths. Bottom centre: what you are carrying and the slap
-- button. Top right: the tsunami countdown, which turns red and flashes
-- in the last ten seconds. Bottom left: the event feed ("Secret spawned!",
-- "Your base was robbed!"). Roblox's own menu buttons sit over the
-- top-left corner, so nothing here goes there.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local stateEvent = remotes:WaitForChild("StateUpdate")
local carryEvent = remotes:WaitForChild("CarryUpdate")
local waveEvent = remotes:WaitForChild("TsunamiWave")
local slapEvent = remotes:WaitForChild("Slap")

local gui = Instance.new("ScreenGui")
gui.Name = "TungTungHud"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local function label(name, parent, position, size, text, textSize, color)
	local l = Instance.new("TextLabel")
	l.Name = name
	l.Position = position
	l.Size = size
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextSize = textSize
	l.TextColor3 = color
	l.TextStrokeTransparency = 0
	l.Font = Enum.Font.FredokaOne
	l.Parent = parent
	return l
end

local function pill(name, parent, position, size, color)
	local f = Instance.new("Frame")
	f.Name = name
	f.Position = position
	f.Size = size
	f.BackgroundColor3 = color
	f.BackgroundTransparency = 0.25
	f.BorderSizePixel = 0
	f.Parent = parent
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = f
	return f
end

-- Top bar, centred so the top-left Roblox menu stays clear.
local topBar = pill("TopBar", gui, UDim2.new(0.5, -330, 0, 12), UDim2.fromOffset(660, 54), Color3.fromRGB(20, 30, 60))
local cashLabel = label("Cash", topBar, UDim2.new(0, 16, 0, 4), UDim2.new(0.42, 0, 1, -8), "$500", 30, Color3.fromRGB(255, 210, 60))
local incomeLabel = label("Income", topBar, UDim2.new(0.42, 0, 0, 4), UDim2.new(0.3, 0, 1, -8), "+$0/s", 24, Color3.fromRGB(120, 255, 140))
local rebirthLabel = label("Rebirths", topBar, UDim2.new(0.72, 0, 0, 4), UDim2.new(0.28, 0, 1, -8), "Rebirth x0", 24, Color3.fromRGB(200, 160, 255))

-- Tsunami countdown, top right.
local wavePill = pill("WavePill", gui, UDim2.new(1, -250, 0, 12), UDim2.fromOffset(230, 54), Color3.fromRGB(20, 60, 90))
local waveLabel = label("Wave", wavePill, UDim2.new(0, 0, 0, 4), UDim2.new(1, 0, 1, -8), "TSUNAMI 90s", 24, Color3.fromRGB(120, 220, 255))

-- Carrying indicator, bottom centre.
local carryPill = pill("CarryPill", gui, UDim2.new(0.5, -200, 1, -120), UDim2.fromOffset(400, 48), Color3.fromRGB(90, 50, 20))
carryPill.Visible = false
local carryLabel = label("Carrying", carryPill, UDim2.new(0, 0, 0, 4), UDim2.new(1, 0, 1, -8), "Carrying: —", 22, Color3.fromRGB(255, 255, 255))

-- Slap button, bottom right: the defence against thieves.
local slapButton = Instance.new("TextButton")
slapButton.Name = "SlapButton"
slapButton.Position = UDim2.new(1, -190, 1, -120)
slapButton.Size = UDim2.fromOffset(170, 48)
slapButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
slapButton.Text = "SLAP! (E)"
slapButton.TextSize = 24
slapButton.TextColor3 = Color3.fromRGB(255, 255, 255)
slapButton.Font = Enum.Font.FredokaOne
slapButton.Parent = gui
local slapCorner = Instance.new("UICorner")
slapCorner.CornerRadius = UDim.new(0, 12)
slapCorner.Parent = slapButton
slapButton.MouseButton1Click:Connect(function()
	slapEvent:FireServer()
end)

-- Event feed, bottom left: the last three things that happened.
local feed = Instance.new("Frame")
feed.Name = "Feed"
feed.Position = UDim2.new(0, 16, 1, -150)
feed.Size = UDim2.fromOffset(360, 130)
feed.BackgroundTransparency = 1
feed.Parent = gui

local function feedLine(text, color)
	for _, child in ipairs(feed:GetChildren()) do
		if child:IsA("TextLabel") then
			child.Position = child.Position + UDim2.new(0, 0, 0, 26)
			if child.Position.Y.Offset > 104 then
				child:Destroy()
			end
		end
	end
	local line = Instance.new("TextLabel")
	line.Position = UDim2.new(0, 0, 0, 0)
	line.Size = UDim2.new(1, 0, 0, 26)
	line.BackgroundTransparency = 1
	line.Text = text
	line.TextSize = 18
	line.TextXAlignment = Enum.TextXAlignment.Left
	line.TextColor3 = color or Color3.fromRGB(255, 255, 255)
	line.TextStrokeTransparency = 0
	line.Font = Enum.Font.SourceSansBold
	line.Parent = feed
end

local function formatCash(n)
	if n >= 1000000 then
		return string.format("$%.1fM", n / 1000000)
	elseif n >= 1000 then
		return string.format("$%.1fK", n / 1000)
	else
		return "$" .. tostring(math.floor(n))
	end
end

stateEvent.OnClientEvent:Connect(function(state)
	cashLabel.Text = formatCash(state.cash)
	incomeLabel.Text = "+" .. formatCash(state.income) .. "/s"
	rebirthLabel.Text = "Rebirth x" .. tostring(state.rebirths)
end)

carryEvent.OnClientEvent:Connect(function(info)
	if info.carrying then
		carryPill.Visible = true
		carryLabel.Text = "Carrying: " .. info.name .. " — run home!"
	else
		carryPill.Visible = false
	end
end)

waveEvent.OnClientEvent:Connect(function(info)
	if info.phase == "warning" then
		waveLabel.Text = "TSUNAMI " .. tostring(info.seconds) .. "s — RUN HOME!"
		wavePill.BackgroundColor3 = Color3.fromRGB(160, 30, 30)
		if info.seconds <= 5 then
			feedLine("TSUNAMI IN " .. tostring(info.seconds) .. "! Get to your base!", Color3.fromRGB(255, 80, 80))
		end
	elseif info.phase == "wave" then
		waveLabel.Text = "TSUNAMI!"
		feedLine("The wave swept the bay!", Color3.fromRGB(120, 220, 255))
	elseif info.phase == "clear" then
		waveLabel.Text = "TSUNAMI 90s"
		wavePill.BackgroundColor3 = Color3.fromRGB(20, 60, 90)
		feedLine("The bay is calm again. Back to the conveyor!", Color3.fromRGB(120, 255, 140))
	end
end)

-- Keyboard: E slaps, so a thief can be stopped without the mouse.
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end
	if input.KeyCode == Enum.KeyCode.E then
		slapEvent:FireServer()
	end
end)

feedLine("Welcome to Tung Tung Bay!", Color3.fromRGB(255, 210, 60))
feedLine("Grab a brainrot off the conveyor, carry it home.", Color3.fromRGB(255, 255, 255))
feedLine("Watch the sea: a tsunami comes every 90 seconds.", Color3.fromRGB(120, 220, 255))
