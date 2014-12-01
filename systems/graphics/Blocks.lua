local beat = require("lib.self.beat")

local util = require("lib.self.util")

---

local floor = math.floor

---

local function get_draw_info(grid_x, grid_y, world)
	local tile_l = world.tile_l
	local tile_pad = world.tile_pad

	local grid_pad_w = world.grid_pad_w
	local grid_pad_h = world.grid_pad_h

	---

	return
		grid_pad_w + grid_x*tile_l + (grid_x + 1)*tile_pad,
		grid_pad_h + grid_y*tile_l + (grid_y + 1)*tile_pad,
		tile_l
end

---

local img_arrow = love.graphics.newImage("graphics/arrow.png")

local ROTATION_MAPPING = {
	up = 0,
	right = math.pi/2,
	down = math.pi,
	left = 3*math.pi/2
}

local DYNAMIC_FADE_TIME = 0.2
local GOAL_FADE_TIME = 0.5

---

local blink_dir = 1
local blink_var = 0

---

return {
	systems = {
		{
			name = "UpdateBlockAlpha",
			requires = {"Color", "Active"},
			update = function(entity, world, dt)
				if not entity.Alpha then
					entity.Alpha = 0
				end

				if world.state == "enter" then

					entity.Alpha = 0

				elseif world.state == "game" then

					local current_beat = world.current_beat
					local beat_fraction = current_beat - math.floor(current_beat)

					local fade_time
					if entity.Direction then
						fade_time = DYNAMIC_FADE_TIME
					elseif entity.Goal then
						fade_time = GOAL_FADE_TIME
					else
						entity.Alpha = entity.Alpha + (2/beat.absbeat_to_seconds(2, world.bpm)) * dt
						if entity.Alpha < 1 then
							entity.Alpha = 1
						end
						return
					end

					---

					if (beat_fraction < fade_time) or (beat_fraction > (1 - fade_time)) then
						entity.Alpha = (beat_fraction < fade_time
							and beat_fraction or 1 - beat_fraction) / fade_time
					else
						entity.Alpha = 1
					end

				elseif world.state == "lose" or world.state == "wait" then

					if entity.Blink or entity.InverseBlink then
						blink_var = blink_var + blink_dir * dt
						if blink_var > 1 or blink_var < 0 then
							blink_var = util.math.clamp(0, blink_var, 1)
							blink_dir = blink_dir * -1
						end

						entity.Alpha = entity.InverseBlink and 1 - blink_var or blink_var
					else
						entity.Alpha = entity.Alpha + (2/beat.absbeat_to_seconds(2, world.bpm)) * dt
						if entity.Alpha > 1 then
							entity.Alpha = 1
						end
					end

				elseif world.state == "reset" then

					entity.Alpha = entity.Alpha - (1/world.TRANSITION_DURATION) * dt
					if entity.Alpha > 0 then
						entity.Alpha = 0
					end

				elseif world.state == "leave" then

					entity.Alpha = world.grid_alpha

				end
			end
		},

		{
			name = "DrawBlock",
			priority = 0,
			requires = {"Position", "Color", "Alpha", "Active"},
			draw = function(entity, world)
				local color = entity.Color
				love.graphics.setColor(color[1], color[2], color[3], (entity.Alpha or 1) * 255)

				local x,y, tl = get_draw_info(entity.Position.x, entity.Position.y, world)
				love.graphics.rectangle("fill", x,y, tl,tl)

				---

				love.graphics.setColor(255, 255, 255, (entity.Alpha or 1) * 255)

				if entity.Direction then
					love.graphics.draw(
						img_arrow,
						x+tl/2, y+tl/2,
						ROTATION_MAPPING[entity.Direction],
						1, 1,
						tl/2, tl/2
					)
				elseif not entity.Goal then
					love.graphics.circle(
						"fill",
						x+tl/2, y+tl/2,
						tl * (5/16)
					)
				end
			end
		}
	}
}
