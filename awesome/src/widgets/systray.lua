--------------------------------
-- This is the power widget --
--------------------------------

-- Awesome Libs
local dpi = require('beautiful').xresources.apply_dpi
local wibox = require('wibox')

local capi = { awesome = awesome }

-- Systray theme variables
Theme.bg_systray = Theme_config.systray.bg
Theme.systray_icon_spacing = dpi(10)

return function()
  local systray = wibox.widget {
    {
      {
        wibox.widget.systray(),
        id = 'systray_margin',
        widget = wibox.container.margin,
      },
      strategy = 'exact',
      widget = wibox.container.constraint,
    },
    widget = wibox.container.background,
    shape = Theme_config.systray.shape,
    bg = Theme_config.systray.bg
  }

  local systray_margin = systray:get_children_by_id('systray_margin')[1]

  -- Wait for an systray update
  capi.awesome.connect_signal('systray::update', function()
    -- Get the number of entries in the systray
    local num_entries = capi.awesome.systray()

    -- If its 0 remove the margins to hide the widget
    if num_entries == 0 then
      systray_margin:set_margins(0)
    else
      systray_margin:set_margins(dpi(6))
    end
  end)

  -- Set the icon size
  systray_margin.widget:set_base_size(dpi(24))

  return systray
end
