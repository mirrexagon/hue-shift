print_centered = (text, x, y) ->
	font = love.graphics.getFont!

	love.graphics.print text,
		x - ((font\getWidth text) / 2),
		y - (font\getHeight! / 2)


interpolate = (value, target, dt, speed) ->
	value + (target - value) * speed * dt



class MenuItem
	new: (height) =>
		--- Height of the menu item in pixels.
		@height = height

	---

	-- Override this!
	draw: =>

	---

	-- Real draw.
	_draw: (width, bg_alpha) =>
		love.graphics.setColor(255, 255, 255, 255  * bg_alpha)
		@draw width


class Menu
	ROW_PAD: 30
	MAX_WIDTH: 600 -- The width after which menu items won't get any wider.
	ROW_BG_ALPHA: 0.7

	---

	new: (w, h, theme) =>
		@set_dimensions w, h -- These include padding, and are usually the window dimensions.
		@theme = theme

		@alpha = 1

		@items = {}
		@selected = 1

		@scroll_offset = 0
		@target_scroll_offset = 0

	---

	add_item: (item) =>
		table.insert @items, item

	---

	set_dimensions: (w, h) =>
		@w = w
		@h = h

	set_alpha: (alpha) =>
		@alpha = alpha

	---

	update: (dt) =>
		@theme.background\update dt

		@scroll_offset = interpolate @scroll_offset,
			@target_scroll_offset, dt, 5

	draw: =>
		@theme.background\draw!

		love.graphics.push!
		love.graphics.translate(0, @scroll_offset)
		love.graphics.pop!


{ :MenuItem, :Menu }