--- Import ---
import Block from require "blocks"
--- ==== ---


--- Constants ---
DIRECTION_MAPPING = {
	up: {x: 0, y: -1}
	right: {x: 1, y: 0}
	down: {x: 0, y: 1}
	left: {x: -1, y: 0}
}

ROTATION_MAPPING = {
	up: 0
	right: math.pi/2
	down: math.pi
	left: 3*math.pi/2
}
--- ==== ---


--- Assets ---
img_arrow = love.graphics.newImage "assets/graphics/arrow.png"
--- ==== ---


--- Blocks that move in the direction they're facing, one cell per beat.
class DynamicBlock
	new: (game, color, x, y, direction) =>
		super game, color, x, y

		@direction = direction

		-- On 80% of the beat, fade during the leading and ending 10%s
		@fade_time = 0.8


	set_direction: (dir) =>
		@direction = dir


	step: =>
		dirmap = DIRECTION_MAPPING[@direction]
	
		@x = (@x + dirmap.x) % @grid.w
		@y = (@y + dirmap.y) % @grid.h


	draw_symbol: (x, y) =>
		min_wh = math.min(@w, @h)

		love.graphics.draw(
			img_arrow,
			x + @w/2, y + @h/2,
			ROTATION_MAPPING[@direction],
			1, 1,
			min_wh/2, min_wh/2)
