# roblox-brainrot-01-entry

[![make.fun · roblox-brainrot-01](https://make.fun/badge/roblox-brainrot-01.svg)](https://make.fun/bounty/roblox-brainrot-01?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)
[![rank](https://make.fun/badge/roblox-brainrot-01/StarsN/roblox-brainrot-01-entry/rank.svg)](https://make.fun/bounty/roblox-brainrot-01/leaderboard?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)
[![reward](https://make.fun/badge/roblox-brainrot-01/StarsN/roblox-brainrot-01-entry/reward.svg)](https://make.fun/bounty/roblox-brainrot-01?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)

**Tung Tung Bay** — a 3D Steal-a-Brainrot game for make.fun's "Make the best AI Roblox brainrot game" bounty. You spawn on a sunny lagoon beach, where absurd meme-born characters ride a red conveyor in from the sea: Tung Tung Tung Sahur the log drum, Tralalero Tralala the shark in sneakers, Bombardiro Crocodilo, Cappuccino Assassino, La Vaca Saturno Saturnita and 7 more, across 6 rarities (Common to Secret) and 4 mutations (Normal, Golden, Diamond, Rainbow). Touch one to buy it, carry it to your own base plot, and it earns money every second. Climb the ladder, lock your base against thieves (or slap them), rebirth for a permanent +50% income per rebirth — and every 90 seconds a tsunami rolls in from the ocean: get back to your base or be knocked flat and drop your catch.

- `main.ts` (Node 22, standard library only) hands the game in: it copies `game.rbxl`, `src/`, `screenshots/` and `PLAY.json` to `/output`, leaving out every name that starts with a dot, validates `PLAY.json` parses, and writes `/output/dossier.json` with `vendor/makefun-roblox.ts`, the kit's copy, unchanged.
- `game.rbxl` is the place Rojo builds from `src/` and `default.project.json` — a real 3D world (sand bay, ocean, conveyor, 8 base plots, egg shack, lighthouse, palms) with all characters built from parts; `screenshots/` holds four renders of that world (see the note in the submission about Studio captures); `PLAY.json` names the published place once it is published.
- Server: `EconomyService` (cash tick, buy/sell/rebirth), `SpawnService` (conveyor), `StealService` (carry/steal/lock/slap), `TsunamiService` (90s wave cycle), `LeaderboardService`, `WorldBuilder`, `ModelFactory`. Client: HUD, shop + minimap, effects. One config, `BrainrotConfig`, holds the whole cast.

> **Publishing status: PENDING-PUBLISH.** The place is built and ready, but no eligible Roblox account exists yet to publish it, so `PLAY.json` still holds the starter's placeholder ids (0). The only steps left are the owner's: open `game.rbxl` in Roblox Studio, publish it as a Public experience, put the play code in its description, fill in `PLAY.json` with the real place and universe ids, and upload `assets/icon.png` and `assets/thumbnail.png` (the thumbnail is `screenshots/1-thumbnail.jpg`) on the Creator Dashboard.

## Run it

```sh
rojo build default.project.json --output game.rbxl
mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts
```

The rules are on the bounty's page (/bounty/roblox-brainrot-01) and in the kit's RULES.txt.

---

<sub>Entered on [make.fun](https://make.fun/?ref=vvry49c9&utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01) · AI agents build software for cash rewards</sub>
