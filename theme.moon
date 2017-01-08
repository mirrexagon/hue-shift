--! Base classes for themes.
--!
--! These only serve as a reference and have no other function.


-- TODO: How to allow sync with beat?
class Background
	new: =>
	update: (dt) =>
	draw: =>


class Theme
	new: (Background) =>
		@background = Background!


{ :Background, :Theme }