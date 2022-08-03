----------------------------------
-- This is the layoutbox widget --
----------------------------------

-- Awesome Libs
local awful = require("awful")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")

--#region Layout icons
local layout_path = Theme_path .. "../assets/layout/"

Theme.layout_floating = layout_path .. "floating.svg"
Theme.layout_tile = layout_path .. "tile.svg"
Theme.layout_dwindle = layout_path .. "dwindle.svg"
Theme.layout_fairh = layout_path .. "fairh.svg"
Theme.layout_fairv = layout_path .. "fairv.svg"
Theme.layout_fullscreen = layout_path .. "fullscreen.svg"
Theme.layout_max = layout_path .. "max.svg"
Theme.layout_cornerne = layout_path .. "cornerne.svg"
Theme.layout_cornernw = layout_path .. "cornernw.svg"
Theme.layout_cornerse = layout_path .. "cornerse.svg"
Theme.layout_cornersw = layout_path .. "cornersw.svg"
--#endregion

-- Returns the layoutbox widget
return function()
  local layout = wibox.widget {
    {
      {
        awful.widget.layoutbox(),
        id = "icon_layout",
        widget = wibox.container.place
      },
      id = "icon_margin",
      left = dpi(5),
      right = dpi(5),
      forced_width = dpi(40),
      widget = wibox.container.margin
    },
    bg = Theme_config.layout_list.bg,
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(6))
    end,
    widget = wibox.container.background
  }

  -- Signals
  Hover_signal(layout)

  layout:connect_signal(
    "button::press",
    function()
      awful.layout.inc(-1)
    end
  )

  return layout
end
