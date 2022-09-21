-------------------------------------------
-- @author https://github.com/Kasper24
-- @copyright 2021-2022 Kasper24
-------------------------------------------

local lgi = require("lgi")
local NM = lgi.NM
local awful = require("awful")
local gobject = require("gears.object")
local gtable = require("gears.table")
local gtimer = require("gears.timer")
local dbus_proxy = require("services.dbus_proxy")

local network = {}
local instance = nil

network.NMState = {
  UNKNOWN = 0, -- Networking state is unknown. This indicates a daemon error that
  -- makes it unable to reasonably assess the state. In such event the applications
  -- are expected to assume Internet connectivity might be present and not disable
  -- controls that require network access. The graphical shells may hide the network
  -- accessibility indicator altogether since no meaningful status indication can be provided.
  ASLEEP = 10, -- Networking is not enabled, the system is being suspended or resumed from suspend.
  DISCONNECTED = 20, -- There is no active network connection. The graphical
  -- shell should indicate no network connectivity and the applications
  -- should not attempt to access the network.
  DISCONNECTING = 30, -- Network connections are being cleaned up.
  -- The applications should tear down their network sessions.
  CONNECTING = 40, -- A network connection is being started The graphical
  -- shell should indicate the network is being connected while the
  -- applications should still make no attempts to connect the network.
  CONNECTED_LOCAL = 50, -- There is only local IPv4 and/or IPv6 connectivity,
  -- but no default route to access the Internet. The graphical
  -- shell should indicate no network connectivity.
  CONNECTED_SITE = 60, -- There is only site-wide IPv4 and/or IPv6 connectivity.
  -- This means a default route is available, but the Internet connectivity check
  -- (see "Connectivity" property) did not succeed. The graphical shell
  -- should indicate limited network connectivity.
  CONNECTED_GLOBAL = 70, -- There is global IPv4 and/or IPv6 Internet connectivity
  -- This means the Internet connectivity check succeeded, the graphical shell should
  -- indicate full network connectivity.
}

network.DeviceType = {
  ETHERNET = 1,
  WIFI = 2
}

network.DeviceState = {
  UNKNOWN = 0, -- the device's state is unknown
  UNMANAGED = 10, -- the device is recognized, but not managed by NetworkManager
  UNAVAILABLE = 20, --the device is managed by NetworkManager,
  --but is not available for use. Reasons may include the wireless switched off,
  --missing firmware, no ethernet carrier, missing supplicant or modem manager, etc.
  DISCONNECTED = 30, -- the device can be activated,
  --but is currently idle and not connected to a network.
  PREPARE = 40, -- the device is preparing the connection to the network.
  -- This may include operations like changing the MAC address,
  -- setting physical link properties, and anything else required
  -- to connect to the requested network.
  CONFIG = 50, -- the device is connecting to the requested network.
  -- This may include operations like associating with the Wi-Fi AP,
  -- dialing the modem, connecting to the remote Bluetooth device, etc.
  NEED_AUTH = 60, -- the device requires more information to continue
  -- connecting to the requested network. This includes secrets like WiFi passphrases,
  -- login passwords, PIN codes, etc.
  IP_CONFIG = 70, -- the device is requesting IPv4 and/or IPv6 addresses
  -- and routing information from the network.
  IP_CHECK = 80, -- the device is checking whether further action
  -- is required for the requested network connection.
  -- This may include checking whether only local network access is available,
  -- whether a captive portal is blocking access to the Internet, etc.
  SECONDARIES = 90, -- the device is waiting for a secondary connection
  -- (like a VPN) which must activated before the device can be activated
  ACTIVATED = 100, -- the device has a network connection, either local or global.
  DEACTIVATING = 110, -- a disconnection from the current network connection
  -- was requested, and the device is cleaning up resources used for that connection.
  -- The network connection may still be valid.
  FAILED = 120 -- the device failed to connect to
  -- the requested network and is cleaning up the connection request
}

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

local function generate_uuid()
  local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
  local uuid = string.gsub(template, '[xy]', function(c)
    local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
    return string.format('%x', v)
  end)
  return uuid
end

