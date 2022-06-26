------------------------------------------------
-- This is the spacing widget under the clock --
------------------------------------------------

-- Awesome Libs
local dpi = require("beautiful").xresources.apply_dpi
local wibox = require("wibox")

return function()

  return wibox.widget {
    {
      forced_height = dpi(2),
      bg = Theme_config.notification_center.spacing_line.color,
      widget = wibox.container.background
    },
    left = dpi(80),
    right = dpi(80),
    widget = wibox.container.margin
  }

end
