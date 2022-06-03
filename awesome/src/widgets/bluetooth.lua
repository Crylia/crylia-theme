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

-- Icon directory path
local icondir = awful.util.getdir("config") .. "src/assets/icons/bluetooth/"

-- Returns the bluetooth widget
return function(s)
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
  -- Hover signal to change color when mouse is over
  Hover_signal(bluetooth_widget, color["Blue200"], color["Grey900"])

  awesome.connect_signal("state", function(state)
    if state then
      bluetooth_widget:get_children_by_id("icon")[1]:set_image(gears.color.recolor_image(icondir .. "bluetooth-on.svg", color["Grey900"]))
    else
      bluetooth_widget:get_children_by_id("icon")[1]:set_image(gears.color.recolor_image(icondir .. "bluetooth-off.svg", color["Grey900"]))
    end
  end)

  bluetooth_widget:connect_signal(
    "button::press",
    function(c, d, e, key)
      if key == 1 then
        awesome.emit_signal("bluetooth_controller::toggle", s)
      else
        awesome.emit_signal("toggle_bluetooth")
      end
    end
  )

  return bluetooth_widget
end
