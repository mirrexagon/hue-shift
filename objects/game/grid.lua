local class = require("lib.hump.class")

return Class{
	init = function(self, args)
		self:set(args)
	end,

	set = function(self, args)
		self.w = args.w or 8
		self.h = args.h or 8

		self.tile_w = args.tile_w or 32
		self.tile_h = args.tile_h or 32

		self.pad = args.pad or 2

		self.alpha = args.alpha or 1
		self.bg_alpha = 0.7
		self.lines_alpha = 1
	end,

	---

	get_pixel_width = function(self)
		local pixel_w = (self.w * self.tile_w) + ((self.w + 1) * self.pad)
		local pixel_h = (self.h * self.tile_h) + ((self.h + 1) * self.pad)

		return pixel_w, pixel_h
	end,

	get_pixel_coords = function(self, grid_x, grid_y)
		local pixel_w, pixel_h = get_pixel_width()

		local x = (love.graphics.getWidth() - pixel_w) / 2
		local y = (love.graphics.getHeight() - pixel_h) / 2

		return x, y
	end,

	draw = function(self)
		-- Get needed variables --
		local pixel_w, pixel_h = get_pixel_width()
		local x, y = self:get_pixel_coords(0, 0)


		-- Grid background --
		love.graphics.setColor(255, 255, 255, self.alpha * self.bg_alpha)
		love.graphics.rectangle("fill", x,y, pixel_w,pixel_h)


		-- Grid lines --
		love.graphics.setColor(255, 255, 255, self.alpha * self.lines_alpha)

		-- Start at 0 to make border.
		for vert = 0, self.w do
			love.graphics.rectangle("fill",
				x + (vert * self.tile_w) + (vert * tile_pad), y, self.pad, pixel_h)
		end

		for hor = 0, self.h do
			love.graphics.rectangle("fill",
				x, y + (hor * self.tile_h) + (hor * self.pad), pixel_w, self.pad)
		end
	end
}
