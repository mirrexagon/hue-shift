--- Require ---
local class = require("lib.hump.class")
local util = require("lib.self.util")

local beat = require("util.beat")
--- ==== ---


return Class{
	init = function(self, path)
		local meta_path = path .. ".meta"

		if not (love.filesystem.isFile(path)
			and love.filesystem.isFile(meta_path))
		then
			error(path .. " and/or its .meta file do not exist", 2)
		end

		---

		self.source = love.audio.newSource(path)
		self.source:setLooping(true)

		---

		for line in love.filesystem.lines(meta_path) do
			local key, value = line:match("^(%w+)%s-%=%s-(.-)$")

			self[key] = value
		end

		assert(util.table.check(self, {
			"name",
			"bpm"
		}))
	end,

	---

	get_sec = function(self)
		return self.source:tell()
	end,

	get_beat = function(self)
		return beat.sectobeat(self:get_sec(), self.bpm)
	end
}
