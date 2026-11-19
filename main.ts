// Tung Tung Bay — Steal a Brainrot (roblox-brainrot-01 entrypoint, Node 22).
//
// The game is a Rojo project: `rojo build default.project.json --output
// game.rbxl` builds the place from src/ and default.project.json, and this
// program hands it in. It copies game.rbxl, src/, screenshots/ and
// PLAY.json from beside this file into /output (or $MAKEFUN_OUTPUT_DIR
// when run locally) and writes /output/dossier.json with the vendored
// make.fun library, so the gate can check the place, the scripts and the
// dossier byte for byte.
//
// Every name under /output must start with a letter, a digit or _ and hold
// only letters, digits, . _ and -: a dot-file such as .gitkeep or
// .DS_Store anywhere under it fails the entry, so the copies below skip
// every name that starts with a dot, at any depth.
//
// Run it the way the grader does, writing out/ in place of /output:
//
//   mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts

import { copyFileSync, cpSync, existsSync, mkdirSync, readdirSync, readFileSync, statSync, writeFileSync } from "node:fs";
import { basename, join } from "node:path";
import { fileURLToPath } from "node:url";
import { buildDossier } from "./vendor/makefun-roblox.ts";

const here = fileURLToPath(new URL(".", import.meta.url));
const out = process.env.MAKEFUN_OUTPUT_DIR ?? "/output";

/** cpSync filter: leave out every file and directory whose name starts with a dot. */
const notDotted = (path: string): boolean => !basename(path).startsWith(".");

function fail(message: string): never {
	throw new Error(`tung-tung-bay main.ts: ${message}`);
}

// The play link is a single file; the sources and the screenshots are
// trees. All four must be present before anything is copied, so a
// half-built entry never reaches /output. PLAY.json must at least parse:
// the gate refuses a link whose ids are not positive whole numbers, and
// a malformed file should fail here, loudly, instead of at the gate.
for (const name of ["game.rbxl", "PLAY.json"]) {
	if (!existsSync(join(here, name))) fail(`missing ${name}: run \`rojo build\` first`);
}
try {
	const play = JSON.parse(readFileSync(join(here, "PLAY.json"), "utf8")) as {
		url?: unknown;
		place_id?: unknown;
		universe_id?: unknown;
	};
	if (typeof play.url !== "string" || !play.url.startsWith("https://www.roblox.com/games/")) {
		fail("PLAY.json url is not a Roblox games link");
	}
	if (!Number.isSafeInteger(play.place_id) || !Number.isSafeInteger(play.universe_id)) {
		fail("PLAY.json place_id / universe_id are not whole numbers");
	}
	if (play.place_id === 0 || play.universe_id === 0) {
		console.warn("tung-tung-bay: PLAY.json still names place 0 — PENDING-PUBLISH, fill it in after publishing");
	}
} catch (err) {
	if (err instanceof Error && err.message.startsWith("tung-tung-bay")) throw err;
	fail(`PLAY.json does not parse: ${(err as Error).message}`);
}
for (const dir of ["src", "screenshots"]) {
	if (!existsSync(join(here, dir))) fail(`missing ${dir}/`);
}

// Screenshots: the gate takes 3 or 4, each at most 256 KiB. Refuse early
// with a readable message instead of handing in a doomed entry.
const shots = readdirSync(join(here, "screenshots")).filter((n) => !n.startsWith("."));
if (shots.length < 3 || shots.length > 4) fail(`screenshots/ holds ${shots.length} images, the gate takes 3 or 4`);
for (const shot of shots) {
	const size = statSync(join(here, "screenshots", shot)).size;
	if (size > 262144) fail(`screenshots/${shot} is ${size} bytes, over the 256 KiB cap`);
}

mkdirSync(out, { recursive: true });
copyFileSync(join(here, "game.rbxl"), join(out, "game.rbxl"));
copyFileSync(join(here, "PLAY.json"), join(out, "PLAY.json"));
cpSync(join(here, "src"), join(out, "src"), { recursive: true, filter: notDotted });
mkdirSync(join(out, "screenshots"), { recursive: true });
cpSync(join(here, "screenshots"), join(out, "screenshots"), { recursive: true, filter: notDotted });

// The scorer's own caps: only text_max_bytes shapes the bytes; the rest
// refuse an entry the scorer would refuse (more than 4 screenshots or one
// over 256 KiB; a place of more than 500000 instances, scripts over 8 MiB
// of source or over 1048576 characters of paths, in all).
writeFileSync(
	join(out, "dossier.json"),
	buildDossier(out, {
		text_max_bytes: 65536,
		screenshots: { max: 4, max_bytes: 262144 },
		max_instances: 500000,
		scripts_max_source_bytes: 8388608,
		scripts_max_path_chars: 1048576,
	}),
);

console.log(`tung-tung-bay: handed in ${shots.length} screenshots to ${out}`);
console.log(`tung-tung-bay: dossier is ${statSync(join(out, "dossier.json")).size} bytes`);
