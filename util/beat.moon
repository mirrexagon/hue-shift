--- Functions ---
beat_to_seconds = (beat, bpm) -> ((beat - 1) * 60) / bpm
seconds_to_beat = (seconds, bpm) -> seconds * (bpm / 60) + 1
--- ==== ---


--- Module ---
{
	:beat_to_seconds
	:seconds_to_beat
}
--- ==== ---
