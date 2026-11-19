-- BrainrotConfig: the single source of truth for Tung Tung Bay.
-- Every brainrot, rarity, mutation and rebirth tier lives here, so the
-- server (economy, spawner, stealing) and the client (shop, HUD) can never
-- disagree about a price or a payout. All characters are original to this
-- game: absurd meme-born creatures of Tung Tung Bay, an Italian-brainrot
-- style lagoon where a log drum, a shark in sneakers and a crocodile bomber
-- all wash up on the same beach.

local BrainrotConfig = {}

-- Rarities, cheapest first. Weight is the conveyor spawn weight; a lower
-- weight means a rarer catch. Colour is the rarity's label colour.
BrainrotConfig.RARITIES = {
	{ name = "Common",    weight = 40, color = Color3.fromRGB(180, 180, 180) },
	{ name = "Rare",      weight = 25, color = Color3.fromRGB(80, 170, 255) },
	{ name = "Epic",      weight = 16, color = Color3.fromRGB(170, 90, 255) },
	{ name = "Legendary", weight = 10, color = Color3.fromRGB(255, 190, 40) },
	{ name = "Mythic",    weight = 6,  color = Color3.fromRGB(255, 70, 120) },
	{ name = "Secret",    weight = 3,  color = Color3.fromRGB(60, 255, 200) },
}

-- Mutations roll on every spawn. Multiplier applies to $/s.
BrainrotConfig.MUTATIONS = {
	{ name = "Normal",  chance = 70, multiplier = 1, color = Color3.fromRGB(255, 255, 255) },
	{ name = "Golden",  chance = 18, multiplier = 2, color = Color3.fromRGB(255, 210, 60) },
	{ name = "Diamond", chance = 9,  multiplier = 4, color = Color3.fromRGB(120, 220, 255) },
	{ name = "Rainbow", chance = 3,  multiplier = 8, color = Color3.fromRGB(255, 120, 220) },
}

-- The cast. cost is what a player pays to buy one off the conveyor;
-- rate is the $/s it earns once it stands on a base. body describes the
-- model ModelFactory builds from parts: shape, colours and accessory.
BrainrotConfig.BRAINROTS = {
	{
		id = "tungtung", name = "Tung Tung Tung Sahur", rarity = "Common",
		cost = 100, rate = 5,
		blurb = "A log drum that never stops knocking. The bay's alarm clock.",
		body = "log", primary = Color3.fromRGB(139, 90, 43), secondary = Color3.fromRGB(90, 55, 20),
		accessory = "bat", size = 1.0,
	},
	{
		id = "chimpanzini", name = "Chimpanzini Bananini", rarity = "Common",
		cost = 250, rate = 9,
		blurb = "A chimp that peels a banana and peels the market too.",
		body = "monkey", primary = Color3.fromRGB(120, 80, 40), secondary = Color3.fromRGB(255, 220, 90),
		accessory = "banana", size = 0.9,
	},
	{
		id = "tralalero", name = "Tralalero Tralala", rarity = "Rare",
		cost = 1200, rate = 28,
		blurb = "A shark in sneakers. It swims the conveyor and sings off-key.",
		body = "shark", primary = Color3.fromRGB(90, 140, 220), secondary = Color3.fromRGB(240, 240, 240),
		accessory = "sneakers", size = 1.1,
	},
	{
		id = "bombardiro", name = "Bombardiro Crocodilo", rarity = "Rare",
		cost = 2200, rate = 45,
		blurb = "A crocodile bomber plane. Drops beats, never bombs. Mostly.",
		body = "croc", primary = Color3.fromRGB(70, 160, 70), secondary = Color3.fromRGB(200, 220, 120),
		accessory = "propeller", size = 1.2,
	},
	{
		id = "lirili", name = "Lirili Larila", rarity = "Epic",
		cost = 6000, rate = 95,
		blurb = "A cactus elephant. Prickly, patient, and weirdly rich.",
		body = "elephant", primary = Color3.fromRGB(90, 180, 90), secondary = Color3.fromRGB(220, 190, 150),
		accessory = "cactus", size = 1.3,
	},
	{
		id = "patapim", name = "Brr Brr Patapim", rarity = "Epic",
		cost = 9000, rate = 140,
		blurb = "A tree with a monkey's grin. It hums when the tide comes in.",
		body = "tree", primary = Color3.fromRGB(110, 80, 40), secondary = Color3.fromRGB(80, 180, 80),
		accessory = "nose", size = 1.3,
	},
	{
		id = "cappuccino", name = "Cappuccino Assassino", rarity = "Legendary",
		cost = 25000, rate = 320,
		blurb = "A coffee cup with a katana. Stealthy. Frothy. Dangerous.",
		body = "cup", primary = Color3.fromRGB(240, 230, 210), secondary = Color3.fromRGB(120, 70, 30),
		accessory = "katana", size = 1.2,
	},
	{
		id = "ballerina", name = "Ballerina Cappuccina", rarity = "Legendary",
		cost = 40000, rate = 480,
		blurb = "A ballerina with a cappuccino head. Pirouettes past the poor.",
		body = "dancer", primary = Color3.fromRGB(255, 200, 220), secondary = Color3.fromRGB(120, 70, 30),
		accessory = "tutu", size = 1.1,
	},
	{
		id = "giraffa", name = "Giraffa Celeste", rarity = "Mythic",
		cost = 120000, rate = 950,
		blurb = "A celestial giraffe. Its spots are constellations.",
		body = "giraffe", primary = Color3.fromRGB(255, 210, 120), secondary = Color3.fromRGB(120, 180, 255),
		accessory = "halo", size = 1.6,
	},
	{
		id = "frigo", name = "Frigo Camelo", rarity = "Mythic",
		cost = 200000, rate = 1500,
		blurb = "A camel that is also a fridge. Cold drinks, colder deals.",
		body = "camel", primary = Color3.fromRGB(200, 220, 240), secondary = Color3.fromRGB(180, 120, 60),
		accessory = "fridge", size = 1.6,
	},
	{
		id = "vaca", name = "La Vaca Saturno Saturnita", rarity = "Secret",
		cost = 500000, rate = 3200,
		blurb = "A cow ringed like Saturn. The bay's rarest moo.",
		body = "cow", primary = Color3.fromRGB(240, 240, 240), secondary = Color3.fromRGB(60, 60, 60),
		accessory = "rings", size = 1.8,
	},
	{
		id = "tralaleritos", name = "Los Tralaleritos", rarity = "Secret",
		cost = 900000, rate = 5500,
		blurb = "Three tiny sharks, one huge attitude. A school of profit.",
		body = "shark", primary = Color3.fromRGB(255, 120, 160), secondary = Color3.fromRGB(240, 240, 240),
		accessory = "sneakers", size = 0.8,
	},
}

