--- Import ---
import Block from require "blocks"
--- ==== ---


--- Constants ---
STATIC_DOT_SIZE_MULT = 5/16
--- ==== ---


class StaticBlock extends Block
    new: (game, color, x, y) =>
        super game, color, x, y

        @direction = direction

        @fade_time = 1


    draw_symbol: (x, y) =>
        min_wh = math.min @w, @h

        love.graphics.circle "fill",
            x + @w/2, y + @h/2, min_wh * STATIC_DOT_SIZE_MULT


{ :StaticBlock }
