--! Main game class and auxiliary classes.


--- Require ---
timer = require "lib.hump.timer"
--- ==== ---


--- Import ---
import beats_to_seconds from require "util.beat"
import StaticBlock from require "blocks.static"
import DynamicBlock from require "blocks.dynamic"
import GoalBlock from require "blocks.goal"
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


-- Duration of entering/exiting transitions (not resetting/stopping).
TRANSITION_DURATION = 0.5
--- ==== ---


--- Helpers ---
generate_control_functions = (players) ->
	funcs = {}

	for id, controls in ipairs(BLOCK_CONTROLS) do
		for dir, key in pairs(controls) do
			funcs[key] = ->
				if players[id]
					players[id]\set_direction dir

	funcs
--- ==== ---


class Level
	new: =>
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


-- TODO: Implement modifiers as classes with functions that patch the Game object?
-- Flexible but may make some modifiers incompatible.
-- Implement it via a class with lots of callbacks for different events?
class Game
	new: (music, theme, level, n_block_pairs) =>
		@DEBUG = false

		-- Can be: entering, running, stopping, stopped, resetting, exiting
		@state = "init"

		@music = music
		@theme = theme
		@n_block_pairs = n_block_pairs

		@game_speed = 1 -- TODO: Be able to modify.

		@alpha = 0
		@speed = 1
		@score = {0, 0, 0}

		@last_beat = 0
		@done_first_beat = false

		-- Called after exit fadeout.
		@exit_func = love.event.quit

		@timer = timer.new!
		@beat_timer = timer.new!

		-- These are just constants.
		@grid_cell_w = BLOCK_WIDTH
		@grid_cell_h = BLOCK_HEIGHT
		@grid_pad = 2

		@transition_duration = @compute_transition_duration!
		@music\load!

		@level = level
		@reset_level!


	run: =>
		music\play!


	deinit: =>
		@music\unload!

	---

	compute_transition_duration: =>
		beats_to_seconds 2, @music.bpm


	--- Callbacks ---
	enter: (previous, ...) =>
		@state_enter!

	leave: =>


	update: (dt) =>
		@timer\update dt

		@theme.background\update dt * @speed
		@music\set_pitch @speed

		current_beat = @music\pos_beats!

		-- Step the game on any beat EXCEPT the first.
		if (math.floor current_beat) ~= (math.floor @last_beat)
			if current_beat >= 2 and not @done_first_beat
				@done_first_beat = true

			if @done_first_beat and @state == "running"
				@step!

		-- TODO: Block blinking when appropriate.

		@last_beat = current_beat


	draw: =>
		love.graphics.setColor 255, 255, 255
		@theme.background\draw!

		love.graphics.push!
		love.graphics.translate @screen_pad!
		@draw_grid!
		@draw_blocks!
		love.graphics.pop!

		if @DEBUG
			love.graphics.setColor 255, 255, 255
			do
				fmt = "Time: %.2f\nBeat: %.2f\nSpeed: %.2f\nAlpha: %.2f"
				status_line = fmt\format @music\pos_seconds!,
					@music\pos_beats!, @speed, @alpha
				love.graphics.print status_line, 10, 10

			do
				fmt = "Scores:\n  1: %d\n  2: %d\n  3: %d"
				status_line = fmt\format @score[1], @score[2], @score[3]
				width = love.graphics.getFont!\getWidth status_line
				love.graphics.print status_line, love.graphics.getWidth! - width - 10, 10


	keypressed: (key, scancode, isrepeat) =>
		if @controls[key] and @state == "running"
			-- Player block controls.
			@controls[key]!
		else
			switch key
				when "escape"
					switch @state
						when "running"
							@state_stopping!
						when "stopping"
							-- Stop game immediately because player is mashing escape.
							@state_stop!
						when "stopped"
							@state_exit!
						when "exiting"
							-- Exit because player is mashing escape.
							if @_alpha_tween then @timer\cancel @_alpha_tween
							@exit_func @
				when "space"
					switch @state
						when "stopping"
							-- Reset game immediately because player is mashing space.
							@state_stop!
							@state_reset!
						when "stopped"
							@state_reset!
						when "resetting"
							-- Start game immediately because player is mashing space.
							@reset_level!
							@state_start!
	--- ==== ---


	-- Called at the start of each beat.
	step: =>
		-- TODO: Put in update?
		@beat_timer\update 1

		@for_all_blocks (block) ->
			block\step!

		@check_player_obstacle_collisions!
		@check_player_goal_collisions!
		@check_player_player_collisions!


	--- State transitions ---
	state_enter: =>
		@state = "entering"

		@_alpha_tween = @timer\tween TRANSITION_DURATION, @,
			{alpha: 1}, "linear", -> @state_start!

	state_exit: =>
		@state = "exiting"

		@_alpha_tween = @timer\tween TRANSITION_DURATION, @,
			{alpha: 0}, "linear", -> @exit_func @


	-- entering|resetting -> running
	state_start: =>
		@state = "running"

		if @_speed_tween then @timer\cancel @_speed_tween
		@speed = @game_speed

		@music\rewind!
		@music\play!


	-- running -> stopping
	state_stopping: =>
		@state = "stopping"

		@_speed_tween = @timer\tween @transition_duration,
			@, {speed: 0}, "linear", -> @state_stop!

		@for_all_blocks (block) ->
			block._alpha_tween = @timer\tween @transition_duration,
				block, {alpha: 1}, "linear"


	-- stopping -> stopped
	state_stop: =>
		@state = "stopped"

		if @_speed_tween then @timer\cancel @_speed_tween
		@speed = 0

		@for_all_blocks (block) ->
			if block._alpha_tween then @timer\cancel block._alpha_tween
			block.alpha = 1


	-- stopped -> resetting
	state_reset: =>
		@state = "resetting"

		@_speed_tween = @timer\tween @transition_duration,
			@, {speed: @game_speed}, "linear", ->
				@reset_level!
				@state_start!

		@for_all_blocks (block) ->
			block._alpha_tween = @timer\tween @transition_duration,
				block, {alpha: 0}, "linear"
	--- ==== ---


	--- Game logic ---
	reset_level: => 
		@load_level @level
		@done_first_beat = false


	load_level: (level) =>
		@grid_w = level.grid_w
		@grid_h = level.grid_h

		@blocks = {
			players: {}
			goals: {}
			obstacles: {}
		}

		if level
			for i = 1, @n_block_pairs
				player_data = @level.players[i]

				table.insert @blocks.players,
					(DynamicBlock @, @theme.BLOCK_PAIR_COLORS[i],
						player_data.x, player_data.y,
						player_data.direction)

				table.insert @blocks.goals,
					(GoalBlock @, @theme.BLOCK_PAIR_COLORS[i],
						0, 0)

				@re_place_block @blocks.goals[i]


			for obs_data in *level.obstacles
				Constructor = if obs_data.dynamic then DynamicBlock else StaticBlock

				table.insert @blocks.obstacles,
					(Constructor @, @theme.OBSTACLE_COLOR,
						obs_data.x, obs_data.y,
						obs_data.direction)

			@controls = generate_control_functions @blocks.players
	--- ==== ---


	--- Beat ---
	do_after_beats: (beats, callback) =>
		@beat_timer\after beats, callback
	--- ==== ---


	--- Block manipulation ---
	for_all_blocks: (callback) =>
		-- Do goals first because goals should be drawn first.
		for goal in *@blocks.goals
			callback goal

		for player in *@blocks.players
			callback player

		for obstacle in *@blocks.obstacles
			callback obstacle


	get_blocks_at: (x, y) =>
		blocks = {}

		@for_all_blocks (block) ->
			if block.x == x and block.y == y
				blocks[#blocks + 1] = block

		blocks


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
		@state_stopping!

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


	check_player_obstacle_collisions: =>
		collisions = {}

		for i, player in ipairs @blocks.players
			for obstacle in *@blocks.obstacles
				if @are_blocks_colliding player, obstacle
					collisions[#collisions + 1] = {player_i: i, obstacle: obstacle}

		if #collisions > 0
			@on_player_obstacle_collisions collisions
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
		beat_fraction = if @state == "running"
			current_beat = @music\pos_beats!
			beat_fraction = current_beat - math.floor(current_beat)

		@for_all_blocks (block) ->
			block\draw beat_fraction


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
