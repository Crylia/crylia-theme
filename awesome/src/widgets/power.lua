--------------------------------
-- This is the power widget --
--------------------------------

-- Awesome Libs
local abutton = require('awful.button')
local gtable = require('gears.table')
local dpi = require('beautiful').xresources.apply_dpi
local wibox = require('wibox')
local gfilesystem = require('gears.filesystem')
local gcolor = require('gears.color')

-- Local libs
local powermenu = require('src.modules.powermenu.init')
local hover = require('src.tools.hover')

-- Icon directory path
local icondir = gfilesystem.get_configuration_dir() .. 'src/assets/icons/power/'

return setmetatable({}, { __call = function()

  local power_widget = wibox.widget {
    {
      {
        image = gcolor.recolor_image(icondir .. 'power.svg', Theme_config.power_button.fg),
        widget = wibox.widget.imagebox,
        valign = 'center',
        halign = 'center',
        resize = false,
      },
      left = dpi(8),
      right = dpi(8),
      widget = wibox.container.margin,
    },
    bg = Theme_config.power_button.bg,
    fg = Theme_config.power_button.fg,
    shape = Theme_config.power_button.shape,
    widget = wibox.container.background,
  }

  -- Signals
  hover.bg_hover { widget = power_widget }

  power_widget:buttons { gtable.join(
    abutton({}, 1, function()
      powermenu:toggle()
    end)
  ), }

  return power_widget
end, })
