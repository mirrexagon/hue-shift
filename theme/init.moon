-- Base classes for themes.


-- TODO: How to allow sync with beat?
class Background
	new: =>
	update: (dt) =>
	draw: =>


class Theme
	BLOCK_PAIR_COLORS: {
		{255, 0, 0},
		{0, 255, 0},
		{0, 0, 255}
	}

	OBSTACLE_COLOR: {100, 100, 100}
	
	---

	new: =>


{ :Background, :Theme }