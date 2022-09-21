-----------------------------
-- This is the date widget --
-----------------------------

-- Awesome Libs
local awful = require("awful")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")
require("src.core.signals")

local capi = {
  awesome = awesome,
}

-- Icon directory path
local icondir = awful.util.getdir("config") .. "src/assets/icons/date/"

-- Returns the date widget
return function()

  local date_widget = wibox.widget {
    {
      {
        {
          {
            {
              id = "icon",
              image = gears.color.recolor_image(icondir .. "calendar.svg", Theme_config.date.fg),
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
          format = "%a, %b %d",
          widget = wibox.widget.textclock
        },
        id = "date_layout",
        layout = wibox.layout.fixed.horizontal
      },
      id = "container",
      left = dpi(8),
      right = dpi(8),
      widget = wibox.container.margin
    },
    bg = Theme_config.date.bg,
    fg = Theme_config.date.fg,
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(6))
    end,
    widget = wibox.container.background
  }

  -- Signals
  Hover_signal(date_widget)

  date_widget:buttons {
    gears.table.join(
      awful.button({}, 1, function()
        capi.awesome.emit_signal("calendar::toggle", date_widget)
      end)
    )
  }

  return date_widget
end
