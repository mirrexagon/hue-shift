--[[
	Hue Shift, a game by LegoSpacy
]]

--[[
	TODO:
		Record scores
		Proper quantified levels
		Challenges - time limit, limited number of moves?
]]

gs = require("lib.hump.gamestate")

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
