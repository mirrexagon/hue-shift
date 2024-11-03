game = {}

-- TODO: music is controlled by this file, hsgame exposes moveBlock for this to call?

local hsgame = require('hs.hsgame')

local fadeAlpha = 0
local fadeState = 'in'

local BLOCK_COLORS = {
  obstacle = {100,100,100},
  player = {
    {255,20,20},{20,255,20},{20,20,255}
  },
  goal = {
    {255,100,100},{100,255,100},{100,100,255}
  }
}

local TRANSITION_DUR = {
  fadein = 0.5,
  fadeout = 0.5
}

function game:init()
	hsgame.init()
end

function game:enter()
	fadeAlpha = 0
	fadeState = 'in'

	hsgame.setup(
		8,8, -- Grid width,height

		{
			{
				x = 4,
				y = 4,
				kind = 'player',
				color = BLOCK_COLORS.player[1],
				static = false,
				pid = 1
			},

			{
				x = 5,
				y = 4,
				kind = 'player',
				color = BLOCK_COLORS.player[2],
				static = false,
				pid = 2
			},

			{
				x = 7,
				y = 5,
				kind = 'obstacle',
				color = BLOCK_COLORS.obstacle,
				static = false
			},
			{
				x = 2,
				y = 2,
				dir = 2,
				kind = 'obstacle',
				color = BLOCK_COLORS.obstacle,
				static = false
			}
		},

		'laserwash' -- Music
	)
end

local function fadeIn()
  fadeState = 'in'
  fadeAlpha = 0
end

local function fadeOut()
  fadeState = 'out'
end

local keydown = love.keyboard.isDown
function game:update(dt)
	hg.update(dt * hsgame.getSpeedFactor())

	if fadeState == 'in' then
    if fadeAlpha < 255 then
      fadeAlpha = fadeAlpha + (255/TRANSITION_DUR['fadein'])*dt
    end
    if fadeAlpha >= 255 then
      fadeAlpha = 255
			fadeState = 'none'
      hsgame.start()
    end
  elseif fadeState == 'out' then
    if fadeAlpha > 0 then
      fadeAlpha = fadeAlpha - (255/TRANSITION_DUR['fadeout'])*dt
    end
    if fadeAlpha <= 0 then
      fadeAlpha = 0
			fadeState = 'none'
      gs.switch(menu)
    end
  else
		hsgame.update(dt)
		if keydown('up') then
			hsgame.setSpeedFactor(hsgame.getSpeedFactor() + 0.4*dt)
		elseif keydown('down') then
			hsgame.setSpeedFactor(hsgame.getSpeedFactor() - 0.4*dt)
		end
	end
end

function game:draw()
  love.graphics.setColor(255,255,255)
  hg.draw()

	if fadeState == 'in' or fadeState == 'out' then
		hsgame.draw(fadeAlpha)
	else
		hsgame.draw()
	end
end

function game:keypressed(k,c)
	if hsgame.keypressed(k,c) then
		fadeOut()
	end
end

function game:mousepressed(x,y,b)
	if b == 'wu' then
		hsgame.setSpeedFactor(hsgame.getSpeedFactor() * 1.05)
	elseif b == 'wd' then
		hsgame.setSpeedFactor(hsgame.getSpeedFactor() / 1.05)
	end
end
