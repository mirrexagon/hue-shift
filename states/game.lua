local game = {}

---

local World = require("logic.world")

---

local GRID_BACKGROUND_ALPHA = 128
local GRID_LINES_ALPHA = 255

---

-- Can be: enter, game, lose, reset, leave
local state = "enter"

local leave_state

local world

---

function game:init()
	world = World.new()
	world:load_system_dir("systems")
end

---

local function draw_grid(grid_w, grid_h, tile_w, tile_h, tile_pad)
	local gridpixw = (grid_w * tile_w) + ((grid_w + 1) * tile_pad)
	local gridpixh = (grid_h * tile_h) + ((grid_h + 1) * tile_pad)

	local screenpadw = (love.graphics.getWidth() - gridpixw) / 2
	local screenpadh = (love.graphics.getHeight() - gridpixh) / 2

	---

	-- Grid background.
	love.graphics.setColor(255, 255, 255, world.grid_alpha * GRID_BACKGROUND_ALPHA)
	love.graphics.rectangle("fill", screenpadw, screenpadh, gridpixw, gridpixh)

	-- Grid lines.
	love.graphics.setColor(255, 255, 255, world.grid_alpha * GRID_LINES_ALPHA)

	for v = 0, grid_w do
		love.graphics.rectangle("fill",
			screenpadw + v*tile_w + v*tile_pad, screenpadh, tile_pad, gridpixh)
	end

	for h = 0, grid_h do
		love.graphics.rectangle("fill",
			screenpadw, screenpadh + h*tile_h + h*tile_pad, gridpixw, tile_pad)
	end
end

---

function game:enter(previous, grid_w, grid_h)
	world.grid_w = grid_w or 8
	world.grid_h = grid_h or 8

	world.tile_w = 32
	world.tile_h = 32
	world.tile_pad = 2

	---

	world.grid_alpha = 0
	world.transition_duration = 1

	---

	state = "enter"
end

---

local function start_game()
	state = "game"
end

local function lose_game()
	state = "lose"
end

local function reset_game()
	state = "reset"
end

local function leave_game(next_state)
	state = "leave"
	leave_state = next_state
end

---

function game:update(dt)
	if state == "enter" then
		---
		world.grid_alpha = world.grid_alpha + (1/world.transition_duration) * dt

		if world.grid_alpha >= 1 then
			world.grid_alpha = 1

			start_game()
		end
		---
	elseif state == "game" then
		---
		world:update(dt)
		---
	elseif state == "lose" then
		---
		---
	elseif state == "reset" then
		---
		---
	elseif state == "leave" then
		---
		world.grid_alpha = world.grid_alpha - (1/world.transition_duration) * dt

		if world.grid_alpha <= 0 then
			world.grid_alpha = 0

			gs.switch(leave_state)
		end
		---
	end
end

function game:draw()
	world:draw{
		background = function()
			-- TODO: background

			draw_grid(world.grid_w, world.grid_h,
				world.tile_w, world.tile_h, world.tile_pad)
		end
	}
end

function game:leave()

end

---

return game
