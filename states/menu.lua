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

local N_ROWS_ONSCREEN = 5
local ROW_PIX_PAD = 30

local ROW_PIX_W = love.graphics.getWidth() - (ROW_PIX_PAD*2)
local ROW_PIX_H = (love.graphics.getHeight() - (N_ROWS_ONSCREEN + 1) * ROW_PIX_PAD) / N_ROWS_ONSCREEN

local ROW_ALPHA = math.floor(0.75 * 255)

local scroll_offset = 0
local target_scroll_offset = 0
local SCROLL_SPEED = 5

---

local img_arrow = love.graphics.newImage("graphics/arrow.png")

local font_row_title = love.graphics.newFont(48)

---

local grid_w, grid_h = 7, 7
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

local function get_row_pix_h(row_h)
	return row_h * ROW_PIX_H + (row_h - 1) * ROW_PIX_PAD
end

local function get_row_pix_y(row_slot)
	return (row_slot - 1) * ROW_PIX_H + (row_slot) * ROW_PIX_PAD
end

local function draw_row_rect(row_slot, row_h, alpha)
	love.graphics.setColor(255, 255, 255, ROW_ALPHA * (alpha or 1))
	love.graphics.rectangle("fill", ROW_PIX_PAD, get_row_pix_y(row_slot), ROW_PIX_W, get_row_pix_h(row_h))
end

local function draw_row_name(row_name, row_slot, row_h, alpha)
	love.graphics.setColor(255, 255, 255, ROW_ALPHA * (alpha or 1))
	love.graphics.setFont(font_row_title)

	love.graphics.print(
		row_name,
		((ROW_PIX_W + ROW_PIX_PAD)/2) - (font_row_title:getWidth(row_name)/2),
		get_row_pix_y(row_slot) + (get_row_pix_h(row_h)/2) - (font_row_title:getHeight()/2)
	)
end


local rows = {
	["BLOCKS"] = {
		draw = function(row_pix_y, row_pix_h, alpha)
			local block_xdiff = ROW_PIX_W/4
			local block_y = row_pix_y + ((row_pix_h)/2 - DEFAULT_TILE_LENGTH/2)

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
		height = 1,
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

local function get_row(row_n)
	local row_name = row_order[row_n or selected_row]
	return rows[row_name]
end

local function get_row_height(row_n)
	local row = get_row(row_n)

	if row then
		if row.height then
			return row.height
		else
			return 1
		end
	else
		return 1
	end
end

local function get_total_row_height(up_to_row_n)
	local total = 0
	for row_n = 1, (up_to_row_n or #row_order) do
		total = total + get_row_height(row_n)
	end
	return total
end

local function draw_row(row_name, row_slot, row, alpha)
	alpha = ((row_order[selected_row] == row_name) and 1 or 0.5) * alpha

	local row_h
	if row then
		if row.height then
			row_h = row.height
		else
			row_h = 1
		end
	else
		row_h = 1
	end

	---

	draw_row_rect(row_slot, row_h, alpha)

	draw_row_name(row_name, row_slot, row_h, alpha)

	if row and row.draw then
		row.draw(get_row_pix_y(row_slot), get_row_pix_h(row_h), alpha)
	end
end

---

function menu:update(dt)
	bg.update(dt)

	if fade_state == "in" then
		---
		global_alpha = global_alpha + (1/TRANSITION_DURATION) * dt
		if global_alpha >= 1 then
			global_alpha = 1
			fade_state = "full"
		end
		---
	elseif fade_state == "full" then
		---
		local row_name = row_order[selected_row]
		local row = rows[row_name]
		if row and row.update then
			row.update(dt)
		end

		scroll_offset = scroll_offset + (target_scroll_offset - scroll_offset)*SCROLL_SPEED*dt
		---
	elseif fade_state == "out" then
		---
		global_alpha = global_alpha - (1/TRANSITION_DURATION) * dt
		if global_alpha <= 0 then
			global_alpha = 0
			if fade_out_to_game then
				gs.switch(state_game, {
					npairs = n_player_blocks,

					grid_w = grid_w,
					grid_h = grid_h,

					music = MUSIC[music].path,
					bpm = MUSIC[music].bpm
				})
			else
				love.event.quit()
			end
		end
		---
	end
end

function menu:draw()
	love.graphics.setColor(255, 255, 255, BG_ALPHA)
	bg.draw()

	---

	love.graphics.push()
	love.graphics.translate(0, -math.floor(scroll_offset * (ROW_PIX_H + ROW_PIX_PAD)))

	local offset = 1
	for i, row_name in ipairs(row_order) do
		local row = rows[row_name]

		draw_row(row_name, offset, row, global_alpha)

		offset = offset + get_row_height(i)
	end

	love.graphics.pop()
end

---

local function prev_row()
	selected_row = selected_row - 1

	if selected_row < 1 then
		selected_row = #row_order
		target_scroll_offset = get_total_row_height() - N_ROWS_ONSCREEN

	else
		local t_row_h = get_total_row_height(selected_row - 1)
		if t_row_h < target_scroll_offset then
			target_scroll_offset = t_row_h
		end
	end
end

local function next_row()
	selected_row = selected_row + 1

	if selected_row > #row_order then
		selected_row = 1
		target_scroll_offset = 0

	else
		local t_row_h = get_total_row_height(selected_row)
		if t_row_h - N_ROWS_ONSCREEN > target_scroll_offset then
			target_scroll_offset = t_row_h - N_ROWS_ONSCREEN
		end
	end
end

function menu:keypressed(k)
	if k == "up" then
		prev_row()
	elseif k == "down" then
		next_row()
	elseif k == "escape" then
		fade_state = "out"
		fade_out_to_game = false

	else
		local row = get_row()
		if row and row.keypressed then
			row.keypressed(k)
		end
	end
end

function menu:mousepressed(x, y, b)
	if b == "wu" then
		prev_row()
	elseif b == "wd" then
		next_row()

	else
		local row = get_row()
		if row and row.mousepressed then
			row.mousepressed(x, y, b)
		end
	end
end

---

function menu:leave()

end

---

return menu
