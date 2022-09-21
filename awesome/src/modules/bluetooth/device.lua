--------------------------------------
-- This is the bluetooth controller --
--------------------------------------

-- Awesome Libs
local awful = require("awful")
local dpi = require("beautiful").xresources.apply_dpi
local gobject = require("gears").object
local gtable = require("gears").table
local gcolor = require("gears").color
local gshape = require("gears").shape
local wibox = require("wibox")

local capi = {
  awesome = awesome,
}

local icondir = awful.util.getdir("config") .. "src/assets/icons/bluetooth/"

local device = { mt = {} }

function device:connect()
  self.device:Connect()
  self.widget:get_children_by_id("con")[1].image = gcolor.recolor_image(icondir .. "link.svg",
    Theme_config.bluetooth_controller.icon_color_dark)
  capi.awesome.emit_signal("bluetooth::disconnect", device)
end

function device:disconnect()
  self.device:Disconnect()
  self.widget:get_children_by_id("con")[1].image = gcolor.recolor_image(icondir .. "link-off.svg",
    Theme_config.bluetooth_controller.icon_color_dark)
  capi.awesome.emit_signal("bluetooth::connect", device)
end

function device.new(args)
  args = args or {}
  args.device = args.device or {}
  args.battery = args.battery or {}

  local ret = gobject { enable_properties = true, enable_auto_signals = true }
  gtable.crush(ret, device, true)

  if args.device then
    ret.device = args.device
  end
  if args.battery then
    ret.battery = args.battery
  end

  local icon = device.Icon or "bluetooth-on"
  local device_widget = wibox.widget {
    {
      {
        {
          {
            {
              image = gcolor.recolor_image(
                icondir .. icon .. ".svg", Theme_config.bluetooth_controller.icon_color),
              id = "icon",
              resize = false,
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
                text = ret.device.Alias or ret.device.Name,
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
            id = "backgr",
            shape = function(cr, width, height)
              gshape.rounded_rect(cr, width, height, dpi(4))
            end,
            bg = Theme_config.bluetooth_controller.con_button_color,
            widget = wibox.container.background
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
    bg = Theme_config.bluetooth_controller.device_bg,
    fg = Theme_config.bluetooth_controller.device_fg,
    border_color = Theme_config.bluetooth_controller.device_border_color,
    border_width = Theme_config.bluetooth_controller.device_border_width,
    id = "background",
    shape = function(cr, width, height)
      gshape.rounded_rect(cr, width, height, dpi(4))
    end,
    device = ret.device,
    widget = wibox.container.background
  }

  if ret.device.Connected then
    device_widget:get_children_by_id("con")[1].image = gcolor.recolor_image(icondir .. "link.svg",
      Theme_config.bluetooth_controller.icon_color_dark)
  else
    device_widget:get_children_by_id("con")[1].image = gcolor.recolor_image(icondir .. "link-off.svg",
      Theme_config.bluetooth_controller.icon_color_dark)
  end

  device_widget:buttons(
    gtable.join(
      awful.button({}, 1, function()
        if ret.device.Connected then
          ret:disconnect()
        else
          ret:connect()
        end
      end)
    )
  )

  Hover_signal(device_widget)

  ret.widget = device_widget

  return ret
end

function device.mt.__call(...)
  return device.new(...)
end

return setmetatable(device, device.mt)
