local function get_draw_info(grid_x, grid_y, world)
	local tile_w = world.tile_w
	local tile_h = world.tile_h
	local tile_pad = world.tile_pad

	local grid_pad_w = world.grid_pad_w
	local grid_pad_h = world.grid_pad_h

	---

	return
		grid_pad_w + grid_x*tile_w + (grid_x + 1)*tile_pad,
		grid_pad_h + grid_y*tile_h + (grid_y + 1)*tile_pad,
		tile_w, tile_h
end

---

local img_arrow = love.graphics.newImage("graphics/arrow.png")

local rotation_mapping = {
	up = 0,
	right = math.pi/2,
	down = math.pi,
	right = 3*math.pi/2
}

---

return {
	systems = {
		{
			name = "DrawBlockColor",
			priority = 0,
			requires = {"Position", "Color"},
			draw = function(entity, world)
				local color = entity.Color
				love.graphics.setColor(color[1], color[2], color[3], (entity.Alpha or 1) * 255)

				love.graphics.rectangle("fill",
					get_draw_info(entity.Position.x, entity.Position.y, world))
			end
		},

		{
			name = "DrawBlockIcon",
			priority = -1,
			requires = {"Position", "Color"},
			draw = function(entity, world)
				local x,y, tw,th = get_draw_info(entity.Position.x, entity.Position.y, world)

				love.graphics.setColor(255, 255, 255, 255)

				if entity.Direction then
					love.graphics.draw(
						img_arrow,
						x+tw/2, y+tw/2,
						rotation_mapping[entity.Direction],
						1, 1,
						tw/2, th/2
					)
				else
					love.graphics.circle(
						"fill",
						x+tw/2, y+tw/2,
						tw * (5/16)
					)
				end
			end
		}
	}
}
