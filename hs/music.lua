local m = {}

require('lib.self.util')

local MUSICLIST = {
  ['laserwash.ogg'] = {
    bpm = 90,
    bpb = 4
  },
  ['tkol.mp3'] = {
    bpm = 140,
    bpb = 4
  },
  ['destiny_redux.mp3'] = {
    bpm = 160,
    bpb = 4,
    introbeats = 1
  },
  ['hue_shift.ogg'] = {
    bpm = 95,
    bpb = 4
  },
  ['dr_credits.mp3'] = {
    bpm = 175/2,
    bpb = 4
  },
  ['follow_the_sun.ogg'] = {
    bpm = 135/2,
    bpb = 4
  },
  ['anticlon.ogg'] = {
    bpm = 132,
    bpb = 4
  },
  ['yuki_satellites.ogg'] = {
    bpm = 190/2,
    bpb = 4
  },
}

local function absBeatToSeconds(absBeat,bpm)
  return ((absBeat)*60)/bpm
end

local function secondsToAbsBeat(seconds,bpm)
  return seconds*(bpm/60) + 1
end

local function absBeatToBar(absBeat,bpb)
  local bar = math.floor((absBeat-1)/bpb)
  local beat = absBeat - (bar*bpb)
  return bar+1,beat
end

local curBeat = 0
local curBar = 0

local curMusic

local music = {}

function m.add(filename,attr)
  if love.filesystem.isFile('music/' .. filename) then
    local name = string.match(filename,'^(.*)%.%w+$')
    local s = love.audio.newSource('music/' ..  filename)
    s:setLooping(true)
    music[name] = {source = s}
    for k,v in pairs(attr) do
      if k == 'introbeats' then
        music[name]['intro'] = absBeatToSeconds(v,attr.bpm)
      else
        music[name][k] = v
      end
    end
  end
end

function m.addList(list)
  for fname,t in pairs(list) do
    m.add(fname,t)
  end
end

m.addList(MUSICLIST)


function m.set(name)
  if music[name] then
    curMusic = music[name]
  else
    error('No music named: ' .. name,2)
  end
end

function m.pause()
  if curMusic then
    curMusic.source:pause()
  end
end

function m.resume()
  if curMusic then
    curMusic.source:play()
  end
end

function m.stop()
  if curMusic then
    curMusic.source:stop()
    curBeat = 0
    curBar = 0
  end
end

function m.setPitch(p,name)
  if not name then
    curMusic.source:setPitch(p)
  else
    music[name].source:setPitch(p)
  end
end

function m.getParam(p)
  return curMusic[p]
end

function m.getTime()
  local src = m.getParam('source')
  local time = src:tell()
  return time
end

function m.getBeat()
  return secondsToAbsBeat(m.getTime() - (m.getParam('intro') or 0),m.getParam('bpm'))
end

function m.getBar()
  local bpb = m.getParam('bpb')
  if not bpb then return 0,0 end
  return absBeatToBar(m.getBeat(),bpb)
end

function m.update(dt)
  local beat = m.getBeat()

  if beat > curBeat + 1 then -- New beat.
    curBeat = math.floor(beat)
    m.onBeat(curBeat,(curBeat == 1 and true or false))
  end

  if beat < curBeat and beat >= 1 then -- Looped to beginning.
    curBeat = 0
    curBar = 0
    m.onBeat(curBeat,true)
  end

  local bar = m.getBar()
  if bar then
    if bar > curBar then -- New bar.
      curBar = bar
      m.onBar(bar)
    end
  end

  return beat
end

function m.onBeat(beat)

end

function m.onBar(bar)

end

return m
