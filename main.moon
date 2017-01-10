-- Hue Shift, a game by Mirrexagon


--- Require ---
--- ==== ---


--- Import ---
import seconds_to_beats, beats_to_seconds from require "util.beat"
import Menu, MenuItem from require "menu"
import Game from require "game"
import Music, MusicLibrary from require "music"
--- ==== ---


--- Main ---
local menu
local game

love.load = ->
	theme = (require "themes.hue-shift")!
	music_library = MusicLibrary "assets/music"

	menu = Menu love.graphics.getWidth!, theme
	menu_item = MenuItem 85, "FANCY LOGO HERE"
	menu\add_item menu_item

	game = Game music_library[1], theme
	game.DEBUG = true

love.update = (dt) ->
	--game\update dt
	menu\update dt

love.draw = ->
	--game\draw!
	menu\draw!

love.wheelmoved = (x, y) ->
	game.speed += 0.1 * (if y > 0 then 1 else -1)

	if game.speed < 0.1
		game.speed = 0.1
		
love.resize = (w, h) ->
	menu\set_width w
--- ==== ---