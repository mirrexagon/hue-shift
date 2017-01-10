-- TODO: be able to have submenus to the right of menus.


print_centered = (text, x, y) ->
	font = love.graphics.getFont!

	love.graphics.print text,
		x - (math.floor (font\getWidth text) / 2),
		y - (math.floor font\getHeight! / 2)


interpolate = (value, target, dt, speed) ->
	value + (target - value) * speed * dt



class MenuItem
	new: (height = 85, label) =>
		@height = height
		@label = label

	---

	-- Override this!
	draw: (width, alpha) =>


class Menu
	ITEM_VERT_PAD: 30
	ITEM_WIDTH: 540
	ITEM_SELECTED_ALPHA: 0.7
	ITEM_UNSELECTED_ALPHA: 0.7 * 0.5

	---

	new: (width, theme) =>
		@items = {}
		@selected = 1

		@set_width width
		@set_alpha 1

		@theme = theme

		@label_font = love.graphics.newFont math.floor (@width / 600) * 48

		@scroll_offset = 0
		@target_scroll_offset = 0

	---

	add_item: (item) =>
		table.insert @items, item

	---

	select_next: =>
	select_prev: =>

	---

	set_width: (width) =>
		@width = width

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

		item_x = (@width - @ITEM_WIDTH)/2
		item_y = @ITEM_VERT_PAD

		for i, item in ipairs @items
			love.graphics.push!
			love.graphics.translate item_x, item_y
			
			love.graphics.setColor 255, 255, 255,
				255 * if i == @selected then @ITEM_SELECTED_ALPHA else @ITEM_UNSELECTED_ALPHA
			love.graphics.rectangle "fill", 0, 0, @ITEM_WIDTH, item.height

			if item.label
				love.graphics.setColor 255, 255, 255, 255
				love.graphics.setFont @label_font
				print_centered item.label, (math.floor @ITEM_WIDTH/2), (math.floor 85/2)

			item\draw @ITEM_WIDTH, @alpha
			love.graphics.pop!

			item_y += item.height + @ITEM_VERT_PAD

			love.graphics.pop!


{ :MenuItem, :Menu }