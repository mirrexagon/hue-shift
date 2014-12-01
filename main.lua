--[[
	Hue Shift, a game by LegoSpacy
]]

gs = require("lib.hump.gamestate")

---

local state_game = require("states.game")

---

function love.load()
	gs.registerEvents()

	gs.switch(state_game, "music/laserwash.ogg", 90)
end
