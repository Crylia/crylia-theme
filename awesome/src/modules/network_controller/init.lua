------------------------------------
-- This is the network controller --
------------------------------------

-- Awesome Libs
local awful = require("awful")
local dbus_proxy = require("src.lib.lua-dbus_proxy.src.dbus_proxy")
local dpi = require("beautiful").xresources.apply_dpi
local gtable = require("gears").table
local gtimer = require("gears").timer
local gshape = require("gears").shape
local gcolor = require("gears").color
local gears = require("gears")
local lgi = require("lgi")
local wibox = require("wibox")
local NM = require("lgi").NM
local base = require("wibox.widget.base")

local rubato = require("src.lib.rubato")

local access_point = require("src.modules.network_controller.access_point")
local dnd_widget = require("awful.widget.toggle_widget")

local icondir = gears.filesystem.get_configuration_dir() .. "src/assets/icons/network/"

local network = { mt = {} }

network.NMState = {
  UNKNOWN = 0,
  ASLEEP = 10,
  DISCONNECTED = 20,
  DISCONNECTING = 30,
  CONNECTING = 40,
  CONNECTED_LOCAL = 50,
  CONNECTED_SITE = 60,
  CONNECTED_GLOBAL = 70,
}

network.DeviceType = {
  ETHERNET = 1,
  WIFI = 2
}

network.DeviceState = {
  UNKNOWN = 0,
  UNMANAGED = 10,
  UNAVAILABLE = 20,
  DISCONNECTED = 30,
  PREPARE = 40,
  CONFIG = 50,
  NEED_AUTH = 60,
  IP_CONFIG = 70,
  IP_CHECK = 80,
  SECONDARIES = 90,
  ACTIVATED = 100,
  DEACTIVATING = 110,
  FAILED = 120
}

