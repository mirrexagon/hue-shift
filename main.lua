--[[
	Hue Shift, a game by LegoSpacy

	---

	Music:
		laserwash by coda (http://coda.s3m.us)
]]

--[[
	GAME:
		Levels are layouts of obstacles and player blocks. Obstacles may be static, moving or AI-controlled.
		The player can choose any song to play any level, and choose the number of player blocks.

		The layouts have a set grid size.
			Most should be a standard size, maybe 7x7.

	LAYOUTS:
		A table representing a grid, or a list of entities? Simplified list of entities?

	---
	---

	TODO:
		Add pause before game start to show player block positions
		Make each song be able to override the background, so you can have backgrounds flashing to the song.


		---

		Record scores
		Obstacle AI

		Add modifiers/challenges row, has things like:
			+ Wrong goal block is obstacle
			+ Time limit, step limit, etc
			+ Game speed

		Effects:
			Screen shake - a shake happens every beat, specify intensity level per song?
				Pattern specified by song?
			Background flashing - also every beat?
			Grid scaling - as above

		Achievements?
		More backgrounds? Set by music?
]]

gs = require("lib.hump.gamestate")
local util = require("lib.self.util")

bg = require("backgrounds.hueshift")

---

state_menu = require("states.menu")
state_game = require("states.game")

---

DIRECTION_MAPPING = {
	up = {x = 0, y = -1},
	right = {x = 1, y = 0},
	down = {x = 0, y = 1},
	left = {x = -1, y = 0}
}

---

GRID_BACKGROUND_ALPHA = 128
GRID_LINES_ALPHA = 255
BG_ALPHA = 160

TRANSITION_DURATION = 0.3

DEFAULT_TILE_LENGTH = 32
DEFAULT_TILE_PAD = 2

BLOCK_CONTROLS = {
	[1] = {
		up = "w",
		right = "d",
		down = "s",
		left = "a"
	},
	[2] = {
		up = "t",
		right = "h",
		down = "g",
		left = "f"
	},
	[3] = {
		up = "i",
		right = "l",
		down = "k",
		left = "j"
	}
}

BLOCK_COLORS = {
	[1] = {255, 0, 0},
	[2] = {0, 255, 0},
	[3] = {0, 0, 255}
}

---

MUSIC = require("music")

LEVELS = require("levels")

---

function love.load()
	gs.registerEvents()

	bg.set_timer(love.math.random(0, 300))

	gs.switch(state_menu)
end