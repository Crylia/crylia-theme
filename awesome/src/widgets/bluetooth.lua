----------------------------------
-- This is the bluetooth widget --
----------------------------------

-- Awesome Libs
local awful = require("awful")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")

-- Icon directory path
local icondir = awful.util.getdir("config") .. "src/assets/icons/bluetooth/"

-- Returns the bluetooth widget
return function(s)
  local bluetooth_widget = wibox.widget {
    {
      {
        {
          id = "icon",
          image = gears.color.recolor_image(icondir .. "bluetooth-off.svg", Theme_config.bluetooth.fg),
          widget = wibox.widget.imagebox,
          valign = "center",
          halign = "center",
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
    bg = Theme_config.bluetooth.bg,
    fg = Theme_config.bluetooth.fg,
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(6))
    end,
    widget = wibox.container.background
  }
  -- Hover signal to change color when mouse is over
  Hover_signal(bluetooth_widget, Theme_config.bluetooth.bg, Theme_config.bluetooth.fg)

  awesome.connect_signal("state", function(state)
    if state then
      bluetooth_widget:get_children_by_id("icon")[1]:set_image(gears.color.recolor_image(icondir .. "bluetooth-on.svg",
        Theme_config.bluetooth.fg))
    else
      bluetooth_widget:get_children_by_id("icon")[1]:set_image(gears.color.recolor_image(icondir .. "bluetooth-off.svg",
        Theme_config.bluetooth.fg))
    end
  end)

  bluetooth_widget:connect_signal(
    "button::press",
    function(_, _, _, key)
      if key == 1 then
        awesome.emit_signal("bluetooth_controller::toggle", s)
      else
        awesome.emit_signal("toggle_bluetooth")
      end
    end
  )

  return bluetooth_widget
end
