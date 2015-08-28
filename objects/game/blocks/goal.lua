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


--- Class definition ---
local GoalBlock = {__includes = Block}
--- ==== ---


--- Class functions ---
function GoalBlock:init(args)
	args.fade_time = 0.5

	Block.init(self, args)
end
--- ==== ---


return Class(GoalBlock)

