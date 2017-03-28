--- Import ---
import Block from require "blocks"
--- ==== ---


class GoalBlock extends Block
	new: (game, color, x, y) =>
		super game, color, x, y

		@direction = direction

		@fade_time = 0.5


{ :GoalBlock }
