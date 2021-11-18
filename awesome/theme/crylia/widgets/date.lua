-----------------------------
-- This is the date widget --
-----------------------------

-- Awesome Libs
local awful = require("awful")
local color = require("theme.crylia.colors")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")
require("Main.Signals")

-- Icon directory path
local icondir = awful.util.getdir("config") .. "theme/crylia/assets/icons/date/"

-- Returns the date widget
return function ()

    local date_widget = wibox.widget{
        {
            {
                {
                    {
                        {
                            id = "icon",
                            image = gears.color.recolor_image(icondir .. "calendar.svg", color.color["Grey900"]),
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
                id = "date_layout",
                layout = wibox.layout.fixed.horizontal
            },
            id = "container",
            left = dpi(10),
            right = dpi(10),
            widget = wibox.container.margin
        },
        bg = color.color["Teal200"],
        fg = color.color["Grey900"],
        shape = function (cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 5)
        end,
        widget = wibox.widget.background
    }

    local set_date = function ()
        date_widget.container.date_layout.label:set_text(os.date("%a, %b %d"))
    end

    -- Updates the date every minute, dont blame me if you miss silvester
    local date_updater = gears.timer {
        timeout = 60,
        autostart = true,
        call_now = true,
        callback = function ()
            set_date()
        end
    }

    -- Signals
    hover_signal(date_widget, color.color["Teal200"])

    date_widget:connect_signal(
        "mouse::enter",
        function ()
            awesome.emit_signal("widget::calendar_osd:stop", true)
        end
    )

    date_widget:connect_signal(
        "mouse::leave",
        function ()
            awesome.emit_signal("widget::calendar_osd:rerun", true)
        end
    )

    return date_widget
end