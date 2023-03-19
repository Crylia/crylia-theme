---------------------------------
-- This is the RAM Info widget --
---------------------------------

-- Awesome Libs
local dpi = require('beautiful').xresources.apply_dpi
local gcolor = require('gears.color')
local gfilesystem = require('gears.filesystem')
local gshape = require('gears.shape')
local wibox = require('wibox')

local ram_helper = require('src.tools.helpers.ram')
local hover = require('src.tools.hover')

local icon_dir = gfilesystem.get_configuration_dir() .. 'src/assets/icons/cpu/'

return function()
  local ram_widget = wibox.widget {
    {
      {
        {
          {
            {
              id = 'icon',
              widget = wibox.widget.imagebox,
              valign = 'center',
              halign = 'center',
              image = gcolor.recolor_image(icon_dir .. 'ram.svg', Theme_config.ram_info.fg),
              resize = false,
            },
            id = 'icon_layout',
            widget = wibox.container.place,
          },
          top = dpi(2),
          widget = wibox.container.margin,
          id = 'icon_margin',
        },
        spacing = dpi(10),
        {
          id = 'label',
          align = 'center',
          valign = 'center',
          widget = wibox.widget.textbox,
        },
        id = 'ram_layout',
        layout = wibox.layout.fixed.horizontal,
      },
      id = 'container',
      left = dpi(8),
      right = dpi(8),
      widget = wibox.container.margin,
    },
    bg = Theme_config.ram_info.bg,
    fg = Theme_config.ram_info.fg,
    shape = function(cr, width, height)
      gshape.rounded_rect(cr, width, height, dpi(6))
    end,
    widget = wibox.container.background,
  }

  hover.bg_hover { widget = ram_widget }

  ram_helper:connect_signal('update::ram_widget', function(_, MemTotal, MemFree, MemAvailable)
    local ram_string = tostring(string.format('%.1f', ((MemTotal - MemAvailable) / 1024 / 1024)) ..
      '/' .. string.format('%.1f', (MemTotal / 1024 / 1024)) .. 'GB'):gsub(',', '.')
    ram_widget.container.ram_layout.label.text = ram_string
  end)

  return ram_widget
end
