local setmetatable = setmetatable

-- Awesome Libs
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi
local gcolor = require('gears.color')
local gfilesystem = require('gears.filesystem')
local wibox = require('wibox')

-- Local libs
local hover = require('src.tools.hover')

-- Icon directory path
local icondir = gfilesystem.get_configuration_dir() .. 'src/assets/icons/clock/'

-- Returns the clock widget
local instance = nil
if not instance then
  instance = setmetatable({}, { __call = function()
    local clock_widget = wibox.widget {
      {
        {
          {
            {
              image = gcolor.recolor_image(icondir .. 'clock.svg', beautiful.colorscheme.bg),
              widget = wibox.widget.imagebox,
              valign = 'center',
              halign = 'center',
              resize = true,
            },
            widget = wibox.container.constraint,
            width = dpi(25),
            height = dpi(25),
            strategy = 'exact',
          },
          {
            halign = 'center',
            valign = 'center',
            format = '%H:%M',
            widget = wibox.widget.textclock,
          },
          spacing = dpi(10),
          layout = wibox.layout.fixed.horizontal,
        },
        left = dpi(8),
        right = dpi(8),
        widget = wibox.container.margin,
      },
      bg = beautiful.colorscheme.bg_yellow,
      fg = beautiful.colorscheme.bg,
      shape = beautiful.shape[6],
      widget = wibox.container.background,
    }

    hover.bg_hover { widget = clock_widget }

    return clock_widget
  end, })
end
return instance
