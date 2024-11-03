menu = {}

local start_font = love.graphics.newFont(ALTERA_PATH,38)
local start_text = 'Press SPACE to begin'

local alpha = 255

local fading = false
local fadetime = 0.6

function menu:init()

end

function menu:enter(previous)
  if previous ~= game then
    alpha = 0
    fading = true
  end
end

function menu:update(dt)
  if fading and alpha <= 255 then
    alpha = alpha + (255/fadetime)*dt
  end
  if alpha >= 255 then
    fading = false
    alpha = 255
  end
  hg.update(dt)
end

function menu:draw()
  love.graphics.setColor(255,255,255,alpha)
  hg.draw()

  if alpha == 255 then
    love.graphics.setFont(start_font)
    love.graphics.print(start_text,
      love.graphics.getWidth()/2 - start_font:getWidth(start_text)/2,
      love.graphics.getHeight()/2 - start_font:getHeight() + love.graphics.getHeight()/4
    )
  end
end

function menu:keypressed(k,c)
  if k == ' ' and alpha == 255 then
    gs.switch(game)
  elseif k == 'escape' then
    love.event.quit()
  end
end
