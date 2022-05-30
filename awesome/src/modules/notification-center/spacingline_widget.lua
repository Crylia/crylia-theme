------------------------------------------------
-- This is the spacing widget under the clock --
------------------------------------------------

-- Awesome Libs
local color = require("src.theme.colors")
local dpi = require("beautiful").xresources.apply_dpi
local wibox = require("wibox")

return function()

  return wibox.widget {
    {
      forced_height = dpi(2),
      bg = color["Grey800"],
      widget = wibox.container.background
    },
    left = dpi(80),
    right = dpi(80),
    widget = wibox.container.margin
  }

end
