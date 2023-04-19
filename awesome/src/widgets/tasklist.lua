local ipairs = ipairs
local setmetatable = setmetatable

-- Awesome Libs
local abutton = require('awful.button')
local atooltip = require('awful.tooltip')
local awidget = require('awful.widget')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi
local gtable = require('gears.table')
local wibox = require('wibox')

-- Local libs
local hover = require('src.tools.hover')

local capi = { client = client }

return setmetatable({}, { __call = function(_, screen)
	return awidget.tasklist {
		filter = awidget.tasklist.filter.currenttags,
		layout = wibox.layout.fixed.horizontal,
		screen = screen,
		update_function = function(widget, _, _, _, clients)
			widget:reset()

			-- Create a task widget for each client
			for _, client in ipairs(clients) do
				local task_widget = wibox.widget {
					{
						{
							{
								{
									valign = 'center',
									halign = 'center',
									resize = true,
									image = client.icon or '',
									widget = wibox.widget.imagebox,
								},
								width = dpi(25),
								height = dpi(25),
								strategy = 'exact',
								widget = wibox.container.constraint,
							},
							{
								id = 'text_role',
								halign = 'center',
								valign = 'center',
								widget = wibox.widget.textbox,
							},
							spacing = dpi(10),
							layout = wibox.layout.fixed.horizontal,
						},
						right = dpi(10),
						left = dpi(10),
						widget = wibox.container.margin,
					},
					fg = beautiful.colorscheme.fg,
					bg = beautiful.colorscheme.bg1,
					shape = beautiful.shape[6],
					widget = wibox.container.background,
				}

				task_widget:buttons { gtable.join(
					abutton({}, 1, nil, function()
						if client == capi.client.focus then
							client.minimized = true
						else
							client.minimized = false
							if not client:isvisible() and client.first_tag then
								client.first_tag:view_only()
							end
							client:emit_signal('request::activate')
							client:raise()
						end
					end),

					abutton({}, 3, function(c)
						client:kill()
					end)
				), }

				local label = beautiful.user_config.taskbar_use_name and client.name or client.class or ''

				-- If the client is focused, show the tooltip and add a label
				if client == capi.client.focus then
					atooltip {
						text = label,
						objects = { task_widget },
						mode = 'outside',
						preferred_alignments = 'middle',
						preferred_positions = 'bottom',
						margins = dpi(10),
						delay_show = 1,
					}
					task_widget:get_children_by_id('text_role')[1].text = label:sub(1, 20)
					task_widget.bg = beautiful.colorscheme.fg
					task_widget.fg = beautiful.colorscheme.bg
				else
					task_widget.bg = beautiful.colorscheme.bg1
					task_widget:get_children_by_id('text_role')[1].text = ''
				end

				hover.bg_hover { widget = task_widget }

				widget:add(task_widget)
				widget:set_spacing(dpi(5))
			end

			return widget
		end,
	}
end, })
