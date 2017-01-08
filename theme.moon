--! Base classes for themes.


-- TODO: How to allow sync with beat?
class Background
	new: =>
	update: (dt) =>
	draw: =>


class Theme
	new: (Background) =>
		@background = Background!


{ :Background, :Theme }