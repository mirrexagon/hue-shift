--- Require ---
local Class = require("lib.hump.class")
local util = require("lib.self.util")
--- ==== ---


--- Localised functions ---

--- ==== ---


--- Class definition ---
local Block = {}
--- ==== ---


--- Constants ---


local STATIC_DOT_SIZE_MULT = 5/16

local DYNAMIC_FADE_TIME
local GOAL_FADE_TIME
--- ==== ---


--- Images ---
local img_arrow = love.graphics.newImage("graphics/arrow.png")
--- ==== ---


--- Class functions ---
function Block:init(args)
	self.grid = args.grid

	self.x = args.x or 0
	self.y = args.y or 0

	self.color = args.color
	self.alpha = 1

	self.fade_time = args.fade_time or 0
end

---

function Block:step()

end

---

function Block:update_alpha(beat_fraction)

end

---

function Block:draw_block(draw_x, draw_y, tile_w, tile_h)
	love.graphics.setColor(self.color[1],
		self.color[2], self.color[3], 255 * self.alpha)

	love.graphics.rectangle("fill", draw_x,draw_y,
		tile_w,tile_h)
end

function Block:draw_symbol(draw_x, draw_y, tile_w, tile_h)

end

function Block:draw()
	local draw_x, draw_y = self.grid:get_pixel_coords(self.x, self.y)
	local tile_w, tile_h = self.grid.tile_w, self.grid.tile_h

	self:draw_block(draw_x, draw_y, tile_w, tile_h)
	self:draw_symbol(draw_x, draw_y, tile_w, tile_h)
end
--- ==== ---


return Class(Block)
