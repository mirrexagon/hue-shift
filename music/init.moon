--- Import ---
import seconds_to_beats, beats_to_seconds from require "util.beat"
--- ==== ---


--- A piece of music (with a constant tempo, currently).
class Music
    new: (path, name, bpm) =>
        @path = path
        @name = name
        @bpm = bpm

    load: =>
        if @source == nil
            -- There seems to be a bug with at least some looped streaming audio, where
            -- `source:tell()` isn't quite right after a loop.
            @source = love.audio.newSource @path, "static"
            @source\setLooping true

    unload: =>
        if @source ~= nil
            @source = nil
            collectgarbage!

    ---

    pos_seconds: => @source\tell!
    pos_beats: => seconds_to_beats @source\tell!, @bpm

    play: => @source\play!
    rewind: => @source\rewind!
    pause: => @source\pause!
    is_paused: => @source\isPaused!

    set_pitch: (pitch) =>
        if pitch == 0
            if not @is_paused!
                @pause!
        else
            @source\setPitch(pitch)
            if @is_paused! then @play!


class MusicLibrary
    new: (dir) =>
        lib = (assert love.filesystem.load dir .. "/init.lua")!

        for music in *lib
            table.insert @, Music dir .. "/" .. music.file, music.name, music.bpm
            

{ :Music, :MusicLibrary }