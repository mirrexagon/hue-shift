--- Import ---
import linear_map from require "util.math"
--- ==== ---


--- Helpers ---
-- TODO: Different alpha curves for different songs (eg. snappy).
default_alpha_curve = (block, beat_fraction) ->
	right_time = clamp(0.5, block.fade_time, 1)
	left_time = 1 - right_time

	if beat_fraction <= left_time then
		return linear_map(beat_fraction, 0,left_time, 0,1)
	elseif beat_fraction >= right_time then
		return linear_map(beat_fraction, right_time,1, 1,0)
	else
		return 1
--- ==== ---


--- Base class for blocks.
class Block
	new: (game, color, x, y) =>
		@game = game
		@w = game.grid_cell_w
		@h = game.grid_cell_h

		@x = x
		@y = y

		@color = color

		@alpha_curve = default_alpha_curve

		-- Fade alpha, will be modified externally.
		@alpha = 0


	step: =>


	compute_alpha: (beat_fraction) =>
		@alpha_curve beat_fraction


	draw_block: (x, y) =>
		love.graphics.rectangle "fill", x, y, @w, @h


	draw_symbol: (x, y) =>


	draw_at: (x, y) =>
		alpha = compute_alpha!

		love.graphics.setColor @color[1], @color[2], @color[3],
			255 * alpha
		@draw_block x, y

		love.graphics.set_color 255, 255, 255, 255 * alpha
		@draw_symbol x, y


	draw: =>
		draw_at @game\pixel_coords @x, @y

{ :Block }