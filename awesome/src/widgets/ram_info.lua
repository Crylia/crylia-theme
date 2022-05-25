---------------------------------
-- This is the RAM Info widget --
---------------------------------

-- Awesome Libs
local awful = require("awful")
local color = require("src.theme.colors")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local watch = awful.widget.watch
local wibox = require("wibox")
require("src.core.signals")

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
              image = gears.color.recolor_image(icon_dir .. "ram.svg", color["Grey900"]),
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
    bg = color["Red200"],
    fg = color["Grey900"],
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, 5)
    end,
    widget = wibox.container.background
  }

  Hover_signal(ram_widget, color["Red200"], color["Grey900"])

  watch(
    [[ bash -c "cat /proc/meminfo| grep Mem | awk '{print $2}'" ]],
    3,
    function(_, stdout)

      local MemTotal, MemFree, MemAvailable = stdout:match("(%d+)\n(%d+)\n(%d+)\n")

      ram_widget.container.ram_layout.label.text = tostring(string.format("%.1f", ((MemTotal - MemAvailable) / 1024 / 1024)) .. "/" .. string.format("%.1f", (MemTotal / 1024 / 1024)) .. "GB"):gsub(",", ".")
    end
  )

  return ram_widget
end
