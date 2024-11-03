local Grid = {}


--- Require ---
local Class = require("lib.hump.class")
--- ==== ---


--- Class definition ---
local Grid = {}
--- ==== ---


-- TODO: Make grid contain blocks, not the other way around.


--- Class functions ---
function Grid:init(args)
	self:set(args)
end

function Grid:set(args)
	self.x = args.x
	self.y = args.y

	self.w = args.w or 8
	self.h = args.h or 8

	self.tile_w = args.tile_w or 32
	self.tile_h = args.tile_h or 32

	self.pad = args.pad or 2

	self.color = args.color or {255, 255, 255}
end

---

function Grid:get_draw_location()
	if self.x and self.y then
		return self.x, self.y
	else
		local pixel_w, pixel_h = self:get_pixel_width()

		local x = (love.graphics.getWidth() - pixel_w) / 2
		local y = (love.graphics.getHeight() - pixel_h) / 2

		return x, y
	end
end

function Grid:get_relative_pixel_coords(grid_x, grid_y)
	local x = (grid_x * self.tile_w) + ((grid_x + 1) * self.pad)
	local y = (grid_y * self.tile_h) + ((grid_y + 1) * self.pad)

	return x, y
end

function Grid:get_pixel_coords(grid_x, grid_y)
	local x_offset, y_offset = self:get_draw_location()
	local x, y = self:get_relative_pixel_coords(grid_x, grid_y)

	return x_offset + x, y_offset + y
end

function Grid:get_pixel_width()
	return self:get_relative_pixel_coords(self.w, self.h)
end

---

function Grid:draw()
	-- Get needed variables --
	local x, y = self:get_draw_location()

	local pixel_w, pixel_h = self:get_pixel_width()
	alpha = alpha or 1


	-- Grid background --
	love.graphics.setColor(self.color[1], self.color[2], self.color[3],
		255 * 0.7 * alpha)

	love.graphics.rectangle("fill", x,y, pixel_w,pixel_h)


	-- Grid lines --
	love.graphics.setColor(self.color[1], self.color[2], self.color[3],
		255 * alpha)

	-- Start at 0 to make border.
	for vert = 0, self.w do
		love.graphics.rectangle("fill",
			x + (vert * self.tile_w) + (vert * self.pad), y, self.pad, pixel_h)
	end

	for hor = 0, self.h do
		love.graphics.rectangle("fill",
			x, y + (hor * self.tile_h) + (hor * self.pad), pixel_w, self.pad)
	end
end
--- ==== ---


return Class(Grid)
