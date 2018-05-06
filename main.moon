-- Hue Shift, a game by Mirrexagon


--- Require ---
gamestate = require "lib.hump.gamestate"
--- ==== ---


--- Import ---
import MenuState from require "states.menu"
import MusicLibrary from require "music"

import Level, Game from require "game"
--- ==== ---


--- Constants ---
export BLOCK_WIDTH = 32
export BLOCK_HEIGHT = 32
--- ==== ---


--- Main ---
love.load = ->
    theme = (require "themes.hue-shift")!
    music_library = MusicLibrary "assets/music"

    menu_state = MenuState theme, music_library

    game = Game {
        music: music_library[1]
        theme: theme
        level: Level!
        n_block_pairs: 1
    }

    game.DEBUG = true

    gamestate.registerEvents!
    gamestate.switch game
--- ==== ---