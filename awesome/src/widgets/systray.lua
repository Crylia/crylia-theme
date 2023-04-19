--------------------------------
-- This is the power widget --
--------------------------------

-- Awesome Libs
local beautiful = require('beautiful')
local dpi = require('beautiful').xresources.apply_dpi
local wibox = require('wibox')
local abutton = require('awful.button')
local gfilesystem = require('gears.filesystem')

local icondir = gfilesystem.get_configuration_dir() .. 'src/assets/icons/systray/'

local instance = nil
if not instance then
  instance = setmetatable({}, {
    __call = function()
      local systray = wibox.widget {
        {
          {
            {
              widget = wibox.widget.imagebox,
              resize = true,
              halign = 'center',
              valign = 'center',
              image = icondir .. 'chevron-right.svg',
            },
            height = dpi(28),
            width = dpi(28),
            widget = wibox.container.constraint,
            strategy = 'exact',
          },
          {
            {
              {
                wibox.widget.systray(),
                id = 'systray_margin',
                margins = dpi(6),
                widget = wibox.container.margin,
              },
              strategy = 'exact',
              widget = wibox.container.constraint,
            },
            widget = wibox.container.place,
          },
          id = 'lay',
          layout = wibox.layout.fixed.horizontal,
        },
        widget = wibox.container.background,
        shape = beautiful.shape[6],
        bg = beautiful.colorscheme.bg1,
      }

      systray:buttons {
        abutton({}, 1, function()
          local c = systray:get_children_by_id('lay')[1].children[2]
          c.visible = not c.visible

          if not c.visible then
            systray:get_children_by_id('lay')[1].children[1].children[1].image = icondir .. 'chevron-left.svg'
          else
            systray:get_children_by_id('lay')[1].children[1].children[1].image = icondir .. 'chevron-right.svg'
          end
        end),
      }

      -- Set the icon size
      systray:get_children_by_id('systray_margin')[1].widget:set_base_size(dpi(24))

      return systray
    end,
  })
end
return instance
