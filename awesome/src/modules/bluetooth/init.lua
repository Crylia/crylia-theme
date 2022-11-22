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
local gfilesystem = require("gears").filesystem
local wibox = require("wibox")

local bt_device = require("src.modules.bluetooth.device")

local rubato = require("src.lib.rubato")

local icondir = gfilesystem.get_configuration_dir() .. "src/assets/icons/bluetooth/"

local capi = {
  awesome = awesome,
  mouse = mouse,
  mousegrabber = mousegrabber,
}

local bluetooth = { mt = {} }

bluetooth.devices = {
  paired = { layout = wibox.layout.fixed.vertical },
  discovered = { layout = wibox.layout.fixed.vertical }
}

function bluetooth:get_devices()
  return self.devices
end

local function add_device(self, device, battery)
  --Check if the device is already in the list
  for _, status in pairs(self.devices) do
    for _, dev in ipairs(status) do
      if dev.device.Address == device.Address then
        return
      end
    end
  end
  if device.Paired then
    table.insert(self.devices.paired, bt_device.new { device = device, battery = battery }.widget)
  else
    table.insert(self.devices.discovered, bt_device.new { device = device, battery = battery }.widget)
  end
end

local function remove_device(self, device)
  for i, dev in pairs(self.devices) do
    if dev.Address == device.Address then
      table.remove(self.devices, i)
    end
  end
end

