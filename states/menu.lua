local menu = {}

---

local util = require("lib.self.util")

---

local fade_state = "in" -- in, full, out
local fade_out_to_game = false
local global_alpha = 0

---

local N_ROWS_ONSCREEN = 5

local ROW_PIX_PAD
local ROW_PIX_W
local ROW_PIX_H

local ROW_ALPHA = math.floor(0.7 * 255)

local INTERPOLATE_SPEED = 5
local scroll_offset = 0
local target_scroll_offset = 0

---

local img_arrow = love.graphics.newImage("graphics/arrow.png")
img_arrow:setFilter("nearest", "nearest")

local img_arrows = love.graphics.newImage("graphics/arrows.png")
img_arrows:setFilter("nearest", "nearest")

local font_row_label

---

local GRID_W_MIN = 3
local GRID_W_MAX = 10

local GRID_H_MIN = 3
local GRID_H_MAX = 10

---

local game_params = {
	grid_w = 7,
	grid_h = 7,

	music = 1,

	npairs = 1
}

local selected_row = 1

---

local function print_centered(text, x, y)
	local font = love.graphics.getFont()

	love.graphics.print(
		text,
		x - (font:getWidth(text)/2),
		y - (font:getHeight()/2)
	)
end

---

local function calculate_dimensions(screenw, screenh)
	font_row_label = love.graphics.newFont(math.floor(48 * (math.min(screenw, screenh) / 600)))

	GRID_W_MAX = math.floor(screenw / (DEFAULT_TILE_LENGTH + DEFAULT_TILE_PAD))
	GRID_H_MAX = math.floor(screenh / (DEFAULT_TILE_LENGTH + DEFAULT_TILE_PAD))

	ROW_PIX_PAD = math.floor(30 * (math.min(screenw, screenh) / 600))
	ROW_PIX_W = screenw - (ROW_PIX_PAD*2)
	ROW_PIX_H = (screenh - (N_ROWS_ONSCREEN + 1) * ROW_PIX_PAD) / N_ROWS_ONSCREEN
end

function menu:resize(screenw, screenh)
	calculate_dimensions(screenw, screenh)

	game_params.grid_w = util.math.clamp(GRID_W_MIN, game_params.grid_w, GRID_W_MAX)
	game_params.grid_h = util.math.clamp(GRID_H_MIN, game_params.grid_h, GRID_H_MAX)
end

---

local function interpolate(value, target, dt, speed)
	return value + (target - value) * (speed or INTERPOLATE_SPEED) * dt
end

---

function menu:init()

end

---

local TRIANGLE_W_FRAC = 0.06
local TRIANGLE_H_FRAC = 0.6
local TRIANGLE_X_DIV = 16

local function draw_lr_arrows(y, alpha, active_l, active_r)
	local triangle_w = TRIANGLE_W_FRAC * ROW_PIX_W
	local triangle_h = TRIANGLE_H_FRAC * ROW_PIX_H

	local triangle_l_x = ROW_PIX_W / TRIANGLE_X_DIV

	local triangle_l_left_x = triangle_l_x - triangle_w/2
	local triangle_l_right_x = triangle_l_left_x + triangle_w

	local triangle_r_right_x = ROW_PIX_W - triangle_l_left_x
	local triangle_r_left_x = triangle_r_right_x - triangle_w

	love.graphics.setColor(255, 255, 255, (active_l and 255 or 64) * alpha)
	love.graphics.polygon(
		"fill",
		triangle_l_left_x, y,
		triangle_l_right_x, y - triangle_h/2,
		triangle_l_right_x, y + triangle_h/2
	)

	love.graphics.setColor(255, 255, 255, (active_r and 255 or 64) * alpha)
	love.graphics.polygon(
		"fill",
		triangle_r_right_x, y,
		triangle_r_left_x, y - triangle_h/2,
		triangle_r_left_x, y + triangle_h/2
	)

	---

	return triangle_r_left_x - triangle_l_right_x
end

---

local function get_row_pix_h(row_h)
	return row_h * ROW_PIX_H + (row_h - 1) * ROW_PIX_PAD
end

local function get_row_pix_y(row_slot)
	return (row_slot - 1) * ROW_PIX_H + (row_slot) * ROW_PIX_PAD
end

---

