local block = {}

local blocks = {}

local BLOCK_IMG = {
  arrow = love.graphics.newImage('graphics/arrow.png')
}

local MOVE_DIR = {
  [0] = {0,-1},
  [1] = {1,0},
  [2] = {0,1},
  [3] = {-1,0}
}

local ARROW_DIR = {
  [0] = 0,
  [1] = math.pi/2,
  [2] = math.pi,
  [3] = 3*(math.pi/2)
}

local flashTimer = 0
local flashUp = true
block.flashDur = 0.6

function block.new(t)
  local x,y = tonumber(t.x),tonumber(t.y)
  if not x or not y then
    error('New block position not given',2)
  end

  if not t.kind then
    error('New block kind not given.',2)
  end

  local b = {
    x = x,
    y = y,
    dir = t.dir or 0,

    --[[
      0 = up
      1 = right
      2 = down
      3 = left
    ]]

    kind = t.kind,
    static = t.static or false,
    color = t.color or {0,255,255},
    alpha = t.alpha or 0,

    resetx = x,
    resety = y,

    pid = t.pid,

    visible = true,
    isPendingVis = false,
    pendingVis = true,

    flashing = false,
    flashInverted = false
  }

  function b:hide()
    self.pendingVis = false
    self.isPendingVis = true
  end

  function b:show()
    self.pendingVis = true
    self.isPendingVis = true
  end

  function b:setDir(dir)
    self.dir = dir
  end

  function b:setPos(x,y)
    self.x,self.y = x or self.x,y or self.y
  end

  function b:move(dir,maxw,maxh)
    self.x = self.x + MOVE_DIR[dir][1]
    self.y = self.y + MOVE_DIR[dir][2]

    if self.x < 1 then
      self.x = maxw
    elseif b.x > maxw then
      self.x = 1
    end

    if self.y < 1 then
      self.y = maxh
    elseif b.y > maxh then
      self.y = 1
    end
  end

  function b:setAlpha(a)
    self.alpha = math.clamp(0,a,255)
  end

  function b:addAlpha(a)
    self:setAlpha(self.alpha + a)
  end

  function b:draw(px,py,pw,ph,a)
    local cx,cy = px + pw/2,py + ph/2

    local r,g,b = unpack(self.color)

    a = a or self.alpha

    love.graphics.setColor(r,g,b,a)
    love.graphics.rectangle('fill',px,py,pw,ph)

    love.graphics.setColor(255,255,255,a)
    if self.static then
      love.graphics.circle('fill',cx,cy,pw/3)
    else
      love.graphics.draw(BLOCK_IMG['arrow'],cx,cy,ARROW_DIR[self.dir],1,1,pw/2,ph/2)
    end
  end

  function b:updateFlash() -- TODO: Figure out how to implement this better
    if self.flashing then
      if self.flashInverted then
        self:setAlpha(255 - (flashTimer/block.flashDur)*255)
      else
        self:setAlpha((flashTimer/block.flashDur)*255)
      end
    end
  end

  blocks[#blocks+1] = b
  return b
end

function block.doPendingVis()
  for b in block.getAll() do
    if b.isPendingVis then
      b.visible = b.pendingVis
      b.isPendingVis = false
    end
  end
end

-- TODO: Is it possible to make getAnd and getOr more DRY-friendly?
-- Get all blocks which match ALL of the parameters.
function block.getAnd(params)
  local list = {}
	local count = 0
  for b in block.getAll() do
		count = count + 1
    if b.visible then
      local add = true
      for k,v in pairs(params) do
        if b[k] ~= v then
          add = false
          break
        end
      end
      if add then list[#list+1] = b end
    end
  end
	return list
end

-- Get all blocks which match AT LEAST ONE of the parameters.
function block.getOr(params)
  local list = {}
  for b in block.getAll() do
    if b.visible then
      local add = true
      for k,v in pairs(params) do
        if b[k] == v then
          add = true
          break
        end
      end
      if add then list[#list+1] = b end
    end
  end
	return list
end

function block.getAt(x,y)
  return block.getAnd{
    x = x,
    y = y
  }
end

function block.getKind(kind)
  return block.getAnd{
    kind = kind
  }
end


function block.getPlayer(pid)
  return (block.getAnd{
    kind = 'player',
    pid = pid,
  })[1]
end

function block.getGoal(pid)
  return (block.getAnd{
    kind = 'goal',
    pid = pid,
  })[1]
end


function block.getAll()
  local i = 0
  return function()
		i = i + 1
		if blocks[i] == nil then -- No more blocks in list.
			return nil
		else
			if blocks[i].visible then
				return blocks[i]
			end
		end
  end
end

function block.clear()
	blocks = {}
end

function block.updateFlash(dt)
  if flashUp then
    flashTimer = flashTimer + dt
    if flashTimer >= block.flashDur then
      flashTimer = block.flashDur
      flashUp = false
    end
  else
    flashTimer = flashTimer - dt
    if flashTimer <= 0 then
      flashTimer = 0
      flashUp = true
    end
  end

	for b in block.getAll() do
		b:updateFlash()
	end
end

function block.draw(pixelfunc,alpha)
  for _,b in ipairs(blocks) do
    local x,y,w,h = pixelfunc(b.x,b.y)
    b:draw(x,y,w,h,alpha)
  end
end

return block
