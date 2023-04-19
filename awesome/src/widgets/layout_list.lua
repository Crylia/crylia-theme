local setmetatable = setmetatable

-- Awesome Libs
local abutton = require('awful.button')
local alayout = require('awful.layout')
local awidget = require('awful.widget')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi
local gtable = require('gears.table')
local wibox = require('wibox')

-- Local libs
local hover = require('src.tools.hover')

return setmetatable({}, {
  __call = function(_, screen)
    local layout = wibox.widget {
      {
        {
          {
            awidget.layoutbox(),
            widget = wibox.container.place,
          },
          left = dpi(5),
          right = dpi(5),
          widget = wibox.container.margin,
        },
        widget = wibox.container.constraint,
        strategy = 'exact',
        width = dpi(40),
      },
      bg = beautiful.colorscheme.bg_blue,
      shape = beautiful.shape[6],
      widget = wibox.container.background,
    }

    hover.bg_hover { widget = layout }

    layout:buttons(gtable.join(
      abutton({}, 1, function()
        alayout.inc(1, screen)
      end),
      abutton({}, 3, function()
        alayout.inc(-1, screen)
      end),
      abutton({}, 4, function()
        alayout.inc(1, screen)
      end),
      abutton({}, 5, function()
        alayout.inc(-1, screen)
      end)
    ))

    return layout
  end,
})
