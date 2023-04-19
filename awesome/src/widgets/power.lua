local setmetatable = setmetatable

-- Awesome Libs
local abutton = require('awful.button')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi
local gcolor = require('gears.color')
local gfilesystem = require('gears.filesystem')
local gtable = require('gears.table')
local wibox = require('wibox')

-- Local libs
local hover = require('src.tools.hover')
local powermenu = require('src.modules.powermenu')

-- Icon directory path
local icondir = gfilesystem.get_configuration_dir() .. 'src/assets/icons/power/'

local instance = nil
if not instance then
  instance = setmetatable({}, { __call = function()

    local power_widget = wibox.widget {
      {
        {
          image = gcolor.recolor_image(icondir .. 'power.svg', beautiful.colorscheme.bg),
          widget = wibox.widget.imagebox,
          valign = 'center',
          halign = 'center',
          resize = false,
        },
        left = dpi(8),
        right = dpi(8),
        widget = wibox.container.margin,
      },
      bg = beautiful.colorscheme.bg_red,
      fg = beautiful.colorscheme.bg,
      shape = beautiful.shape[6],
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
end
return instance
