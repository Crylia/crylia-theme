----------------------------------
-- This is the bluetooth widget --
----------------------------------

-- Awesome Libs
local awful = require("awful")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")

local capi = {
  awesome = awesome,
}

-- Icon directory path
local icondir = gears.filesystem.get_configuration_dir() .. "src/assets/icons/bluetooth/"

-- Returns the bluetooth widget
return function(s)

  local bt_widget = require("src.modules.bluetooth.init") { screen = s }

  local bluetooth_container = awful.popup {
    widget = bt_widget:get_widget(),
    ontop = true,
    bg = Theme_config.bluetooth_controller.container_bg,
    stretch = false,
    visible = false,
    forced_width = dpi(400),
    screen = s,
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(12))
    end
  }

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

  bt_widget:connect_signal("bluetooth::status", function(status)
    bluetooth_widget:get_children_by_id("icon")[1].image = gears.color.recolor_image(status._private.Adapter1.Powered and
      icondir .. "bluetooth-on.svg" or icondir .. "bluetooth-off.svg", Theme_config.bluetooth.fg)
  end)

  -- Hover signal to change color when mouse is over
  Hover_signal(bluetooth_widget)

  bluetooth_widget:connect_signal(
    "button::press",
    function(_, _, _, key)
      if key == 1 then
        local geo = mouse.current_wibox:geometry()
        bluetooth_container.x = geo.x
        bluetooth_container.y = geo.y + dpi(55)
        bluetooth_container.visible = not bluetooth_container.visible
      else
        capi.awesome.emit_signal("toggle_bluetooth")
      end
    end
  )

  return bluetooth_widget
end
