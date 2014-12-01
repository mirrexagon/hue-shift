local ces = require("lib.self.ces")

local signal = require("lib.hump.signal")
local timer = require("lib.hump.timer")

local util = require("lib.self.util")

---

local clamp = util.math.clamp

---

local world = {}
world.__index = world

---

function world:register_event(event, func)
	self.signal.register(event, func)
end

function world:emit_event(event, ...)
	self.signal.emit(event, self, ...)
end

---

function world:add_timer(delay, func)
	return self.timer.add(delay, func)
end

function world:add_periodic_timer(delay, func)
	return self.timer.addPeriodic(delay, func)
end

---

function world:spawn_entity(t)
	local entity = self.ces:spawn_entity(t)

	if entity.OnSpawn then
		entity:OnSpawn(self)
	end

	return entity
end

function world:get_entities_with(components)
	return self.ces:get_entities_with(components)
end

function world:destroy_entity(entity)
	self.ces:destroy_entity(entity)

	if entity.OnDestroy then
		entity:OnDestroy(self)
	end
end

function world:clear_entities()
	self.ces:clear_entities()
end

function world:add_system(arg)
	self.ces:add_system(arg)
end

function world:run_systems(kind, ...)
	self.ces:run_systems(kind, self, ...)
end

function world:load_system_dir(dir)
	for _, item in ipairs(love.filesystem.getDirectoryItems(dir)) do
		if love.filesystem.isDirectory(dir .. "/" .. item) then
			self:load_system_dir(dir .. "/" .. item)
		else
			local t = love.filesystem.load(dir .. "/" .. item)()

			if type(t) ~= "table" then
				error(("System file \"%s\" doesn't return a table!"):format(dir .."/" .. item))
			end

			if t.systems then
				for _, system in ipairs(t.systems) do
					self:add_system(system)
				end
			end
			if t.events then
				for _, eventitem in pairs(t.events) do
					self:register_event(eventitem.event, eventitem.func)
				end
			end
		end
	end
end

---

function world:update(dt)
	self.timer:update(dt)
	self:run_systems("update", dt)
end

function world:draw(funcs)
	if funcs.background then
		funcs.background(self)
	end

	---

	self:run_systems("draw")

	---

	if funcs.ui then
		funcs.ui(self)
	end
end

---

local function new()
	local w = {
		ces = ces.new(),
		signal = signal.new(),
		timer = timer.new()
	}

	w.entities = w.ces.entities

	return setmetatable(w, world)
end

return {
	new = new
}
