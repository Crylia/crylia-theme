--------------------------------------------------------------------------------------------------------------
-- This is the statusbar, every widget, module and so on is combined to all the stuff you see on the screen --
--------------------------------------------------------------------------------------------------------------
-- Awesome Libs
local awful = require("awful")
local color = require("src.theme.colors")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")

return function(s, widgets)

  local top_center = awful.popup {
    screen = s,
    widget = wibox.container.background,
    ontop = false,
    bg = color["Grey900"],
    visible = true,
    maximum_width = dpi(500),
    placement = function(c) awful.placement.top(c, { margins = dpi(10) }) end,
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, 5)
    end
  }

  top_center:struts {
    top = 55
  }

  local function prepare_widgets(widgets)
    local layout = {
      forced_height = 45,
      layout = wibox.layout.fixed.horizontal
    }
    for i, widget in pairs(widgets) do
      if i == 1 then
        table.insert(layout,
          {
          widget,
          left = dpi(6),
          right = dpi(6),
          top = dpi(6),
          bottom = dpi(6),
          widget = wibox.container.margin
        })
      elseif i == #widgets then
        table.insert(layout,
          {
          widget,
          left = dpi(3),
          right = dpi(6),
          top = dpi(6),
          bottom = dpi(6),
          widget = wibox.container.margin
        })
      else
        table.insert(layout,
          {
          widget,
          left = dpi(3),
          right = dpi(3),
          top = dpi(6),
          bottom = dpi(6),
          widget = wibox.container.margin
        })
      end
    end
    return layout
  end

  top_center:setup {
    nil,
    prepare_widgets(widgets),
    nil,
    layout = wibox.layout.fixed.horizontal
  }

  client.connect_signal(
    "manage",
    function(c)
    if #s.selected_tag:clients() < 1 then
      top_center.visible = false
    else
      top_center.visible = true
    end
  end
  )

  client.connect_signal(
    "unmanage",
    function(c)
    if #s.selected_tag:clients() < 1 then
      top_center.visible = false
    else
      top_center.visible = true
    end
  end
  )

  client.connect_signal(
    "tag::switched",
    function(c)
    if #s.selected_tag:clients() < 1 then
      top_center.visible = false
    else
      top_center.visible = true
    end
  end
  )

  awesome.connect_signal(
    "refresh",
    function(c)
    if #s.selected_tag:clients() < 1 then
      top_center.visible = false
    else
      top_center.visible = true
    end
  end
  )

end
