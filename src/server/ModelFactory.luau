-- ModelFactory: builds every brainrot as a real 3D Model of parts, so the
-- characters the player sees on the conveyor and on a base are the same
-- geometry the place file holds, not a flat picture. Each model gets a
-- HumanoidRootPart-free anchored body, a face, an accessory, and a
-- BillboardGui label with its name, rarity and $/s.

local ModelFactory = {}

local function part(name, size, color, shape, parent)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Color = color
	p.Shape = shape or Enum.PartType.Block
	p.Material = Enum.Material.SmoothPlastic
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.Parent = parent
	return p
end

-- Body shapes: one builder per silhouette. `s` is the scale from the config.
local function buildLog(model, primary, secondary, s)
	local body = part("Body", Vector3.new(2.2 * s, 3.4 * s, 2.2 * s), primary, Enum.PartType.Cylinder, model)
	body.CFrame = CFrame.new(0, 1.7 * s, 0) * CFrame.Angles(0, 0, math.rad(90))
	local face = part("Face", Vector3.new(2.3 * s, 1.2 * s, 0.2 * s), secondary, Enum.PartType.Block, model)
	face.CFrame = CFrame.new(0, 2.6 * s, 1.1 * s)
	local eyeL = part("EyeL", Vector3.new(0.3 * s, 0.4 * s, 0.2 * s), Color3.fromRGB(255, 255, 255), Enum.PartType.Ball, model)
	eyeL.CFrame = CFrame.new(-0.5 * s, 2.8 * s, 1.2 * s)
	local eyeR = part("EyeR", Vector3.new(0.3 * s, 0.4 * s, 0.2 * s), Color3.fromRGB(255, 255, 255), Enum.PartType.Ball, model)
	eyeR.CFrame = CFrame.new(0.5 * s, 2.8 * s, 1.2 * s)
	return body
end

local function buildMonkey(model, primary, secondary, s)
	local body = part("Body", Vector3.new(2.4 * s, 2.6 * s, 1.8 * s), primary, Enum.PartType.Ball, model)
	body.CFrame = CFrame.new(0, 1.6 * s, 0)
	local head = part("Head", Vector3.new(1.8 * s, 1.6 * s, 1.6 * s), primary, Enum.PartType.Ball, model)
	head.CFrame = CFrame.new(0, 3.4 * s, 0)
	local muzzle = part("Muzzle", Vector3.new(1.2 * s, 0.8 * s, 0.6 * s), secondary, Enum.PartType.Ball, model)
	muzzle.CFrame = CFrame.new(0, 3.1 * s, 0.8 * s)
	local earL = part("EarL", Vector3.new(0.5 * s, 0.7 * s, 0.4 * s), secondary, Enum.PartType.Ball, model)
	earL.CFrame = CFrame.new(-1 * s, 3.6 * s, 0)
	local earR = part("EarR", Vector3.new(0.5 * s, 0.7 * s, 0.4 * s), secondary, Enum.PartType.Ball, model)
	earR.CFrame = CFrame.new(1 * s, 3.6 * s, 0)
	return body
end

local function buildShark(model, primary, secondary, s)
	local body = part("Body", Vector3.new(2.0 * s, 1.6 * s, 4.2 * s), primary, Enum.PartType.Block, model)
	body.CFrame = CFrame.new(0, 1.4 * s, 0)
	local nose = part("Nose", Vector3.new(1.6 * s, 1.2 * s, 1.2 * s), primary, Enum.PartType.Wedge, model)
	nose.CFrame = CFrame.new(0, 1.4 * s, 2.6 * s)
	local belly = part("Belly", Vector3.new(1.7 * s, 0.9 * s, 3.6 * s), secondary, Enum.PartType.Block, model)
	belly.CFrame = CFrame.new(0, 0.9 * s, 0)
	local fin = part("Fin", Vector3.new(0.3 * s, 1.4 * s, 1.2 * s), primary, Enum.PartType.Wedge, model)
	fin.CFrame = CFrame.new(0, 2.6 * s, -0.4 * s)
	local tail = part("Tail", Vector3.new(0.3 * s, 1.6 * s, 1.4 * s), primary, Enum.PartType.Wedge, model)
	tail.CFrame = CFrame.new(0, 1.6 * s, -2.6 * s) * CFrame.Angles(0, math.rad(180), 0)
	return body
end