-- Rebirth: pay cash, lose your cash and your brainrots, keep a permanent
-- +50% income multiplier per rebirth and a badge on the leaderboard.
BrainrotConfig.REBIRTH_COSTS = { 50000, 250000, 1000000, 5000000, 25000000 }
BrainrotConfig.REBIRTH_BONUS = 0.5 -- +50% $/s per rebirth

-- The map: 8 base plots in a row along the south beach, the conveyor
-- along the north beach, the egg shack on the west cliff.
BrainrotConfig.PLOT_COUNT = 8
BrainrotConfig.PLOT_SIZE = Vector3.new(24, 1, 20)
BrainrotConfig.PLOT_CENTERS = {}
for i = 1, BrainrotConfig.PLOT_COUNT do
	BrainrotConfig.PLOT_CENTERS[i] = Vector3.new(-105 + (i - 1) * 30, 0.5, 70)
end
BrainrotConfig.PLOT_COLORS = {
	Color3.fromRGB(255, 120, 120), Color3.fromRGB(255, 180, 80),
	Color3.fromRGB(255, 230, 90), Color3.fromRGB(120, 220, 120),
	Color3.fromRGB(90, 180, 255), Color3.fromRGB(170, 120, 255),
	Color3.fromRGB(255, 140, 200), Color3.fromRGB(120, 230, 220),
}
BrainrotConfig.CONVEYOR_START = Vector3.new(-90, 1, -55)
BrainrotConfig.CONVEYOR_END = Vector3.new(90, 1, -55)
BrainrotConfig.CONVEYOR_SPEED = 6 -- studs per second along the belt
BrainrotConfig.SPAWN_INTERVAL = 4 -- seconds between conveyor spawns
BrainrotConfig.MAX_SLOTS_PER_PLOT = 6 -- brainrots a base can hold
BrainrotConfig.SELL_FRACTION = 0.7 -- selling returns 70% of the buy price
BrainrotConfig.START_CASH = 500
BrainrotConfig.TSUNAMI_PERIOD = 90 -- seconds between waves
BrainrotConfig.TSUNAMI_WARNING = 10 -- seconds of warning before the wave
BrainrotConfig.BASE_LOCK_SECONDS = 30 -- a lock blocks stealing for this long
BrainrotConfig.STEAL_CHANNEL_SECONDS = 3 -- hold still this long to steal one

function BrainrotConfig.getBrainrot(id)
	for _, b in ipairs(BrainrotConfig.BRAINROTS) do
		if b.id == id then
			return b
		end
	end
	return nil
end

function BrainrotConfig.getRarity(name)
	for _, r in ipairs(BrainrotConfig.RARITIES) do
		if r.name == name then
			return r
		end
	end
	return BrainrotConfig.RARITIES[1]
end

function BrainrotConfig.getMutation(name)
	for _, m in ipairs(BrainrotConfig.MUTATIONS) do
		if m.name == name then
			return m
		end
	end
	return BrainrotConfig.MUTATIONS[1]
end

-- Weighted roll over the cast: rarer brainrots appear less often.
function BrainrotConfig.rollBrainrot()
	local total = 0
	for _, b in ipairs(BrainrotConfig.BRAINROTS) do
		total += BrainrotConfig.getRarity(b.rarity).weight
	end
	local roll = math.random() * total
	for _, b in ipairs(BrainrotConfig.BRAINROTS) do
		roll -= BrainrotConfig.getRarity(b.rarity).weight
		if roll <= 0 then
			return b
		end
	end
	return BrainrotConfig.BRAINROTS[1]
end

function BrainrotConfig.rollMutation()
	local roll = math.random() * 100
	local acc = 0
	for _, m in ipairs(BrainrotConfig.MUTATIONS) do
		acc += m.chance
		if roll <= acc then
			return m
		end
	end
	return BrainrotConfig.MUTATIONS[1]
end

function BrainrotConfig.rebirthCost(rebirths)
	return BrainrotConfig.REBIRTH_COSTS[math.min(rebirths + 1, #BrainrotConfig.REBIRTH_COSTS)]
end

return BrainrotConfig
