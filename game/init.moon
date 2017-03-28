--! Main game class and auxiliary classes.


--- Require ---
--- ==== ---


--- Constants ---
BLOCK_CONTROLS = {
	[1]: {
		up: "w"
		right: "d"
		down: "s"
		left: "a"
	}

	[2]: {
		up: "t"
		right: "h"
		down: "g"
		left: "f"
	}

	[3]: {
		up: "i"
		right: "l"
		down: "k"
		left: "j"
	}
}
--- ==== ---


--- Helpers ---
generate_control_functions = (players) ->
	funcs = {}

	for id, controls in ipairs(BLOCK_CONTROLS) do
		for dir, key in pairs(controls) do
			funcs[key] = ->
				if players[id]
					players[id]:set_direction(dir)

	funcs
--- ==== ---


class Level
	@name = "<BASE>"

	@grid_w = 7
	@grid_w = 7

	@players = {
		[1]: {
			x: 0
			y: 6
			direction: "up"
		}

		[2]: {
			x: 3
			y: 6
			direction: "up"
		}

		[3]: {
			x: 6
			y: 6
			direction: "up"
		}
	}

	@obstacles = {
		{
			x: 3
			y: 3
			type: "static"
		}
	}


class Grid
	new: (w,h, cell_w = BLOCK_WIDTH,cell_h = BLOCK_HEIGHT, pad = 2) =>
		@w = w
		@h = h
		@cell_w = cell_w
		@cell_h = cell_h
		@pad = pad

		@alpha = 1

		@reset!

	---

	set_alpha: (alpha) => 
		@alpha = alpha
		
	---

	reset: (level) =>
		@blocks = {
			players: {}
			goals: {}
			obstacles: {}

	---

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
	new: (music, theme) => -- TODO: Also specify level in constructor, and other game_params
		@DEBUG = false

		-- Can be: entering, running, stopping, stopped, resetting, exiting
		@state = "entering"
		@music = music
		@theme = theme
		@speed = 1

		@alpha = 1

		@grid = Grid 7, 7

		music\load!
		
	run: =>
		music\play!

	deinit: =>
		@music\unload!

	---

	set_alpha: (alpha) =>
		@grid\set_alpha alpha

	---

	update: (dt) =>
		scaled_dt = dt * @speed

		@theme.background\update scaled_dt
		@music\set_pitch @speed

	draw: =>
		@theme.background\draw!

		love.graphics.push!
		love.graphics.translate @grid\screen_pad!
		@grid\draw!
		love.graphics.pop!

		if @DEBUG
			status_line = ("Time: %.2f\nBeat: %.2f\nSpeed: %.2f")\format @music\pos_seconds!,
				@music\pos_beats!, @speed
			love.graphics.print status_line, 10, 10


{ :Game }