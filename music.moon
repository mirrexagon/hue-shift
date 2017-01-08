--- Import ---
import seconds_to_beats, beats_to_seconds from require "util.beat"
--- ==== ---


--- A piece of music (with a constant tempo, currently).
class Music
	new: (name, path, bpm) =>
		@name = name
		-- There seems to be a bug with at least some looped streaming audio, where
		-- `source:tell()` isn't quite right after a loop.
		@source = love.audio.newSource path, "static"
		@bpm = bpm
		
		@source\setLooping true
		
	pos_seconds: => @source\tell!
	pos_beats: => seconds_to_beats @source\tell!, @bpm
	
	play: => @source\play!
	rewind: => @source\rewind!
	pause: => @source\pause!
	is_paused: => @source\isPaused!
	
	set_pitch: (pitch) =>
		if pitch == 0
			if not @is_paused!
				@pause!
		else
			@source\setPitch(pitch)
			if @is_paused! then @play!