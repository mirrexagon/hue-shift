local beat = {}

local tempo = 0
local beatsInBar = 4

-- Timekeeping.
local curBeat = 1
local beatTimer = 1
local curBar = 1

local speedFactor = 1

function beat.reset()
  --beat.set(bpm,barlen)
  curBeat = 1
  beatTimer = 1
  curBar = 1
end

function beat.set(bpm,bpb)
  tempo = bpm
  beatsInBar = bpb or 4
end

function beat.setSpeedFactor(n)
  speedFactor = n
end

function beat.update(dt)
  beatTimer = beatTimer + (tempo/60)*speedFactor*dt

  if beatTimer > curBeat + 1 then -- Next beat.
    curBeat = math.floor(beatTimer)
    beat.onBeat(curBeat)
  end

  if beatTimer > beatsInBar + 1 then -- New bar.
    beatTimer = 1
    curBeat = 1
    curBar = curBar + 1
    beat.onBar(curBar)
  end
end

function beat.onBeat(beat)

end

function beat.onBar(bar)

end

function beat.getInfo()
  return curBeat,beatTimer,curBar
end

return beat
