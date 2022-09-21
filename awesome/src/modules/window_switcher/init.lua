---------------------------------
-- This is the window_switcher --
---------------------------------

-- Awesome Libs
local awful = require("awful")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")

local capi = {
  awesome = awesome,
  mouse = mouse,
}

local window_elements = require("src.modules.window_switcher.window_elements")()

return function(s)

  local window_switcher_list = wibox.widget {
    window_elements,
    margins = dpi(20),
    widget = wibox.container.margin
  }

  local window_switcher_container = awful.popup {
    widget = wibox.container.background,
    ontop = true,
    visible = false,
    stretch = false,
    screen = s,
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(12))
    end,
    placement = awful.placement.centered,
    bg = Theme_config.window_switcher.bg,
    border_color = Theme_config.window_switcher.border_color,
    border_width = Theme_config.window_switcher.border_width
  }

  window_switcher_container:setup {
    window_switcher_list,
    layout = wibox.layout.fixed.vertical
  }

  capi.awesome.connect_signal(
    "toggle_window_switcher",
    function()
      if capi.mouse.screen == s then
        window_switcher_container.visible = not window_switcher_container.visible
      end
    end
  )
end
