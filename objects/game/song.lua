--- Require ---
local class = require("lib.hump.class")

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

		-- TODO: Custom errors for meta file syntax.
		local meta = love.filesystem.read()

		-- TODO: Split into lines
		local name, bpm = meta:match("^(.+)\n(.+)")
		bpm = tonumber(bpm)

		self.name = name
		self.bpm = bpm
	end,

	---

	get_sec = function(self)
		return self.source:tell()
	end,

	get_beat = function(self)
		return beat.sectobeat(self:get_sec(), self.bpm)
	end
}
