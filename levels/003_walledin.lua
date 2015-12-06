local level = {
	name = "walled in",

	grid = {
		w = 9,
		h = 9
	},

	players = {
		[1] = {
			x = 1,
			y = 7,

			direction = "up"
		},

		[2] = {
			x = 4,
			y = 7,

			direction = "up"
		},

		[3] = {
			x = 7,
			y = 7,

			direction = "up"
		}
	}
}

---

local obstacles = {}

-- Top and bottom rows.
for x = 0, level.grid.w - 1 do
	obstacles[#obstacles + 1] = {
		x = x,
		y = 0,

		type = "static"
	}

	obstacles[#obstacles + 1] = {
		x = x,
		y = level.grid.h - 1,

		type = "static"
	}
end

-- Sides.
for y = 1, level.grid.h - 2 do
	obstacles[#obstacles + 1] = {
		x = 0,
		y = y,

		type = "static"
	}

	obstacles[#obstacles + 1] = {
		x = level.grid.w - 1,
		y = y,

		type = "static"
	}
end

level.obstacles = obstacles

---

return level
