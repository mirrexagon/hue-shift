--- Require ---
local Class = require("lib.hump.class")
local timer = require("lib.hump.timer")

local util = require("lib.self.util")

local beat = require("util.beat")
--- ==== ---


--- Classes ---
local Grid = require("objects.game.grid")
local DynamicBlock = require("objects.game.blocks.dynamic")
--- ==== ---


--- Class definition ---
local Game = {}
--- ==== ---


--- Class functions ---
function Game:init(args)
	--- Store needed variables.
	self.level = args.level
	self.music = args.music
	self.theme = args.theme
	self.n_players = args.n_players
	self.speed = args.speed or 1

	self.canvas = love.graphics.newCanvas()
	self.alpha = 1

	--- Setup grid.
	self.grid = Grid{
		w = self.level.grid.w,
		h = self.level.grid.h,

		color = self.theme.grid.color
	}


	--- Setup blocks.
	self.blocks = {}

	-- Setup level obstacles.
	self.blocks.obstacles = {}

	-- Setup player and goal blocks.
	self.blocks.players = {}
	self.blocks.goals = {}

	for i = 1, self.n_players do
		self.blocks.players[i] = DynamicBlock{
			grid = self.grid,
			color = self.theme.blocks.player[i],

			x = self.level.players[i].x,
			y = self.level.players[i].y
		}
	end
end

function Game:step()
	--- Step blocks in their appropriate directions.
	for i, player in ipairs(self.blocks.players) do
		player:step()
	end

	for i, obstacle in ipairs(self.blocks.obstacles) do
		obstacle:step()
	end

	--- Check collisions.
end

function Game:update(dt)
	--- Update theme.
	self.theme:update(dt)

	--- Update beat.
	local dbeat = beat.sectobeat(dt, self.music.bpm)
end

function Game:draw()
	love.graphics.setColor(255, 255, 255, 255)

	--- Draw background.
	self.theme:draw_bg(love.graphics.getDimensions())


	---- Canvas for fading.
	self.canvas:clear()
	love.graphics.setCanvas(self.canvas)

	-- Draw grid.
	self.grid:draw()

	-- Draw blocks.
	for i, goal in ipairs(self.blocks.goals) do
		goal:draw()
	end

	for i, player in ipairs(self.blocks.players) do
		player:draw()
	end

	for i, obstacle in ipairs(self.blocks.obstacles) do
		obstacle:draw()
	end

	love.graphics.setCanvas()

	--- Draw the canvas.
	love.graphics.setColor(255, 255, 255, 255 * self.alpha)
	love.graphics.draw(self.canvas)
end
--- ==== ---


return Class(Game)
