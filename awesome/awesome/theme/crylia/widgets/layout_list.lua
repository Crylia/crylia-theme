----------------------------------
-- This is the layoutbox widget --
----------------------------------

-- Awesome Libs
local awful = require("awful")
local color = require("theme.crylia.colors")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")

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
    local old_wibox, old_cursor, old_bg
    layout:connect_signal(
        "mouse::enter",
        function ()
            old_bg = layout.bg
            layout.bg = color.color["LightBlue200"] .. "dd"
            local w = mouse.current_wibox
            if w then
                old_cursor, old_wibox = w.cursor, w
                w.cursor = "hand1"
            end
        end
    )

    layout:connect_signal(
        "button::press",
        function ()
            layout.bg = color.color["LightBlue200"] .. "bb"
        end
    )

    layout:connect_signal(
        "button::release",
        function ()
            layout.bg = color.color["LightBlue200"] .. "dd"
        end
    )

    layout:connect_signal(
        "mouse::leave",
        function ()
            layout.bg = old_bg
            if old_wibox then
                old_wibox.cursor = old_cursor
                old_wibox = nil
            end
        end
    )

    return layout
end