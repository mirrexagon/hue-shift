--! Number of player block pairs (player and goal) selection MenuItem


-- TODO: Make it easier to see how many blocks are active when this item is not selected.
-- TODO: Maybe draw black outline or shadow for text and other white objects?


--- Import ---
import Menu, MenuItem from require "menu"
--- ==== ---


--- Assets ---
img_arrow = love.graphics.newImage("assets/graphics/arrow.png")
--- ==== ---


class NBlockPairsMenuItem extends MenuItem
	new: =>
		super Menu.ITEM_STANDARD_HEIGHT, "BLOCKS"


	init: (menu) =>
		super menu
		@menu.game_params.n_block_pairs = 1


	draw: (width, height, alpha) =>
		love.graphics.setColor 255, 255, 255, alpha

		-- Draw the three blocks equally spaced along the bar, centered vertically.
		block_y = math.floor height/2 - BLOCK_HEIGHT/2

		for pair_n = 1, 3 do
			block_alpha = (pair_n <= @menu.game_params.n_block_pairs and 1 or 0.25) * alpha

			---

			love.graphics.setColor(
				@menu.game_params.theme.BLOCK_PAIR_COLORS[pair_n][1],
				@menu.game_params.theme.BLOCK_PAIR_COLORS[pair_n][2],
				@menu.game_params.theme.BLOCK_PAIR_COLORS[pair_n][3],
				block_alpha * 255
			)

			block_x = math.floor width/4 * pair_n - BLOCK_WIDTH/2
			love.graphics.rectangle "fill", 
				block_x, block_y,
				BLOCK_WIDTH, BLOCK_HEIGHT

			---

			love.graphics.setColor 255, 255, 255, block_alpha * 255
			love.graphics.draw(img_arrow, block_x, block_y)

		-- Draw arrows on each side.
		@draw_lr_arrows width/2, width/2.3, height/2, 35, 55, alpha, 
			@menu.game_params.n_block_pairs > 1, 
			@menu.game_params.n_block_pairs < 3


	keypressed: (key, scancode, isrepeat) =>
		switch key
			when "left", "a"
				@menu.game_params.n_block_pairs -= 1
			when "right", "d"				
				@menu.game_params.n_block_pairs += 1

		if @menu.game_params.n_block_pairs < 1 then @menu.game_params.n_block_pairs = 1
		if @menu.game_params.n_block_pairs > 3 then @menu.game_params.n_block_pairs = 3
		

{ :NBlockPairsMenuItem }