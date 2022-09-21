--------------------------------
-- This is the power widget --
--------------------------------

-- Awesome Libs
local awful = require("awful")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")

local capi = {
  awesome = awesome,
}

-- Icon directory path
local icondir = awful.util.getdir("config") .. "src/assets/icons/power/"

return function()

  local power_widget = wibox.widget {
    {
      {
        {
          {
            {
              id = "icon",
              image = gears.color.recolor_image(icondir .. "power.svg", Theme_config.power_button.fg),
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
        id = "power_layout",
        layout = wibox.layout.fixed.horizontal
      },
      id = "container",
      left = dpi(8),
      right = dpi(8),
      widget = wibox.container.margin
    },
    bg = Theme_config.power_button.bg,
    fg = Theme_config.power_button.fg,
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(6))
    end,
    widget = wibox.container.background
  }

  -- Signals
  Hover_signal(power_widget)

  power_widget:connect_signal(
    "button::release",
    function()
      capi.awesome.emit_signal("module::powermenu:show")
    end
  )

  return power_widget
end
