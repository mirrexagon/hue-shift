-- TODO: be able to have submenus to the right of menus.


print_centered = (text, x, y) ->
	font = love.graphics.getFont!

	love.graphics.print text,
		x - (math.floor (font\getWidth text) / 2),
		y - (math.floor font\getHeight! / 2)


interpolate = (value, target, dt, speed) ->
	value + (target - value) * speed * dt


cycle = (i, len) ->
	i = i % len

	if i == 0
		i = len

	i


class MenuItem
	new: (height = 0, label) =>
		@height = height
		@label = label

	-- Called by Menu, shouldn't be called elsewhere.
	set_width: (width) =>
		@width = width

	get_width: =>
		@width

	-- Overridable methods.

	init: =>

	update: (dt) =>

	draw: (alpha) =>

	keypressed: (key, scancode, isrepeat) =>

	keyreleased: (key, scancode) =>


class Menu
	WIDTH: 600
	ITEM_STANDARD_HEIGHT: 85
	ITEM_PAD: 30

	ITEM_BAR_ALPHA: 0.7
	ITEM_TEXT_ALPHA: 1.0
	ITEM_UNSELECTED_ALPHA_MOD: 0.5

	---

	new: (theme) =>
		@items = {}
		@selected = 1
		@item_width = @WIDTH - 2*@ITEM_PAD

		@set_alpha 1
		@set_interactable true

		@theme = theme

		@label_font = love.graphics.newFont 48

		@scroll_offset = 0
		@target_scroll_offset = 0

	---

	get_width: => @WIDTH

	---

	add_item: (item) =>
		table.insert @items, item
		item\init!
		item\set_width @item_width

	get_item_height: (item_i) =>
		@ITEM_STANDARD_HEIGHT

	---

	select_next: =>
		@selected = cycle @selected + 1, #@items

	select_prev: =>
		@selected = cycle @selected - 1, #@items

	---

	set_alpha: (alpha) =>
		@alpha = alpha

	set_interactable: (interactable) =>
		@interactable = interactable

	---

	update: (dt) =>
		@theme.background\update dt

		@scroll_offset = interpolate @scroll_offset,
			@target_scroll_offset, dt, 5
			
		for item in *@items
			item\update dt

	draw: =>
		@theme.background\draw!

		love.graphics.push!
		love.graphics.translate(0, -@scroll_offset)

		item_x = @ITEM_PAD
		item_y = @ITEM_PAD

		for i, item in ipairs @items
			love.graphics.push!
			love.graphics.translate item_x, item_y

			---

			-- Rectangle
			item_full_height = item.height + if item.label then @ITEM_STANDARD_HEIGHT else 0
			item_alpha_mod = if i == @selected then 1 else @ITEM_UNSELECTED_ALPHA_MOD

			love.graphics.setColor 255, 255, 255, @ITEM_BAR_ALPHA * item_alpha_mod * 255
			love.graphics.rectangle "fill", 0, 0, @item_width, item_full_height

			-- Label
			if item.label
				love.graphics.setColor 255, 255, 255, @ITEM_TEXT_ALPHA * item_alpha_mod * 255
				love.graphics.setFont @label_font
				print_centered item.label, (math.floor @item_width/2),
					(math.floor @ITEM_STANDARD_HEIGHT/2)

			-- Draw callback
			if item.label
				love.graphics.push!
				love.graphics.translate 0, @ITEM_STANDARD_HEIGHT

			item\draw @item_width, @alpha * item_alpha_mod

			if item.label
				love.graphics.pop!

			---

			love.graphics.pop! -- item_x, item_y

			item_y += item_full_height + @ITEM_PAD

		love.graphics.pop! -- scroll_offset
		
	keypressed: (key, scancode, isrepeat) =>
		if @interactable
			switch key
				when "up", "w"
					@select_prev!
				when "down", "s"
					@select_next!
				--when "escape"
					-- TODO: Fade out and quit
				else
					for item in *@items
						item\keypressed key, scancode, isrepeat

	keyreleased: (key, scancode) =>
		if @interactable
			for item in *@items
				item\keyreleased key, scancode

	wheelmoved: (x, y) =>
		if @interactable
			if y > 0
				@select_prev!
			elseif y < 0
				@select_next!


{ :MenuItem, :Menu }