local beat = {}

function beat.absbeat_to_seconds(absbeat, bpm)
  return ((absbeat - 1) * 60) / bpm
end

function beat.seconds_to_absbeat(seconds, bpm)
  return seconds * (bpm / 60) + 1
end

return beat
