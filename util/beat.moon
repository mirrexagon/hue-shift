beats_to_seconds = (beat, bpm) -> ((beat - 1) * 60) / bpm
seconds_to_beats = (seconds, bpm) -> seconds * (bpm / 60) + 1

{ :beats_to_seconds, :seconds_to_beats }