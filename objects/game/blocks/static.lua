--- Require ---
local Class = require("lib.hump.class")
local util = require("lib.self.util")
--- ==== ---


--- Classes ---
local Block = require("objects.game.blocks.block")
--- ==== ---


--- Localised functions ---
local floor = math.floor
local min = math.min
--- ==== ---


--- Constants ---
local STATIC_DOT_SIZE_MULT = 5/16
--- ==== ---


--- Class definition ---
local StaticBlock = {__includes = Block}
--- ==== ---


--- Class functions ---
function StaticBlock:init(args)
	args.fade_time = 1

	Block.init(self, args)
end

---

function StaticBlock:draw_symbol(draw_x, draw_y, tile_w, tile_h)
	local min_wh = min(tile_w, tile_h)
	love.graphics.circle("fill", draw_x + tile_w/2, draw_y + tile_h/2, min_wh * STATIC_DOT_SIZE_MULT)
end
--- ==== ---


return Class(StaticBlock)

