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
        wibox.widget.inputtextbox,
        application_grid,
        layout = wibox.layout.fixed.vertical
      },
      margins = dpi(20),
      widget = wibox.container.margin
    },
    height = dpi(600),
    width = dpi(800),
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
    "application_laucher::show",
    function()
      application_container.visible = not application_container.visible
    end
  )

end
