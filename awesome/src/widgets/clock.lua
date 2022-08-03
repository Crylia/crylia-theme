------------------------------
-- This is the clock widget --
------------------------------

-- Awesome Libs
local awful = require("awful")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")

-- Icon directory path
local icondir = awful.util.getdir("config") .. "src/assets/icons/clock/"

-- Returns the clock widget
return function()

  local clock_widget = wibox.widget {
    {
      {
        {
          {
            {
              id = "icon",
              image = gears.color.recolor_image(icondir .. "clock.svg", Theme_config.clock.fg),
              widget = wibox.widget.imagebox,
              valign = "center",
              halign = "center",
              resize = false
            },
            id = "icon_layout",
            widget = wibox.container.place
          },
          id = "icon_margin",
          top = dpi(2),
          widget = wibox.container.margin
        },
        spacing = dpi(10),
        {
          id = "label",
          align = "center",
          valign = "center",
          format = "%H:%M",
          widget = wibox.widget.textclock
        },
        id = "clock_layout",
        layout = wibox.layout.fixed.horizontal
      },
      id = "container",
      left = dpi(8),
      right = dpi(8),
      widget = wibox.container.margin
    },
    bg = Theme_config.clock.bg,
    fg = Theme_config.clock.fg,
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(6))
    end,
    widget = wibox.container.background
  }

  Hover_signal(clock_widget)

  return clock_widget
end
