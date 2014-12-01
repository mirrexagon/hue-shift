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

				local x,y, tl = get_draw_info(entity.Position.x, entity.Position.y, world)
				love.graphics.rectangle("fill", x,y, tl,tl)
			end
		},

		{
			name = "DrawBlockIcon",
			priority = -1,
			requires = {"Position", "Color"},
			draw = function(entity, world)
				local x,y, tl = get_draw_info(entity.Position.x, entity.Position.y, world)

				love.graphics.setColor(255, 255, 255, 255)

				if entity.Direction then
					love.graphics.draw(
						img_arrow,
						x+tl/2, y+tl/2,
						rotation_mapping[entity.Direction],
						1, 1,
						tl/2, tl/2
					)
				else
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
