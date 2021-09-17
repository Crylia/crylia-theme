------------------------------
-- This is the clock widget --
------------------------------

-- Awesome Libs
local awful = require("awful")
local color = require("theme.crylia.colors")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")

-- Icon directory path
local icondir = awful.util.getdir("config") .. "theme/crylia/assets/icons/clock/"

-- Returns the clock widget
return function ()

    local clock_widget = wibox.widget{
        {
            {
                {
                    {
                        {
                            id = "icon",
                            image = gears.color.recolor_image(icondir .. "clock.svg", color.color["Grey900"]),
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
            left = dpi(10),
            right = dpi(10),
            widget = wibox.container.margin
        },
        bg = color.color["Orange200"],
        fg = color.color["Grey900"],
        shape = function (cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 5)
        end,
        widget = wibox.widget.background
    }

    local set_clock = function ()
        clock_widget.container.clock_layout.label:set_text(os.date("%H:%M"))
    end

    -- Updates the clock every 5 seconds, worst case you are 5 seconds behind
    -- ¯\_(ツ)_/¯
    local clock_update = gears.timer {
        timeout = 5,
        autostart = true,
        call_now = true,
        callback = function ()
            set_clock()
        end
    }

    -- Signals
    local old_wibox, old_cursor, old_bg
    clock_widget:connect_signal(
        "mouse::enter",
        function ()
            old_bg = clock_widget.bg
            clock_widget.bg = color.color["Orange200"] .. "dd"
            local w = mouse.current_wibox
            if w then
                old_cursor, old_wibox = w.cursor, w
                w.cursor = "hand1"
            end
        end
    )

    clock_widget:connect_signal(
        "button::press",
        function ()
            clock_widget.bg = color.color["Orange200"] .. "bb"
        end
    )

    clock_widget:connect_signal(
        "button::release",
        function ()
            clock_widget.bg = color.color["Orange200"] .. "dd"
        end
    )

    clock_widget:connect_signal(
        "mouse::leave",
        function ()
            clock_widget.bg = old_bg
            if old_wibox then
                old_wibox.cursor = old_cursor
                old_wibox = nil
            end
        end
    )

    return clock_widget
end