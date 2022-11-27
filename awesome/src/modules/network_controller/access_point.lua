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
local base = require("wibox.widget.base")
local NM = require("lgi").NM

local ap_form = require("src.modules.network_controller.ap_form")

local icondir = gfilesystem.get_configuration_dir() .. "src/assets/icons/network/"

local access_point = { mt = {} }

function access_point.new(args)
  args = args or {}

  if not args.NetworkManagerAccessPoint then return end

  local bg, fg, icon_color = Theme_config.network_manager.access_point.bg, Theme_config.network_manager.access_point.fg,
      Theme_config.network_manager.access_point.icon_color

  --[[ if get_active_access_point() == args.NetworkManagerAccessPoint.access_point_path then
    bg, fg, icon_color = Theme_config.network_manager.access_point.fg, Theme_config.network_manager.access_point.bg,
        Theme_config.network_manager.access_point.icon_color2
  end ]]

  local ret = base.make_widget_from_value(wibox.widget {
    {
      {
        {
          {
            {
              image = gcolor.recolor_image(
                icondir .. "wifi-strength-" .. math.floor(args.NetworkManagerAccessPoint.Strength / 25) + 1 .. ".svg",
                icon_color),
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
                text = NM.utils_ssid_to_utf8(args.NetworkManagerAccessPoint.Ssid) or
                    args.NetworkManagerAccessPoint.hw_address or "Unknown",
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
    widget = wibox.container.background
  })

  gtable.crush(ret, access_point, true)

  ret.NetworkManagerAccessPoint = args.NetworkManagerAccessPoint

  ret.ap_form = ap_form { screen = args.screen, ssid = NM.utils_ssid_to_utf8(ret.NetworkManagerAccessPoint.Ssid) }

  ret:buttons(
    gtable.join(
      awful.button(
        {},
        1,
        nil,
        function()
          ret.ap_form:popup_toggle()
        end
      )
    )
  )

  ret:get_children_by_id("con")[1].image = gcolor.recolor_image(
    icondir .. "link.svg", icon_color)

  Hover_signal(ret)

  return ret
end

function access_point.mt:__call(...)
  return access_point.new(...)
end

return setmetatable(access_point, access_point.mt)
