local lgi = require('lgi')
local gobject = require('gears.object')

local dbus_proxy = require('src.lib.lua-dbus_proxy.src.dbus_proxy')

local nmdevice = require('src.tools.network.device')

local network = gobject {}

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
  WIFI = 2,
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
  FAILED = 120,
}

function network:toggle_network()
  self._private.NetworkManager:Set('org.freedesktop.NetworkManager', 'NetworkingEnabled', lgi.GLib.Variant('b', not self.NetworkingEnabled))
end

function network:get_active_device()
  for path, device in pairs(self.Devices) do
    print(device.ActiveConnection, path)
    if device.State == self.DeviceState.ACTIVATED then
      print(device, path)
    else
      print('no active device')
    end
  end
end

function network:get_devices()
  local devices = self.NetworkManager:GetDevices() or {}
  self.Devices = {}
  for _, device in ipairs(devices) do
    self.Devices[device] = nmdevice(device)
    self.Devices[device]:connect_signal('NetworkManagerDevice::StateChanged', function(_, s, r)
      print(device, s, r)
    end)
  end
end

function network:toggle_wifi()
  if not self.NetworkingEnabled then
    self:toggle_network()
  end
  self._private.NetworkManager:Set('org.freedesktop.NetworkManager', 'WirelessEnabled', lgi.GLib.Variant('b', not self.NetworkingEnabled))
end

local instance = nil
if not instance then
  instance = setmetatable(network, {
    __call = function(self)
      self.NetworkManager = dbus_proxy.Proxy:new {
        bus = dbus_proxy.Bus.SYSTEM,
        name = 'org.freedesktop.NetworkManager',
        interface = 'org.freedesktop.NetworkManager',
        path = '/org/freedesktop/NetworkManager',
      }

      self.NetworkManagerProperties = dbus_proxy.Proxy:new {
        bus = dbus_proxy.Bus.SYSTEM,
        name = 'org.freedesktop.NetworkManager',
        interface = 'org.freedesktop.DBus.Properties',
        path = '/org/freedesktop/NetworkManager',
      }

      self.NetworkManagerSettings = dbus_proxy.Proxy:new {
        bus = dbus_proxy.Bus.SYSTEM,
        name = 'org.freedesktop.NetworkManager',
        interface = 'org.freedesktop.NetworkManager.Settings',
        path = '/org/freedesktop/NetworkManager/Settings',
      }

      self.NetworkManager:connect_signal(function(_, device_path)
        if device_path then
          self:emit_signal('NetworkManager::DeviceAdded', device_path)
        end
      end, 'DeviceAdded')

      self.NetworkManager:connect_signal(function(_, device_path)
        if device_path then
          self:emit_signal('NetworkManager::DeviceRemoved', device_path)
        end
      end, 'DeviceRemoved')

      self.NetworkManagerProperties:connect_signal(function(_, _, data)
        if data.WirelessEnabled ~= nil then
          self.WirelessEnabled = data.WirelessEnabled
          self:emit_signal('NetworkManager::WirelessEnabled', data.WirelessEnabled)
        end
        if data.NetworkingEnabled ~= nil then
          self.NetworkingEnabled = data.NetworkingEnabled
          self:emit_signal('NetworkManager::NetworkingEnabled', data.NetworkingEnabled)
        end
      end, 'PropertiesChanged')

      self:get_devices()
      self:get_active_device()
    end,
  })
end
return instance
