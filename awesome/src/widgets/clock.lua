------------------------------
-- This is the clock widget --
------------------------------

-- Awesome Libs
local awful = require("awful")
local color = require("src.theme.colors")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")
require("src.core.signals")

-- Icon directory path
local icondir = awful.util.getdir("config") .. "src/assets/icons/clock/"

-- Returns the clock widget
return function()

    local clock_widget = wibox.widget {
        {
            {
                {
                    {
                        {
                            id = "icon",
                            image = gears.color.recolor_image(icondir .. "clock.svg", color["Grey900"]),
                            widget = wibox.widget.imagebox,
                            resize = false
                        },
                        id = "icon_layout",
                        widget = wibox.container.place
                    },
                    id = "icon_margin",
                    top = dpi(2),
                    widget = wibox.container.margin
                },
                spacing = dpi(10),
                {
                    id = "label",
                    align = "center",
                    valign = "center",
                    widget = wibox.widget.textbox
                },
                id = "clock_layout",
                layout = wibox.layout.fixed.horizontal
            },
            id = "container",
            left = dpi(8),
            right = dpi(8),
            widget = wibox.container.margin
        },
        bg = color["Orange200"],
        fg = color["Grey900"],
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 5)
        end,
        widget = wibox.container.background
    }

    local set_clock = function()
        clock_widget.container.clock_layout.label:set_text(os.date("%H:%M"))
    end

    -- Updates the clock every 5 seconds, worst case you are 5 seconds behind
    -- ¯\_(ツ)_/¯
    local clock_update = gears.timer {
        timeout = 5,
        autostart = true,
        call_now = true,
        callback = function()
            set_clock()
        end
    }

    Hover_signal(clock_widget, color["Orange200"])

    return clock_widget
end
