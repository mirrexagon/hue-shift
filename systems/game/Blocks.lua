local util = require("lib.self.util")

---

local DIRECTION_MAPPING = {
	up = {x = 0, y = -1},
	right = {x = 1, y = 0},
	down = {x = 0, y = 1},
	left = {x = -1, y = 0}
}

---

local function add_pair(t, ent1, ent2)
	t[ent1][ent2] = true
	t[ent2][ent1] = true
end

local function remove_pair(t, ent1, ent2)
	t[ent1][ent2] = nil
	t[ent2][ent1] = nil
end

local function check_pair(t, ent1, ent2)
	return t[ent1][ent2] --and t[ent2][ent1]
end

local function get_pairs(ent)
	return t[ent]
end

---

return {
	events = {
		{
			event = "Beat",
			func = function(world, beat)
				if beat < 2 then return end

				---

				local grid = setmetatable({},
					{
						__index = function(self, key)
							local t = {}
							rawset(self, key, t)
							return t
						end,

						__mode = "kv"
					}
				)

				local col_pairs = setmetatable({},
					{
						__index = function(self, key)
							local t = {}
							rawset(self, key, t)
							return t
						end,

						__mode = "kv"
					}
				)

				---

				for entity in pairs(world:get_entities_with{"Position", "Direction"}) do
					------
					local dir = DIRECTION_MAPPING[entity.Direction]

					entity.Position.x = (entity.Position.x + dir.x) % world.grid_w
					entity.Position.y = (entity.Position.y + dir.y) % world.grid_h

					---

					local cell
					if not grid[entity.Position.x][entity.Position.y] then
						cell = {}
						grid[entity.Position.x][entity.Position.y] = cell
					else
						cell = grid[entity.Position.x][entity.Position.y]
					end
					table.insert(cell, entity)

					---

					if #cell > 1 then
						for _, other in pairs(cell) do
							if other ~= entity and not check_pair(col_pairs, entity, other) then
								add_pair(col_pairs, entity, other)

								world:emit_event("BlockCollision", entity, other, entity.Position.x, entity.Position.y)
							end
						end
					end
					------
				end
			end
		},

		{ -- Goal or death.
			event = "BlockCollision",
			func = function(world, ent1, ent2, x, y)
				if ent1.Player or ent2.Player then
					local player, other
					if ent1.Player then
						player = ent1
						other = ent2
					else
						player = ent2
						other = ent1
					end

					---

					if other.Goal then
						if player.Player == other.Goal then
							-- Score!
						end
					elseif other.Obstacle then
						-- Death.
					end
				end
			end
		}
	}
}
