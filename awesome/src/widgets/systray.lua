--------------------------------
-- This is the power widget --
--------------------------------

-- Awesome Libs
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")

Theme.bg_systray = Theme_config.systray.bg
Theme.systray_icon_spacing = dpi(10)

return function(s)
  local systray = wibox.widget {
    {
      {
        wibox.widget.systray(),
        widget = wibox.container.margin,
        id = 'st'
      },
      strategy = "exact",
      widget = wibox.container.constraint,
      id = "container"
    },
    widget = wibox.container.background,
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(6))
    end,
    bg = Theme_config.systray.bg
  }
  -- Signals
  Hover_signal(systray, Theme_config.systray.bg)

  awesome.connect_signal("systray::update", function()
    local num_entries = awesome.systray()

    if num_entries == 0 then
      systray.container.st:set_margins(0)
    else
      systray.container.st:set_margins(dpi(6))
    end
  end)

  systray.container.st.widget:set_base_size(dpi(24))

  return systray
end