local function buildQuadruped(model, primary, secondary, s, tall)
	local body = part("Body", Vector3.new(2.2 * s, 1.8 * s, 3.6 * s), primary, Enum.PartType.Block, model)
	body.CFrame = CFrame.new(0, 1.6 * s, 0)
	local head = part("Head", Vector3.new(1.8 * s, 1.8 * s, 1.8 * s), primary, Enum.PartType.Block, model)
	head.CFrame = CFrame.new(0, (tall and 3.6 or 2.6) * s, 1.9 * s)
	local snout = part("Snout", Vector3.new(1.2 * s, 0.9 * s, 0.9 * s), secondary, Enum.PartType.Block, model)
	snout.CFrame = CFrame.new(0, (tall and 3.3 or 2.3) * s, 2.9 * s)
	for i, dx in ipairs({ -0.8, 0.8 }) do
		for _, dz in ipairs({ -1.3, 1.3 }) do
			local leg = part("Leg" .. i .. dz, Vector3.new(0.5 * s, 1.0 * s, 0.5 * s), secondary, Enum.PartType.Block, model)
			leg.CFrame = CFrame.new(dx * s, 0.5 * s, dz * s)
		end
	end
	return body
end

local function buildCup(model, primary, secondary, s)
	local cup = part("Body", Vector3.new(2.2 * s, 2.8 * s, 2.2 * s), primary, Enum.PartType.Cylinder, model)
	cup.CFrame = CFrame.new(0, 1.6 * s, 0)
	local foam = part("Foam", Vector3.new(2.3 * s, 0.6 * s, 2.3 * s), secondary, Enum.PartType.Cylinder, model)
	foam.CFrame = CFrame.new(0, 3.1 * s, 0)
	local handle = part("Handle", Vector3.new(0.4 * s, 1.4 * s, 0.4 * s), secondary, Enum.PartType.Block, model)
	handle.CFrame = CFrame.new(1.3 * s, 1.6 * s, 0)
	return cup
end

local function buildDancer(model, primary, secondary, s)
	local torso = part("Body", Vector3.new(1.6 * s, 2.2 * s, 1.2 * s), primary, Enum.PartType.Block, model)
	torso.CFrame = CFrame.new(0, 1.8 * s, 0)
	local head = part("Head", Vector3.new(1.6 * s, 1.6 * s, 1.6 * s), secondary, Enum.PartType.Ball, model)
	head.CFrame = CFrame.new(0, 3.6 * s, 0)
	local leg = part("Leg", Vector3.new(0.5 * s, 1.6 * s, 0.5 * s), primary, Enum.PartType.Cylinder, model)
	leg.CFrame = CFrame.new(0, 0.8 * s, 0)
	return torso
end

local BUILDERS = {
	log = buildLog,
	monkey = buildMonkey,
	shark = buildShark,
	croc = function(m, p, s2, s) return buildQuadruped(m, p, s2, s, false) end,
	elephant = function(m, p, s2, s) return buildQuadruped(m, p, s2, s, true) end,
	tree = buildMonkey,
	cup = buildCup,
	dancer = buildDancer,
	giraffe = function(m, p, s2, s) return buildQuadruped(m, p, s2, s, true) end,
	camel = function(m, p, s2, s) return buildQuadruped(m, p, s2, s, true) end,
	cow = function(m, p, s2, s) return buildQuadruped(m, p, s2, s, false) end,
}