local rows = {
	["HUE SHIFT"] = {
		hide_label = false,
		label = "FANCY LOGO HERE"
	},

	["GRID"] = {
		height = 2,

		w_red = 0,
		h_red = 0,
		draw = function(self, row_pix_w, row_pix_h, alpha)
			local num_y = math.floor(1.5 * ROW_PIX_H + ROW_PIX_PAD)
			local num_xsep_frac = 0.1

			local arrow_y = math.floor(row_pix_h/2)

			local scale = math.min(love.graphics.getWidth(), love.graphics.getHeight()) / 600

			love.graphics.setColor(255, 255, 255, 255 * alpha)
			love.graphics.setFont(font_row_label)
			local font_h = font_row_label:getHeight()

			---
			---

			local num_xsep = num_xsep_frac * row_pix_w

			local w_text = tostring(game_params.grid_w)
			local w_text_x = math.floor(row_pix_w/2 - num_xsep)

			local h_text = tostring(game_params.grid_h)
			local h_text_x = math.floor(row_pix_w/2 + num_xsep)

			---

			local mid = "x"
			love.graphics.print(mid, math.floor(row_pix_w/2 - font_row_label:getWidth(mid)/2), num_y - font_h/2 - 5)

			---

			local w_gb = (1 - self.w_red) * 255
			love.graphics.setColor(255, w_gb, w_gb, 255 * alpha)
			love.graphics.print(w_text, w_text_x - math.floor(font_row_label:getWidth(w_text)/2), num_y - font_h/2)
			love.graphics.draw(
				img_arrows,
				w_text_x, arrow_y,
				0,
				scale, scale,
				img_arrows:getWidth()/2, img_arrows:getHeight()/2
			)

			local h_gb = (1 - self.h_red) * 255
			love.graphics.setColor(255, h_gb, h_gb, 255 * alpha)
			love.graphics.print(h_text, h_text_x - math.floor(font_row_label:getWidth(h_text)/2), num_y - font_h/2)
			love.graphics.draw(
				img_arrows,
				h_text_x, arrow_y,
				math.pi/2,
				scale, scale,
				img_arrows:getWidth()/2, img_arrows:getHeight()/2
			)
		end,

		update = function(self, dt)
			self.w_red = interpolate(self.w_red, 0, dt)
			self.h_red = interpolate(self.h_red, 0, dt)
		end,

		keypressed = function(self, k)
			if k == "w" then
				game_params.grid_w = game_params.grid_w + 1
			elseif k == "s" then
				game_params.grid_w = game_params.grid_w - 1
			elseif k == "i" then
				game_params.grid_h = game_params.grid_h + 1
			elseif k == "k" then
				game_params.grid_h = game_params.grid_h - 1
			end

			if not util.math.range(GRID_W_MIN, game_params.grid_w, GRID_W_MAX) then
				self.w_red = 1
			end
			if not util.math.range(GRID_H_MIN, game_params.grid_h, GRID_H_MAX) then
				self.h_red = 1
			end

			game_params.grid_w = util.math.clamp(GRID_W_MIN, game_params.grid_w, GRID_W_MAX)
			game_params.grid_h = util.math.clamp(GRID_H_MIN, game_params.grid_h, GRID_H_MAX)
		end
	},

	["MUSIC"] = { -- TODO: Play selected music quietly while MUSIC is selected? Pulse something to its beat? (Will have to modularise beat logic from game.lua) Have dedicated menu music that plays otherwise? Pulse something to its beat too?
		height = 2,
		font = love.graphics.newFont(36),
		x_space = 0,

		init = function(self)
			self.x_space = draw_lr_arrows(1, 1)
		end,

		draw = function(self, row_pix_w, row_pix_h, alpha)
			local y_space = row_pix_h - ROW_PIX_H
			local y = ROW_PIX_H + math.floor(y_space/2)

			--[[
			love.graphics.line(0,ROW_PIX_H, row_pix_w,ROW_PIX_H)
			love.graphics.line(0,y, row_pix_w,y)
			--]]

			self.x_space = draw_lr_arrows(y, alpha, true, true)

			love.graphics.setColor(255, 255, 255, 255 * alpha)
			love.graphics.setFont(self.font)

			local text = MUSIC[game_params.music].name
			local text_w = self.font:getWidth(text)
			local text_h = self.font:getHeight()

			local text_w_actual, text_wraps = self.font:getWrap(text, self.x_space)
			text_wraps = text_wraps - 1

			self.height = 2 + 0.75 * text_wraps * (text_h / ROW_PIX_H)

			love.graphics.printf(
				text,
				(row_pix_w/2) - (self.x_space/2), y - (text_h/2) - text_wraps*(text_h/2),
				self.x_space,
				"center"
			)
		end,

		keypressed = function(self, k)
			if k == "right" then
				game_params.music = game_params.music + 1
				if game_params.music > #MUSIC then
					game_params.music = 1
				end
			elseif k == "left" then
				game_params.music = game_params.music - 1
				if game_params.music < 1 then
					game_params.music = #MUSIC
				end
			end
		end
	},

	["BLOCKS"] = {
		height = 2,
		draw = function(self, row_pix_w, row_pix_h, alpha)
			local half_tl = (DEFAULT_TILE_LENGTH/2)

			local block_xdiff = math.floor(row_pix_w/4)
			local block_y = math.floor(1.5 * ROW_PIX_H + ROW_PIX_PAD)

			for i = 1, 3 do
				local lalpha = (i <= game_params.npairs and 255 or 64) * alpha

				love.graphics.setColor(
					BLOCK_COLORS[i][1],
					BLOCK_COLORS[i][2],
					BLOCK_COLORS[i][3],
					lalpha
				)

				local x = (block_xdiff * i) - half_tl

				love.graphics.rectangle("fill", x, block_y - half_tl,
					DEFAULT_TILE_LENGTH, DEFAULT_TILE_LENGTH)

				love.graphics.setColor(255, 255, 255, lalpha)
				love.graphics.draw(img_arrow, x, block_y - half_tl)
			end

			love.graphics.setColor(255, 255, 255, 128 * alpha)

			draw_lr_arrows(block_y, alpha,
				(game_params.npairs ~= 1) ,
				(game_params.npairs ~= 3)
			)
		end,

		keypressed = function(self, k)
			if k == "right" then
				game_params.npairs = game_params.npairs + 1
			elseif k == "left" then
				game_params.npairs = game_params.npairs - 1
			end

			n_player_blocks = util.math.clamp(1, game_params.npairs, 3)
		end
	},

	["START"] = {
		keypressed = function(self, k)
			if k == "return" or k == " " then
				fade_state = "out"
				fade_out_to_game = true
			end
		end
	}
}

