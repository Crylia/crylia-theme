local setmetatable = setmetatable
local string = string
local tostring = tostring

-- Awesome Libs
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi
local gcolor = require('gears.color')
local gfilesystem = require('gears.filesystem')
local wibox = require('wibox')

-- Local Libs
local hover = require('src.tools.hover')
local ram_helper = require('src.tools.helpers.ram')

local icon_dir = gfilesystem.get_configuration_dir() .. 'src/assets/icons/cpu/'

local instance = nil
if not instance then
  instance = setmetatable({}, {
    __call = function()
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
                  image = gcolor.recolor_image(icon_dir .. 'ram.svg', beautiful.colorscheme.fg),
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
        bg = beautiful.colorscheme.bg_red,
        fg = beautiful.colorscheme.bg,
        shape = beautiful.shape[6],
        widget = wibox.container.background,
      }

      hover.bg_hover { widget = ram_widget }

      ram_helper:connect_signal('update::ram_widget', function(_, MemTotal, _, MemAvailable)
        local ram_string = tostring(string.format('%.1f', ((MemTotal - MemAvailable) / 1024 / 1024)) ..
          '/' .. string.format('%.1f', (MemTotal / 1024 / 1024)) .. 'GB'):gsub(',', '.')
        ram_widget.container.ram_layout.label.text = ram_string
      end)

      return ram_widget
    end,
  })
end
return instance
