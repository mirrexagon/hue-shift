--- Require ---
local Class = require("lib.hump.class")
local util = require("lib.self.util")
--- ==== ---


--- Class definition ---
local Block = {}
--- ==== ---


--- Class functions ---
function Block:init(args)
	self.type = args.type
	self.color = args.color
end
--- ==== ---


return Class(Block)