local row_order = {
	"HUE SHIFT", "GRID", "MUSIC", "BLOCKS", "OBSTACLES", "START"
}

local function get_row(row_n)
	local row_name = row_order[row_n or selected_row]
	return rows[row_name]
end

local function get_row_height(row_n)
	local row = get_row(row_n)

	if row then
		if row._actual_height then
			return row._actual_height
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

local function draw_row_rect(row_h, alpha)
	love.graphics.setColor(255, 255, 255, ROW_ALPHA * (alpha or 1))
	love.graphics.rectangle("fill", 0, 0, ROW_PIX_W, get_row_pix_h(row_h))
end

local function draw_row_label(row_name, row_pix_w, row_pix_h, alpha)
	love.graphics.setColor(255, 255, 255, 255 * (alpha or 1))
	love.graphics.setFont(font_row_label)

	print_centered(row_name, row_pix_w/2, row_pix_h/2)
end

local function draw_row(row_n, row_slot, alpha)
	alpha = ((row_n == selected_row) and 1 or 0.5) * alpha

	local row_h = get_row_height(row_n)

	---

	local row = get_row(row_n) or {}


	love.graphics.push()
	love.graphics.translate(ROW_PIX_PAD, get_row_pix_y(row_slot))

	draw_row_rect(row_h, alpha)

	if not row.hide_label then
		draw_row_label(row.label or row_order[row_n], ROW_PIX_W, ROW_PIX_H, alpha)
	end

	if row.draw then
		row:draw(ROW_PIX_W, get_row_pix_h(row_h), alpha)
	end

	love.graphics.pop()
end

---

function menu:enter(previous, arg)
	calculate_dimensions(love.graphics.getWidth(), love.graphics.getHeight())

	for row_name, row in pairs(rows) do
		if row.init then row:init() end
	end

	---

	fade_state = "in"
	global_alpha = 0
end

function menu:update(dt)
	bg.update(dt)

	---

	for row_n, row_name in ipairs(row_order) do
		local row = rows[row_name]
		if row then
			if row.update then
				row:update(dt)
			end

			row._actual_height = interpolate(row._actual_height or row.height or 1, row.height or 1, dt)
		end
	end

	scroll_offset = interpolate(scroll_offset, target_scroll_offset, dt)

	---

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

		---
	elseif fade_state == "out" then
		---
		global_alpha = global_alpha - (1/TRANSITION_DURATION) * dt
		if global_alpha <= 0 then
			global_alpha = 0
			if fade_out_to_game then
				gs.switch(state_game, {
					npairs = game_params.npairs,

					grid_w = game_params.grid_w,
					grid_h = game_params.grid_h,

					music = MUSIC[game_params.music].path,
					bpm = MUSIC[game_params.music].bpm,
					onbeat = MUSIC[game_params.music].onbeat
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
	for row_n, row_name in ipairs(row_order) do
		draw_row(row_n, offset, global_alpha)

		offset = offset + get_row_height(row_n)
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
	local old_row = get_row()
	if old_row then
		old_row.selected = false
		if old_row.on_deselect then
			old_row:on_deselect()
		end
	end

	---

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

	---

	local new_row = get_row()
	if new_row then
		new_row.selected = true
		if new_row.on_select then
			new_row:on_select()
		end
	end
end

function menu:keypressed(k, isrep)
	if not isrep then
		if k == "up" then
			prev_row()
		elseif k == "down" then
			next_row()
		elseif k == "escape" then
			fade_state = "out"
			fade_out_to_game = false
		end
	end

	local row = get_row()
	if row and row.keypressed then
		row:keypressed(k, isrep)
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
			row:mousepressed(x, y, b)
		end
	end
end

---

function menu:leave()

end

---

return menu
