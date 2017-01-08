-- Hue Shift, a game by Mirrexagon


--- Require ---
--- ==== ---


--- Helper functions ---
beat_to_seconds = (beat, bpm) -> ((beat - 1) * 60) / bpm
seconds_to_beat = (seconds, bpm) -> seconds * (bpm / 60) + 1
--- ==== ---


--- Main ---
local music

love.load = ->
	music = love.audio.newSource "assets/music/laserwash.ogg"
	music\play!

love.draw = (dt) ->
	beat = seconds_to_beat music\tell(), 90
	love.graphics.print "Beat: #{beat}", 10, 10 
--- ==== ---