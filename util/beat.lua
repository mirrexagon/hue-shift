local beat = {}

---

function beat.beattosec(absbeat, bpm)
  return ((absbeat - 1) * 60) / bpm
end

function beat.sectobeat(seconds, bpm)
  return seconds * (bpm / 60) + 1
end

---

return beat
