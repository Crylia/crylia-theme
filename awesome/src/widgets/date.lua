-----------------------------
-- This is the date widget --
-----------------------------

-- Awesome Libs
local apopup = require('awful.popup')
local dpi = require('beautiful').xresources.apply_dpi
local wibox = require('wibox')
local abutton = require('awful.button')
local gfilesystem = require('gears.filesystem')
local gtable = require('gears.table')
local gcolor = require('gears.color')

-- Local libs
local cal = require('src.modules.calendar.init') {}
local hover = require('src.tools.hover')

-- Icon directory path
local icondir = gfilesystem.get_configuration_dir() .. 'src/assets/icons/date/'

local capi = { mouse = mouse }

-- Returns the date widget
return setmetatable({}, { __call = function(_, screen)
  local date_widget = wibox.widget {
    {
      {
        {
          {
            image = gcolor.recolor_image(icondir .. 'calendar.svg', Theme_config.date.fg),
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
          format = '%a, %b %d',
          widget = wibox.widget.textclock,
        },
        spacing = dpi(10),
        layout = wibox.layout.fixed.horizontal,
      },
      left = dpi(8),
      right = dpi(8),
      widget = wibox.container.margin,
    },
    bg = Theme_config.date.bg,
    fg = Theme_config.date.fg,
    shape = Theme_config.date.shape,
    widget = wibox.container.background,
  }

  local calendar_popup = apopup {
    widget = cal:get_widget(),
    screen = screen,
    ontop = true,
    visible = false,
  }

  hover.bg_hover { widget = date_widget }

  date_widget:buttons { gtable.join(
    abutton({}, 1, function()
      local geo = capi.mouse.coords()
      calendar_popup.y = dpi(65)
      if geo.x + (calendar_popup.width / 2) > capi.mouse.screen.geometry.width then
        calendar_popup.x = capi.mouse.screen.geometry.x + capi.mouse.screen.geometry.width - calendar_popup.width
      else
        calendar_popup.x = geo.x - (calendar_popup.width / 2)
      end
      calendar_popup.visible = not calendar_popup.visible
    end)
  ), }

  return date_widget
end, })
