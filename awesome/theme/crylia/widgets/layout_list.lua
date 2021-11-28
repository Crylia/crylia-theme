----------------------------------
-- This is the layoutbox widget --
----------------------------------

-- Awesome Libs
local awful = require("awful")
local color = require("theme.crylia.colors")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")
require("main.signals")

-- Returns the layoutbox widget
return function ()
    local layout = wibox.widget{
        {
            awful.widget.layoutbox(),
            margins = dpi(3),
            forced_width = dpi(33),
            widget = wibox.container.margin
        },
        bg = color.color["LightBlue200"],
        shape = function (cr, width, height)
        gears.shape.rounded_rect(cr, width, height, 5)
        end,
        widget = wibox.container.background
    }

    -- Signals
    hover_signal(layout, color.color["LightBlue200"])

    layout:connect_signal(
        "button::press",
        function ()
            awful.layout.inc(-1)
        end
    )

    return layout
end