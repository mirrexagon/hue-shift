--! Main game class and auxiliary classes.


--- Import ---
from require "util.beat" import seconds_to_beats, beats_to_seconds
--- ==== ---


class Music
	new: (name, path, bpm) =>
		@name = name
		-- There seems to be a bug with at least some looped streaming audio, where
		-- `source:tell()` isn't quite right after a loop.
		@source = love.audio.newSource path "static"
		@bpm = bpm
		
		@source\setLooping true
		
	pos_seconds: => @source\tell!
	pos_beats: => seconds_to_beats @source\tell!
	
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


class Grid
	new: (w,h, cell_w,cell_h, pad) =>
		@w = w
		@h = h
		@cell_w = cell_w or 32
		@cell_h = cell_h or 32
		@pad = pad or 2
		
		@alpha = 1
		
		@blocks = {}
		
	draw: =>
		@draw_grid!
		
	draw_grid: =>
		pixel_w, pixel_h = @pixel_dimensions!
		
		-- Background.
		love.graphics.setColor 255, 255, 255, 255 * 0.7 * @alpha
		love.graphics.rectangle "fill", 0, 0, pixel_w, pixel_h
		
		-- Grid lines.
		love.graphics.setColor 255, 255, 255, 255 * @alpha
		
		for x = 0, @w
			love.graphics.rectangle "fill", (x * @cell_w) + (x * @pad), 0, @pad, pixel_h
		
		for y = 0, @h
			love.graphics.rectangle "fill",  0, (y * @cell_h) + (y * @pad), pixel_w, @pad
	
	-- Compute where the top-left corner of the grid should be to have it centered
	-- in the window.
	screen_pad: =>
		pixel_w, pixel_h = @pixel_dimensions!
		screen_w, screen_h = love.graphics.getDimensions!
		
		x = (screen_w - pixel_w) / 2
		y = (screen_h - pixel_h) / 2
		
		x, y
		
	-- Compute the pixel dimensions of the grid (including pad and borders).
	pixel_dimensions: =>
		-- The pixel dimensions are equivalent to the pixel coordinates of the cell 
		-- just diagonally down-right outside the grid, so we just compute that.
		@pixel_coords @w, @h
		
	-- Compute the pixel coordinates of a grid cell, relative to the top-left of the grid.
	pixel_coords: (grid_x, grid_y) =>
		pixel_x = grid_x * @cell_w + (grid_x + 1) * @pad
		pixel_y = grid_y * @cell_h + (grid_y + 1) * @pad
		
		pixel_x, pixel_y


class Game
	new: =>
		-- Can be: entering, running, stopping, stopped, resetting, exiting
		@state = "entering"
		@theme = (require "themes.hue-shift")!
		@speed = 1
		
		@grid = Grid 7, 7

	---

	update: (dt) =>
		scaled_dt = dt * @speed

		@theme.background\update scaled_dt

	draw: =>
		@theme.background\draw!
		
		love.graphics.push!
		love.graphics.translate @grid\screen_pad!
		@grid\draw!
		love.graphics.pop!
