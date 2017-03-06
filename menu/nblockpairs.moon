--! Number of player block pairs (player and goal) selection MenuItem


--- Import ---
import Menu, MenuItem from require "menu"
--- ==== ---


--- Assets ---
img_arrow = love.graphics.newImage("assets/graphics/arrow.png")
--- ==== ---


class NBlockPairsMenuItem extends MenuItem
	new: =>
		super Menu.ITEM_STANDARD_HEIGHT, "BLOCKS"


	init: (game_params) =>
		game_params.n_block_pairs = 1


	draw: (width, height, alpha, game_params) =>
		love.graphics.setColor 255, 255, 255, alpha

		-- Draw the three blocks equally spaced along the bar, centered vertically.
		block_y = math.floor height/2 - BLOCK_HEIGHT/2

		for pair_n = 1, 3 do
			alpha = (pair_n <= game_params.n_block_pairs and 1 or 0.5) * alpha

			---

			love.graphics.setColor(
				game_params.theme.BLOCK_PAIR_COLORS[pair_n][1],
				game_params.theme.BLOCK_PAIR_COLORS[pair_n][2],
				game_params.theme.BLOCK_PAIR_COLORS[pair_n][3],
				alpha * 255
			)

			block_x = math.floor width/4 * pair_n - BLOCK_WIDTH/2
			love.graphics.rectangle "fill", 
				block_x, block_y,
				BLOCK_WIDTH, BLOCK_HEIGHT

			---

			love.graphics.setColor 255, 255, 255, alpha * 255
			love.graphics.draw(img_arrow, block_x, block_y)


	keypressed: (key, scancode, isrepeat) =>
		

{ :NBlockPairsMenuItem }