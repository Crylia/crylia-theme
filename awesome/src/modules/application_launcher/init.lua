--------------------------------------
-- This is the application launcher --
--------------------------------------

-- Awesome Libs
local awful = require("awful")
local color = require("src.theme.colors")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")

-- Icon directory path
local icondir = awful.util.getdir("config") .. "src/assets/icons/application_launcher/"

return function(s)

  local applicaton_launcher = wibox.widget {

  }

  local application_container = awful.popup {

  }

end
