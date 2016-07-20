--- Require ---
local Class = require("lib.hump.class")
local timer = require("lib.hump.timer")

local util = require("lib.self.util")
--- ==== ---


--- Localised functions ---
--- ==== ---


--- Classes ---
--- ==== ---


--- Class definition ---
local MenuItem = {}
--- ==== ---


--- Class functions ---
function MenuItem:init(h, draw)
	self.h = h
	self.xdraw = draw
end

---

function MenuItem:get_width()

end

function MenuItem:get_height()

end

---

function MenuItem:update(dt)

end


function MenuItem:xdraw(h)

end

function MenuItem:draw()
	-- Box - handle in Menu?

	-- xdraw
end


function MenuItem:keypressed(k)

end
--- ==== ---


return Class(MenuItem)