local function create_profile(access_point, password, auto_connect)
  local s_con =
  {
    -- ["interface-name"] = lgi.GLib.Variant("s", access_point.device_interface),
    ["uuid"] = lgi.GLib.Variant("s", generate_uuid()),
    ["id"] = lgi.GLib.Variant("s", access_point.ssid),
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
  if access_point.security ~= "" then
    if access_point.security:match("WPA") ~= nil then
      s_wsec["key-mgmt"] = lgi.GLib.Variant("s", "wpa-psk")
      s_wsec["auth-alg"] = lgi.GLib.Variant("s", "open")
      s_wsec["psk"] = lgi.GLib.Variant("s", helpers.string.trim(password))
    else
      s_wsec["key-mgmt"] = lgi.GLib.Variant("s", "None")
      s_wsec["wep-key-type"] = lgi.GLib.Variant("s", NM.WepKeyType.PASSPHRASE)
      s_wsec["wep-key0"] = lgi.GLib.Variant("s", helpers.string.trim(password))
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

local function on_wifi_device_state_changed(self, proxy, new_state, old_state, reason)
  local active_access_point_proxy = dbus_proxy.Proxy:new {
    bus = dbus_proxy.Bus.SYSTEM,
    name = "org.freedesktop.NetworkManager",
    interface = "org.freedesktop.NetworkManager.AccessPoint",
    path = self._private.wifi_proxy.ActiveAccessPoint
  }

  self:emit_signal(tostring(active_access_point_proxy.HwAddress) .. "::state", new_state, old_state)
  if new_state == network.DeviceState.ACTIVATED then
    local ssid = NM.utils_ssid_to_utf8(active_access_point_proxy.Ssid)
    self:emit_signal("access_point::connected", ssid, active_access_point_proxy.Strength)
  end
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

    if string.find(connection_proxy.Filename, ssid) then
      table.insert(connection_proxies, connection_proxy)
    end
  end

  return connection_proxies
end

local function get_wifi_proxy(self)
  local devices = self._private.client_proxy:GetDevices()
  for _, device_path in ipairs(devices) do
    local device_proxy = dbus_proxy.Proxy:new {
      bus = dbus_proxy.Bus.SYSTEM,
      name = "org.freedesktop.NetworkManager",
      interface = "org.freedesktop.NetworkManager.Device",
      path = device_path
    }

    if device_proxy.DeviceType == network.DeviceType.WIFI then
      self._private.device_proxy = device_proxy
      self._private.wifi_proxy = dbus_proxy.Proxy:new {
        bus = dbus_proxy.Bus.SYSTEM,
        name = "org.freedesktop.NetworkManager",
        interface = "org.freedesktop.NetworkManager.Device.Wireless",
        path = device_path
      }

      self._private.device_proxy:connect_signal("StateChanged", function(proxy, new_state, old_state, reason)
        on_wifi_device_state_changed(self, proxy, new_state, old_state, reason)
      end)
    end
  end
end

function network:scan_access_points()
  self._private.access_points = {}

  self._private.wifi_proxy:RequestScanAsync(function(proxy, context, success, failure)
    if failure ~= nil then
      print("Rescan wifi failed: ", failure)
      print("Rescan wifi failed error code: ", failure.code)
      self:emit_signal("scan_access_points::failed", tostring(failure), tostring(failure.code))
      return
    end

    local access_points = self._private.wifi_proxy:GetAccessPoints()
    for _, access_point_path in ipairs(access_points) do
      local access_point_proxy = dbus_proxy.Proxy:new {
        bus = dbus_proxy.Bus.SYSTEM,
        name = "org.freedesktop.NetworkManager",
        interface = "org.freedesktop.NetworkManager.AccessPoint",
        path = access_point_path
      }

      -- for _, access_point in ipairs(self._private.access_points) do
      --     if access_point.hw_address == access_point_proxy.HwAddress then
      --         print("duplicates")
      --         return
      --     end
      -- end

      if access_point_proxy.Ssid ~= nil then
        local ssid = NM.utils_ssid_to_utf8(access_point_proxy.Ssid)
        local security = flags_to_security(access_point_proxy.Flags, access_point_proxy.WpaFlags,
          access_point_proxy.RsnFlags)
        local password = ""
        local connections = get_access_point_connections(self, ssid)

        for _, connection in ipairs(connections) do
          if string.find(connection.Filename, ssid) then
            local secrets = connection:GetSecrets("802-11-wireless-security")
            if secrets ~= nil then
              password = secrets["802-11-wireless-security"].psk
            end
          end
        end

        table.insert(self._private.access_points, {
          raw_ssid = access_point_proxy.Ssid,
          ssid = ssid,
          security = security,
          password = password,
          strength = access_point_proxy.Strength,
          path = access_point_path,
          hw_address = access_point_proxy.HwAddress,
          device_interface = self._private.device_proxy.Interface,
          device_proxy_path = self._private.device_proxy.object_path,
        })
      end
    end

    table.sort(self._private.access_points, function(a, b)
      return a.strength > b.strength
    end)

    self:emit_signal("scan_access_points::success", self._private.access_points)
  end, { call_id = "my-id" }, {})
end

function network:connect_to_access_point(access_point, password, auto_connect)
  local connections = get_access_point_connections(self, access_point.ssid)
  local profile = create_profile(access_point, password, auto_connect)

  -- No connection profiles, need to create one
  if #connections == 0 then
    -- AddAndActivateConnectionAsync doesn't actually verify that the profile is valid
    -- The NetworkManager libary has methods to verify manually, but they are not exposed to DBus
    -- so instead I'm using the 2 seperate methods
    self._private.client_proxy:AddAndActivateConnectionAsync(function(proxy, context, success, failure)
      if failure ~= nil then
        print("Failed to activate connection: ", failure)
        print("Failed to activate connection error code: ", failure.code)
        self:emit_signal("activate_access_point::failed", tostring(failure), tostring(failure.code))
        return
      end

      self:emit_signal("activate_access_point::success", access_point.ssid)
    end, { call_id = "my-id" }, profile, access_point.device_proxy_path, access_point.path)
  else
    connections[1]:Update(profile)
    self._private.client_proxy:ActivateConnectionAsync(function(proxy, context, success, failure)
      if failure ~= nil then
        print("Failed to activate connection: ", failure)
        print("Failed to activate connection error code: ", failure.code)
        self:emit_signal("activate_access_point::failed", tostring(failure), tostring(failure.code))
        return
      end

      self:emit_signal("activate_access_point::success", access_point.ssid)

    end, { call_id = "my-id" }, connections[1].object_path, access_point.device_proxy_path, access_point.path)
  end
end

function network:is_access_point_active(access_point)
  return access_point.path == self._private.wifi_proxy.ActiveAccessPoint
end

function network:disconnect_from_access_point()
  self._private.client_proxy:DeactivateConnection(self._private.device_proxy.ActiveConnection)
end

function network:toggle_access_point(access_point, password, auto_connect)
  if self:is_access_point_active(access_point) then
    self:disconnect_from_access_point()
  else
    self:connect_to_access_point(access_point, password, auto_connect)
  end
end

function network:toggle_wireless_state()
  local enable = not self._private.client_proxy.WirelessEnabled
  if enable == true then
    self:set_network_state(true)
  end

  self._private.client_proxy:Set("org.freedesktop.NetworkManager", "WirelessEnabled", lgi.GLib.Variant("b", enable))
  self._private.client_proxy.WirelessEnabled = { signature = "b", value = enable }
end

function network:set_network_state(state)
  self._private.client_proxy:Enable(state)
end

function network:open_settings()
  awful.spawn("nm-connection-editor", false)
end

local function new()
  local ret = gobject {}
  gtable.crush(ret, network, true)

  ret._private = {}
  ret._private.access_points = {}

  ret._private.client_proxy = dbus_proxy.Proxy:new {
    bus = dbus_proxy.Bus.SYSTEM,
    name = "org.freedesktop.NetworkManager",
    interface = "org.freedesktop.NetworkManager",
    path = "/org/freedesktop/NetworkManager"
  }

  ret._private.settings_proxy = dbus_proxy.Proxy:new {
    bus = dbus_proxy.Bus.SYSTEM,
    name = "org.freedesktop.NetworkManager",
    interface = "org.freedesktop.NetworkManager.Settings",
    path = "/org/freedesktop/NetworkManager/Settings"
  }

  local client_properties_proxy = dbus_proxy.Proxy:new {
    bus = dbus_proxy.Bus.SYSTEM,
    name = "org.freedesktop.NetworkManager",
    interface = "org.freedesktop.DBus.Properties",
    path = "/org/freedesktop/NetworkManager"
  }

  client_properties_proxy:connect_signal("PropertiesChanged", function(self, interface, data)
    if data.WirelessEnabled ~= nil and ret._private.WirelessEnabled ~= data.WirelessEnabled then
      ret._private.WirelessEnabled = data.WirelessEnabled
      ret:emit_signal("wireless_state", data.WirelessEnabled)

      if data.WirelessEnabled == true then
        gtimer { timeout = 5, autostart = true, call_now = false, single_shot = true, callback = function()
          ret:scan_access_points()
        end }
      end
    end
  end)

  get_wifi_proxy(ret)
  ret:scan_access_points()

  gtimer.delayed_call(function()
    ret:emit_signal("wireless_state", ret._private.client_proxy.WirelessEnabled)

    local active_access_point = ret._private.wifi_proxy.ActiveAccessPoint
    if ret._private.device_proxy.State == network.DeviceState.ACTIVATED and active_access_point ~= "/" then
      local active_access_point_proxy = dbus_proxy.Proxy:new {
        bus = dbus_proxy.Bus.SYSTEM,
        name = "org.freedesktop.NetworkManager",
        interface = "org.freedesktop.NetworkManager.AccessPoint",
        path = active_access_point
      }

      local ssid = NM.utils_ssid_to_utf8(active_access_point_proxy.Ssid)
      ret:emit_signal("access_point::connected", ssid, active_access_point_proxy.Strength)
    end
  end)

  return ret
end

if not instance then
  instance = new()
end
return instance
