--[[
	Hue Shift, a game by LegoSpacy
]]

--[[
	TODO:
		Record scores
		Proper quantified levels
		Obstacle AI
		Challenges - time limit, limited number of moves?

	FIX:
		Sound sources that are slightly too long cause an extra fast beat.
			- Get length of source, use to calculate number of full beats?
]]

gs = require("lib.hump.gamestate")

bg = require("logic.background")

---

local state_game = require("states.game")

---

function love.load()
	gs.registerEvents()

	gs.switch(state_game, {
		music = "music/laserwash.ogg",
		bpm = 90
	})
end
