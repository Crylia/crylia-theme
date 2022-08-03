--------------------------------------
-- This is the bluetooth controller --
--------------------------------------

-- Awesome Libs
local awful = require("awful")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")

local rubato = require("src.lib.rubato")

local icondir = awful.util.getdir("config") .. "src/assets/icons/bluetooth/"

return function(s)

  local function create_device(device, battery)
    local icon = device.Icon or "bluetooth-on"
    local device_widget = wibox.widget {
      {
        {
          {
            {
              {
                image = gears.color.recolor_image(
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
                  text = device.Alias or device.Name,
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
                gears.shape.rounded_rect(cr, width, height, dpi(4))
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
        gears.shape.rounded_rect(cr, width, height, dpi(4))
      end,
      widget = wibox.container.background
    }

    --! using :Connect freezes awesome, either find a solution or switch to console commands
    if device.Connected then
      device_widget:get_children_by_id("con")[1].image = gears.color.recolor_image(icondir .. "link-off.svg",
        Theme_config.bluetooth_controller.icon_color_dark)
      device_widget:connect_signal(
        "button::press",
        function(_, _, _, key)
          if key == 1 then
            device:Disconnect()
            awesome.emit_signal("bluetooth::connect", device)
          end
        end
      )
    else
      device_widget:get_children_by_id("con")[1].image = gears.color.recolor_image(icondir .. "link.svg",
        Theme_config.bluetooth_controller.icon_color_dark)
      device_widget:connect_signal(
        "button::press",
        function(_, _, _, key)
          if key == 1 then
            device:Connect()
            awesome.emit_signal("bluetooth::disconnect", device)
          end
        end
      )
    end
    Hover_signal(device_widget)
    return device_widget
  end

  local connected_devices_list = wibox.widget {
    {
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
      id = "place",
      height = dpi(200),
      strategy = "max",
      widget = wibox.container.constraint
    },
    id = "connected_device_background",
    border_color = Theme_config.bluetooth_controller.con_device_border_color,
    border_width = Theme_config.bluetooth_controller.con_device_border_width,
    shape = function(cr, width, height)
      gears.shape.partially_rounded_rect(cr, width, height, false, false, true, true, dpi(4))
    end,
    widget = wibox.container.background
  }

  local discovered_devices_list = wibox.widget {
    {
      {
        {
          spacing = dpi(10),
          step = dpi(50),
          layout = require("src.lib.overflow_widget.overflow").vertical,
          scrollbar_width = 0,
          id = "discovered_device_list"
        },
        id = "margin",
        margins = dpi(10),
        widget = wibox.container.margin
      },
      id = "place",
      height = dpi(200),
      strategy = "max",
      widget = wibox.container.constraint
    },
    id = "discovered_device_background",
    border_color = Theme_config.bluetooth_controller.con_device_border_color,
    border_width = Theme_config.bluetooth_controller.con_device_border_width,
    shape = function(cr, width, height)
      gears.shape.partially_rounded_rect(cr, width, height, false, false, true, true, dpi(4))
    end,
    widget = wibox.container.background
  }

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
                    image = gears.color.recolor_image(icondir .. "menu-down.svg",
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
                gears.shape.rounded_rect(cr, width, height, dpi(4))
              end,
              widget = wibox.container.background
            },
            id = "connected_margin",
            widget = wibox.container.margin
          },
          {
            id = "connected_list",
            widget = connected_devices_list,
            forced_height = 0
          },
          {
            {
              {
                {
                  {
                    resize = false,
                    image = gears.color.recolor_image(icondir .. "menu-down.svg",
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
                gears.shape.rounded_rect(cr, width, height, dpi(4))
              end,
              widget = wibox.container.background
            },
            id = "discovered_margin",
            top = dpi(10),
            widget = wibox.container.margin
          },
          {
            id = "discovered_list",
            widget = discovered_devices_list,
            forced_height = 0
          },
          id = "layout1",
          layout = wibox.layout.fixed.vertical
        },
        id = "margin",
        margins = dpi(15),
        widget = wibox.container.margin
      },
      shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, dpi(8))
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

  -- Main container
  local bluetooth_controller_container = awful.popup {
    widget = wibox.container.background,
    ontop = true,
    bg = Theme_config.bluetooth_controller.container_bg,
    stretch = false,
    visible = false,
    screen = s,
    placement = function(c) awful.placement.align(c,
        { position = "top_right", margins = { right = dpi(380), top = dpi(60) } })
    end,
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(12))
    end
  }

  local connected_devices, nearby_devices = {}, {}

  -- function to check if a device is already in the list
  local function is_device_in_list(device)
    for i = 1, #connected_devices do
      if connected_devices[i].Address == device.Address then
        return true
      end
    end
    return false
  end

  awesome.connect_signal(
    "bluetooth::device_changed",
    function(device, battery)
      if not is_device_in_list(device) then
        -- add device and battery to list
        if device.Paired then
          table.insert(connected_devices, device)
        else
          table.insert(nearby_devices, device)
        end
      end

      if (#connected_devices + #nearby_devices) > 0 then
        local cd_list, dd_list = {}, {}
        for _, d in pairs(connected_devices) do
          if d.Paired then
            table.insert(cd_list, create_device(d))
          else
            table.insert(dd_list, create_device(d))
          end
        end
        for _, d in pairs(nearby_devices) do
          if d.Paired then
            table.insert(cd_list, create_device(d, battery))
          else
            table.insert(dd_list, create_device(d, battery))
          end
        end
        connected_devices_list:get_children_by_id("connected_device_list")[1].children = cd_list
        discovered_devices_list:get_children_by_id("discovered_device_list")[1].children = dd_list
      end
    end
  )

  -- Variables for easier access and better readability
  local connected_margin = bluetooth_container:get_children_by_id("connected_margin")[1]
  local connected_list = bluetooth_container:get_children_by_id("connected_list")[1]
  local connected_bg = bluetooth_container:get_children_by_id("connected_bg")[1]
  local connected = bluetooth_container:get_children_by_id("connected")[1].center

  -- Click event for the microphone dropdown
  connected_margin:connect_signal(
    "button::press",
    function()
      local rubato_timer = rubato.timed {
        duration = 0.4,
        intro = 0.1,
        outro = 0.1,
        pos = connected_list.forced_height,
        easing = rubato.linear,
        subscribed = function(v)
          connected_list.forced_height = v
        end
      }
      if connected_list.forced_height == 0 then
        local size = (#connected_devices * 45) + ((#connected_devices - 1) * 10)
        if size < 210 then
          rubato_timer.target = dpi(size)
        else
          rubato_timer.target = dpi(210)
        end
        connected_margin.connected_bg.shape = function(cr, width, height)
          gears.shape.partially_rounded_rect(cr, width, height, true, true, false, false, dpi(4))
        end
        connected.icon:set_image(gears.color.recolor_image(icondir .. "menu-up.svg",
          Theme_config.bluetooth_controller.connected_icon_color))
      else
        rubato_timer.target = 0
        connected_bg.shape = function(cr, width, height)
          gears.shape.rounded_rect(cr, width, height, 4)
        end
        connected.icon:set_image(gears.color.recolor_image(icondir .. "menu-down.svg",
          Theme_config.bluetooth_controller.connected_icon_color))
      end
    end
  )

  -- Variables for easier access and better readability
  local discovered_margin = bluetooth_container:get_children_by_id("discovered_margin")[1]
  local discovered_list = bluetooth_container:get_children_by_id("discovered_list")[1]
  local discovered_bg = bluetooth_container:get_children_by_id("discovered_bg")[1]
  local discovered = bluetooth_container:get_children_by_id("discovered")[1].center

  -- Click event for the microphone dropdown
  discovered_margin:connect_signal(
    "button::press",
    function()
      local rubato_timer = rubato.timed {
        duration = 0.4,
        intro = 0.1,
        outro = 0.1,
        pos = discovered_list.forced_height,
        easing = rubato.linear,
        subscribed = function(v)
          discovered_list.forced_height = v
        end
      }

      if discovered_list.forced_height == 0 then
        local size = (#nearby_devices * dpi(45)) + ((#nearby_devices - 1) * dpi(10))
        if size < 210 then
          rubato_timer.target = dpi(size)
        else
          rubato_timer.target = dpi(20)
        end
        discovered_margin.discovered_bg.shape = function(cr, width, height)
          gears.shape.partially_rounded_rect(cr, width, height, true, true, false, false, dpi(4))
        end
        discovered.icon:set_image(gears.color.recolor_image(icondir .. "menu-up.svg",
          Theme_config.bluetooth_controller.discovered_icon_color))
      else
        rubato_timer.target = 0
        discovered_bg.shape = function(cr, width, height)
          gears.shape.rounded_rect(cr, width, height, 4)
        end
        discovered.icon:set_image(gears.color.recolor_image(icondir .. "menu-down.svg",
          Theme_config.bluetooth_controller.discovered_icon_color))
      end
    end
  )

  -- When the mouse leaves the popup it stops the mousegrabber and hides the popup.
  bluetooth_controller_container:connect_signal(
    "mouse::leave",
    function()
      mousegrabber.run(
        function()
          awesome.emit_signal("bluetooth_controller::toggle", s)
          mousegrabber.stop()
          return true
        end,
        "arrow"
      )
    end
  )

  bluetooth_controller_container:connect_signal(
    "mouse::enter",
    function()
      mousegrabber.stop()
    end
  )

  -- Draw the popup
  bluetooth_controller_container:setup {
    bluetooth_container,
    layout = wibox.layout.fixed.horizontal
  }

  -- Toggle container visibility
  awesome.connect_signal(
    "bluetooth_controller::toggle",
    function(scr)
      if scr == s then
        bluetooth_controller_container.visible = not bluetooth_controller_container.visible
      end
    end
  )

end
