--[[
	Hue Shift v3, a game by LegoSpacy

	---

	Music:
		laserwash by coda (http://coda.s3m.us)
]]

--[[
	GAME:
		Levels are layouts of obstacles and player blocks. Obstacles may be static, moving or AI-controlled.
		The player can choose any song to play any level, and choose the number of player blocks.

		The layouts have a set grid size.
			Most should be a standard size, 7x7.

	MENU:


	THEMES:
		Changing theme makes background and block colors on menu fade to new theme

	---
	---

	BUGS:
		On song loop, game is off by half a beat. This continues through all subsequent loops.

	TODO:
		Show both blocks or indicate when two blocks overlap.

		Record scores
		Obstacle AI

		Add modifiers/challenges row, has things like:
			+ Wrong goal block is obstacle
			+ Time limit, step limit, etc
			+ Game speed
				+ Faster
				+ Changes randomly

		Effects:
			Screen shake - a shake happens every beat, specify intensity level per song?
				Pattern specified by song?
			Background flashing - also every beat?
			Grid scaling - as above

		Achievements?
		More backgrounds? Set by music?
]]

local gamestate = require("lib.hump.gamestate")
local timer = require("lib.hump.timer")

local util = require("lib.self.util")

---

--local state_menu = require("states.menu")
local state_game = require("states.game")

---

function love.load()
	gamestate.registerEvents()
	gamestate.switch(state_game)
end

function love.update(dt)
	--- Update global timer.
	timer.update(dt)
end
