--- Require ---
local gamestate = require("lib.hump.gamestate")
local timer = require("lib.hump.timer")

local util = require("lib.self.util")
--- ==== ---


--- Classes ---
local Game = require("objects.game.game")

local Song = require("objects.game.song")
--- ==== ---


--- Gamestate definition ---
local game = {}
--- ==== ---


--- Constants ---
local TRANSITION_DUR = 0.5
--- ==== ---


--- Gamestate functions ---
function game:init()

end

function game:fadein()
	self.state = "fadein"

	self.tween = timer.tween(TRANSITION_DUR, self.game, {alpha = 1}, "linear", function()
		self.state = "game"
		self.game:start()
	end)
end

function game:fadeout(after)
	self.state = "fadeout"

	self.tween = timer.tween(TRANSITION_DUR, self.game, {alpha = 0}, "linear", function()
		after(self)
	end)
end

function game:enter(prev, args)
	self.game = Game{
		level = require("levels.001_relax"),
		music = Song("music/laserwash.ogg"),
		theme = require("themes.hueshift")(),

		n_players = 2,
		speed = 1
	}

	self.state = "fadein" -- fadein, game, fadeout
	self.game.alpha = 0

	self:fadein()
end

function game:exit()
	love.event.quit()
end

function game:update(dt)
	if self.state == "game" then
		self.game:update(dt)
	end
end

function game:draw()
	self.game:draw()
end

function game:keypressed(key)
	if key == "escape" then
		if self.game.state == "stopped" then
			self:fadeout(function(self) -- Fade out game.
				self:exit()
			end)
		elseif self.state == "fadeout" then
			--timer.cancel(self.tween)
			--self:exit() -- Exit because player is mashing escape.
		end
	end

	if self.state == "game" then
		self.game:keypressed(key)
	end
end

function game:mousepressed(x, y, b)
	if self.state == "game" then
		if b == "wu" then
			self.game.speed = util.math.clamp(0.2, self.game.speed + 0.2, 7)
		elseif b == "wd" then
			self.game.speed = util.math.clamp(0.2, self.game.speed - 0.2, 7)
		end
	end
end
--- ==== ---


return game
