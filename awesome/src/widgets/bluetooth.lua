----------------------------------
-- This is the bluetooth widget --
----------------------------------

-- Awesome libs
local awful = require("awful")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")

-- Own libs
local bt_module = require("src.modules.bluetooth.init")

local capi = {
  awesome = awesome,
  mouse = mouse
}

-- Icon directory path
local icondir = gears.filesystem.get_configuration_dir() .. "src/assets/icons/bluetooth/"

-- Returns the bluetooth widget
return function(s)

  -- Get the bluetooth module
  local bt_widget = bt_module { screen = s }
  -- Create the bluetooth widget
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

  -- If bt_widget is nil then there is no bluetooth adapter and there shouldn't be done
  -- anything besides returning the widget without any logic behind
  if not bt_widget then
    return bluetooth_widget
  end

  -- Create the awful.popup container for the module
  local bluetooth_container = awful.popup {
    widget = bt_widget,
    ontop = true,
    stretch = false,
    visible = false,
    screen = s,
    border_color = Theme_config.bluetooth_controller.container_border_color,
    border_width = Theme_config.bluetooth_controller.container_border_width,
    bg = Theme_config.bluetooth_controller.container_bg
  }

  -- When the status changes update the icon
  bt_widget:connect_signal("bluetooth::status", function(status)
    bluetooth_widget:get_children_by_id("icon")[1].image = gears.color.recolor_image(status._private.Adapter1.Powered and
      icondir .. "bluetooth-on.svg" or icondir .. "bluetooth-off.svg", Theme_config.bluetooth.fg)
  end)

  -- Hover signal to change color when mouse is over
  Hover_signal(bluetooth_widget)

  -- On left click toggle the bluetooth container else toggle the bluetooth on/off
  bluetooth_widget:connect_signal("button::press", function(_, _, _, key)
    if key == 1 then
      local geo = capi.mouse.current_wibox:geometry()
      bluetooth_container.x = geo.x
      bluetooth_container.y = geo.y + dpi(55)
      bluetooth_container.visible = not bluetooth_container.visible
    else
      capi.awesome.emit_signal("toggle_bluetooth")
    end
  end)

  return bluetooth_widget
end
