--- Require ---
local util = require("lib.self.util")
--- ==== ---


--- Classes ---
local Game = require("objects.game.game")

local Song = require("objects.game.song")
--- ==== ---


--- Gamestate definition ---
local game = {}
--- ==== ---


--- Gamestate functions ---
function game:init()

end

function game:enter(prev, ...)
	self.game = Game{
		level = require("levels.001_keepitsimple"),
		music = Song("music/laserwash.ogg"),
		theme = require("themes.hueshift")(),

		n_players = 3,
		speed = 1
	}
end

function game:update(dt)
	self.game:update(dt)
end

function game:draw()
	self.game:draw()
end

function game:keypressed(key)
	self.game:keypressed(key)
end

function game:mousepressed(x, y, b)
	if b == "wu" then
		self.game.speed = util.math.clamp(0, self.game.speed + 0.2, 7)
	elseif b == "wd" then
		self.game.speed = util.math.clamp(0, self.game.speed - 0.2, 7)
	end
end
--- ==== ---


return game
