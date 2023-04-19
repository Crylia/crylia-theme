local tinsert = table.insert
local pairs = pairs

-- Awesome Libs
local aplacement = require('awful.placement')
local apopup = require('awful.popup')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi
local wibox = require('wibox')

local function prepare_widgets(w)
  local layout = {
    layout = wibox.layout.fixed.horizontal,
  }

  for i, widget in pairs(w) do
    if i == 1 then
      tinsert(layout,
        {
          widget,
          left = dpi(6),
          right = dpi(3),
          top = dpi(6),
          bottom = dpi(6),
          widget = wibox.container.margin,
        })
    elseif i == #w then
      tinsert(layout,
        {
          widget,
          left = dpi(3),
          right = dpi(6),
          top = dpi(6),
          bottom = dpi(6),
          widget = wibox.container.margin,
        })
    else
      tinsert(layout,
        {
          widget,
          left = dpi(3),
          right = dpi(3),
          top = dpi(6),
          bottom = dpi(6),
          widget = wibox.container.margin,
        })
    end
  end
  return layout
end

return setmetatable({}, {
  __call = function(_, s, w)
    local top_right = apopup {
      widget = {
        prepare_widgets(w),
        widget = wibox.container.constraint,
        strategy = 'exact',
        height = dpi(50),
      },
      ontop = false,
      bg = beautiful.colorscheme.bg,
      visible = true,
      screen = s,
      placement = function(c) aplacement.top_right(c, { margins = dpi(10) }) end,
    }

    top_right:struts {
      top = dpi(60),
    }
  end,
})
