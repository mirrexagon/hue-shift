--! The default theme.


--- REquire ---
theme = require "theme"
--- ==== ---


class Background extends theme.Background
	new: =>
		@time = 0
		@image_w = 6
		@image_h = 6

	update: (dt) =>
		@time += dt -- Good at 90 BPM, scale with BPM?

	draw: =>
		love.graphics.push!
		love.graphics.scale love.graphics.getWidth! / @image_w,
			love.graphics.getHeight! / @image_h
		love.graphics.draw @_generate_image!
		love.graphics.pop!

	---

	_generate_image: =>
		image_data = love.image.newImageData @image_w, @image_h
		image_data\mapPixel (x, y, r, g, b, a) -> @_compute_pixel x, y, @time
		love.graphics.newImage image_data

	-- Adapted from http://www.love2d.org/wiki/Chromatic_Paths
	_MAGIC: {0.1, 0.1, 0.1, 0.1, 0.1, 0.8}

	_compute_pixel: (x, y, time) =>
		f = (v) -> (math.sin v) * 127 + 128

		r = f time + x * @_MAGIC[1]
		g = f time * @_MAGIC[2] + y * @_MAGIC[3]
		b = f x * @_MAGIC[4] + y * @_MAGIC[5] - time * @_MAGIC[6]

		r, g, b, 255


class Theme extends theme.Theme
	new: =>
		super Background

---

Theme