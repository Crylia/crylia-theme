------------------------------------
-- This is the network controller --
------------------------------------

-- Awesome Libs
local awful = require("awful")
local dpi = require("beautiful").xresources.apply_dpi
local gtable = require("gears").table
local gfilesystem = require("gears").filesystem
local gobject = require("gears").object
local gcolor = require("gears").color
local wibox = require("wibox")

local ap_form = require("src.modules.network_controller.ap_form")

local icondir = gfilesystem.get_configuration_dir() .. "src/assets/icons/network/"

local access_point = { mt = {} }

access_point.connected = false

function access_point.new(args)
  args = args or {}

  if not args.access_point then return end

  local ret = gobject { enable_properties = true, enable_auto_signals = true }
  gtable.crush(ret, access_point, true)

  local strength = args.access_point.strength or 0

  --normalize strength between 1 and 4
  strength = math.floor(strength / 25) + 1

  local icon = "wifi-strength-" .. strength .. ".svg"

  local bg, fg, icon_color = Theme_config.network_manager.access_point.bg, Theme_config.network_manager.access_point.fg,
      Theme_config.network_manager.access_point.icon_color

  if args.active == args.access_point.access_point_path then
    bg, fg, icon_color = Theme_config.network_manager.access_point.fg, Theme_config.network_manager.access_point.bg,
        Theme_config.network_manager.access_point.icon_color2
  end

  local ap_widget = wibox.widget {
    {
      {
        {
          {
            {
              image = gcolor.recolor_image(
                icondir .. icon, icon_color),
              id = "icon",
              resize = true,
              valign = "center",
              halign = "center",
              forced_width = dpi(24),
              forced_height = dpi(24),
              widget = wibox.widget.imagebox
            },
            id = "icon_container",
            strategy = "max",
            width = dpi(24),
            height = dpi(24),
            widget = wibox.container.constraint
          },
          {
            {
              {
                text = args.access_point.ssid or args.access_point.hw_address or "Unknown",
                id = "alias",
                widget = wibox.widget.textbox
              },
              {
                text = "Connecting...",
                id = "connecting",
                visible = false,
                font = User_config.font.specify .. ", regular 10",
                widget = wibox.widget.textbox
              },
              id = "alias_container",
              layout = wibox.layout.fixed.horizontal
            },
            width = dpi(260),
            height = dpi(40),
            strategy = "max",
            widget = wibox.container.constraint
          },
          spacing = dpi(10),
          layout = wibox.layout.fixed.horizontal
        },
        { -- Spacing
          forced_width = dpi(10),
          widget = wibox.container.background
        },
        {
          {
            {
              {
                id = "con",
                resize = false,
                valign = "center",
                halign = "center",
                forced_width = dpi(24),
                forced_height = dpi(24),
                widget = wibox.widget.imagebox
              },
              id = "place",
              strategy = "max",
              width = dpi(24),
              height = dpi(24),
              widget = wibox.container.constraint
            },
            id = "margin",
            margins = dpi(2),
            widget = wibox.container.margin
          },
          id = "margin0",
          margin = dpi(5),
          widget = wibox.container.margin
        },
        id = "device_layout",
        layout = wibox.layout.align.horizontal
      },
      id = "device_margin",
      margins = dpi(5),
      widget = wibox.container.margin
    },
    bg = bg,
    fg = fg,
    border_color = Theme_config.network_manager.access_point.border_color,
    border_width = Theme_config.network_manager.access_point.border_width,
    id = "background",
    shape = Theme_config.network_manager.access_point.device_shape,
    device = ret.access_point,
    widget = wibox.container.background
  }

  ap_form { screen = args.screen, SSID = args.access_point.ssid }

  ap_widget:buttons(
    gtable.join(
      awful.button(
        {},
        1,
        nil,
        function()
          ap_form:popup_toggle()
        end
      )
    )
  )

  ap_widget:get_children_by_id("con")[1].image = gcolor.recolor_image(
    icondir .. "link.svg", icon_color)

  Hover_signal(ap_widget)

  ret.widget = ap_widget

  return ret
end

function access_point.mt:__call(...)
  return access_point.new(...)
end

return setmetatable(access_point, access_point.mt)
