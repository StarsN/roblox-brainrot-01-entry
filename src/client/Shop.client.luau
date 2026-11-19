-- Shop.client: the shop, the rebirth altar and the minimap, all in one
-- ScreenGui panel on the right side of the screen. The shop lists every
-- brainrot in the cast with its price and $/s, so the player can plan the
-- climb from Tung Tung to Los Tralaleritos. Buying happens by touching
-- the brainrot on the conveyor; the shop also sells (70% back) and
-- rebirths. The minimap is a top-down drawing of the bay: ocean, belt,
-- plots and the player's own base, updated as brainrots ride the belt.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BrainrotConfig"))
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local sellEvent = remotes:WaitForChild("SellBrainrot")
local rebirthEvent = remotes:WaitForChild("Rebirth")
local lockEvent = remotes:WaitForChild("ToggleLock")
local stateEvent = remotes:WaitForChild("StateUpdate")

local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "ShopGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Name = "ShopPanel"
panel.Position = UDim2.new(1, -330, 0, 90)
panel.Size = UDim2.new(0, 310, 0, 560)
panel.BackgroundColor3 = Color3.fromRGB(20, 28, 55)
panel.BackgroundTransparency = 0.15
panel.BorderSizePixel = 0
panel.Parent = gui
local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 14)
panelCorner.Parent = panel

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Position = UDim2.new(0, 0, 0, 8)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "BRAINROT SHOP"
title.TextSize = 24
title.TextColor3 = Color3.fromRGB(255, 210, 60)
title.Font = Enum.Font.FredokaOne
title.Parent = panel

local hint = Instance.new("TextLabel")
hint.Name = "Hint"
hint.Position = UDim2.new(0, 12, 0, 38)
hint.Size = UDim2.new(1, -24, 0, 34)
hint.BackgroundTransparency = 1
hint.Text = "Touch a brainrot on the conveyor to buy it, then carry it to your base."
hint.TextSize = 14
hint.TextWrapped = true
hint.TextColor3 = Color3.fromRGB(220, 220, 220)
hint.Font = Enum.Font.SourceSans
hint.Parent = panel

local list = Instance.new("ScrollingFrame")
list.Name = "List"
list.Position = UDim2.new(0, 10, 0, 76)
list.Size = UDim2.new(1, -20, 0, 330)
list.BackgroundTransparency = 1
list.ScrollBarThickness = 4
list.CanvasSize = UDim2.new(0, 0, 0, #Config.BRAINROTS * 46)
list.Parent = panel
local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 4)
listLayout.Parent = list

for _, b in ipairs(Config.BRAINROTS) do
	local rarity = Config.getRarity(b.rarity)
	local row = Instance.new("Frame")
	row.Name = "Row_" .. b.id
	row.Size = UDim2.new(1, 0, 0, 42)
	row.BackgroundColor3 = Color3.fromRGB(35, 45, 80)
	row.BorderSizePixel = 0
	row.Parent = list
	local rowCorner = Instance.new("UICorner")
	rowCorner.CornerRadius = UDim.new(0, 8)
	rowCorner.Parent = row

	local name = Instance.new("TextLabel")
	name.Position = UDim2.new(0, 8, 0, 2)
	name.Size = UDim2.new(0.62, 0, 0, 22)
	name.BackgroundTransparency = 1
	name.Text = b.name
	name.TextSize = 15
	name.TextXAlignment = Enum.TextXAlignment.Left
	name.TextColor3 = Color3.fromRGB(255, 255, 255)
	name.Font = Enum.Font.SourceSansBold
	name.Parent = row

	local meta = Instance.new("TextLabel")
	meta.Position = UDim2.new(0, 8, 0, 22)
	meta.Size = UDim2.new(0.62, 0, 0, 18)
	meta.BackgroundTransparency = 1
	meta.Text = b.rarity .. "  •  $" .. tostring(b.rate) .. "/s"
	meta.TextSize = 13
	meta.TextXAlignment = Enum.TextXAlignment.Left
	meta.TextColor3 = rarity.color
	meta.Font = Enum.Font.SourceSans
	meta.Parent = row

	local price = Instance.new("TextLabel")
	price.Position = UDim2.new(0.62, 0, 0, 2)
	price.Size = UDim2.new(0.38, -8, 1, 0)
	price.BackgroundTransparency = 1
	price.Text = "$" .. tostring(b.cost)
	price.TextSize = 17
	price.TextXAlignment = Enum.TextXAlignment.Right
	price.TextColor3 = Color3.fromRGB(255, 210, 60)
	price.Font = Enum.Font.SourceSansBold
	price.Parent = row
