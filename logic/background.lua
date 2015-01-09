local bg = {}

---

local sin = math.sin

---

local IMG_W = 6
local IMG_H = 6
local OPT_SCREEN_W = 600
local OPT_SCREEN_H = 600

local timer = 0

function bg.update(dt)
	timer = timer + dt
end

---

-- This piece of magic comes from http://www.love2d.org/wiki/Chromatic_Paths
local a,b,c,d,e,f = 0.1,0.1,0.1,0.1,0.1,0.8
local function get_pixel_color(x,y, time)
	return
		sin(time + x*a)*127+128,
		sin(time*b + y*c)*127+128,
		sin(x*d+y*e-time*f)*127+128,
		255
end

local function make_image(time)
	local imagedata = love.image.newImageData(IMG_W, IMG_H)

	for x = 0, imagedata:getWidth() - 1 do
		for y = 0, imagedata:getHeight() - 1 do
			imagedata:setPixel(x,y, get_pixel_color(x,y, time))
		end
	end

	return love.graphics.newImage(imagedata)
end

function bg.draw()
	local screenw, screenh = love.graphics.getDimensions()
	love.graphics.draw(make_image(timer), 0,0, 0,
		screenw / IMG_W,screenh / IMG_H)
end

function bg.set_timer(t)
	timer = t
end

---

return bg
