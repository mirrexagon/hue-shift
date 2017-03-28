--- Import ---
import Menu, MenuItem from require "menu"
import NBlockPairsMenuItem from require "menu.nblockpairs"
import MusicMenuItem from require "menu.music"
--- ==== ---


class MenuState
	new: (theme, music_library) =>
		@menu = with Menu theme
			\add_item MenuItem 0, "FANCY LOGO HERE"
			\add_item MusicMenuItem music_library
			\add_item NBlockPairsMenuItem!
			\add_item MenuItem 0, "GRID"
			\add_item MenuItem 0, "OBSTACLES"
			\add_item MenuItem 0, "START"


	update: (dt) =>
		@menu\update dt


	draw: =>
		@menu\draw!

	
	keypressed: (key, scancode, isrepeat) =>
		@menu\keypressed key, scancode, isrepeat
	
	
	keyreleased: (key, scancode) =>
		@menu\keyreleased key, scancode
	
	
	wheelmoved: (x, y) =>
		@menu\wheelmoved x, y


{ :MenuState }
