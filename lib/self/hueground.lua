local hg = {}

local sin = math.sin

local timer = 0

function hg.update(dt)
  timer = timer + dt
end

-- Default: 0.1,0.9,0.1,0.1,0.1,0.8
local a,b,c,d,e,f = 0.1,0.1,0.1,0.1,0.1,0.8

local function getPixelColor(x,y,time)
  return {
    sin(time + x*a)*127+128,
    sin(time*b + y*c)*127+128,
    sin(x*d+y*e-time*f)*127+128,
    255
  }
end

local function makeBGImage(time)
  local bg = love.image.newImageData(love.graphics.getWidth()/100,love.graphics.getHeight()/100)
  for x = 0,bg:getWidth() - 1 do
    for y = 0,bg:getHeight() - 1 do
      bg:setPixel(x,y,unpack(getPixelColor(x,y,timer)))
    end
  end
  return love.graphics.newImage(bg)
end

function hg.draw()
  love.graphics.draw(makeBGImage(),0,0,0,110,110)
end

return hg
