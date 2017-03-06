-- Hue Shift, a game by Mirrexagon


--- Require ---
--- ==== ---


--- Import ---
import seconds_to_beats, beats_to_seconds from require "util.beat"

import Menu, MenuItem from require "menu"
import MusicMenuItem from require "menu.music"

import Game from require "game"

import Music, MusicLibrary from require "music"
--- ==== ---


--- Menu items ---
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
	menu = with Menu love.graphics.getWidth!, theme
		\add_item MenuItem 0, "FANCY LOGO HERE"
		\add_item MusicMenuItem music_library


love.update = (dt) ->
	menu\update dt


love.draw = ->
	menu\draw!


love.keypressed = (key, scancode, isrepeat) ->
	menu\keypressed key, scancode, isrepeat


love.keyreleased = (key, scancode) ->
	menu\keyreleased key, scancode


love.wheelmoved = (x, y) ->
	game.speed += 0.1 * (if y > 0 then 1 else -1)

	if game.speed < 0.1
		game.speed = 0.1

		
love.resize = (w, h) ->
	menu\set_window_width w
--- ==== ---