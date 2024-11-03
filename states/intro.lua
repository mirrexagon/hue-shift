--[[
Modes:
  1 = Hexagon spins at constant speed. 4*dt per frame
  2 = Hexagon starts not moving and then spins faster and faster. 3*dt acceleration per frame
  3 = Hexagon rotates with mouse movement. Clockwise if cursor is above it, anti-clockwise if cursor is below it.
  4 = One face of the hexagon always faces the mouse, using atan2.

  Have the Super Hexagon triangle spinning around sometimes.
]]
intro = {}

local img_logo
local img_hex

local hex_angle = 0
local hex_speed = 0

local timer = 0

local fadein = 1
local ontime = 2
local fadeout = 1
local blackend = 0.5

local alpha = 0
local alpha2 = 0
local mode = 1
local last_mx,last_my = 0,0

local scale = 0.25

local modes = {}

function intro:init()
  img_logo = love.graphics.newImage('graphics/logo_main.png')
  img_hex = love.graphics.newImage('graphics/logo_hex.png')

  modes[1] = function(dt)
    hex_angle = hex_angle + (4*dt)
  end
  modes[2] = function(dt)
    if timer > 0.2 then
      hex_speed = hex_speed + (3*dt)
    end
    hex_angle = hex_angle + (hex_speed*dt)
  end
  modes[3] = function(dt)
    local new_x,new_y = love.mouse.getPosition()
    if last_x and last_y then
      if new_y < love.graphics.getHeight()/2 then
        hex_angle = hex_angle - ((last_x - new_x)/100)
      else
        hex_angle = hex_angle + ((last_x - new_x)/100)
      end
    end
    last_x,last_y = new_x,new_y
  end
  modes[4] = function(dt)
    local m_x,m_y = love.mouse.getPosition()
    hex_angle = math.atan2(m_y - love.graphics.getHeight()/2,m_x - (love.graphics.getWidth()/2 + 175)) + math.pi/6
  end
end

function intro:enter(previous)
  timer = 0
  mode = math.random(2)
end

function intro:update(dt)
  if love.graphics.isCreated() then
    timer = timer + dt

    if timer < fadein then
      alpha = (timer/fadein) * 255
    end

    if timer > fadein and timer < fadein + ontime then
      alpha = 255
    end

    if timer > fadein + ontime + 0.1 and timer < fadein + ontime + fadeout then
      alpha = (1 - (timer/fadein + ontime + fadeout)) * 255
    end

    if timer > fadein + ontime + fadeout and timer <  fadein + ontime + fadeout + blackend then
      alpha = 0
    end

    if timer >= fadein + ontime + fadeout + blackend then
      love.graphics.setColor(255,255,255,255)
      gs.switch(menu)
    end

    modes[mode](dt)
  end
end

function intro:draw()
  love.graphics.setColor(255,255,255,alpha)

  love.graphics.draw(img_logo,
    love.graphics.getWidth()/2,
    love.graphics.getHeight()/2,
    0,
    scale,scale,
    img_logo:getWidth()/2,
    img_logo:getHeight()/2
  )

  love.graphics.draw(img_hex,
    love.graphics.getWidth()/2 + 175,
    love.graphics.getHeight()/2,
    hex_angle,
    scale,scale,
    img_hex:getWidth()/2,
    img_hex:getHeight()/2
  )
end
