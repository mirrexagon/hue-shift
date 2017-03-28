-- Hue Shift, a game by Mirrexagon


--- Require ---
gamestate = require "lib.hump.gamestate"
--- ==== ---


--- Import ---
import MenuState from require "states.menu"
import MusicLibrary from require "music"
--- ==== ---


--- Constants ---
export BLOCK_WIDTH = 32
export BLOCK_HEIGHT = 32
--- ==== ---


--- Main ---
love.load = ->
	theme = (require "themes.hue-shift")!
	music_library = MusicLibrary "assets/music"

	menu_state = MenuState theme, music_library

	gamestate.registerEvents!
	gamestate.switch menu_state
--- ==== ---