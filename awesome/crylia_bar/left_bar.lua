--------------------------------------------------------------------------------------------------------------
-- This is the statusbar, every widget, module and so on is combined to all the stuff you see on the screen --
--------------------------------------------------------------------------------------------------------------
-- Awesome Libs
local awful = require("awful")
local color = require("src.theme.colors")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")

return function(s, widgets)

    local top_left = awful.popup {
        screen = s,
        widget = wibox.container.background,
        ontop = false,
        bg = color["Grey900"],
        visible = true,
        maximum_width = dpi(650),
        placement = function(c) awful.placement.top_left(c, { margins = dpi(10) }) end,
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 5)
        end
    }

    top_left:struts {
        top = 55
    }

    top_left:setup {
        {
            {
                widgets[1],
                left = dpi(6),
                right = dpi(3),
                top = dpi(6),
                bottom = dpi(6),
                widget = wibox.container.margin
            },
            {
                widgets[2],
                left = dpi(3),
                right = dpi(3),
                top = dpi(6),
                bottom = dpi(6),
                widget = wibox.container.margin
            },
            {
                widgets[3],
                left = dpi(3),
                right = dpi(6),
                top = dpi(6),
                bottom = dpi(6),
                widget = wibox.container.margin
            },
            forced_height = 45,
            layout = wibox.layout.fixed.horizontal
        },
        nil,
        nil,
        layout = wibox.layout.fixed.horizontal
    }
end
