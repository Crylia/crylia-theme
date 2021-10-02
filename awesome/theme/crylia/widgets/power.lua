--------------------------------
-- This is the power widget --
--------------------------------

-- Awesome Libs
local awful = require("awful")
local color = require("theme.crylia.colors")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local naughty = require("naughty")
local wibox = require("wibox")

-- Icon directory path
local icondir = awful.util.getdir("config") .. "theme/crylia/assets/icons/power/"

return function ()

    local power_widget = wibox.widget{
        {
            {
                {
                    {
                        {
                            id = "icon",
                            image = gears.color.recolor_image(icondir .. "power.svg", color.color["Grey900"]),
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
                id = "power_layout",
                layout = wibox.layout.fixed.horizontal
            },
            id = "container",
            left = dpi(5),
            right = dpi(5),
            widget = wibox.container.margin
        },
        bg = color.color["Red200"],
        fg = color.color["Grey800"],
        shape = function (cr, width, height)
            gears.shape.rounded_rect(cr, height, width, 5)
        end,
        widget = wibox.widget.background
    }

    -- Signals
    local old_wibox, old_cursor, old_bg
    power_widget:connect_signal(
        "mouse::enter",
        function ()
            old_bg = power_widget.bg
            power_widget.bg = color.color["Red200"] .. "dd"
            local w = mouse.current_wibox
            if w then
                old_cursor, old_wibox = w.cursor, w
                w.cursor = "hand1"
            end
        end
    )

    power_widget:connect_signal(
        "button::press",
        function ()
            power_widget.bg = color.color["Red200"] .. "bb"
        end
    )

    power_widget:connect_signal(
        "button::release",
        function ()
            power_widget.bg = color.color["Red200"] .. "dd"
        end
    )

    power_widget:connect_signal(
        "mouse::leave",
        function ()
            power_widget.bg = old_bg
            if old_wibox then
                old_wibox.cursor = old_cursor
                old_wibox = nil
            end
        end
    )

    return power_widget
end