----------------------------------
-- This is the bluetooth widget --
----------------------------------

-- Awesome Libs
local awful = require("awful")
local color = require("theme.crylia.colors")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")
require("main.signals")

-- Icon directory path
local icondir = awful.util.getdir("config") .. "theme/crylia/assets/icons/bluetooth/"

-- Returns the bluetooth widget
return function()
    local bluetooth_widget = wibox.widget {
        {
            {
                {
                    id = "icon",
                    image = gears.color.recolor_image(icondir .. "bluetooth-off.svg"),
                    widget = wibox.widget.imagebox,
                    resize = false
                },
                id = "icon_layout",
                widget = wibox.container.place
            },
            id = "icon_margin",
            left = dpi(8),
            right = dpi(8),
            widget = wibox.container.margin
        },
        bg = color.color["Blue200"],
        fg = color.color["Grey900"],
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 5)
        end,
        widget = wibox.container.background
    }

    local bluetooth_tooltip = awful.tooltip {
        objects = { bluetooth_widget },
        text = "",
        mode = "inside",
        preferred_alignments = "middle",
        margins = dpi(10)
    }

    local bluetooth_state = "off"
    local connected_device = "nothing"

    -- ! if you don't have a bluetooth device then this function will
    -- ! spawn hundereds of processes of bluetoothctl, this will be bad
    -- TODO: Check for a bluetooth controller first, maybe use a different program
    local get_bluetooth_information = function()
        --     awful.spawn.easy_async_with_shell(
        --         [[ bluetoothctl show | grep Powered | awk '{print $2}' ]],
        --         function(stdout)
        --             local icon = icondir .. "bluetooth"
        --             stdout = stdout:gsub("\n", "")
        --             if stdout == "yes" then
        --                 icon = icon .. "-on"
        --                 bluetooth_state = "on"
        --                 awful.spawn.easy_async_with_shell(
        --                     [[ bluetoothctl info | grep Name: | awk '{ first = $1; $1 = ""; print $0 }' ]],
        --                     function(stdout2)
        --                         if stdout2 == nil or stdout2:gsub("\n", "") == "" then
        --                             bluetooth_tooltip:set_text("Bluetooth is turned " .. bluetooth_state .. "\n" .. "You are currently not connected")
        --                         else
        --                             bluetooth_tooltip:set_text("Bluetooth is turned " .. bluetooth_state .. "\n" .. "You are currently connected to:" .. connected_device)
        --                             connected_device = stdout2
        --                         end
        --                     end
        --                 )
        --             else
        --                 icon = icon .. "-off"
        --                 bluetooth_state = "off"
        --                 bluetooth_tooltip:set_text("Bluetooth is turned " .. bluetooth_state .. "\n")
        --             end
        --             bluetooth_widget.icon_margin.icon_layout.icon:set_image(gears.color.recolor_image(icon .. ".svg", color.color["Grey900"]))
        --         end
        --     )
    end

    local bluetooth_update = gears.timer {
        timeout = 5,
        autostart = true,
        call_now = true,
        callback = function()
            --[[ awful.spawn.easy_async_with_shell(
                "bluetoothctl list",
                function(stdout)
                    if stdout ~= nil or stdout:gsub("\n", ""):match("") then
                        get_bluetooth_information()
                    end
                end
            ) ]]
        end
    }

    -- Signals
    Hover_signal(bluetooth_widget, color.color["Blue200"])

    bluetooth_widget:connect_signal(
        "button::press",
        function()
            if bluetooth_state == "on" then
                awful.spawn.easy_async_with_shell(
                    "bluetoothctl power off",
                    function(stdout)
                        get_bluetooth_information()
                    end
                )
            else
                awful.spawn.easy_async_with_shell(
                    "bluetoothctl power on",
                    function(stdout)
                        get_bluetooth_information()
                    end
                )
            end
        end
    )

    get_bluetooth_information()
    return bluetooth_widget
end