end

local function actionButton(name, y, text, color)
	local b = Instance.new("TextButton")
	b.Name = name
	b.Position = UDim2.new(0, 10, 0, y)
	b.Size = UDim2.new(1, -20, 0, 40)
	b.BackgroundColor3 = color
	b.Text = text
	b.TextSize = 18
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.Font = Enum.Font.FredokaOne
	b.Parent = panel
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 10)
	c.Parent = b
	return b
end

local rebirthButton = actionButton("RebirthButton", 414, "REBIRTH — $50,000", Color3.fromRGB(150, 60, 200))
local lockButton = actionButton("LockButton", 462, "LOCK BASE (30s)", Color3.fromRGB(40, 120, 200))
local sellButton = actionButton("SellButton", 510, "SELL FIRST BRAINROT (70% back)", Color3.fromRGB(200, 120, 40))

stateEvent.OnClientEvent:Connect(function(state)
	rebirthButton.Text = "REBIRTH — $" .. tostring(state.rebirthCost) .. "  (+50% $/s forever)"
	if os.time() < state.lockedUntil then
		lockButton.Text = "BASE LOCKED — tap to unlock"
	else
		lockButton.Text = "LOCK BASE (30s)"
	end
end)

rebirthButton.MouseButton1Click:Connect(function()
	rebirthEvent:FireServer()
end)
lockButton.MouseButton1Click:Connect(function()
	lockEvent:FireServer()
end)
sellButton.MouseButton1Click:Connect(function()
	-- Sells the first brainrot on the player's base; the server picks it.
	sellEvent:FireServer("__first__")
end)

-- Minimap: a top-down map of the bay in the bottom-right corner.
-- Ocean north, conveyor belt, eight plots south, spawn pad, egg shack.
local map = Instance.new("Frame")
map.Name = "Minimap"
map.Position = UDim2.new(1, -330, 1, -180)
map.Size = UDim2.fromOffset(310, 160)
map.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
map.BackgroundTransparency = 0.15
map.BorderSizePixel = 0
map.Parent = gui
local mapCorner = Instance.new("UICorner")
mapCorner.CornerRadius = UDim.new(0, 12)
mapCorner.Parent = map

local function mapRect(name, x, y, w, h, color)
	local f = Instance.new("Frame")
	f.Name = name
	f.Position = UDim2.new(0, x, 0, y)
	f.Size = UDim2.fromOffset(w, h)
	f.BackgroundColor3 = color
	f.BorderSizePixel = 0
	f.Parent = map
	return f
end

mapRect("Ocean", 0, 0, 310, 28, Color3.fromRGB(40, 110, 220))
mapRect("Belt", 10, 62, 290, 10, Color3.fromRGB(220, 60, 60))
mapRect("Spawn", 140, 140, 30, 16, Color3.fromRGB(120, 255, 140))
mapRect("Shack", 4, 60, 18, 16, Color3.fromRGB(255, 210, 60))
for i = 1, 8 do
	local plot = mapRect("Plot" .. i, 8 + (i - 1) * 37, 100, 32, 26, Config.PLOT_COLORS[i])
	plot.BackgroundTransparency = 0.3
end
local you = mapRect("You", 150, 100, 10, 10, Color3.fromRGB(255, 255, 255))
you.Name = "YouMarker"

local mapTitle = Instance.new("TextLabel")
mapTitle.Position = UDim2.new(0, 8, 0, 30)
mapTitle.Size = UDim2.new(1, -16, 0, 18)
mapTitle.BackgroundTransparency = 1
mapTitle.Text = "TUNG TUNG BAY — ocean top, your base below"
mapTitle.TextSize = 12
mapTitle.TextXAlignment = Enum.TextXAlignment.Left
mapTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
mapTitle.Font = Enum.Font.SourceSans
mapTitle.Parent = map

-- The "you" dot follows the player across the minimap.
local RunService = game:GetService("RunService")
RunService.RenderStepped:Connect(function()
	local character = player.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then
		return
	end
	local pos = character.HumanoidRootPart.Position
	-- World x in [-120, 120] -> map x in [8, 302]; world z in [-120, 120] -> map y in [0, 156].
	local mx = math.clamp((pos.X + 120) / 240 * 294 + 8, 8, 302)
	local my = math.clamp((pos.Z + 120) / 240 * 150, 4, 150)
	you.Position = UDim2.new(0, mx - 5, 0, my - 5)
end)
