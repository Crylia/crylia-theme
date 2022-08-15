--------------------------------------
-- This is the application launcher --
--------------------------------------

-- Awesome Libs
local awful = require("awful")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")

local application_grid = require("src.modules.application_launcher.application")()
local searchbar = require("src.modules.application_launcher.searchbar")()

return function(s)

  local applicaton_launcher = wibox.widget {
    {
      {
        searchbar,
        {
          application_grid,
          spacing = dpi(10),
          layout = require("src.lib.overflow_widget.overflow").vertical,
          scrollbar_width = 0,
          step = dpi(50),
          id = "scroll_bar",
        },
        spacing = dpi(10),
        layout = wibox.layout.fixed.vertical
      },
      margins = dpi(20),
      widget = wibox.container.margin
    },
    height = s.geometry.height / 100 * 60,
    width = s.geometry.width / 100 * 60,
    strategy = "exact",
    widget = wibox.container.constraint
  }

  local application_container = awful.popup {
    widget = wibox.container.background,
    ontop = true,
    visible = false,
    stretch = false,
    screen = s,
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(12))
    end,
    placement = awful.placement.centered,
    bg = Theme_config.application_launcher.bg,
    border_color = Theme_config.application_launcher.border_color,
    border_width = Theme_config.application_launcher.border_width
  }

  application_container:setup {
    applicaton_launcher,
    layout = wibox.layout.fixed.vertical
  }

  awesome.connect_signal(
    "application_launcher::show",
    function()
      if mouse.screen == s then
        application_container.visible = not application_container.visible
        if application_container.visible == false then
          awesome.emit_signal("searchbar::stop")
        end
      end
      if application_container.visible then
        awesome.emit_signal("searchbar::start")
      end
    end
  )

end
