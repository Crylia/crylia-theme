------------------------------
-- This is the audio widget --
------------------------------

-- Awesome Libs
local awful = require("awful")
local color = require("theme.crylia.colors")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")
require("Main.Signals")

-- Icon directory path
local icondir = awful.util.getdir("config") .. "theme/crylia/assets/icons/kblayout/"

return function ()
    local kblayout_widget = wibox.widget{
        {
            {
                {
                    {
                        {
                            id = "icon",
                            widget = wibox.widget.imagebox,
                            resize = false,
                            image = gears.color.recolor_image(icondir .. "keyboard.svg", color.color["Grey900"])
                        },
                        id = "icon_layout",
                        widget = wibox.container.place
                    },
                    top = dpi(2),
                    widget = wibox.container.margin,
                    id = "icon_margin"
                },
                spacing = dpi(6),
                {
                    id = "label",
                    align = "center",
                    valign = "center",
                    widget = wibox.widget.textbox
                },
                id = "kblayout_layout",
                layout = wibox.layout.fixed.horizontal
            },
            id = "container",
            left = dpi(5),
            right = dpi(10),
            widget = wibox.container.margin
        },
        bg = color.color["Green200"],
        fg = color.color["Grey900"],
        shape = function (cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 5)
        end,
        widget = wibox.widget.background
    }
    local layout = "";
    local get_kblayout = function ()
        awful.spawn.easy_async_with_shell(
            [[ setxkbmap -query | grep layout | awk '{print $2}' ]],
            function (stdout)
                layout = stdout
                kblayout_widget.container.kblayout_layout.label.text = stdout
                return stdout
            end
        )
        return layout
    end

    local set_kblayout = function (kblayout)
        kblayout = "de"
        if get_kblayout():gsub("\n", "") == "de" then
            kblayout = "ru"
        end
        awful.spawn.easy_async_with_shell("setxkbmap -layout " .. kblayout)
        get_kblayout()
    end

    -- Signals
    hover_signal(kblayout_widget, color.color["Green200"])

    kblayout_widget:connect_signal(
        "button::press",
        function ()
            set_kblayout()
        end
    )

    get_kblayout()
    return kblayout_widget
end