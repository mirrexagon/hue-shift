--! Main game class and auxiliary classes.


--- Import ---
import StaticBlock, DynamicBlock, GoalBlock from require "blocks"
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
	@grid_h = 7

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
			dynamic: false
		}
	}


class Game
	new: (music, theme, level, n_block_pairs) =>
		@DEBUG = false

		-- Can be: entering, running, stopping, stopped, resetting, exiting
		@state = "entering"

		@music = music
		@theme = theme
		@n_block_pairs = n_block_pairs

		@level = level
		@load_level @level

		@alpha = 1
		@speed = 1
		@score = {0, 0, 0}
		@beat_callbacks = {}

		-- These are just constants.
		@grid_cell_w = BLOCK_WIDTH
		@grid_cell_h = BLOCK_WIDTH
		@grid_pad = 2

		@transition_duration = @compute_transition_duration!
		@music\load!


	run: =>
		music\play!


	deinit: =>
		@music\unload!

	---

	-- Two beats.
	compute_transition_duration: =>
		beats_to_seconds 2, @music.bpm

	---

	-- Called at the start of each beat.
	beat: =>
		for i = 1, #@beat_callbacks
			event = @beat_callbacks[i]
			event.beats -= 1

			if event.beats <= 0
				event.callback!
				table.remove(@beat_callbacks, i)


	update: (dt) =>
		scaled_dt = dt * @speed

		@theme.background\update scaled_dt
		@music\set_pitch @speed

		-- TODO: Call beat when appropriate


	draw: =>
		@theme.background\draw!

		love.graphics.push!
		love.graphics.translate @grid\screen_pad!
		@draw_grid!
		@draw_blocks!
		love.graphics.pop!

		if @DEBUG
			status_line = ("Time: %.2f\nBeat: %.2f\nSpeed: %.2f")\format @music\pos_seconds!,
				@music\pos_beats!, @speed
			love.graphics.print status_line, 10, 10


	--- State transitions ---
	-- entering|resetting -> running
	start: =>
		@state = "running"

		@speed = 1 -- TODO: Don't hardcode game speed.

		music\rewind!
		music\play!


	-- running -> stopping
	stopping: =>
		@state = "stopping"

	--- ==== ---


	--- Game logic ---
	load_level: (level) =>
		@grid_w = level.grid_w
		@grid_h = level.grid_h

		@blocks = {
			players: {}
			goals: {}
			obstacles: {}

		if level
			for i = 1, @n_block_pairs
				player_data = @level.players[i]

				table.insert @blocks.players, 
					(DynamicBlock self, @theme.BLOCK_PAIR_COLORS[i],
						player_data.x, player_data.y,
						player_data.direction)

				table.insert @blocks.goals, 
					(GoalBlock self, @theme.BLOCK_PAIR_COLORS[i])


			for obs_data in *level.obstacles
				Constructor = DynamicBlock if obs_data.dynamic else StaticBlock

				table.insert @blocks.obstacles, 
					(Constructor self, @theme.OBSTACLE_COLOR,
						obs_data.x, obs_data.y,
						obs_data.direction) 
	--- ==== ---


	--- Beat ---
	do_after_beats: (beats, callback) =>
		table.insert(@beat_callbacks, { beats: beats, callback: callback})
	--- ==== ---


	--- Block manipulation ---
	for_all_blocks: (callback) =>
		for player in *@blocks.players
			callback player

		for goal in *@blocks.goals
			callback goal

		for obstacle in *@blocks.obstacles
			callback obstacle


	get_blocks_at: (x, y) =>
		blocks = {}

		@for_all_blocks (block) ->
			if block.x == x and block.y == y
				blocks[#blocks + 1] = block


	-- Move block to a random new position.
	-- Used to re-place goal blocks.
	re_place_block: (block) =>
		while true
			new_x = love.math.random(@grid_w) - 1
			new_y = love.math.random(@grid_h) - 1

			if #(@get_blocks_at new_x, new_y) == 0
				block.x = new_x
				block.y = new_y
				return


	are_blocks_colliding: (b1, b2) =>
		b1.x == b2.x and b1.y == b2.y
	--- ==== ---


	--- Block collisions ---
	on_player_player_collision: (p1, p2) =>
		-- TODO: Fade both ("ghost")


	on_player_goal_collision: (pair_i) =>
		@score[pair_i] += 1

		-- Schedule goal re-place for start of next beat.
		@do_after_beats 1, -> @re_place_block @blocks.goals[pair_i]


	on_player_obstacle_collisions: (collisions) =>
		-- TODO: Go into stopping state.

		-- TODO: Indicate where the player died.
		-- Along with system for highlighting overlapping blocks,
		-- specially indicate this spot with a crosshair or such.

		-- TODO: Mark all collisions, not just the first one to be detected

	---
	
	-- For things like fading blocks to show them on top of each other,
	-- "other player block is obstacle" modifier.
	check_player_player_collisions: =>
		-- TODO: Don't check pairs of player blocks more than once.
		for p1 in *@blocks.players
			for p2 in *@blocks.players
				if p1 ~= p2
					if @are_blocks_colliding p1, p2
						@on_player_player_collision p1, p2


	check_player_goal_collisions: =>
		for i, player in ipairs @blocks.players
			goal = @blocks.goals[i]

			if @are_blocks_colliding player, goal
				@on_player_goal_collision i


	check_player_obstacle_collisions:
		collisions = {}

		for i, player in ipairs @blocks.players
			for obstacle in *@blocks.obstacles
				if @are_blocks_colliding player, obstacle
					collisions[#collisions + 1] = {player_i = i, obstacle = obstacle}
	--- ==== ---


	--- Drawing grid and blocks ---
	draw_grid: =>
		pixel_w, pixel_h = @pixel_dimensions!

		-- Background.
		love.graphics.setColor 255, 255, 255, 255 * 0.7 * @alpha
		love.graphics.rectangle "fill", 0, 0, pixel_w, pixel_h

		-- Grid lines.
		love.graphics.setColor 255, 255, 255, 255 * @alpha

		for x = 0, @grid_w
			love.graphics.rectangle "fill", (x * @grid_cell_w) + (x * @grid_pad), 0, @grid_pad, pixel_h

		for y = 0, @grid_h
			love.graphics.rectangle "fill",  0, (y * @grid_cell_h) + (y * @grid_pad), pixel_w, @grid_pad


	draw_blocks: =>
		-- TODO


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
		@pixel_coords @grid_w, @grid_h


	-- Compute the pixel coordinates of a grid cell, relative to the top-left of the grid.
	pixel_coords: (grid_x, grid_y) =>
		pixel_x = grid_x * @grid_cell_w + (grid_x + 1) * @grid_pad
		pixel_y = grid_y * @grid_cell_h + (grid_y + 1) * @grid_pad

		pixel_x, pixel_y
	--- ==== ---


{ :Level, :Game }
