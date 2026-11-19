-- WorldBuilder: builds the 3D world of Tung Tung Bay at server start, on
-- top of the static baseplate, ocean and conveyor in default.project.json.
-- Eight coloured base plots along the south beach, a palm grove, rocks,
-- clouds, the egg shack sign and the leaderboard board. Everything is
-- anchored parts, so the world is exactly what the scripts describe.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BrainrotConfig"))

local WorldBuilder = {}

local function part(name, size, color, cframe, parent, material, shape)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Color = color
	p.CFrame = cframe
	p.Anchored = true
	p.CanCollide = true
	p.Material = material or Enum.Material.SmoothPlastic
	if shape then
		p.Shape = shape
	end
	p.Parent = parent
	return p
end

local function labelOn(partInstance, text, color, size)
	local gui = Instance.new("BillboardGui")
	gui.Name = "Sign"
	gui.Size = UDim2.fromOffset(260, 70)
	gui.StudsOffset = Vector3.new(0, 4, 0)
	gui.AlwaysOnTop = true
	gui.Parent = partInstance
	local t = Instance.new("TextLabel")
	t.Size = UDim2.fromScale(1, 1)
	t.BackgroundTransparency = 1
	t.Text = text
	t.TextColor3 = color or Color3.fromRGB(255, 255, 255)
	t.TextStrokeTransparency = 0
	t.TextScaled = true
	t.Font = Enum.Font.FredokaOne
	t.Parent = gui
end

function WorldBuilder.buildPlots()
	local folder = Instance.new("Folder")
	folder.Name = "BasePlots"
	folder.Parent = Workspace
	for i, center in ipairs(Config.PLOT_CENTERS) do
		local color = Config.PLOT_COLORS[i]
		-- The pad a player owns.
		part("Plot" .. i .. "Pad", Config.PLOT_SIZE, color,
			CFrame.new(center), folder, Enum.Material.Neon)
		-- Low back wall so placed brainrots read as "on a base".
		part("Plot" .. i .. "Wall", Vector3.new(24, 3, 1), color,
			CFrame.new(center + Vector3.new(0, 1.5, 10.5)), folder)
		-- A numbered sign post at the front corner.
		local post = part("Plot" .. i .. "Post", Vector3.new(1, 5, 1),
			Color3.fromRGB(90, 60, 30), CFrame.new(center + Vector3.new(-11, 2.5, -9)), folder)
		labelOn(post, "BASE " .. i, color, 70)
		-- Six slot markers: where a bought brainrot will stand.
		for slot = 1, Config.MAX_SLOTS_PER_PLOT do
			local sx = center.X - 9 + (slot - 1) * 3.6
			part("Plot" .. i .. "Slot" .. slot, Vector3.new(3, 0.2, 3),
				Color3.fromRGB(255, 255, 255),
				CFrame.new(sx, center.Y + 0.6, center.Z + 3), folder, Enum.Material.Neon)
		end
	end
end

