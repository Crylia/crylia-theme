local setmetatable = setmetatable

-- Awesome Libs
local abutton = require('awful.button')
local apopup = require('awful.popup')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi
local gcolor = require('gears.color')
local gfilesystem = require('gears.filesystem')
local gtable = require('gears.table')
local gtimer = require('gears.timer')
local wibox = require('wibox')

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
            image = gcolor.recolor_image(icondir .. 'calendar.svg', beautiful.colorscheme.bg),
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
    bg = beautiful.colorscheme.bg_teal,
    fg = beautiful.colorscheme.bg,
    shape = beautiful.shape[6],
    widget = wibox.container.background,
  }

  local calendar_popup = apopup {
    widget = cal:get_widget(),
    screen = screen,
    ontop = true,
    visible = true,
  }

  -- Delayed call so the popup can eval its dimensions
  gtimer.delayed_call(function()
    calendar_popup.visible = false
  end)

  hover.bg_hover { widget = date_widget }

  date_widget:buttons { gtable.join(
    abutton({}, 1, function()
      local geo = capi.mouse.coords()
      calendar_popup.y = dpi(70)
      if geo.x + (calendar_popup.width / 2) > capi.mouse.screen.geometry.width then
        calendar_popup.x = capi.mouse.screen.geometry.x + capi.mouse.screen.geometry.width - calendar_popup.width
      else
        calendar_popup.x = geo.x - (calendar_popup.width / 2)
      end
      calendar_popup.visible = not calendar_popup.visible
      collectgarbage('collect')
    end)
  ), }

  return date_widget
end, })
