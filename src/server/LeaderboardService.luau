-- LeaderboardService: the "RICHEST IN THE BAY" board beside the spawn.
-- Once every five seconds it ranks every player by cash and writes the
-- top five onto the board's SurfaceGui, with rebirth badges.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LeaderboardService = {}

local function formatCash(n)
	if n >= 1000000 then
		return string.format("$%.1fM", n / 1000000)
	elseif n >= 1000 then
		return string.format("$%.1fK", n / 1000)
	else
		return "$" .. tostring(n)
	end
end

function LeaderboardService.init()
	task.spawn(function()
		while true do
			task.wait(5)
			local board = Workspace:FindFirstChild("LeaderboardBoard")
			if not board then
				continue
			end
			local gui = board:FindFirstChild("LeaderboardGui")
			if not gui then
				continue
			end
			local ranked = {}
			for _, player in ipairs(Players:GetPlayers()) do
				local stats = player:FindFirstChild("leaderstats")
				local cash = stats and stats:FindFirstChild("Cash")
				local rebirths = stats and stats:FindFirstChild("Rebirths")
				if cash then
					table.insert(ranked, {
						name = player.DisplayName,
						cash = cash.Value,
						rebirths = rebirths and rebirths.Value or 0,
					})
				end
			end
			table.sort(ranked, function(a, b)
				return a.cash > b.cash
			end)
			for i = 1, 5 do
				local row = gui:FindFirstChild("Row" .. i)
				if row then
					local entry = ranked[i]
					if entry then
						local badge = ""
						if entry.rebirths > 0 then
							badge = string.format("  [x%d Rebirth]", entry.rebirths)
						end
						row.Text = string.format("%d. %s  %s%s", i, entry.name, formatCash(entry.cash), badge)
					else
						row.Text = i .. ". —"
					end
				end
			end
		end
	end)
end

return LeaderboardService
