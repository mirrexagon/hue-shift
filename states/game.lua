local game = {}

---

local beat = require("lib.self.beat")

local World = require("logic.world")

---

local floor = math.floor

---

local GRID_BACKGROUND_ALPHA = 128
local GRID_LINES_ALPHA = 255

local TRANSITION_DURATION = 0.5
local LOSE_TRANS_DURATION = 0.5

---

local world = World.new()

local last_beat = 0
local beat_duration

local leave_func = love.event.quit

---

function game:init()
	world:load_system_dir("systems")
end

---

local function draw_grid(grid_w, grid_h, tile_w, tile_h, tile_pad)
	local grid_pixel_w = (grid_w * tile_w) + ((grid_w + 1) * tile_pad)
	local grid_pixel_h = (grid_h * tile_h) + ((grid_h + 1) * tile_pad)

	local grid_pad_w = (love.graphics.getWidth() - grid_pixel_w) / 2
	local grid_pad_h = (love.graphics.getHeight() - grid_pixel_h) / 2

	---

	-- Grid background.
	love.graphics.setColor(255, 255, 255, world.grid_alpha * GRID_BACKGROUND_ALPHA)
	love.graphics.rectangle("fill", grid_pad_w, grid_pad_h, grid_pixel_w, grid_pixel_h)

	-- Grid lines.
	love.graphics.setColor(255, 255, 255, world.grid_alpha * GRID_LINES_ALPHA)

	for v = 0, grid_w do
		love.graphics.rectangle("fill",
			grid_pad_w + v*tile_w + v*tile_pad, grid_pad_h, tile_pad, grid_pixel_h)
	end

	for h = 0, grid_h do
		love.graphics.rectangle("fill",
			grid_pad_w, grid_pad_h + h*tile_h + h*tile_pad, grid_pixel_w, tile_pad)
	end

	---

	--world.grid_pixel_w = grid_pixel_w
	--world.grid_pixel_h = grid_pixel_h

	world.grid_pad_w = grid_pad_w
	world.grid_pad_h = grid_pad_h
end

---

function game:enter(previous, music, bpm, grid_w, grid_h)
	assert(music and bpm, "game: music path and/or BPM not supplied!")

	---

	world.grid_w = grid_w or 8
	world.grid_h = grid_h or 8

	world.tile_l = 32
	world.tile_pad = 2

	---

	world.grid_alpha = 0

	---

	music = love.audio.newSource(music)
	music:setLooping(true)

	world.music = music
	world.bpm = bpm

	---

	-- Can be: enter, game, lose, wait, reset, leave
	world.state = "enter"
end

---

function world.start_game()
	world.state = "game"

	world.music:rewind()
	world.music:play()
end

function world.lose_game()
	world.state = "lose"

	beat_duration = beat.absbeat_to_seconds(2, world.bpm)
end

function world.wait_game()
	world.state = "wait"

	world.music:pause()
end

function world.reset_game()
	world.state = "reset"

	world.music:play()
end

function world.leave_game(func)
	world.state = "leave"

	leave_func = func
end

---

function game:update(dt)
	if world.state == "enter" then
		---
		world.grid_alpha = world.grid_alpha + (1/TRANSITION_DURATION) * dt
		world:update(dt)

		if world.grid_alpha >= 1 then
			world.grid_alpha = 1

			world.start_game()
		end
		---
	elseif world.state == "game" then
		---
		local current_beat = beat.seconds_to_absbeat(world.music:tell(), world.bpm)

		if floor(current_beat) ~= last_beat then
			last_beat = floor(current_beat)

			world:emit_event("Beat", floor(current_beat))
		end

		world.current_beat = current_beat

		world:update(dt)
		---
	elseif world.state == "lose" then
		---
		local new_pitch = world.music:getPitch() - (1/beat_duration)*dt

		if new_pitch > 0 then
			world.music:setPitch(new_pitch)
			world:update(dt)
		else
			world.wait_game()
		end

		---
	elseif world.state == "wait" then
		---
		world:update(dt)
		---
	elseif world.state == "reset" then
		---
		local new_pitch = world.music:getPitch() + (1/beat_duration)*dt

		if new_pitch < 1 then
			world.music:setPitch(new_pitch)
			world:update(dt)
		else
			world.music:setPitch(1)

			world.start_game()
		end
		---
	elseif world.state == "leave" then
		---
		world.grid_alpha = world.grid_alpha - (1/TRANSITION_DURATION) * dt
		world:update(dt)

		if world.grid_alpha <= 0 then
			world.grid_alpha = 0

			leave_func()
		end
		---
	end
end

function game:draw()
	world:draw{
		background = function()
			-- TODO: background

			draw_grid(world.grid_w, world.grid_h,
				world.tile_l, world.tile_l, world.tile_pad)
		end
	}
end

---

function game:keypressed(key)
	if key == " " and world.state == "wait" then
		world.reset_game()
	elseif key == "escape" then
		if world.state == "game" then
			world.lose_game()
		elseif world.state == "wait" then
			world.leave_game(love.event.quit)
		end
	end
end

---

function game:leave()

end

---

return game
