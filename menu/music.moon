--! Music selection MenuItem


-- TODO: Use submenu list for music?


--- Import ---
import Menu, MenuItem from require "menu"
--- ==== ---


class MusicMenuItem extends MenuItem
	new: (music_library) =>
		super 0, "MUSIC"
		@music_library = music_library
		
	draw: (width, height, alpha) =>
		

{ :MusicMenuItem }