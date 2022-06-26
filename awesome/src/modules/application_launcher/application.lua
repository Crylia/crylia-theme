--------------------------------------
-- This is the application launcher --
--------------------------------------

-- Awesome Libs
local awful = require("awful")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")

return function()

  local application_list = wibox.widget {
    homogenous = true,
    expand = false,
    spacing = dpi(10),
    layout = wibox.container.grid
  }

  return application_list
end
