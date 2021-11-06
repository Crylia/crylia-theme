-----------------------------------
-- This is the titlebar module --
-----------------------------------

-- Awesome Libs
local awful = require("awful")
local color = require("theme.crylia.colors")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")

awful.titlebar.enable_tooltip = true
awful.titlebar.fallback_name = 'Client'

local double_click_event_handler = function(double_click_event)
	if double_click_timer then
		double_click_timer:stop()
		double_click_timer = nil
		double_click_event()
		return
	end
	double_click_timer = gears.timer.start_new(
		0.20,
		function()
			double_click_timer = nil
			return false
		end
	)
end

local create_click_events = function (c)
    local buttons = gears.table.join(
        awful.button(
            {},
            1,
            function ()
                double_click_event_handler(function ()
                    if c.floating then
                        c.float = false
                        return
                    end
                    c.maximized = not c.maximized
                    c:raise()
                end)
                c:activate { context = 'titlebar', action = 'mouse_move' }
            end
        ),
        awful.button(
            {},
            3,
            function ()
                c:activate { context = 'titlebar', action = 'mouse_resize' }
            end
        )
    )
    return buttons
end

local create_titlebar = function (c, bg, size)
    awful.titlebar(c, { position = "left", bg = bg, size = size }) : setup {
        {
            {
                {
                    awful.titlebar.widget.closebutton(c),
                    widget = wibox.container.background,
                    bg = color.color["Red200"],
                    shape = function (cr, height, width)
                        gears.shape.rounded_rect(cr, width, height, 4)
                    end
                },
                {
                    awful.titlebar.widget.maximizedbutton(c),
                    widget = wibox.container.background,
                    bg = color.color["Yellow200"],
                    shape = function (cr, height, width)
                        gears.shape.rounded_rect(cr, width, height, 4)
                    end
                },
                {
                    awful.titlebar.widget.minimizebutton(c),
                    widget = wibox.container.background,
                    bg = color.color["Green200"],
                    shape = function (cr, height, width)
                        gears.shape.rounded_rect(cr, width, height, 4)
                    end
                },
                spacing = dpi(10),
				layout  = wibox.layout.fixed.vertical
            },
            margins = dpi(8),
            widget = wibox.container.margin
        },
        {
			buttons = create_click_events(c),
			layout = wibox.layout.flex.vertical
        },
        nil,
        layout = wibox.layout.align.vertical
    }
end

local create_titlebar_dialog = function(c, bg, size)
	awful.titlebar(c, {position = "left", bg = bg, size = size}) : setup {
		{
			{
				{
                    awful.titlebar.widget.closebutton(c),
                    widget = wibox.container.background,
                    bg = color.color["Red200"],
                    shape = function (cr, height, width)
                        gears.shape.rounded_rect(cr, width, height, 4)
                    end
                },
                {
                    awful.titlebar.widget.minimizebutton(c),
                    widget = wibox.container.background,
                    bg = color.color["Green200"],
                    shape = function (cr, height, width)
                        gears.shape.rounded_rect(cr, width, height, 4)
                    end
                },
				spacing = dpi(7),
				layout  = wibox.layout.fixed.vertical
			},
			margins = dpi(8),
			widget = wibox.container.margin
		},
		{
			buttons = create_click_events(c),
			layout = wibox.layout.flex.vertical
		},
		nil,
		layout = wibox.layout.align.vertical
	}
end

local draw_titlebar = function (c)
    if c.type == 'normal' then
        if c.class == 'Firefox' then
            create_titlebar(c, '#121212AA', 35)
        elseif c.name == "Steam" then
            create_titlebar(c, '#121212AA', 0)
        elseif c.name == "Settings" then
            create_titlebar(c, '#121212AA', 0)
        elseif c.class == "gcr-prompter" or c.class == "Gcr-prompter" then
            create_titlebar(c, '#121212AA', 0)
        else
            create_titlebar(c, '#121212AA', 35)
        end
    elseif c.type == 'dialog' then
        create_titlebar_dialog(c, '#121212AA', 35)
    elseif c.type == 'modal' then
        create_titlebar(c, '#121212AA', 35)
    end
end

client.connect_signal(
    "request::titlebars",
    function (c)
        draw_titlebar(c)
        if not c.floating then
            awful.titlebar.hide(c, 'left')
        end
    end
)

client.connect_signal(
    'property::floating',
    function (c)
        if c.floating then
            if c.class == "Steam" then
                awful.titlebar.hide(c, 'left')
            else
                awful.titlebar.show(c, 'left')
            end
        else
            awful.titlebar.hide(c, 'left')
        end
    end
)