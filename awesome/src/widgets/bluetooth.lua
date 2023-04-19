local setmetatable = setmetatable

-- Awesome libs
local apopup = require('awful.popup')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi
local gcolor = require('gears.color')
local gfilesystem = require('gears.filesystem')
local gtimer = require('gears.timer')
local wibox = require('wibox')

-- Own libs
local bt_module = require('src.modules.bluetooth')
local hover = require('src.tools.hover')

local capi = {
  awesome = awesome,
  mouse = mouse,
}

-- Icon directory path
local icondir = gfilesystem.get_configuration_dir() .. 'src/assets/icons/bluetooth/'

-- Returns the bluetooth widget
return setmetatable({}, {
  __call = function(_, s)
    -- Get the bluetooth module
    local bt_widget = bt_module { screen = s }
    -- Create the bluetooth widget
    local bluetooth_widget = wibox.widget {
      {
        {
          {
            id = 'icon',
            image = gcolor.recolor_image(icondir .. 'bluetooth-off.svg', beautiful.colorscheme.bg),
            widget = wibox.widget.imagebox,
            valign = 'center',
            halign = 'center',
            resize = false,
          },
          id = 'icon_layout',
          widget = wibox.container.place,
        },
        id = 'icon_margin',
        left = dpi(8),
        right = dpi(8),
        widget = wibox.container.margin,
      },
      bg = beautiful.colorscheme.bg_blue,
      fg = beautiful.colorscheme.bg,
      shape = beautiful.shape[6],
      widget = wibox.container.background,
    }

    hover.bg_hover { widget = bluetooth_widget }

    -- Create the awful.popup container for the module
    local bluetooth_container = apopup {
      widget = bt_widget,
      ontop = true,
      stretch = false,
      visible = true,
      screen = s,
      border_color = beautiful.colorscheme.border_color,
      border_width = dpi(2),
      bg = beautiful.colorscheme.bg,
    }

    gtimer.delayed_call(function()
      bluetooth_container.visible = false
    end)

    -- When the status changes update the icon
    bt_widget:connect_signal('bluetooth::status', function(status)
      bluetooth_widget:get_children_by_id('icon')[1].image = gcolor.recolor_image(status._private.Adapter1.Powered and
        icondir .. 'bluetooth-on.svg' or icondir .. 'bluetooth-off.svg', beautiful.colorscheme.bg)
    end)

    -- On left click toggle the bluetooth container else toggle the bluetooth on/off
    bluetooth_widget:connect_signal('button::press', function(_, _, _, key)
      if key == 1 then
        local geo = capi.mouse.current_wibox:geometry()
        bluetooth_container.x = capi.mouse.coords().x - (bluetooth_container:geometry().width / 2)
        bluetooth_container.y = dpi(70)
        bluetooth_container.visible = not bluetooth_container.visible
      else
        capi.awesome.emit_signal('toggle_bluetooth')
      end
    end)

    return bluetooth_widget
  end,
})
