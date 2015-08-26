--- Require ---
local Class = require("lib.hump.class")
local timer = require("lib.hump.timer")

local util = require("lib.self.util")
--- ==== ---


--- Localised functions ---

--- ==== ---


--- Class definition ---
local Block = {}
--- ==== ---


--- Constants ---
local STATIC_DOT_SIZE_MULT = 5/16
--- ==== ---


--- Images ---
local img_arrow = love.graphics.newImage("graphics/arrow.png")
--- ==== ---


--- Local functions ---
local function lerp(a, b, t)
	return a + (a - b) * t
end
--- ==== ---


--- Class functions ---
function Block:init(args)
	self.grid = args.grid

	self.x = args.x or 0
	self.y = args.y or 0

	self.color = args.color
	self.alpha = 1

	self.fade_time = args.fade_time or 1
end

---

function Block:step()

end

---

function Block:update_alpha(beat_fraction)
	-- eg. self.fade_time = 0.8

	local border_time = 1 - self.fade_time
	-- eg. border_time = 0.2

	if beat_fraction < border_time then
	-- eg. if beat_fraction < 0.2
		-- tween
	end
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
