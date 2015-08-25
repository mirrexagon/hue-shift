local Game = {}


--- Require ---
local Class = require("lib.hump.class")
local timer = require("lib.hump.timer")

local beat = require("lib.self.beat")
local util = require("lib.self.util")
--- ==== ---


--- Classes ---
local Grid = require("objects.game.grid")
local DynamicBlock = require("objects.game.blocks.dynamic")
--- ==== ---


--- Class functions ---
function Game:init(args)
	--- Store needed variables.
	self.level = arg.level
	self.music = arg.music
	self.theme = arg.theme
	self.n_players = arg.n_players
	self.speed = arg.speed or 1


	--- Setup grid.
	self.grid = Grid{
		w = self.level.grid.w,
		h = self.level.grid.h,

		color = self.theme.grid.color,
		bg_alpha = self.theme.grid.bg_alpha,
		lines_alpha = self.theme.grid.lines_alpha
	}


	--- Setup blocks.
	self.blocks = {}

	-- Setup level obstacles.
	self.blocks.obstacles = {}

	-- Setup player blocks.
	self.blocks.players = {}

	for i = 1, self.n_players do
		self.blocks.players[i] = DynamicBlock{
			color = self.theme.blocks.player[i]
		}
	end
end

function Game:step()

end

function Game:update(dbeat)
	--- Update theme.
	self.theme:update(dbeat)
end

function Game:draw()
	--- Draw background.
	self.theme:draw_bg()

	--- Draw grid.
	self.grid:draw()


end
--- ==== ---
