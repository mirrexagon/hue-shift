--- Require ---
local Class = require("lib.hump.class")
local util = require("lib.self.util")

local beat = require("util.beat")
--- ==== ---


--- Class definition ---
local Song = {}
--- ==== ---


--- Class functions ---
function Song:init(path)
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

		if value == "true" or value == "yes" then
			value = true
		elseif value == "false" or value == "no" then
			value = false
		end

		self[key] = value
	end

	assert(util.table.check(self, {"name", "bpm"}))
end

---

function Song:get_sec()
	return self.source:tell()
end

function Song:get_beat()
	return beat.sectobeat(self:get_sec(), self.bpm)
end

---

function Song:_set_pitch(pitch)
	self.source:setPitch(pitch)
end

function Song:set_pitch(pitch)
	if pitch < 0.001 then
		if not self:is_paused() then
			self:pause()
		end
	else
		self:_set_pitch(pitch)
		if self:is_paused() then
			self:play()
		end
	end
end

---

function Song:pause()
	self.source:pause()
end

function Song:is_paused()
	return self.source:isPaused()
end

function Song:rewind()
	self.source:rewind()
end

function Song:play()
	self.source:play()
end
--- ==== ---


return Class(Song)
