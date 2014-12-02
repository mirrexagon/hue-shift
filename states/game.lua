local game = {}

---

local beat = require("lib.self.beat")
local util = require("lib.self.util")

local World = require("logic.world")

---

local floor = math.floor

---

local GRID_BACKGROUND_ALPHA = 128
local GRID_LINES_ALPHA = 255

---

local BLOCK_CONTROLS = {
	[1] = {
		up = "w",
		right = "d",
		down = "s",
		left = "a"
	},
	[2] = {
		up = "t",
		right = "h",
		down = "g",
		left = "f"
	},
	[3] = {
		up = "i",
		right = "l",
		down = "k",
		left = "j"
	}
}

local control_functions

---

local world = World.new()

world.TRANSITION_DURATION = 0.5

---

function game:init()
	world:load_system_dir("systems")

	---

	world.beat_timers = {}

	function world:add_beat_timer(delay, func)
		table.insert(self.beat_timers, {delay = delay, func = func})
	end

	function world:step_beat_timers()
		for i, event in ipairs(world.beat_timers) do
			event.delay = event.delay - 1

			if event.delay == 0 then
				event.func(event.func)
				world.beat_timers[i] = nil
			end
		end
	end

	---

	world:spawn_entity{
		Obstacle = true,

		Position = {x = 0, y = 0},
		Color = {100, 100, 100},
		Active = true
	}

	-- Spawn player and goal blocks.
	world.player_blocks = {}
	world.player_blocks[1] = world:spawn_entity{
		Player = 1,

		Color = {255, 0, 0},
		Direction = "up",
		Active = false
	}
	world.player_blocks[2] = world:spawn_entity{
		Player = 2,

		Color = {0, 255, 0},
		Direction = "up",
		Active = false
	}
	world.player_blocks[3] = world:spawn_entity{
		Player = 3,

		Color = {0, 0, 255},
		Direction = "up",
		Active = false
	}

	world.goal_blocks = {}
	world.goal_blocks[1] = world:spawn_entity{
		Goal = 1,

		Color = {255, 0, 0},
		Active = false
	}
	world.goal_blocks[2] = world:spawn_entity{
		Goal = 2,

		Color = {0, 255, 0},
		Active = false
	}
	world.goal_blocks[3] = world:spawn_entity{
		Goal = 3,

		Color = {0, 0, 255},
		Active = false
	}
end

---

local function generate_control_functions(world, keyt)
	local funcs = {}

	for id, controls in ipairs(keyt) do
		for dir, key in pairs(controls) do
			funcs[key] = function()
				world.player_blocks[id].Direction = dir
			end
		end
	end

	return funcs
end

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

function game:enter(previous, arg)
	assert(arg.music and arg.bpm, "game: music path and/or BPM not supplied!")

	---

	world.grid_w = arg.grid_w or 7
	world.grid_h = arg.grid_h or 7

	world.tile_l = arg.tile_l or 32
	world.tile_pad = arg.tile_pad or 2

	---

	world.grid_alpha = 0

	---

	music = love.audio.newSource(arg.music)
	music:setLooping(true)
	world.music = music

	world.bpm = arg.bpm

	---

	world.game_speed = arg.game_speed or 1

	---

	world.npairs = arg.npairs or 1

	---

	control_functions = generate_control_functions(world, BLOCK_CONTROLS)

	---

	-- Can be: enter, game, lose, wait, reset, leave
	world.state = "enter"
end

---

function world:set_pair_active(id, active)
	local player = self.player_blocks[id]
	local goal = self.goal_blocks[id]

	player.Active = active
	goal.Active = active
end

function world:reset_player_blocks()
	self.player_blocks[1].Position = {x = 0, y = self.grid_h - 1}
	self.player_blocks[2].Position = {x = floor(self.grid_w/2), y = self.grid_h - 1}
	self.player_blocks[3].Position = {x = self.grid_w - 1, y = self.grid_h - 1}

	self.player_blocks[1].Direction = "up"
	self.player_blocks[2].Direction = "up"
	self.player_blocks[3].Direction = "up"
end

