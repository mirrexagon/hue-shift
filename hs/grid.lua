local grid = {}

require('lib.self.util')

-- Values that are set by user.
local tilew,tileh
local gridw,gridh
local gridpad

-- Values that are calculated from set values.
--local screenw,screenh
local gridpixw,gridpixh
local screenpadw,screenpadh

local GRID_BG_ALPHA_MOD = 128

function grid.set(gw,gh,tw,th,pad)
  gridw = gw or 8
  gridh = gh or 8

  tilew = tw or 32
  tileh = th or 32

  gridpad = pad or 2

  -- Calculated values.
  --screenw = love.graphics.getWidth()
  --screenh = love.graphics.getHeight()

  gridpixw = (gridw*tilew) + ((gridw+1)*gridpad)
  gridpixh = (gridh*tileh) + ((gridh+1)*gridpad)

  --screenpadw = (love.graphics.getWidth() - gridpixw)/2
  --screenpadh = (love.graphics.getHeight() - gridpixh)/2
end

function grid.draw(gridalpha)
  screenpadw = (love.graphics.getWidth() - gridpixw)/2
  screenpadh = (love.graphics.getHeight() - gridpixh)/2

  love.graphics.setColor(255,255,255,((gridalpha - GRID_BG_ALPHA_MOD < 0) and 0 or gridalpha - GRID_BG_ALPHA_MOD))
  love.graphics.rectangle('fill',screenpadw,screenpadh,gridpixw,gridpixh)

  love.graphics.setColor(255,255,255,gridalpha)
  -- Vertical lines.
  for i=0,gridw do
    love.graphics.rectangle('fill',i*tilew+i*gridpad+screenpadw,screenpadh,gridpad,gridpixh)
  end
  -- Horizontal lines.
  for i=0,gridh do
    love.graphics.rectangle('fill',screenpadw,i*tileh+i*gridpad+screenpadh,gridpixw,gridpad)
  end
end

function grid.getInfo()
  return gridw,gridh,tilew,tileh
end

function grid.getPixDim()
	return gridpixw,gridpixh
end

function grid.getDrawPosition(gx,gy)
  if (gx > 0 and gx <= gridw) and (gy > 0 and gx <= gridh) then
    return (gx-1)*tilew + gx*gridpad + screenpadw,(gy-1)*tilew + gy*gridpad + screenpadh,tilew,tileh
  end
end

return grid
