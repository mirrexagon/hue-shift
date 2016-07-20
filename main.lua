--[[
	Hue Shift, a game by LegoSpacy

	---

	Music:
		Laserwash by coda (http://coda.s3m.us)
		Hue Shift by coda (http://coda.s3m.us)
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

	BUGS:
		On song loop, game is off by half a beat. This continues through all subsequent loops.
		Fading in and out doesn't look as nice as v2: fading the whole thing via a canvas looks bad.
			Should fade each element individually.

	TODO:
		Record scores
		Obstacle AI

		Add modifiers/challenges row, has things like:
			+ Wrong goal block is obstacle
			+ Time limit, step limit, etc
			+ Game speed
				+ Faster
				+ Changes randomly

	---

	Effects:
		Screen shake - a shake happens every beat, specify intensity level per song?
			Pattern specified by song?
		Background flashing - also every beat?
		Grid scaling - as above
]]


--- Require ---
local gamestate = require("lib.hump.gamestate")
local timer = require("lib.hump.timer")

local util = require("lib.self.util")
--- ==== ---


--- Gamestates ---
--local state_menu = require("states.menu")
local state_game = require("states.game")
--- ==== ---


--- Main love functions ---
function love.load()
	gamestate.registerEvents()
	gamestate.switch(state_game)
end

function love.update(dt)
	-- Update global timer.
	timer.update(dt)
end
--- ==== ---
