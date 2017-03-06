-- Hue Shift, a game by Mirrexagon


--- Require ---
--- ==== ---


--- Import ---
import seconds_to_beats, beats_to_seconds from require "util.beat"

import Menu, MenuItem from require "menu"
import NBlockPairsMenuItem from require "menu.nblockpairs"
import MusicMenuItem from require "menu.music"

import Game from require "game"

import Music, MusicLibrary from require "music"
--- ==== ---


--- Constants ---
export BLOCK_WIDTH = 32
export BLOCK_HEIGHT = 32
--- ==== ---


--- Main ---
local menu
local game

---

love.load = ->
	-- Load and instantiate default theme.
	theme = (require "themes.hue-shift")!

	-- Instantiate music library.
	music_library = MusicLibrary "assets/music"

	-- Instantiate menu and add MenuItems.
	menu = with Menu theme
		\add_item MenuItem 0, "FANCY LOGO HERE"
		\add_item MusicMenuItem music_library
		\add_item NBlockPairsMenuItem!
		\add_item MenuItem 0, "GRID"
		\add_item MenuItem 0, "OBSTACLES"
		\add_item MenuItem 0, "START"


love.update = (dt) ->
	menu\update dt


love.draw = ->
	menu\draw!


love.keypressed = (key, scancode, isrepeat) ->
	menu\keypressed key, scancode, isrepeat


love.keyreleased = (key, scancode) ->
	menu\keyreleased key, scancode


love.wheelmoved = (x, y) ->
	menu\wheelmoved x, y


love.resize = (w, h) ->
--- ==== ---