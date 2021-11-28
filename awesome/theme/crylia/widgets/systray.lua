--------------------------------
-- This is the power widget --
--------------------------------

-- Awesome Libs
local awful = require("awful")
local color = require("theme.crylia.colors")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")
require("main.signals")


return function (s)

    local systray = wibox.widget{
        {
            {
                wibox.widget.systray,
                top = dpi(6),
                bottom = dpi(6),
                left = dpi(6),
                right = dpi(6),
                widget = wibox.container.margin
            },
            width = dpi(100),
            strategy = "exact",
            layout = wibox.container.constraint,
        },
        widget = wibox.container.background,
        shape = function (cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 5)
        end,
        bg = color.color["BlueGrey800"]
    }
    -- Signals
    --hover_signal(systray, color.color["Red200"])

    return systray
end