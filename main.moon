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


--- Gamestates ---
--- ==== ---


--- Main ---
love.load = ->
	music_library = MusicLibrary "assets/music"
	menu_state = MenuState music_library

	gamestate.registerEvents!
	gamestate.switch menu_state
--- ==== ---