function bluetooth.new(args)
  args = args or {}

  local ret = gobject { enable_properties = true, enable_auto_signals = true }
  gtable.crush(ret, bluetooth, true)

  local bluetooth_container = wibox.widget {
    {
      {
        {
          {
            {
              {
                {
                  {
                    resize = false,
                    image = gcolor.recolor_image(icondir .. "menu-down.svg",
                      Theme_config.bluetooth_controller.connected_icon_color),
                    widget = wibox.widget.imagebox,
                    valign = "center",
                    halign = "center",
                    id = "icon"
                  },
                  id = "center",
                  halign = "center",
                  valign = "center",
                  widget = wibox.container.place,
                },
                {
                  {
                    text = "Paired Devices",
                    widget = wibox.widget.textbox,
                    id = "device_name"
                  },
                  margins = dpi(5),
                  widget = wibox.container.margin
                },
                id = "connected",
                layout = wibox.layout.fixed.horizontal
              },
              id = "connected_bg",
              bg = Theme_config.bluetooth_controller.connected_bg,
              fg = Theme_config.bluetooth_controller.connected_fg,
              shape = function(cr, width, height)
                gshape.rounded_rect(cr, width, height, dpi(4))
              end,
              widget = wibox.container.background
            },
            id = "connected_margin",
            widget = wibox.container.margin
          },
          {
            id = "connected_list",
            {
              {
                step = dpi(50),
                spacing = dpi(10),
                layout = require("src.lib.overflow_widget.overflow").vertical,
                scrollbar_width = 0,
                id = "connected_device_list"
              },
              id = "margin",
              margins = dpi(10),
              widget = wibox.container.margin
            },
            border_color = Theme_config.bluetooth_controller.con_device_border_color,
            border_width = Theme_config.bluetooth_controller.con_device_border_width,
            shape = function(cr, width, height)
              gshape.partially_rounded_rect(cr, width, height, false, false, true, true, dpi(4))
            end,
            widget = wibox.container.background,
            forced_height = 0
          },
          {
            {
              {
                {
                  {
                    resize = false,
                    image = gcolor.recolor_image(icondir .. "menu-down.svg",
                      Theme_config.bluetooth_controller.discovered_icon_color),
                    widget = wibox.widget.imagebox,
                    valign = "center",
                    halign = "center",
                    id = "icon",
                  },
                  id = "center",
                  halign = "center",
                  valign = "center",
                  widget = wibox.container.place,
                },
                {
                  {
                    text = "Nearby Devices",
                    widget = wibox.widget.textbox,
                    id = "device_name"
                  },
                  margins = dpi(5),
                  widget = wibox.container.margin
                },
                id = "discovered",
                layout = wibox.layout.fixed.horizontal
              },
              id = "discovered_bg",
              bg = Theme_config.bluetooth_controller.discovered_bg,
              fg = Theme_config.bluetooth_controller.discovered_fg,
              shape = function(cr, width, height)
                gshape.rounded_rect(cr, width, height, dpi(4))
              end,
              widget = wibox.container.background
            },
            id = "discovered_margin",
            top = dpi(10),
            widget = wibox.container.margin
          },
          {
            id = "discovered_list",
            {
              {
                id = "discovered_device_list",
                spacing = dpi(10),
                step = dpi(50),
                layout = require("src.lib.overflow_widget.overflow").vertical,
                scrollbar_width = 0,
              },
              id = "margin",
              margins = dpi(10),
              widget = wibox.container.margin
            },
            border_color = Theme_config.bluetooth_controller.con_device_border_color,
            border_width = Theme_config.bluetooth_controller.con_device_border_width,
            shape = function(cr, width, height)
              gshape.partially_rounded_rect(cr, width, height, false, false, true, true, dpi(4))
            end,
            widget = wibox.container.background,
            forced_height = 0
          },
          {
            { -- action buttons
              { -- turn off
                {
                  {
                    image = gcolor.recolor_image(icondir .. "power.svg",
                      Theme_config.bluetooth_controller.power_icon_color),
                    resize = false,
                    valign = "center",
                    halign = "center",
                    widget = wibox.widget.imagebox,
                    id = "icon"
                  },
                  widget = wibox.container.margin,
                  margins = dpi(5),
                  id = "center"
                },
                border_width = dpi(2),
                border_color = Theme_config.bluetooth_controller.border_color,
                shape = function(cr, width, height)
                  gshape.rounded_rect(cr, width, height, dpi(4))
                end,
                bg = Theme_config.bluetooth_controller.power_bg,
                widget = wibox.container.background,
                id = "power",
              },
              nil,
              { -- refresh
                {
                  {
                    image = gcolor.recolor_image(icondir .. "refresh.svg",
                      Theme_config.bluetooth_controller.refresh_icon_color),
                    resize = false,
                    valign = "center",
                    halign = "center",
                    widget = wibox.widget.imagebox,
                  },
                  widget = wibox.container.margin,
                  margins = dpi(5),
                },
                border_width = dpi(2),
                border_color = Theme_config.bluetooth_controller.border_color,
                shape = function(cr, width, height)
                  gshape.rounded_rect(cr, width, height, dpi(4))
                end,
                bg = Theme_config.bluetooth_controller.refresh_bg,
                widget = wibox.container.background
              },
              layout = wibox.layout.align.horizontal
            },
            widget = wibox.container.margin,
            top = dpi(10),
          },
          id = "layout1",
          layout = wibox.layout.fixed.vertical
        },
        id = "margin",
        margins = dpi(15),
        widget = wibox.container.margin
      },
      shape = function(cr, width, height)
        gshape.rounded_rect(cr, width, height, dpi(8))
      end,
      border_color = Theme_config.bluetooth_controller.container_border_color,
      border_width = Theme_config.bluetooth_controller.container_border_width,
      bg = Theme_config.bluetooth_controller.container_bg,
      id = "background",
      widget = wibox.container.background
    },
    width = dpi(400),
    strategy = "exact",
    widget = wibox.container.constraint
  }

  capi.awesome.connect_signal(
    "bluetooth::device_changed",
    function(device, battery)
      add_device(ret, device, battery)
      remove_device(ret, device)
      bluetooth_container:get_children_by_id("connected_device_list")[1].children = ret:get_devices().paired
      bluetooth_container:get_children_by_id("discovered_device_list")[1].children = ret:get_devices().discovered
    end
  )

  local connected_margin = bluetooth_container:get_children_by_id("connected_margin")[1]
  local connected_list = bluetooth_container:get_children_by_id("connected_list")[1]
  local connected = bluetooth_container:get_children_by_id("connected")[1].center

  connected_margin:connect_signal(
    "button::press",
    function()
      capi.awesome.emit_signal("bluetooth::scan")
      local rubato_timer = rubato.timed {
        duration = 0.2,
        pos = connected_list.forced_height,
        easing = rubato.linear,
        subscribed = function(v)
          connected_list.forced_height = v
        end
      }
      if connected_list.forced_height == 0 then
        local size = (#ret:get_devices().paired * 60) + 1
        if size < 210 then
          rubato_timer.target = dpi(size)
        end
        connected_margin.connected_bg.shape = function(cr, width, height)
          gshape.partially_rounded_rect(cr, width, height, true, true, false, false, dpi(4))
        end
        connected.icon:set_image(gcolor.recolor_image(icondir .. "menu-up.svg",
          Theme_config.bluetooth_controller.connected_icon_color))
      else
        rubato_timer.target = 0
        connected_margin.connected_bg.shape = function(cr, width, height)
          gshape.rounded_rect(cr, width, height, 4)
        end
        connected.icon:set_image(gcolor.recolor_image(icondir .. "menu-down.svg",
          Theme_config.bluetooth_controller.connected_icon_color))
      end
    end
  )

  local discovered_margin = bluetooth_container:get_children_by_id("discovered_margin")[1]
  local discovered_list = bluetooth_container:get_children_by_id("discovered_list")[1]
  local discovered_bg = bluetooth_container:get_children_by_id("discovered_bg")[1]
  local discovered = bluetooth_container:get_children_by_id("discovered")[1].center

  discovered_margin:connect_signal(
    "button::press",
    function()
      capi.awesome.emit_signal("bluetooth::scan")

      local rubato_timer = rubato.timed {
        duration = 0.2,
        pos = discovered_list.forced_height,
        easing = rubato.linear,
        subscribed = function(v)
          discovered_list.forced_height = v
        end
      }

      if discovered_list.forced_height == 0 then
        local size = (#ret:get_devices().discovered * 60) + 1
        if size > 210 then
          size = 210
        end
        rubato_timer.target = dpi(size)
        discovered_margin.discovered_bg.shape = function(cr, width, height)
          gshape.partially_rounded_rect(cr, width, height, true, true, false, false, dpi(4))
        end
        discovered.icon:set_image(gcolor.recolor_image(icondir .. "menu-up.svg",
          Theme_config.bluetooth_controller.discovered_icon_color))
      else
        rubato_timer.target = 0
        discovered_bg.shape = function(cr, width, height)
          gshape.rounded_rect(cr, width, height, 4)
        end
        discovered.icon:set_image(gcolor.recolor_image(icondir .. "menu-down.svg",
          Theme_config.bluetooth_controller.discovered_icon_color))
      end
    end
  )

  ret.widget = awful.popup {
    widget = bluetooth_container,
    ontop = true,
    bg = Theme_config.bluetooth_controller.container_bg,
    stretch = false,
    visible = false,
    screen = args.screen,
    placement = function(c) awful.placement.align(c,
        { position = "top_right", margins = { right = dpi(360), top = dpi(60) } })
    end,
    shape = function(cr, width, height)
      gshape.rounded_rect(cr, width, height, dpi(12))
    end
  }

  awesome.connect_signal(
    "bluetooth_controller::toggle",
    function()
      if ret.widget.screen == capi.mouse.screen then
        ret.widget.visible = not ret.widget.visible
      end
    end
  )


  ret.widget:connect_signal(
    "mouse::leave",
    function()
      capi.mousegrabber.run(
        function()
          capi.awesome.emit_signal("bluetooth_controller::toggle", args.screen)
          capi.mousegrabber.stop()
          return true
        end,
        "arrow"
      )
    end
  )

  ret.widget:connect_signal(
    "mouse::enter",
    function()
      capi.mousegrabber.stop()
    end
  )
end

function bluetooth.mt:__call(...)
  return bluetooth.new(...)
end

return setmetatable(bluetooth, bluetooth.mt)
