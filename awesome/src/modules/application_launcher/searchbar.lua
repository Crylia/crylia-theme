-------------------------------------------------------
-- This is the seachbar for the application launcher --
-------------------------------------------------------

-- Awesome Libs
local awful = require("awful")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")

local icondir = awful.util.getdir("config") .. "src/assets/icons/application_launcher/searchbar/"

return function()

  local searchbar = wibox.widget {
    {
      {
        {
          { -- Search icon
            {
              resize = false,
              image = icondir .. "search.svg",
              widget = wibox.widget.imagebox
            },
            strategy = "exact",
            widget = wibox.container.constraint
          },
          {
            fg = Theme_config.application_launcher.searchbar.fg_hint,
            text = "Search",
            valign = "center",
            align = "center",
            widget = wibox.widget.textbox
          },
          widget = wibox.layout.fixed.horizontal
        },
        margins = dpi(5),
        widget = wibox.container.margin
      },
      bg = Theme_config.application_launcher.searchbar.bg,
      fg = Theme_config.application_launcher.searchbar.fg,
      border_color = Theme_config.application_launcher.searchbar.border_color,
      border_width = Theme_config.application_launcher.searchbar.border_width,
      widget = wibox.container.background
    },
    width = dpi(400),
    height = dpi(40),
    strategy = "exact",
    widget = wibox.container.constraint
  }

  return searchbar
end
