--- Require ---
local Class = require("lib.hump.class")
local timer = require("lib.hump.timer")

local util = require("lib.self.util")
--- ==== ---


--- Localised functions ---
local clamp = util.math.clamp
local map = util.math.map
--- ==== ---


--- Class definition ---
local Block = {}
--- ==== ---


--- Local functions ---
local function default_alpha_curve(self, beat_fraction, snappy)
	local fade_mod = snappy and 1.07 or 1

	local right_time = clamp(0.5, self.fade_time, 1)
	local left_time = 1 - right_time

	if beat_fraction <= left_time then
		return map(beat_fraction, 0,left_time, 0,1)
	elseif beat_fraction >= right_time then
		return map(beat_fraction, right_time,1, 1,0)
	else
		return 1
	end
end
--- ==== ---


--- Class functions ---
function Block:init(args)
	self.grid = args.grid

	self.x = args.x or 0
	self.y = args.y or 0

	self.color = args.color

	self.alpha_curve = default_alpha_curve

	self.alpha = 0 -- Alpha without regard to ghosting.
	self._alpha = 0 -- True alpha.
	self.ghost = args.ghost or false

	self.fade_time = args.fade_time or 1
end

---

function Block:step()

end

---

-- TODO: General alpha curve function as a function of `beat_fraction` and `snappy`.

function Block:update_alpha(beat_fraction, snappy)
	self.alpha = self:alpha_curve(beat_fraction, snappy)
end

---

function Block:draw_block(draw_x, draw_y, tile_w, tile_h)
	love.graphics.rectangle("fill", draw_x,draw_y,
		tile_w,tile_h)
end

function Block:draw_symbol(draw_x, draw_y, tile_w, tile_h)

end

function Block:draw_at(x, y)
	local tile_w = self.grid.tile_w
	local tile_h = self.grid.tile_h

	love.graphics.setColor(self.color[1],
		self.color[2], self.color[3], 255 * self._alpha)
	self:draw_block(x, y, tile_w, tile_h)

	love.graphics.setColor(255, 255, 255, 255 * self._alpha)
	self:draw_symbol(x, y, tile_w, tile_h)
end

function Block:draw()
	self._alpha = self.alpha * (self.ghost and 0.5 or 1)

	local draw_x, draw_y = self.grid:get_pixel_coords(self.x, self.y)
	self:draw_at(draw_x, draw_y)
end
--- ==== ---


return Class(Block)
