------------------------------------
-- This is the network controller --
------------------------------------

-- Awesome Libs
local awful = require("awful")
local dbus_proxy = require("dbus_proxy")
local dpi = require("beautiful").xresources.apply_dpi
local gtable = require("gears").table
local gtimer = require("gears").timer
local gshape = require("gears").shape
local gobject = require("gears").object
local gcolor = require("gears").color
local gears = require("gears")
local lgi = require("lgi")
local wibox = require("wibox")

local NM = require("lgi").NM

local rubato = require("src.lib.rubato")

local access_point = require("src.modules.network_controller.access_point")

local icondir = gears.filesystem.get_configuration_dir() .. "src/assets/icons/network/"

local capi = {
  awesome = awesome,
}

local network = { mt = {} }

network.access_points = { layout = wibox.layout.fixed.vertical }

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

local function flags_to_security(flags, wpa_flags, rsn_flags)
  local str = ""
  if flags == 1 and wpa_flags == 0 and rsn_flags == 0 then
    str = str .. " WEP"
  end
  if wpa_flags ~= 0 then
    str = str .. " WPA1"
  end
  if not rsn_flags ~= 0 then
    str = str .. " WPA2"
  end
  if wpa_flags == 512 or rsn_flags == 512 then
    str = str .. " 802.1X"
  end

  return (str:gsub("^%s", ""))
end

local function get_wifi_proxy(self)
  local devices = self._private.client_proxy:GetDevices()
  for _, device in ipairs(devices) do
    local device_proxy = dbus_proxy.Proxy:new {
      bus = dbus_proxy.Bus.SYSTEM,
      name = "org.freedesktop.NetworkManager",
      interface = "org.freedesktop.NetworkManager.Device",
      path = device
    }

    if device_proxy.DeviceType == network.DeviceType.WIFI then
      self._private.device_proxy = device_proxy
      self._private.wifi_proxy = dbus_proxy.Proxy:new {
        bus = dbus_proxy.Bus.SYSTEM,
        name = "org.freedesktop.NetworkManager",
        interface = "org.freedesktop.NetworkManager.Device.Wireless",
        path = device
      }

      self._private.device_proxy:connect_signal(function(proxy, new_state, old_state, reason)
        local active_access_point_proxy = dbus_proxy.Proxy:new {
          bus = dbus_proxy.Bus.SYSTEM,
          name = "org.freedesktop.NetworkManager",
          interface = "org.freedesktop.NetworkManager.AccessPoint",
          path = self._private.wifi_proxy.ActiveAccessPoint
        }

        self:emit_signal(tostring(active_access_point_proxy.HwAddress) .. "::state", new_state, old_state)
        if new_state == network.DeviceState.ACTIVATED then
          local ssid = NM.utils_ssid_to_utf8(active_access_point_proxy.Ssid)
          self:emit_signal("NM::AccessPointConnected", ssid, active_access_point_proxy.Strength)
        end
      end, "StateChanged")
    end
  end
end