function network:get_wifi_proxy()
  local devices = self._private.NetworkManager:GetDevices()
  if (not devices) or (#devices == 0) then return end
  for _, path in ipairs(devices) do
    local NetworkManagerDevice = dbus_proxy.Proxy:new {
      bus = dbus_proxy.Bus.SYSTEM,
      name = "org.freedesktop.NetworkManager",
      interface = "org.freedesktop.NetworkManager.Device",
      path = path
    }

    if NetworkManagerDevice.DeviceType == network.DeviceType.WIFI then
      self._private.NetworkManagerDevice = NetworkManagerDevice
      self._private.NetworkManagerDeviceWireless = dbus_proxy.Proxy:new {
        bus = dbus_proxy.Bus.SYSTEM,
        name = "org.freedesktop.NetworkManager",
        interface = "org.freedesktop.NetworkManager.Device.Wireless",
        path = path
      }

      self._private.NetworkManagerDevice:connect_signal(function(proxy, new_state, old_state, reason)
        local NetworkManagerAccessPoint = dbus_proxy.Proxy:new {
          bus = dbus_proxy.Bus.SYSTEM,
          name = "org.freedesktop.NetworkManager",
          interface = "org.freedesktop.NetworkManager.AccessPoint",
          path = self._private.wifi_proxy.ActiveAccessPoint
        }

        self:emit_signal(tostring(NetworkManagerAccessPoint.HwAddress) .. "::state", new_state, old_state)
        if new_state == network.DeviceState.ACTIVATED then
          local ssid = NM.utils_ssid_to_utf8(NetworkManagerAccessPoint.Ssid)
          self:emit_signal("NM::AccessPointConnected", ssid, NetworkManagerAccessPoint.Strength)
          print("AP Connected: ", ssid, NetworkManagerAccessPoint.Strength)
        end
      end, "StateChanged")
    end
  end
end

function network.device_state_to_string(state)
  local device_state_to_string = {
    [0] = "Unknown",
    [10] = "Unmanaged",
    [20] = "Unavailable",
    [30] = "Disconnected",
    [40] = "Prepare",
    [50] = "Config",
    [60] = "Need Auth",
    [70] = "IP Config",
    [80] = "IP Check",
    [90] = "Secondaries",
    [100] = "Activated",
    [110] = "Deactivated",
    [120] = "Failed"
  }

  return device_state_to_string[state]
end

---Scan for access points and create a widget for each one.
function network:scan_access_points()
  if not self._private.NetworkManagerDeviceWireless then return end
  local ap_list = self:get_children_by_id("wifi_ap_list")[1]
  ap_list:reset()
  self._private.NetworkManagerDeviceWireless:RequestScanAsync(function(proxy, context, success, failure)
    if failure then
      return
    end

    -- Get every access point even those who hide their ssid
    for _, ap in ipairs(self._private.NetworkManagerDeviceWireless:GetAllAccessPoints()) do

      -- Create a new proxy for every ap
      local NetworkManagerAccessPoint = dbus_proxy.Proxy:new {
        bus = dbus_proxy.Bus.SYSTEM,
        name = "org.freedesktop.NetworkManager",
        interface = "org.freedesktop.NetworkManager.AccessPoint",
        path = ap
      }

      -- We are only interested in those with a ssid
      if NetworkManagerAccessPoint.Ssid then
        ap_list:add(access_point {
          NetworkManagerAccessPoint = NetworkManagerAccessPoint,
          NetworkManagerDevice = self._private.NetworkManagerDevice,
          NetworkManagerSettings = self._private.NetworkManagerSettings,
          NetworkManager = self._private.NetworkManager,
          NetworkManagerDeviceWireless = self._private.NetworkManagerDeviceWireless
        })
      end
    end

    table.sort(ap_list, function(a, b)
      return a.NetworkManagerAccessPoint.Strength > b.NetworkManagerAccessPoint.Strength
    end)
  end, { call_id = "my-id" }, {})
end

function network:is_ap_active(ap)
  return ap.path == self._private.NetworkManagerDeviceWireless.ActiveAccessPoint
end

---Toggles networking on or off
function network:toggle_wifi()
  local enable = not self._private.NetworkManager.WirelessEnabled
  if enable then
    self._private.NetworkManager.Enable(true)
  end

  self._private.NetworkManager:Set("org.freedesktop.NetworkManager", "WirelessEnabled", lgi.GLib.Variant("b", enable))
  self._private.NetworkManager.WirelessEnabled = { signature = "b", value = enable }
end

function network.new(args)
  args = args or {}

  local ret = base.make_widget_from_value(wibox.widget {
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
                      Theme_config.network_manager.wifi_icon_color),
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
                    text = "Wifi Networks",
                    widget = wibox.widget.textbox,
                    id = "ap_name"
                  },
                  margins = dpi(5),
                  widget = wibox.container.margin
                },
                id = "wifi",
                layout = wibox.layout.fixed.horizontal
              },
              id = "wifi_bg",
              bg = Theme_config.network_manager.wifi_bg,
              fg = Theme_config.network_manager.wifi_fg,
              shape = function(cr, width, height)
                gshape.rounded_rect(cr, width, height, dpi(4))
              end,
              widget = wibox.container.background
            },
            id = "wifi_margin",
            widget = wibox.container.margin
          },
          {
            id = "wifi_list",
            {
              {
                step = dpi(50),
                spacing = dpi(10),
                layout = require("src.lib.overflow_widget.overflow").vertical,
                scrollbar_width = 0,
                id = "wifi_ap_list"
              },
              id = "margin",
              margins = dpi(10),
              widget = wibox.container.margin
            },
            border_color = Theme_config.network_manager.ap_border_color,
            border_width = Theme_config.network_manager.ap_border_width,
            shape = function(cr, width, height)
              gshape.partially_rounded_rect(cr, width, height, false, false, true, true, dpi(4))
            end,
            widget = wibox.container.background,
            forced_height = 0
          },
          {
            { -- action buttons
              {
                dnd_widget {
                  color = Theme_config.network_manager.power_icon_color,
                  size = dpi(40)
                },
                id = "dnd",
                widget = wibox.container.place,
                valign = "center",
                halign = "center"
              },
              nil,
              { -- refresh
                {
                  {
                    image = gcolor.recolor_image(icondir .. "refresh.svg",
                      Theme_config.network_manager.refresh_icon_color),
                    resize = false,
                    valign = "center",
                    halign = "center",
                    widget = wibox.widget.imagebox,
                    id = "icon"
                  },
                  widget = wibox.container.margin,
                  margins = dpi(5),
                  id = "center",
                },
                border_width = dpi(2),
                border_color = Theme_config.network_manager.border_color,
                shape = function(cr, width, height)
                  gshape.rounded_rect(cr, width, height, dpi(4))
                end,
                bg = Theme_config.network_manager.refresh_bg,
                widget = wibox.container.background,
                id = "refresh"
              },
              layout = wibox.layout.align.horizontal
            },
            widget = wibox.container.margin,
            top = dpi(10),
            id = "action_buttons"
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
      border_color = Theme_config.network_manager.border_color,
      border_width = Theme_config.network_manager.border_width,
      bg = Theme_config.network_manager.bg,
      id = "background",
      widget = wibox.container.background
    },
    width = dpi(400),
    strategy = "exact",
    widget = wibox.container.constraint
  })

  local dnd = ret:get_children_by_id("dnd")[1]:get_widget()

  dnd:connect_signal("dnd::toggle", function(enable)
    ret:toggle_wifi()
  end)

  gtable.crush(ret, network, true)

  --#region Wifi Proxies

  ret._private.NetworkManager = dbus_proxy.Proxy:new {
    bus = dbus_proxy.Bus.SYSTEM,
    name = "org.freedesktop.NetworkManager",
    interface = "org.freedesktop.NetworkManager",
    path = "/org/freedesktop/NetworkManager",
  }

  ret._private.NetworkManagerSettings = dbus_proxy.Proxy:new {
    bus = dbus_proxy.Bus.SYSTEM,
    name = "org.freedesktop.NetworkManager",
    interface = "org.freedesktop.NetworkManager.Settings",
    path = "/org/freedesktop/NetworkManager/Settings",
  }

  ret._private.NetworkManagerProperties = dbus_proxy.Proxy:new {
    bus = dbus_proxy.Bus.SYSTEM,
    name = "org.freedesktop.NetworkManager",
    interface = "org.freedesktop.DBus.Properties",
    path = "/org/freedesktop/NetworkManager",
  }

  ret._private.NetworkManagerProperties:connect_signal(function(_, properties, data)
    if data.WirelessEnables ~= nil and ret._private.WirelessEnabled ~= data.WirelessEnabled then
      ret._private.WirelessEnabled = data.WirelessEnabled

      ret:emit_signal("NetworkManager::status", ret._private.WirelessEnabled)
      print(ret._private.WirelessEnabled)

      if data.WirelessEnabled then
        gtimer {
          timeout = 5,
          autostart = true,
          call_now = false,
          single_shot = true,
          callback = function()
            ret:scan_access_points()
          end
        }
      end
    end
  end, "PropertiesChanged")

  ret:get_wifi_proxy()

  ret:scan_access_points()

  --[[ gtimer.delayed_call(function()
    local active_access_point = ret._private.NetworkManagerDeviceWireless.ActiveAccessPoint
    if ret._private.NetworkManager.State == network.DeviceState.ACTIVATED and active_access_point ~= "/" then
      local active_access_point_proxy = dbus_proxy.Proxy:new {
        bus = dbus_proxy.Bus.SYSTEM,
        name = "org.freedesktop.NetworkManager",
        interface = "org.freedesktop.NetworkManager.AccessPoint",
        path = active_access_point,
      }
    end
  end) ]]

  --#endregion

  --#region Dropdown logic
  local wifi_margin = ret:get_children_by_id("wifi_margin")[1]
  local wifi_list = ret:get_children_by_id("wifi_list")[1]
  local wifi = ret:get_children_by_id("wifi")[1].center

  local rubato_timer = rubato.timed {
    duration = 0.2,
    pos = wifi_list.forced_height,
    easing = rubato.linear,
    subscribed = function(v)
      wifi_list.forced_height = v
    end
  }

  wifi_margin:buttons(gtable.join(
    awful.button({}, 1, nil,
      function()
        if wifi_list.forced_height == 0 then
          if not ret:get_children_by_id("wifi_ap_list")[1].children then
            return
          end
          local size = (5 * 49) + 1

          size = size > 210 and 210 or size

          rubato_timer.target = dpi(size)
          wifi_margin.wifi_bg.shape = function(cr, width, height)
            gshape.partially_rounded_rect(cr, width, height, true, true, false, false, dpi(4))
          end
          wifi.icon:set_image(gcolor.recolor_image(icondir .. "menu-up.svg",
            Theme_config.network_manager.wifi_icon_color))
        else
          rubato_timer.target = 0
          wifi_margin.wifi_bg.shape = function(cr, width, height)
            gshape.partially_rounded_rect(cr, width, height, true, true, true, true, dpi(4))
          end
          wifi.icon:set_image(gcolor.recolor_image(icondir .. "menu-down.svg",
            Theme_config.network_manager.wifi_icon_color))
        end
      end
    )
  ))
  --#endregion

  local refresh_button = ret:get_children_by_id("refresh")[1]
  refresh_button:buttons(gtable.join(
    awful.button({}, 1, nil,
      function()
        ret:scan_access_points()
      end
    )
  ))
  Hover_signal(refresh_button)

  return ret
end

function network.mt:__call(...)
  return network.new(...)
end

return setmetatable(network, network.mt)
