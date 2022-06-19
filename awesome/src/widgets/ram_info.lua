---------------------------------
-- This is the RAM Info widget --
---------------------------------

-- Awesome Libs
local awful = require("awful")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local watch = awful.widget.watch
local wibox = require("wibox")

local icon_dir = awful.util.getdir("config") .. "src/assets/icons/cpu/"

return function()
  local ram_widget = wibox.widget {
    {
      {
        {
          {
            {
              id = "icon",
              widget = wibox.widget.imagebox,
              valign = "center",
              halign = "center",
              image = gears.color.recolor_image(icon_dir .. "ram.svg", Theme_config.ram_info.fg),
              resize = false
            },
            id = "icon_layout",
            widget = wibox.container.place
          },
          top = dpi(2),
          widget = wibox.container.margin,
          id = "icon_margin"
        },
        spacing = dpi(10),
        {
          id = "label",
          align = "center",
          valign = "center",
          widget = wibox.widget.textbox
        },
        id = "ram_layout",
        layout = wibox.layout.fixed.horizontal
      },
      id = "container",
      left = dpi(8),
      right = dpi(8),
      widget = wibox.container.margin
    },
    bg = Theme_config.ram_info.bg,
    fg = Theme_config.ram_info.fg,
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(6))
    end,
    widget = wibox.container.background
  }

  Hover_signal(ram_widget, Theme_config.ram_info.bg, Theme_config.ram_info.fg)

  awesome.connect_signal(
    "update::ram",
    function(MemTotal, MemFree, MemAvailable)
      local ram_string = tostring(string.format("%.1f", ((MemTotal - MemAvailable) / 1024 / 1024)) ..
        "/" .. string.format("%.1f", (MemTotal / 1024 / 1024)) .. "GB"):gsub(",", ".")
      ram_widget.container.ram_layout.label.text = ram_string
    end
  )

  return ram_widget
end
