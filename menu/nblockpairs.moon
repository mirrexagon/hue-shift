-- Number of player block pairs (player and goal) selection MenuItem


--- Import ---
import Menu, MenuItem from require "menu"
--- ==== ---


class NBlockPairsMenuItem extends MenuItem
	new: =>
		super Menu.ITEM_STANDARD_HEIGHT, "BLOCKS"
		@n_block_pairs = 1
		
	draw: (width, height, alpha) =>
		love.graphics.setColor 255, 255, 255, alpha

	keypressed: (key, scancode, isrepeat) =>
		

{ :NBlockPairsMenuItem }