---------------------------------
-- This is the tasklist widget --
---------------------------------

-- Awesome Libs
local awful = require('awful')
local wibox = require('wibox')
local dpi = require('beautiful').xresources.apply_dpi
local gears = require('gears')

local color = require("src.lib.color")
local rubato = require("src.lib.rubato")

local list_update = function(widget, buttons, label, _, objects)
	widget:reset()
	for _, object in ipairs(objects) do
		local task_widget = wibox.widget {
			{
				{
					{
						{
							nil,
							{
								id = "icon",
								valign = "center",
								halign = "center",
								resize = true,
								image = Get_icon(object.class, object.name) or object.icon,
								widget = wibox.widget.imagebox
							},
							nil,
							layout = wibox.layout.align.horizontal,
							id = "layout_icon"
						},
						forced_width = dpi(33),
						margins = dpi(3),
						widget = wibox.container.margin,
						id = "margin"
					},
					{
						text = "",
						align = "center",
						valign = "center",
						visible = true,
						widget = wibox.widget.textbox,
						id = "title"
					},
					layout = wibox.layout.fixed.horizontal,
					id = "layout_it"
				},
				right = dpi(5),
				left = dpi(5),
				widget = wibox.container.margin,
				id = "container"
			},
			fg = Theme_config.tasklist.fg,
			shape = function(cr, width, height)
				gears.shape.rounded_rect(cr, width, height, dpi(6))
			end,
			widget = wibox.container.background
		}

		local task_tool_tip = awful.tooltip {
			objects = { task_widget },
			mode = "inside",
			preferred_alignments = "middle",
			preferred_positions = "bottom",
			margins = dpi(10),
			gaps = 0,
			delay_show = 1
		}

		local function create_buttons(buttons_t, object_t)
			if buttons_t then
				local btns = {}
				for _, b in ipairs(buttons_t) do
					local btn = awful.button {
						modifiers = b.modifiers,
						button = b.button,
						on_press = function()
							b:emit_signal('press', object_t)
						end,
						on_release = function()
							b:emit_signal('release', object_t)
						end
					}
					btns[#btns + 1] = btn
				end
				return btns
			end
		end

		task_widget:buttons(create_buttons(buttons, object))

		local text, _ = label(object, task_widget.container.layout_it.title)


		--#region Rubato and Color animation

		-- Background rubato init
		local r_timed_bg = rubato.timed { duration = 0.5 }
		local g_timed_bg = rubato.timed { duration = 0.5 }
		local b_timed_bg = rubato.timed { duration = 0.5 }

		-- starting color
		r_timed_bg.pos, g_timed_bg.pos, b_timed_bg.pos = color.utils.hex_to_rgba(Theme_config.tasklist.bg)


		-- Foreground rubato init
		local r_timed_fg = rubato.timed { duration = 0.5 }
		local g_timed_fg = rubato.timed { duration = 0.5 }
		local b_timed_fg = rubato.timed { duration = 0.5 }

		-- starting color
		r_timed_fg.pos, g_timed_fg.pos, b_timed_fg.pos = color.utils.hex_to_rgba(Theme_config.tasklist.fg)

		-- Subscribable function to have rubato set the bg/fg color
		local function update_bg()
			task_widget:set_bg("#" .. color.utils.rgba_to_hex { r_timed_bg.pos, g_timed_bg.pos, b_timed_bg.pos })
		end

		local function update_fg()
			task_widget:set_fg("#" .. color.utils.rgba_to_hex { r_timed_fg.pos, g_timed_fg.pos, b_timed_fg.pos })
		end

		-- Subscribe to the function bg and fg
		r_timed_bg:subscribe(update_bg)
		g_timed_bg:subscribe(update_bg)
		b_timed_bg:subscribe(update_bg)
		r_timed_fg:subscribe(update_fg)
		g_timed_fg:subscribe(update_fg)
		b_timed_fg:subscribe(update_fg)

		-- Both functions to set a color, if called they take a new color
		local function set_bg(newbg)
			r_timed_bg.target, g_timed_bg.target, b_timed_bg.target = color.utils.hex_to_rgba(newbg)
		end

		local function set_fg(newfg)
			r_timed_fg.target, g_timed_fg.target, b_timed_fg.target = color.utils.hex_to_rgba(newfg)
		end

		--#endregion

		if object == client.focus then
			if text == nil or text == '' then
				task_widget.container.layout_it.title:set_margins(0)
			else
				local text_full = text:match('>(.-)<')
				if text_full then
					if object.class == nil then
						text = object.name
					else
						text = object.class:sub(1, 20)
					end
					task_tool_tip:set_text(text_full)
					task_tool_tip:add_to_object(task_widget)
				else
					task_tool_tip:remove_from_object(task_widget)
				end
			end
			set_bg(Theme_config.tasklist.bg_focus)
			set_fg(Theme_config.tasklist.fg_focus)
			task_widget.container.layout_it.title:set_text(text)
		else
			set_bg(Theme_config.tasklist.bg)
			task_widget.container.layout_it.title:set_text('')
		end

		Hover_signal(task_widget)

		widget:add(task_widget)
		widget:set_spacing(dpi(6))
	end
	return widget
end

return function(s)
	return awful.widget.tasklist(
		s,
		awful.widget.tasklist.filter.currenttags,
		awful.util.table.join(
			awful.button(
				{},
				1,
				function(c)
					if c == client.focus then
						c.minimized = true
					else
						c.minimized = false
						if not c:isvisible() and c.first_tag then
							c.first_tag:view_only()
						end
						c:emit_signal('request::activate')
						c:raise()
					end
				end
			),
			awful.button(
				{},
				3,
				function(c)
					c:kill()
				end
			)
		),
		{},
		list_update,
		wibox.layout.fixed.horizontal()
	)
end
