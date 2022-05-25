----------------------------------
-- This is the bluetooth widget --
----------------------------------

-- Awesome Libs
local awful = require("awful")
local color = require("src.theme.colors")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local naughty = require("naughty")
local wibox = require("wibox")
require("src.core.signals")

-- Icon directory path
local icondir = awful.util.getdir("config") .. "src/assets/icons/bluetooth/"

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
    bg = color["Blue200"],
    fg = color["Grey900"],
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

  awful.widget.watch(
    "rfkill list bluetooth",
    5,
    function(_, stdout)
      local icon = icondir .. "bluetooth"
      if stdout:match('Soft blocked: yes') or stdout:gsub("\n", "") == '' then
        icon = icon .. "-off"
        bluetooth_state = "off"
        bluetooth_tooltip:set_text("Bluetooth is turned " .. bluetooth_state .. "\n")
      else
        icon = icon .. "-on"
        bluetooth_state = "on"
        awful.spawn.easy_async_with_shell(
          './.config/awesome/src/scripts/bt.sh',
          function(stdout2)
            if stdout2 == nil or stdout2:gsub("\n", "") == "" then
              bluetooth_tooltip:set_text("Bluetooth is turned " .. bluetooth_state .. "\n" .. "You are currently not connected")
            else
              connected_device = stdout2:gsub("%(", ""):gsub("%)", "")
              bluetooth_tooltip:set_text("Bluetooth is turned " .. bluetooth_state .. "\n" .. "You are currently connected to:\n" .. connected_device)
            end
          end
        )
      end
      bluetooth_widget.icon_margin.icon_layout.icon:set_image(gears.color.recolor_image(icon .. ".svg", color["Grey900"]))
    end,
    bluetooth_widget
  )

  -- Signals
  Hover_signal(bluetooth_widget, color["Blue200"], color["Grey900"])

  bluetooth_widget:connect_signal(
    "button::press",
    function()
      awful.spawn.easy_async_with_shell(
        "rfkill list bluetooth",
        function(stdout)
          if stdout:gsub("\n", "") ~= '' then
            if bluetooth_state == "off" then
              awful.spawn.easy_async_with_shell(
                [[
              rfkill unblock bluetooth
              sleep 1
              bluetoothctl power on
            ]]   ,
                function()
                  naughty.notification {
                    title = "System Notification",
                    app_name = "Bluetooth",
                    message = "Bluetooth activated"
                  }
                end
              )
            else
              awful.spawn.easy_async_with_shell(
                [[
              bluetoothctl power off
              rfkill block bluetooth
            ]]   ,
                function()
                  naughty.notification {
                    title = "System Notification",
                    app_name = "Bluetooth",
                    message = "Bluetooth deactivated"
                  }
                end
              )
            end
          end
        end
      )
    end
  )

  return bluetooth_widget
end
