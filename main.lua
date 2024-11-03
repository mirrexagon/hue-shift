--[[
Hue Shift, a game by LegoSpacy.

]]

--[[
Notes:
Each beat of the music, all blocks that can move will move in the direction that the arrow on them points.

You have to get the blocks into their corresponding goals, marked by their colour. Obstacles are there to block you, and dynamic ones can move around like the player blocks.

WASD to control red block.
TFGH to control green block.
IJKL to control blue block.

Each level has it's own update function to allow expansion (as opposed to set level formats).
]]

-- Libraries
-- HUMP
gs = require('lib.hump.gamestate')

-- Self
hg = require('lib.self.hueground')

-- Path to the font!
ALTERA_PATH = 'graphics/altera.otf'

function love.load()
  --[[
  local img_icon = love.graphics.newImage('graphics/icon.png')
  love.window.setIcon(img_icon)
  --]]

  gs.registerEvents()

  -- Load gamestates
  require('states.intro')
  require('states.menu')
  require('states.game')

  gs.switch(menu)
end

function love.update(dt)

end

function love.draw()

end
