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


return function(s)

    local systray = wibox.widget {
        {
            {
                wibox.widget.systray(),
                margins = dpi(6),
                widget = wibox.container.margin,
                id = 'st'
            },
            strategy = "exact",
            layout = wibox.container.constraint,
            id = "container"
        },
        widget = wibox.container.background,
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 5)
        end,
        bg = color.color["BlueGrey800"]
    }
    -- Signals
    Hover_signal(systray.container, color.color["Red200"])

    systray.container.st.widget:set_base_size(dpi(20))

    return systray
end
