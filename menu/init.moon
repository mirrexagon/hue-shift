-- TODO: be able to have submenus to the right of menus.


print_centered = (text, x, y) ->
	font = love.graphics.getFont!

	love.graphics.print text,
		x - (math.floor (font\getWidth text) / 2),
		y - (math.floor font\getHeight! / 2)


interpolate = (value, target, dt, speed) ->
	value + (target - value) * speed * dt


class MenuItem
	new: (height = 0, label) =>
		@height = height
		@label = label

	-- Overridable methods.
	init: (game_params) =>

	update: (dt, game_params) =>

	draw: (width, height, alpha, params) =>

	keypressed: (key, scancode, isrepeat) =>
	keyreleased: (key, scancode) =>

	selected: => -- TODO
	deselected: => -- TODO


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

		@game_params = { theme: @theme }

	---

	get_width: => @WIDTH

	---

	add_item: (item) =>
		table.insert @items, item
		item\init @game_params

	---

	get_item_height: (item_i) =>
		@ITEM_STANDARD_HEIGHT + @items[item_i].height

	-- Get the combined height from the top of the menu (including the pad at the top) 
	-- to the bottom of the given item.
	get_items_height: (to_i) =>
		items_height = 0

		for i = 1, to_i do
			items_height += @ITEM_PAD + @get_item_height i

		items_height

	---

	select_prev: =>
		@selected -= 1

		if @selected < 1
			-- Wrap around to last item.
			@selected = #@items

			-- Get the offset from the top of the menu to the bottom of the last 
			-- item, and add the bottom pad.
			items_height = (@get_items_height #@items) + @ITEM_PAD

			-- Scroll so the bottom of the lowest pad is at the bottom of the window.
			@target_scroll_offset = items_height - love.graphics.getHeight!
		else
			items_height = @get_items_height @selected - 1

			-- If any part of the item ABOVE the now-selected item 
			-- is offscreen, scroll up so it is just onscreen.
			if items_height - @target_scroll_offset < 0
				@target_scroll_offset = items_height


	select_next: =>
		@selected += 1

		if @selected > #@items
			-- Wrap around to first item.
			@selected = 1
			@target_scroll_offset = 0
		else
			-- Get the offset from the top of the menu to the bottom of the 
			-- now-selected item, and add the pad below it.
			items_height = (@get_items_height @selected) + @ITEM_PAD

			-- If any part of the now-selected item (including pad below it) 
			-- is offscreen, scroll down so it (and the pad) is just onscreen.
			if items_height - @target_scroll_offset > love.graphics.getHeight!
				@target_scroll_offset = items_height - love.graphics.getHeight!

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
			item\update dt, @game_params

	draw: =>
		@theme.background\draw!

		love.graphics.push!
		love.graphics.translate(0, -(math.floor @scroll_offset))

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

			item\draw @item_width, item.height, 
				@alpha * item_alpha_mod, @game_params

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
						item\keypressed key, scancode, isrepeat, @game_params

	keyreleased: (key, scancode) =>
		if @interactable
			for item in *@items
				item\keyreleased key, scancode, @game_params

	wheelmoved: (x, y) =>
		if @interactable
			if y > 0
				@select_prev!
			elseif y < 0
				@select_next!


{ :MenuItem, :Menu }