function network.device_state_to_string(state)
  local device_state_to_string =
  {
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

local function get_access_point_connections(self, ssid)
  local connection_proxies = {}

  local connections = self._private.settings_proxy:ListConnections()
  for _, connection_path in ipairs(connections) do
    local connection_proxy = dbus_proxy.Proxy:new {
      bus = dbus_proxy.Bus.SYSTEM,
      name = "org.freedesktop.NetworkManager",
      interface = "org.freedesktop.NetworkManager.Settings.Connection",
      path = connection_path
    }

    if connection_proxy.Filename:find(ssid) then
      table.insert(connection_proxies, connection_proxy)
    end
  end

  return connection_proxies
end

local function generate_uuid()
  local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
  local uuid = string.gsub(template, '[xy]', function(c)
    local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
    return string.format('%x', v)
  end)
  return uuid
end

local function create_profile(ap, password, auto_connect)
  local s_con =
  {
    -- ["interface-name"] = lgi.GLib.Variant("s", ap.device_interface),
    ["uuid"] = lgi.GLib.Variant("s", generate_uuid()),
    ["id"] = lgi.GLib.Variant("s", ap.ssid),
    ["type"] = lgi.GLib.Variant("s", "802-11-wireless"),
    ["autoconnect"] = lgi.GLib.Variant("b", auto_connect),
  }

  local s_ip4 =
  {
    ["method"] = lgi.GLib.Variant("s", "auto")
  }

  local s_ip6 =
  {
    ["method"] = lgi.GLib.Variant("s", "auto"),
  }

  local s_wifi =
  {
    ["mode"] = lgi.GLib.Variant("s", "infrastructure"),
  }

  local s_wsec = {}
  if ap.security ~= "" then
    if ap.security:match("WPA") ~= nil then
      s_wsec["key-mgmt"] = lgi.GLib.Variant("s", "wpa-psk")
      s_wsec["auth-alg"] = lgi.GLib.Variant("s", "open")
      --s_wsec["psk"] = lgi.GLib.Variant("s", helpers.string.trim(password))
    else
      s_wsec["key-mgmt"] = lgi.GLib.Variant("s", "None")
      s_wsec["wep-key-type"] = lgi.GLib.Variant("s", NM.WepKeyType.PASSPHRASE)
      --s_wsec["wep-key0"] = lgi.GLib.Variant("s", helpers.string.trim(password))
    end
  end

  return {
    ["connection"] = s_con,
    ["ipv4"] = s_ip4,
    ["ipv6"] = s_ip6,
    ["802-11-wireless"] = s_wifi,
    ["802-11-wireless-security"] = s_wsec
  }
end

function network:scan_access_points()
  self._private.access_points = {}

  self._private.wifi_proxy:RequestScanAsync(function(proxy, context, success, failure)
    if failure ~= nil then
      self.access_points = { layout = wibox.layout.fixed.vertical }
      self:emit_signal("NM::AccessPointsFound", self.access_points[1].ssid)
      self:emit_signal("NM::ScanFailed", tostring(failure))
      return
    end

    local access_points = self._private.wifi_proxy:GetAllAccessPoints()

    self._private.access_points = {}
    if (not access_point) or (#access_points == 0) then
      self.access_points = { layout = wibox.layout.fixed.vertical }
      self:emit_signal("NM::AccessPointsFound", self.access_points[1].ssid)
    end

    for _, ap in ipairs(access_points) do
      local access_point_proxy = dbus_proxy.Proxy:new {
        bus = dbus_proxy.Bus.SYSTEM,
        name = "org.freedesktop.NetworkManager",
        interface = "org.freedesktop.NetworkManager.AccessPoint",
        path = ap
      }

      if access_point_proxy.Ssid then
        local appSsid = access_point_proxy.Ssid or ""
        local ssid = NM.utils_ssid_to_utf8(appSsid) or ""
        local security = flags_to_security(access_point_proxy.Flags, access_point_proxy.WpaFlags)
        local password = ""
        local connections = get_access_point_connections(self, ssid)

        for _, connection in ipairs(connections) do
          if connection.Filename:find(ssid) then
            local secrets = connection:GetSecrets("802-11-wireless-security")
            if secrets then
              password = secrets["802-11-wireless-security"].psk
            end
          end
        end

        table.insert(self._private.access_points, {
          ssid = ssid,
          security = security,
          password = password,
          strength = access_point_proxy.Strength,
          hw_address = access_point_proxy.HwAddress,
          device_interface = self._private.device_proxy.Interface,
          device_path = self._private.device_proxy.object_path,
          access_point_path = ap
        })
      end
    end

    self.access_points = { layout = wibox.layout.fixed.vertical }

    local seen = {}
    for _, ap2 in ipairs(self._private.access_points) do
      if not seen[ap2.ssid] then
        seen[ap2.ssid] = true
        table.insert(self.access_points,
          access_point.new { access_point = ap2, active = self._private.wifi_proxy.ActiveAccessPoint }.widget)
      end
    end

    table.sort(self._private.access_points, function(a, b)
      return a.strength > b.strength
    end)

    self:emit_signal("NM::AccessPointsFound", self.access_points[1].ssid)
  end, { call_id = "my-id" }, {})
end

function network:toggle()
  self.container.visible = not self.container.visible
end

function network:is_ap_active(ap)
  print(self._private.wifi_proxy.ActiveAccessPoint)
  return ap.path == self._private.wifi_proxy.ActiveAccessPoint
end

function network:disconnect_ap()
  self._private.client_proxy:DeactivateConnection(self._private.device_proxy.ActiveConnection)
end

function network:connect_ap(ap, pw, auto_connect)
  local connections = get_access_point_connections(self, ap.ssid)
  local profile = create_profile(ap, pw, auto_connect)

  if #connections == 0 then
    self._private.client_proxy:AddAndActivateConnectionAsync(function(proxy, context, success, failure)
      if failure then
        self:emit_signal("NM::AccessPointFailed", tostring(failure))
        return
      end

      self:emit_signal("NM::AccessPointConnected", ap.ssid)
    end, { call_id = "my-id", profile, ap.device_proxy_path, ap.path })
  else
    connections[1]:Update(profile)
    self._private.client_proxy:ActivateConnectionAsync(function(proxy, context, success, failure)
      if failure then
        self:emit_signal("NM::AccessPointFailed", tostring(failure))
        return
      end

      self:emit_signal("NM::AccessPointConnected", ap.ssid)
    end, { call_id = "my-id", connections[1].object_path, ap.device_proxy_path, ap.path })
  end
end

function network:toggle_access_point(ap, password, auto_connect)
  if self:is_ap_active(ap) then
    self:disconnect_ap()
  else
    self:connect_ap(ap, password, auto_connect)
  end
end

function network:toggle_wireless()
  local enable = not self._private.client_proxy.WirelessEnabled
  if enable then
    self._private.client_proxy:Enable(true)
  end

  self._private.client_proxy:Set("org.freedesktop.NetworkManager", "WirelessEnabled", lgi.GLib.Variant("b", enable))

  return enable
end

function network.new(args)
  args = args or {}

  local ret = gobject {}

  gtable.crush(ret, network, true)

  ret._private = {}

  ret._private.client_proxy = dbus_proxy.Proxy:new {
    bus = dbus_proxy.Bus.SYSTEM,
    name = "org.freedesktop.NetworkManager",
    interface = "org.freedesktop.NetworkManager",
    path = "/org/freedesktop/NetworkManager",
  }

  ret._private.settings_proxy = dbus_proxy.Proxy:new {
    bus = dbus_proxy.Bus.SYSTEM,
    name = "org.freedesktop.NetworkManager",
    interface = "org.freedesktop.NetworkManager.Settings",
    path = "/org/freedesktop/NetworkManager/Settings",
  }

  local property_proxy = dbus_proxy.Proxy:new {
    bus = dbus_proxy.Bus.SYSTEM,
    name = "org.freedesktop.NetworkManager",
    interface = "org.freedesktop.DBus.Properties",
    path = "/org/freedesktop/NetworkManager",
  }

  -- dbus proxy signals are in reversed order (function, signal)
  property_proxy:connect_signal(function(_, properties, data)
    if data.WirelessEnables ~= nil and ret._private.WirelessEnabled ~= data.WirelessEnabled then
      ret._private.WirelessEnabled = data.WirelessEnabled
      ret:emit_signal("NM::WirelessStateChanged", ret._private.WirelessEnabled)

      if data.WirelessEnabled then
        gtimer {
          timeout = 5,
          autostart = true,
          call_now = false,
          single_shot = true,
          callback = function()
            ret:get_access_points()
          end
        }
      end
    end
  end, "PropertiesChanged")

  get_wifi_proxy(ret)

  ret:scan_access_points()

  gtimer.delayed_call(function()
    ret:emit_signal("NM::WirelessStateChanged", ret._private.client_proxy.WirelessEnabled)

    local active_access_point = ret._private.wifi_proxy.ActiveAccessPoint
    if ret._private.device_proxy.State == network.DeviceState.ACTIVATED and active_access_point ~= "/" then
      local active_access_point_proxy = dbus_proxy.Proxy:new {
        bus = dbus_proxy.Bus.SYSTEM,
        name = "org.freedesktop.NetworkManager",
        interface = "org.freedesktop.NetworkManager.AccessPoint",
        path = active_access_point,
      }

      local ssid = NM.utils_ssid_to_utf8(active_access_point_proxy.Ssid)
      ret:emit_signal("NM:AccessPointConnected", ssid, active_access_point_proxy.Strength)
    end
  end)

  local network_widget = wibox.widget {
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
              nil,
              { -- airplane mode
                {
                  {
                    image = gcolor.recolor_image(icondir .. "airplane-off.svg",
                      Theme_config.network_manager.airplane_icon_color),
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
                id = "airplane"
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
  }

  local refresh_button = network_widget:get_children_by_id("refresh")[1]

  refresh_button:buttons(
    gtable.join(
      awful.button(
        {},
        1,
        nil,
        function()
          ret:scan_access_points()
        end
      )
    )
  )

  Hover_signal(refresh_button)

  local airplane_button = network_widget:get_children_by_id("airplane")[1]

  airplane_button:buttons(
    gtable.join(
      awful.button(
        {},
        1,
        nil,
        function()
          if ret:toggle_wireless() then
            airplane_button.center.icon.image = gcolor.recolor_image(icondir
              .. "airplane-off.svg",
              Theme_config.network_manager.airplane_icon_color)
          else
            airplane_button.center.icon.image = gcolor.recolor_image(icondir
              .. "airplane-on.svg",
              Theme_config.network_manager.airplane_icon_color)
          end
          ret:scan_access_points()
        end
      )
    )
  )

  Hover_signal(airplane_button)

  local wifi_margin = network_widget:get_children_by_id("wifi_margin")[1]
  local wifi_list = network_widget:get_children_by_id("wifi_list")[1]
  local wifi = network_widget:get_children_by_id("wifi")[1].center

  local rubato_timer = rubato.timed {
    duration = 0.2,
    pos = wifi_list.forced_height,
    easing = rubato.linear,
    subscribed = function(v)
      wifi_list.forced_height = v
    end
  }

  wifi_margin:buttons(
    gtable.join(
      awful.button(
        {},
        1,
        nil,
        function()
          if wifi_list.forced_height == 0 then
            local size = (#ret.access_points * 49) + 1

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
    )
  )

  ret.widget = awful.popup {
    widget = network_widget,
    bg = Theme_config.network_manager.bg,
    screen = args.screen,
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

  capi.awesome.connect_signal("NM::toggle_container", function()
    ret.widget.visible = not ret.widget.visible
    ret:scan_access_points()
  end)

  capi.awesome.connect_signal("NM::toggle_wifi", function()
    ret:toggle_wireless()
  end)

  ret:connect_signal("NM::AccessPointsFound", function(tab)
    network_widget:get_children_by_id("wifi_ap_list")[1].children = ret.access_points
  end)
end

function network.mt:__call(...)
  return network.new(...)
end

return setmetatable(network, network.mt)
