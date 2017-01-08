--- Require ---
--- ==== ---


class Game
	new: =>
		-- Can be: entering, running, stopping, stopped, resetting, exiting
		@state = "entering"
		@speed = 1
		@theme = (require "themes.hue-shift")!

	---

	update: (dt) =>
		scaled_dt = dt * @speed

		@theme.background\update scaled_dt

	draw: =>
		@theme.background\draw!
