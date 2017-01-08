-- Hue Shift, a game by Mirrexagon


--- Require ---
Game = require("game")
--- ==== ---


--- Import ---
from require "util.beat" import seconds_to_beats, beats_to_seconds
--- ==== ---


--- Main ---
local music
local game

love.load = ->
	game = Game!
	
	-- There seems to be a bug when this is streaming audio, where source:tell()
	-- isn't quite right after looping.
	music = love.audio.newSource "assets/music/laserwash.ogg", "static"
	music\setLooping true
	music\play!
	
love.update = (dt) ->
	music\setPitch game.speed
	game\update dt

love.draw = ->
	beat = seconds_to_beat music\tell(), 90
	
	game\draw!
	
	status_line = ("Time: %.2f\nBeat: %.2f\nSpeed: %.2f")\format music\tell!, 
		beat, game.speed
	love.graphics.print status_line, 10, 10
	
love.wheelmoved = (x, y) ->
	game.speed += 0.1 * (if y > 0 then 1 else -1)
	
	if game.speed < 0.1
		game.speed = 0.1
--- ==== ---