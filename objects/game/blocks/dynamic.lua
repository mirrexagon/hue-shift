--- Require ---
local Class = require("lib.hump.class")
local util = require("lib.self.util")
--- ==== ---


--- Classes ---
local Block = require("objects.game.blocks.block")
--- ==== ---


--- Localised functions ---
local floor = math.floor
local min = math.min
--- ==== ---


--- Class definition ---
local DynamicBlock = {__includes = Block}
--- ==== ---


--- Constants ---
local DIRECTION_MAPPING = {
	up = {x = 0, y = -1},
	right = {x = 1, y = 0},
	down = {x = 0, y = 1},
	left = {x = -1, y = 0}
}

local ROTATION_MAPPING = {
	up = 0,
	right = math.pi/2,
	down = math.pi,
	left = 3*math.pi/2
}
--- ==== ---


--- Images ---
local img_arrow = love.graphics.newImage("graphics/arrow.png")
--- ==== ---


--- Class functions ---
function DynamicBlock:init(args)
	self.direction = args.direction or "up"

	args.fade_time = 0.8 -- On 80% of the beat, fade during the leading and ending 10%s.

	Block.init(self, args)
end

---

function DynamicBlock:set_direction(dir)
	if DIRECTION_MAPPING[dir] then
		self.direction = dir
	end
end

function DynamicBlock:step()
	local dirmap = DIRECTION_MAPPING[self.direction]

	self.x = (self.x + dirmap.x) % self.grid.w
	self.y = (self.y + dirmap.y) % self.grid.h
end

---

function DynamicBlock:draw_symbol(draw_x, draw_y, tile_w, tile_h)
	local min_wh = min(tile_w, tile_h)

	love.graphics.draw(
		img_arrow,
		draw_x + tile_w/2, draw_y + tile_h/2,
		ROTATION_MAPPING[self.direction],
		1, 1,
		min_wh/2, min_wh/2)
end
--- ==== ---


return Class(DynamicBlock)
