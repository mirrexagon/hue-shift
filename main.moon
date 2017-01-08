-- Hue Shift, a game by Mirrexagon


--- Require ---
Music = require("music")
Game = require("game")
--- ==== ---


--- Import ---
import seconds_to_beats, beats_to_seconds from require "util.beat"
--- ==== ---


--- Main ---
local game

love.load = ->
	laserwash = Music "coda - laserwash", "assets/music/laserwash.ogg", 90
	game = Game laserwash
	game.DEBUG = true
	
love.update = (dt) ->
	game\update dt

love.draw = ->
	game\draw!
	
love.wheelmoved = (x, y) ->
	game.speed += 0.1 * (if y > 0 then 1 else -1)
	
	if game.speed < 0.1
		game.speed = 0.1
--- ==== ---