--! Music selection MenuItem


--- Import ---
import Menu, MenuItem from require "menu"
--- ==== ---


class MusicMenuItem extends MenuItem
	new: (music_library) =>
		super Menu.ITEM_STANDARD_HEIGHT, "MUSIC"
		@music_library = music_library
		
	draw: (width, height, alpha) =>
		

{ :MusicMenuItem }