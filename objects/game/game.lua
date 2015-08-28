--- Require ---
local Class = require("lib.hump.class")
local timer = require("lib.hump.timer")

local util = require("lib.self.util")

local beat = require("util.beat")
--- ==== ---


--- Localised functions ---
local floor = math.floor
--- ==== ---


--- Classes ---
local Grid = require("objects.game.grid")
local DynamicBlock = require("objects.game.blocks.dynamic")
--- ==== ---


--- Class definition ---
local Game = {}
--- ==== ---


--- Local functions ---
local BLOCK_CONTROLS = {
	[1] = {
		up = "w",
		right = "d",
		down = "s",
		left = "a"
	},
	[2] = {
		up = "t",
		right = "h",
		down = "g",
		left = "f"
	},
	[3] = {
		up = "i",
		right = "l",
		down = "k",
		left = "j"
	}
}

local function generate_control_functions(players)
	local funcs = {}

	for id, controls in ipairs(BLOCK_CONTROLS) do
		for dir, key in pairs(controls) do
			funcs[key] = function()
				players[id]:set_direction(dir)
			end
		end
	end

	return funcs
end
--- ==== ---


--- Class functions ---
function Game:init(args)
	--- Store/initialise needed variables.
	self.level = args.level
	self.music = args.music
	self.theme = args.theme
	self.n_players = args.n_players
	self.speed = args.speed or 1

	self.canvas = love.graphics.newCanvas()
	self.alpha = 1

	self.last_beat = 0
	self.done_first_beat = false

	--- Setup grid.
	self.grid = Grid{
		w = self.level.grid.w,
		h = self.level.grid.h,

		color = self.theme.grid.color
	}

	--- Setup blocks.
	self.blocks = {}

	-- Setup obstacle blocks.
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

	--- Setup controls.
	self.controls = generate_control_functions(self.blocks.players)

	--- Start game by playing music.
	self.music:play()
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
	--- Update beat.
	local current_beat = self.music:get_beat()

	--- Step the game on a beat EXCEPT the first.
	if current_beat > floor(self.last_beat) + 1 then
		if current_beat >= 2 and not self.done_first_beat then
			self.done_first_beat = true
		end

		if self.done_first_beat then
			self:step()
		end
	end

	--- Update music pitch.
	if self.speed == 0 and not self.music:is_paused() then
		self.music:pause()
		self.music:set_pitch(0.0001)
	else
		self.music:set_pitch(self.speed)
		if self.music:is_paused() then
			self.music:play()
		end
	end

	--- Update theme.
	self.theme:update(dt, self.music)

	--- Update block alpha.
	local beat_int, beat_fraction = math.modf(current_beat)

	for i, goal in ipairs(self.blocks.goals) do
		goal:update_alpha(beat_fraction)
	end

	for i, player in ipairs(self.blocks.players) do
		player:update_alpha(beat_fraction)
	end

	for i, obstacle in ipairs(self.blocks.obstacles) do
		obstacle:update_alpha(beat_fraction)
	end


	---
	self.last_beat = current_beat
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

	-- Set no canvas.
	love.graphics.setCanvas()

	--- Draw the canvas.
	love.graphics.setColor(255, 255, 255, 255 * self.alpha)
	love.graphics.draw(self.canvas)
end

function Game:keypressed(k)
	if self.controls[k] then
		self.controls[k]()
	end
end
--- ==== ---


return Class(Game)
