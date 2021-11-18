--------------------------------------------------------------------------------------------------------------
-- This is the statusbar, every widget, module and so on is combined to all the stuff you see on the screen --
--------------------------------------------------------------------------------------------------------------
-- Awesome Libs
local awful = require("awful")
local colors = require ("theme.crylia.colors")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")

return function (s, widget)

    local top_center = awful.popup{
        widget = wibox.container.background,
        ontop = false,
        bg = colors.color["Grey900"],
        stretch = false,
        visible = true,
        maximum_width = dpi(500),
        placement = function (c) awful.placement.top(c, {margins = dpi(10)}) end,
        shape = function (cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 10)
        end
    }

    top_center:setup{
        {
            widget,
            margins = dpi(6),
            widget = wibox.container.margin
        },
        forced_height = 45,
        layout = wibox.layout.align.horizontal
    }

    awesome.connect_signal(
        "hide_centerbar",
        function (hide)
            top_center.visible = hide
        end
    )
end