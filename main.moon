-- Hue Shift, a game by Mirrexagon


--- Require ---
--- ==== ---


--- Helper functions ---
beat_to_seconds = (beat, bpm) -> ((beat - 1) * 60) / bpm
seconds_to_beat = (seconds, bpm) -> seconds * (bpm / 60) + 1
--- ==== ---


--- Main ---
local music
speed = 1.0

love.load = ->
	-- There seems to be a bug when this is streaming audio, where source:tell()
	-- isn't quite right after looping.
	music = love.audio.newSource "assets/music/laserwash.ogg", "static"
	music\setLooping true
	music\play!

love.draw = ->
	music\setPitch speed

	beat = seconds_to_beat music\tell(), 90
	
	status_line = ("Time: %.2f\nBeat: %.2f\nSpeed: %.2f")\format music\tell!, beat, speed
	love.graphics.print status_line, 10, 10
	
love.wheelmoved = (x, y) ->
	speed += 0.1 * (if y > 0 then 1 else -1)
	
	if speed < 0.1
		speed = 0.1
--- ==== ---