----------------------------------
-- This is the layoutbox widget --
----------------------------------

-- Awesome Libs
local abutton = require("awful.button")
local alayout = require("awful.layout")
local awidget = require("awful.widget")
local dpi = require("beautiful").xresources.apply_dpi
local gtable = require("gears.table")
local wibox = require("wibox")

--#region Layout icons
local layout_path = Theme_path .. "../assets/layout/"

Theme.layout_cornerne   = layout_path .. "cornerne.png"
Theme.layout_cornernw   = layout_path .. "cornernw.png"
Theme.layout_cornerse   = layout_path .. "cornerse.png"
Theme.layout_cornersw   = layout_path .. "cornersw.png"
Theme.layout_dwindle    = layout_path .. "dwindle.png"
Theme.layout_fairh      = layout_path .. "fairh.png"
Theme.layout_fairv      = layout_path .. "fairv.png"
Theme.layout_floating   = layout_path .. "floating.png"
Theme.layout_fullscreen = layout_path .. "fullscreen.png"
Theme.layout_magnifier  = layout_path .. "magnifier.png"
Theme.layout_max        = layout_path .. "max.png"
Theme.layout_spiral     = layout_path .. "spiral.png"
Theme.layout_tile       = layout_path .. "tile.png"
Theme.layout_tilebottom = layout_path .. "tilebottom.png"
Theme.layout_tileleft   = layout_path .. "tileleft.png"
Theme.layout_tiletop    = layout_path .. "tiletop.png"
--#endregion

-- Returns the layoutbox widget
return function()
  local layout = wibox.widget {
    {
      {
        {
          awidget.layoutbox(),
          widget = wibox.container.place,
          halign = "center",
          valign = "center"
        },
        left = dpi(5),
        right = dpi(5),
        widget = wibox.container.margin,
      },
      widget = wibox.container.constraint,
      width = dpi(40)
    },
    bg = Theme_config.layout_list.bg,
    shape = Theme_config.layout_list.shape,
    widget = wibox.container.background
  }

  Hover_signal(layout)

  layout:buttons(gtable.join(
    abutton({}, 1, function()
      alayout.inc(1)
    end),
    abutton({}, 3, function()
      alayout.inc(-1)
    end),
    abutton({}, 4, function()
      alayout.inc(1)
    end),
    abutton({}, 5, function()
      alayout.inc(-1)
    end)
  ))

  return layout
end
