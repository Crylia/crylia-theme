------------------------------------
-- This is the network controller --
------------------------------------

-- Awesome Libs
local awful = require("awful")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")

local rubato = require("src.lib.rubato")

local icondir = awful.util.getdir("config") .. "src/assets/icons/network/"

return function(s)

  local function get_connected_network()

  end

  local network_controller = wibox.widget {
    {
      {
        { -- Connected
          { --Connected header
            {
              {
                text = "Connected to",
                widget = wibox.widget.textbox
              },
              widget = wibox.container.background
            },
            widget = wibox.container.margin
          },
          { -- Connected network
            {
              get_connected_network(),
              widget = wibox.container.background
            },
            widget = wibox.container.margin
          },
          layout = wibox.layout.fixed.vertical
        },
        { -- Discovered networks
          { --Discovered header
            {
              {
                text = "Available networks",
                widget = wibox.widget.textbox
              },
              widget = wibox.container.background
            },
            widget = wibox.container.margin
          },
          { -- Discovered networks list

          },
          spacing = dpi(10),
          layout = wibox.layout.fixed.vertical
        },
        { -- Airplanemode/Refresh buttons
          { -- Airplane mode toggle
            {
              {
                {
                  -- TODO: Replace with image
                  text = "Airplane mode",
                  widget = wibox.widgeet.textbox
                },
                widget = wibox.container.margin
              },
              shape = function(cr, width, height)
                gears.shape.rounded_rect(cr, width, height, dpi(5))
              end,
              widget = wibox.container.background
            },
            widget = wibox.container.margin
          },
          { -- Refresh button
            {
              {
                {
                  -- TODO: Replace with image
                  text = "Refresh",
                  widget = wibox.widgeet.textbox
                },
                widget = wibox.container.margin
              },
              shape = function(cr, width, height)
                gears.shape.rounded_rect(cr, width, height, dpi(5))
              end,
              widget = wibox.container.background
            },
            widget = wibox.container.margin
          },
          layout = wibox.layout.align.horizontal
        },
        layout = wibox.layout.fixed.vertical
      },
      margins = dpi(10),
      widget = wibox.container.margin
    },
    width = dpi(400),
    strategy = "exact",
    widget = wibox.container.constraint
  }

  local network_controller_container = awful.popup {
    widget = wibox.container.background,
    bg = Theme_config.network_controller.bg,
    border_color = Theme_config.network_controller.border_color,
    border_width = Theme_config.network_controller.border_width,
    screen = s,
    stretch = false,
    visible = false,
    ontop = true,
    placement = function(c) awful.placement.align(c,
        { position = "top_right", margins = { right = dpi(350), top = dpi(60) } })
    end,
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(12))
    end
  }

  network_controller_container:setup {
    network_controller,
    layout = wibox.layout.fixed.vertical
  }

end