function WorldBuilder.buildPalm(x, z, parent)
	local trunk = part("PalmTrunk", Vector3.new(1.2, 10, 1.2),
		Color3.fromRGB(120, 80, 40), CFrame.new(x, 5, z) * CFrame.Angles(0, 0, math.rad(6)), parent)
	trunk.TopSurface = Enum.SurfaceType.Smooth
	for i = 1, 5 do
		local angle = (i - 1) * (math.pi * 2 / 5)
		local leaf = part("PalmLeaf", Vector3.new(1.6, 0.3, 6),
			Color3.fromRGB(60, 180, 80),
			CFrame.new(x + math.cos(angle) * 2.6, 10.4, z + math.sin(angle) * 2.6)
				* CFrame.Angles(math.rad(28), angle, 0), parent)
		leaf.CanCollide = false
	end
	local nut = part("Coconut", Vector3.new(1, 1, 1), Color3.fromRGB(90, 60, 30),
		CFrame.new(x + 1, 9.6, z), parent, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
	nut.CanCollide = false
end

function WorldBuilder.buildNature()
	local folder = Instance.new("Folder")
	folder.Name = "Nature"
	folder.Parent = Workspace
	-- Palm grove along the west and east edges, clear of plots and belt.
	for _, spot in ipairs({ { -115, -30 }, { -115, 30 }, { 115, -30 }, { 115, 30 }, { -60, 95 }, { 60, 95 }, { -115, -80 }, { 115, -80 } }) do
		WorldBuilder.buildPalm(spot[1], spot[2], folder)
	end
	-- Rocks on the beach.
	for _, spot in ipairs({ { -40, -85, 3 }, { 30, -88, 4 }, { 80, 40, 2.5 }, { -80, 45, 2 } }) do
		local rock = part("Rock", Vector3.new(spot[3], spot[3] * 0.7, spot[3]),
			Color3.fromRGB(130, 130, 130), CFrame.new(spot[1], spot[3] * 0.35, spot[2]),
			folder, Enum.Material.Slate, Enum.PartType.Ball)
		rock.CanCollide = false
	end
	-- Clouds drifting high above the bay.
	for _, spot in ipairs({ { -50, 55, -40 }, { 40, 62, -70 }, { 0, 58, 20 } }) do
		local cloud = part("Cloud", Vector3.new(22, 3, 10),
			Color3.fromRGB(255, 255, 255), CFrame.new(spot[1], spot[2], spot[3]),
			folder, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
		cloud.CanCollide = false
		cloud.Transparency = 0.15
	end
end

function WorldBuilder.buildShack()
	local folder = Instance.new("Folder")
	folder.Name = "EggShack"
	folder.Parent = Workspace
	-- The egg shack: a stall on the west cliff where rare eggs hatch.
	local base = part("ShackBase", Vector3.new(22, 1, 16), Color3.fromRGB(180, 140, 90),
		CFrame.new(-95, 0.5, -10), folder, Enum.Material.WoodPlanks)
	local roof = part("ShackRoof", Vector3.new(24, 1, 18), Color3.fromRGB(220, 90, 90),
		CFrame.new(-95, 7, -10), folder, Enum.Material.WoodPlanks)
	roof.Orientation = Vector3.new(0, 0, 0)
	for _, dx in ipairs({ -10, 10 }) do
		part("ShackPost", Vector3.new(1, 6, 1), Color3.fromRGB(120, 80, 40),
			CFrame.new(-95 + dx, 3.5, -16), folder)
		part("ShackPost", Vector3.new(1, 6, 1), Color3.fromRGB(120, 80, 40),
			CFrame.new(-95 + dx, 3.5, -4), folder)
	end
	local egg = part("GoldenEgg", Vector3.new(3, 4, 3), Color3.fromRGB(255, 210, 60),
		CFrame.new(-95, 3, -10), folder, Enum.Material.Neon, Enum.PartType.Ball)
	egg.CanCollide = false
	labelOn(base, "EGG SHACK — hatch a Secret!", Color3.fromRGB(255, 210, 60), 70)
end

function WorldBuilder.buildBoard()
	-- Leaderboard board beside the spawn, facing the plots.
	local board = part("LeaderboardBoard", Vector3.new(16, 10, 1),
		Color3.fromRGB(40, 40, 60), CFrame.new(30, 5, 96), Workspace, Enum.Material.SmoothPlastic)
	local gui = Instance.new("SurfaceGui")
	gui.Name = "LeaderboardGui"
	gui.Face = Enum.NormalId.Front
	gui.Parent = board
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0.2, 0)
	title.BackgroundTransparency = 1
	title.Text = "RICHEST IN THE BAY"
	title.TextColor3 = Color3.fromRGB(255, 210, 60)
	title.TextScaled = true
	title.Font = Enum.Font.FredokaOne
	title.Parent = gui
	for i = 1, 5 do
		local row = Instance.new("TextLabel")
		row.Name = "Row" .. i
		row.Position = UDim2.new(0, 0, 0.2 + (i - 1) * 0.16, 0)
		row.Size = UDim2.new(1, 0, 0.16, 0)
		row.BackgroundTransparency = 1
		row.Text = i .. ". —"
		row.TextColor3 = Color3.fromRGB(255, 255, 255)
		row.TextScaled = true
		row.Font = Enum.Font.SourceSansBold
		row.Parent = gui
	end
end

function WorldBuilder.build()
	WorldBuilder.buildPlots()
	WorldBuilder.buildNature()
	WorldBuilder.buildShack()
	WorldBuilder.buildBoard()
end

return WorldBuilder
