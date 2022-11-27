--------------------------------------------------------------------------------------------------------------
-- This is the statusbar, every widget, module and so on is combined to all the stuff you see on the screen --
--------------------------------------------------------------------------------------------------------------
-- Awesome Libs
local awful = require("awful")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")

local capi = {
  awesome = awesome,
  client = client,
}

return function(s, widgets)

  local function prepare_widgets(w)
    local layout = {
      forced_height = dpi(50),
      layout = wibox.layout.fixed.horizontal
    }
    for i, widget in pairs(w) do
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
      elseif i == #w then
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

  local top_center = awful.popup {
    screen = s,
    widget = prepare_widgets(widgets),
    ontop = false,
    bg = Theme_config.center_bar.bg,
    visible = true,
    maximum_width = dpi(500),
    placement = function(c) awful.placement.top(c, { margins = dpi(10) }) end
  }

  top_center:struts {
    top = dpi(55)
  }

  capi.client.connect_signal("manage", function(c)
    if #s.selected_tag:clients() < 1 then
      top_center.visible = false
    else
      top_center.visible = true
    end
  end)

  capi.client.connect_signal("unmanage", function(c)
    if #s.selected_tag:clients() < 1 then
      top_center.visible = false
    else
      top_center.visible = true
    end
  end)

  capi.client.connect_signal("property::selected", function(c)
    if #s.selected_tag:clients() < 1 then
      top_center.visible = false
    else
      top_center.visible = true
    end
  end)

  capi.awesome.connect_signal("refresh", function(c)
    if #s.selected_tag:clients() < 1 then
      top_center.visible = false
    else
      top_center.visible = true
    end
  end)

end
