local Game = {}


--- Require ---
local Class = require("lib.hump.class")
local timer = require("lib.hump.timer")

local beat = require("lib.self.beat")
local util = require("lib.self.util")
--- ==== ---


--- Classes ---
local Grid = require("objects.game.grid")
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
	}


	--- Setup blocks.
	self.blocks = {}

	-- Setup level obstacles.
	self.blocks.obstacles = {}

	-- Setup player blocks.
	self.blocks.players = {}
end

function Game:update(dt)

end

function Game:draw()

end
--- ==== ---