function world:place_goal(id)
	local goal = self.goal_blocks[id]
	local success = false

	for try = 1, 10 do
		local x = love.math.random(0, world.grid_w - 1)
		local y = love.math.random(0, world.grid_h - 1)

		local ok = true
		for i, entity in ipairs(self:get_entities_with{"Position"}) do
			if entity.Position.x == x and entity.Position.y == y then
				ok = false
				break
			end
		end
		if ok then
			goal.Position = {x = x, y = y}
			return
		end
	end

	if not success then util.printf("Could not place goal block %d", id) end
end

---

local norm_pitch = 1

function world:to_game()
	self.state = "game"

	---

	world.score = {
		[1] = 0,
		[2] = 0,
		[3] = 0
	}

	self.beat_timers = {}

	world.done_first_beat = false

	---

	for entity in pairs(self.entities) do
		entity.Blink = nil
		entity.InverseBlink = nil
	end

	world:reset_player_blocks()

	---

	for id = 1, 3 do
		world:set_pair_active(id, false)
	end

	for id = 1, world.npairs do
		world:set_pair_active(id, true)
		world:place_goal(id)
	end

	---

	norm_pitch = 1
	self.music:rewind()
	self.music:play()
end

function world:to_lose()
	self.state = "lose"

	-- TODO: Record score here
end

function world:to_wait()
	self.state = "wait"

	self.music:pause()
end

function world:to_reset()
	self.state = "reset"

	self.music:play()
end

local leave_func = love.event.quit
function world:leave_game(func)
	self.state = "leave"

	leave_func = func
end

---

local last_beat = 0
function game:update(dt)
	if world.state ~= "wait" then
		bg.update(dt * world.game_speed * norm_pitch)
	end

	---

	world.beat_duration = beat.absbeat_to_seconds(2, world.bpm * world.game_speed)

	if world.state == "enter" then
		---
		world.grid_alpha = world.grid_alpha + (1/world.TRANSITION_DURATION) * dt
		world:update(dt)

		if world.grid_alpha >= 1 then
			world.grid_alpha = 1

			world:to_game()
		end
		---
	elseif world.state == "game" then
		---
		local current_beat = beat.seconds_to_absbeat(world.music:tell(), world.bpm)
		local int_current_beat = floor(current_beat)

		if int_current_beat ~= last_beat then
			last_beat = int_current_beat

			-- This makes sure blocks don't move on the first beat
			-- of the first loop of the music.
			if int_current_beat == 2 then
				world.done_first_beat = true
			end

			world:step_beat_timers()
			world:emit_event("Beat", int_current_beat)
		end

		world.current_beat = current_beat

		world:update(dt)
		---
	elseif world.state == "lose" then
		---
		local new_pitch = norm_pitch - (1/world.beat_duration)*dt

		if new_pitch > 0 then
			norm_pitch = new_pitch
			world:update(dt)
		else
			world:to_wait()
		end

		---
	elseif world.state == "wait" then
		---
		world:update(dt)
		---
	elseif world.state == "reset" then
		---
		local new_pitch = norm_pitch + (1/world.beat_duration)*dt

		if new_pitch < 1 then
			norm_pitch = new_pitch
			world:update(dt)
		else
			world:to_game()
		end
		---
	elseif world.state == "leave" then
		---
		world.grid_alpha = world.grid_alpha - (1/world.TRANSITION_DURATION) * dt
		world:update(dt)

		if world.grid_alpha <= 0 then
			world.grid_alpha = 0

			leave_func()
		end
		---
	end

	world.music:setPitch(norm_pitch * world.game_speed)
end

function game:draw()
	world:draw{
		background = function()
			love.graphics.setColor(255, 255, 255, 200)
			bg.draw()

			draw_grid(world.grid_w, world.grid_h,
				world.tile_l, world.tile_l, world.tile_pad)
		end
	}
end

---

function game:keypressed(key)
	if key == " " and world.state == "wait" then
		world:to_reset()
	elseif key == "escape" then
		if world.state == "game" then
			world:to_lose()
		elseif world.state == "wait" then
			world:leave_game(love.event.quit)
		end

	elseif world.state == "game" and control_functions[key] then
		control_functions[key]()
	end
end

function game:mousepressed(x, y, b)
	if b == "wu" then
		world.game_speed = world.game_speed + 0.1
	elseif b == "wd" then
		world.game_speed = world.game_speed - 0.1
	end
end

---

function game:leave()
	for id = 1, 3 do
		world:set_pair_active(id, false)
	end
end

---

return game