-- Accessories: one small prop that sells the joke.
local function addAccessory(model, kind, primary, secondary, s)
	if kind == "bat" then
		local bat = part("Bat", Vector3.new(0.4 * s, 2.2 * s, 0.4 * s), secondary, Enum.PartType.Cylinder, model)
		bat.CFrame = CFrame.new(1.4 * s, 2.0 * s, 0) * CFrame.Angles(0, 0, math.rad(-30))
	elseif kind == "banana" then
		local b = part("Banana", Vector3.new(0.4 * s, 1.4 * s, 0.4 * s), Color3.fromRGB(255, 220, 90), Enum.PartType.Cylinder, model)
		b.CFrame = CFrame.new(1.2 * s, 2.4 * s, 0.6 * s) * CFrame.Angles(math.rad(40), 0, 0)
	elseif kind == "sneakers" then
		for _, dx in ipairs({ -0.7, 0.7 }) do
			local shoe = part("Sneaker", Vector3.new(0.7 * s, 0.5 * s, 1.4 * s), Color3.fromRGB(255, 255, 255), Enum.PartType.Block, model)
			shoe.CFrame = CFrame.new(dx * s, 0.3 * s, 0.4 * s)
		end
	elseif kind == "propeller" then
		local prop = part("Propeller", Vector3.new(2.6 * s, 0.3 * s, 0.3 * s), Color3.fromRGB(220, 220, 220), Enum.PartType.Block, model)
		prop.CFrame = CFrame.new(0, 2.2 * s, 2.6 * s)
	elseif kind == "cactus" then
		local c = part("Cactus", Vector3.new(0.6 * s, 1.6 * s, 0.6 * s), Color3.fromRGB(60, 160, 60), Enum.PartType.Cylinder, model)
		c.CFrame = CFrame.new(0, 4.2 * s, 0)
	elseif kind == "nose" then
		local n = part("Nose", Vector3.new(1.0 * s, 0.7 * s, 0.7 * s), Color3.fromRGB(200, 120, 60), Enum.PartType.Ball, model)
		n.CFrame = CFrame.new(0, 3.2 * s, 1.0 * s)
	elseif kind == "katana" then
		local k = part("Katana", Vector3.new(0.2 * s, 2.6 * s, 0.2 * s), Color3.fromRGB(200, 200, 220), Enum.PartType.Block, model)
		k.CFrame = CFrame.new(1.3 * s, 2.2 * s, 0) * CFrame.Angles(0, 0, math.rad(25))
	elseif kind == "tutu" then
		local t = part("Tutu", Vector3.new(2.8 * s, 0.3 * s, 2.8 * s), Color3.fromRGB(255, 220, 235), Enum.PartType.Cylinder, model)
		t.CFrame = CFrame.new(0, 1.0 * s, 0)
	elseif kind == "halo" then
		local h = part("Halo", Vector3.new(2.0 * s, 0.3 * s, 2.0 * s), Color3.fromRGB(255, 230, 120), Enum.PartType.Cylinder, model)
		h.CFrame = CFrame.new(0, 5.0 * s, 0)
	elseif kind == "fridge" then
		local f = part("Fridge", Vector3.new(1.8 * s, 2.4 * s, 1.0 * s), Color3.fromRGB(220, 230, 240), Enum.PartType.Block, model)
		f.CFrame = CFrame.new(0, 2.6 * s, -1.6 * s)
	elseif kind == "rings" then
		local r = part("Rings", Vector3.new(4.4 * s, 0.25 * s, 4.4 * s), Color3.fromRGB(255, 210, 90), Enum.PartType.Cylinder, model)
		r.CFrame = CFrame.new(0, 1.6 * s, 0)
	end
end

-- Builds a brainrot model at `cframe`. Returns the Model; its PrimaryPart
-- is the body, and it carries StringValues (BrainrotId, Mutation) plus a
-- BillboardGui label the player can read at a glance.
function ModelFactory.build(brainrot, mutation, cframe, labelRate)
	local model = Instance.new("Model")
	model.Name = brainrot.name

	local builder = BUILDERS[brainrot.body] or buildLog
	local body = builder(model, brainrot.primary, brainrot.secondary, brainrot.size)
	addAccessory(model, brainrot.accessory, brainrot.primary, brainrot.secondary, brainrot.size)

	model.PrimaryPart = body
	model:PivotTo(cframe)

	local idValue = Instance.new("StringValue")
	idValue.Name = "BrainrotId"
	idValue.Value = brainrot.id
	idValue.Parent = model

	local mutValue = Instance.new("StringValue")
	mutValue.Name = "Mutation"
	mutValue.Value = mutation.name
	mutValue.Parent = model

	local gui = Instance.new("BillboardGui")
	gui.Name = "BrainrotLabel"
	gui.Size = UDim2.fromOffset(220, 64)
	gui.StudsOffset = Vector3.new(0, 5.2 * brainrot.size, 0)
	gui.AlwaysOnTop = true
	gui.Parent = model

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Size = UDim2.fromScale(1, 0.45)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = brainrot.name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextStrokeTransparency = 0
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.FredokaOne
	nameLabel.Parent = gui

	local rateLabel = Instance.new("TextLabel")
	rateLabel.Name = "RateLabel"
	rateLabel.Position = UDim2.fromScale(0, 0.45)
	rateLabel.Size = UDim2.fromScale(1, 0.55)
	rateLabel.BackgroundTransparency = 1
	local shown = labelRate or brainrot.rate
	rateLabel.Text = string.format("$%d/s  •  %s", shown, mutation.name)
	rateLabel.TextColor3 = mutation.color
	rateLabel.TextStrokeTransparency = 0
	rateLabel.TextScaled = true
	rateLabel.Font = Enum.Font.SourceSansBold
	rateLabel.Parent = gui

	return model
end

return ModelFactory
