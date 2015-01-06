local menu = {}

---

local util = require("lib.self.util")

---

local clamp = util.math.clamp

---

local fade_state = "in" -- in, full, out
local fade_out_to_game = false
local global_alpha = 0

---

local N_ROWS = 5
local ROW_PAD = 30

local ROW_WIDTH = love.graphics.getWidth() - (ROW_PAD*2)
local ROW_HEIGHT = (love.graphics.getHeight() - (N_ROWS + 1) * ROW_PAD) / N_ROWS

local ROW_ALPHA = math.floor(0.75 * 255)

---

local img_arrow = love.graphics.newImage("graphics/arrow.png")

local font_row_title = love.graphics.newFont(48)

---

local gridw, gridh = 7, 7
local n_player_blocks = 1
local music = "laserwash"

local selected_row = 1

---

function menu:init()

end

function menu:enter(previous, arg)
	fade_state = "in"
	global_alpha = 0
end

---

local function get_row_y(i)
	return i * ROW_PAD + (i - 1) * ROW_HEIGHT
end

local function draw_row_rect(n, alpha)
	local row_y = get_row_y(n)
	love.graphics.setColor(255, 255, 255, ROW_ALPHA * (alpha or 1))
	love.graphics.rectangle("fill", ROW_PAD, row_y, ROW_WIDTH, ROW_HEIGHT)
end

local function draw_row_title(title, row_y, alpha)
	love.graphics.setColor(255, 255, 255, ROW_ALPHA * (alpha or 1))
	love.graphics.setFont(font_row_title)

	love.graphics.print(
		title,
		((ROW_WIDTH + ROW_PAD)/2) - (font_row_title:getWidth(title)/2),
		row_y + (ROW_HEIGHT/2) - (font_row_title:getHeight()/2)
	)
end


local rows = {
	["BLOCKS"] = {
		draw = function(row_y, alpha)
			local block_xdiff = ROW_WIDTH/4
			local block_y = row_y + (ROW_HEIGHT/2 - DEFAULT_TILE_LENGTH/2)

			for i = 1, 3 do
				local lalpha = (i <= n_player_blocks and 255 or 64) * alpha

				love.graphics.setColor(
					BLOCK_COLORS[i][1],
					BLOCK_COLORS[i][2],
					BLOCK_COLORS[i][3],
					lalpha
				)
				love.graphics.rectangle("fill", block_xdiff * i, block_y,
					DEFAULT_TILE_LENGTH, DEFAULT_TILE_LENGTH)

				love.graphics.setColor(255, 255, 255, lalpha)
				love.graphics.draw(img_arrow, block_xdiff * i, block_y)
			end
		end,

		keypressed = function(k)
			if k == "right" then
				n_player_blocks = n_player_blocks + 1
			elseif k == "left" then
				n_player_blocks = n_player_blocks - 1
			end

			n_player_blocks = clamp(1, n_player_blocks, 3)
		end
	},

	["START"] = {
		keypressed = function(k)
			if k == "return" then
				fade_state = "out"
				fade_out_to_game = true
			end
		end
	}
}

local row_order = {
	"GRID", "MUSIC", "BLOCKS", "OBSTACLES", "START"
}

local function draw_row(n, alpha)
	local row_name = row_order[n]
	local row = rows[row_name]

	---

	alpha = ((n == selected_row) and 1 or 0.5) * alpha

	local row_y = get_row_y(n)

	---

	draw_row_rect(n, alpha)

	draw_row_title(row_name, row_y, alpha)

	if row and row.draw then
		row.draw(row_y, alpha)
	end
end

---

function menu:update(dt)
	bg.update(dt)

	if fade_state == "in" then
		global_alpha = global_alpha + (1/TRANSITION_DURATION) * dt
		if global_alpha >= 1 then
			global_alpha = 1
			fade_state = "full"
		end
	elseif fade_state == "full" then
		local row_name = row_order[selected_row]
		local row = rows[row_name]
		if row and row.update then
			row.update(dt)
		end
	elseif fade_state == "out" then
		global_alpha = global_alpha - (1/TRANSITION_DURATION) * dt
		if global_alpha <= 0 then
			global_alpha = 0
			if fade_out_to_game then
				gs.switch(state_game, {
					npairs = n_player_blocks,

					music = MUSIC[music].path,
					bpm = MUSIC[music].bpm
				})
			else
				love.event.quit()
			end
		end
	end
end

function menu:draw()
	love.graphics.setColor(255, 255, 255, BG_ALPHA)
	bg.draw()

	---

	row_counter = 1

	for n = 1, #row_order do
		draw_row(n, global_alpha)
	end
end

function menu:keypressed(k)
	if k == "up" then
		selected_row = selected_row - 1
		if selected_row < 1 then selected_row = #row_order end
	elseif k == "down" then
		selected_row = selected_row + 1
		if selected_row > #row_order then selected_row = 1 end
	elseif k == "escape" then
		fade_state = "out"
		fade_out_to_game = false

	else
		local row_name = row_order[selected_row]
		local row = rows[row_name]
		if row and row.keypressed then
			row.keypressed(k)
		end
	end
end

---

function menu:leave()

end

---

return menu
