--[[
	Hue Shift, a game by LegoSpacy

	---

	Music:
		laserwash by coda (http://coda.s3m.us)
]]

--[[
	TODO:
		Randomise player starting positions
		Add pause before game start to show player block positions

		---

		Record scores
		Obstacle AI

		Add modifiers/challenges row, has things like:
			+ Wrong goal block is obstacle
			+ Time limit, step limit, etc
			+ Game speed

		Effects:
			Screen shake - a shake happens every beat, specify intensity level per song?
			Background flashing - also every beat?
			Grid scaling - as above

		Achievements?
		More backgrounds? Set by music?
]]

gs = require("lib.hump.gamestate")
local util = require("lib.self.util")

bg = require("logic.background")

---

state_menu = require("states.menu")
state_game = require("states.game")

---

GRID_BACKGROUND_ALPHA = 128
GRID_LINES_ALPHA = 255
BG_ALPHA = 200

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

MUSIC = {
	{
		name = "coda - laserwash",
		path = "music/laserwash.ogg",
		bpm = 90
	}
}

---

DIRECTION_MAPPING = {
	up = {x = 0, y = -1},
	right = {x = 1, y = 0},
	down = {x = 0, y = 1},
	left = {x = -1, y = 0}
}

---

function love.load()
	gs.registerEvents()

	bg.set_timer(love.math.random(0, 300))

	gs.switch(state_menu)
end
