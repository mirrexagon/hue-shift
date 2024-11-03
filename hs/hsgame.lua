local hsgame = {}

-- TODO: on lose, blocks still flash but don't move until gameSpeedFactor == 0 then they go solid.
-- TODO: make event system (callbacks?).

local grid = require('hs.grid')
local block = require('hs.block')
local music = require('hs.music')
require('lib.self.util')

local BLOCK_CONTROLS = {
  [1] = {
    [0] = 'w',
    [1] = 'd',
    [2] = 's',
    [3] = 'a'
  },
  [2] = {
    [0] = 't',
    [1] = 'h',
    [2] = 'g',
    [3] = 'f'
  },
  [3] = {
    [0] = 'i',
    [1] = 'l',
    [2] = 'k',
    [3] = 'j'
  }
}

local BLOCK_CONTROL_FUNCS = {}

local FADE_THRES = {
  static = 0,
  dynamic = 0.2,
  goal = 0.5,
	grid = 0.2
}

local TRANSITION_DUR = {
  stop = 0.6,
  reset = 0.6
}

local gamestate

local resetReady = false

-- Controls music speed and background speed. 1 = normal speed.
local gameSpeedFactor = 1

local gridScale = 1 -- Scale of grid including everything on it.

function hsgame.start()
  gamestate = 'game'
	gameSpeedFactor = 1
  music.stop()
  music.resume()
end

function hsgame.stop()
  gamestate = 'stop'
end

function hsgame.reset()
  gamestate = 'reset'
	for b in block.getAll() do
		b.flashing = false
		b.flashInverted = false
	end
  resetReady = false
  music.resume()
end

-- Moves all blocks one grid cell in their current direction.
-- Meant to be called on every beat.
local function moveBlocks()
  local gridw,gridh = grid.getInfo()
  for b in block.getAll() do
    if not b.static then
      b:move(b.dir,gridw,gridh)
    end
  end
end

function hsgame.init()
	debugFont = love.graphics.newFont(14)

  music.onBeat = function(beat,first)
    if not first then
      moveBlocks()

			-- Collision checking.
			for _,b in ipairs(block.getKind('player')) do
				for _,cb in ipairs(block.getAt(b.x,b.y)) do
					if cb.kind == 'obstacle' then
						hsgame.stop()
						b.flashing = true
						cb.flashing = true
						cb.flashInverted = true
					elseif cb.kind == 'goal' then
						if cb.pid == b.pid then -- Goal got!

						end
					end
				end
			end
		end
  end

  grid.set()

  -- Generate control list.
  for pid,controls in ipairs(BLOCK_CONTROLS) do
    for dir,key in pairs(controls) do
      BLOCK_CONTROL_FUNCS[key] = function()
        block.getPlayer(pid):setDir(dir)
      end
    end
  end
end

function hsgame.setup(w,h,blocklist,mus)
	block.clear()

	grid.set(w,h)

	for _,bargs in ipairs(blocklist) do
		block.new(bargs)
	end

	music.set(mus)
end

function hsgame.getSpeedFactor()
	return gameSpeedFactor
end

function hsgame.setSpeedFactor(n)
	gameSpeedFactor = math.clamp(0.05,n,7)
end

function hsgame.getGamestate()
	return gamestate
end

function hsgame.update(dt)
  music.setPitch(gameSpeedFactor)

  -- Transitions
  if gamestate == 'game' then
    local beat = music.update(dt)
		local beatFrac = beat - math.floor(beat)

    for b in block.getAll() do
      -- Block fading in sync with beat.
      local thres = b.kind == 'goal' and FADE_THRES.goal or (b.static and FADE_THRES.static or FADE_THRES.dynamic)
      if (beatFrac < thres) or (beatFrac > 1-thres) then
        b:setAlpha( ( (beatFrac < thres and beatFrac or 1-beatFrac)/thres ) * 255 )
      else
        b:setAlpha(255)
      end -- Threshold check
    end -- Block loop

		-- Grid "breathing" in sync with beat.
		-- TODO: Fix this! Draw location and getting scale to work from centre
		local thres = FADE_THRES.grid
		if (beatFrac < thres) or (beatFrac > 1-thres) then
			gridScale = ( (beatFrac < thres and beatFrac or 1-beatFrac)/thres )
		else
			gridScale = 1
		end -- Threshold check

  elseif gamestate == 'stop' then
    -- Slow the music to a stop.
    if gameSpeedFactor > 0 then
      gameSpeedFactor = gameSpeedFactor - (1/TRANSITION_DUR['stop'])*dt
      if gameSpeedFactor <= 0 then
        gameSpeedFactor = 0
        music.pause()
        resetReady = true
      end
    end

    -- Flashing.
    block.updateFlash(dt * (gameSpeedFactor > 1 and gameSpeedFactor or 1))

    -- Fade in all blocks...
    for b in block.getAll() do
      if not b.flashing then -- ...if the block isn't being flashed.
        if b.alpha < 255 then
          b:addAlpha((1/TRANSITION_DUR['stop'])*dt*255)
        else
          b:setAlpha(255)
        end
			end
    end
  elseif gamestate == 'reset' then
    -- Speed the music back up.
    gameSpeedFactor = gameSpeedFactor + (1/TRANSITION_DUR['reset'])*dt
    if gameSpeedFactor >= 1 then
      gameSpeedFactor = 1
      hsgame.start()
    end

    -- Fade out all blocks.
    for b in block.getAll() do
      if b.alpha > 0 then
        b:addAlpha(-(1/TRANSITION_DUR['reset'])*dt*255)
      else
        b:setAlpha(0)
      end
    end
  end
end

function hsgame.draw(alpha)
  love.graphics.setColor(255,255,255)

	--love.graphics.push()
	--local gpw,gph = grid.getPixDim()
	--love.graphics.translate(-gpw/2,-gph/2)

	--love.graphics.scale(gridScale)

  if alpha then
    grid.draw(alpha)
    block.draw(grid.getDrawPosition,alpha)
  else
    grid.draw(255)
    block.draw(grid.getDrawPosition)
  end

	--love.graphics.translate(gpw/2,gph/2)
	--love.graphics.pop()


  love.graphics.setColor(255,255,255,255)
  love.graphics.setFont(debugFont)
  love.graphics.print(string.format('Speed: %.2f',gameSpeedFactor),10,10)

  local time = music.getTime()
  love.graphics.print(string.format('Song time: %.2f',time),10,25)

  local absBeat = music.getBeat()
  love.graphics.print(string.format('Total beats: %.2f',absBeat),10,40)

  local bar,beat = music.getBar()
  love.graphics.print(string.format('Calculated bar/beat: %d/%.2f',bar,beat),10,55)

	love.graphics.print(string.format('Gamestate: %s',gamestate),10,70)

	love.graphics.print(string.format('Ready to reset: %s',resetReady),10,85)
end

function hsgame.keypressed(k,c)
	if k == 'escape' then
    if gamestate == 'stop' and resetReady then
			resetReady = false
      return true
    elseif gamestate == 'game' then
      hsgame.stop()
    end
  elseif k == ' ' then
    if gamestate == 'stop' and resetReady then
      hsgame.reset()
    end
  elseif BLOCK_CONTROL_FUNCS[k] then -- Control keys
    BLOCK_CONTROL_FUNCS[k]()
  end
end

return hsgame
