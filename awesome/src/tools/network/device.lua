local lgi = require('lgi')
local NM = lgi.NM
local dbus_proxy = require('src.lib.lua-dbus_proxy.src.dbus_proxy')
local gtable = require('gears.table')
local gobject = require('gears.object')

local device = gobject {}
local WIRELESS = gobject {}


device.DeviceType = {
  ETHERNET = 1,
  WIFI = 2,
}

device.DeviceState = {
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

function WIRELESS:GetAllAccessPoints()
  return self.NetworkManagerDeviceWireless:GetAllAccessPoints()
end

function WIRELESS:RequestScan()
  --TODO: Are options needed? What do they do?
  self.NetworkManagerDeviceWireless:RequestScan {}
end

return setmetatable(device, {
  __call = function(self, device_path)
    self.NetworkManagerDevice = dbus_proxy.Proxy:new {
      bus = dbus_proxy.Bus.SYSTEM,
      name = 'org.freedesktop.NetworkManager',
      interface = 'org.freedesktop.NetworkManager.Device',
      path = device_path,
    }

    self.NetworkManagerDevice:connect_signal(function(_, new_state, reason)
      self:emit_signal('NetworkManagerDevice::StateChanged', new_state, reason)
    end, 'StateChanged')

    if self.NetworkManagerDevice.DeviceType == self.DeviceType.WIFI then

      gtable.crush(self, WIRELESS)

      self.NetworkManagerDeviceWireless = dbus_proxy.Proxy:new {
        bus = dbus_proxy.Bus.SYSTEM,
        name = 'org.freedesktop.NetworkManager',
        interface = 'org.freedesktop.NetworkManager.Device.Wireless',
        path = device_path,
      }
      self.NetworkManagerDeviceWirelessProperties = dbus_proxy.Proxy:new {
        bus = dbus_proxy.Bus.SYSTEM,
        name = 'org.freedesktop.NetworkManager',
        interface = 'org.freedesktop.DBus.Properties',
        path = device_path,
      }

      self.NetworkManagerDeviceWirelessProperties:connect_signal(function(_, _, data)
        if data.Birate then
          self:emit_signal('NetworkManagerDeviceWireless::Bitrate', data.Bitrate)
        end
        if data.ActiveAccessPoint then
          self.emit_signal('NetworkManagerDeviceWireless::ActiveAccessPoint', data.ActiveAccessPoint)
        end
      end, 'PropertiesChanged')

      self.NetworkManagerDeviceWireless:connect_signal(function(_, path)
        self:emit_signal('NetworkManagerDeviceWireless::AccessPointAdded', path)
      end, 'AccessPointAdded')

      self.NetworkManagerDeviceWireless:connect_signal(function(_, path)
        self:emit_signal('NetworkManagerDeviceWireless::AccessPointRemoved', path)
      end, 'AccessPointRemoved')

    elseif self.NetworkManagerDevice.DeviceType == self.DeviceType.ETHERNET then

      self.NetworkManagerDeviceWired = dbus_proxy.Proxy:new {
        bus = dbus_proxy.Bus.SYSTEM,
        name = 'org.freedesktop.NetworkManager',
        interface = 'org.freedesktop.NetworkManager.Device.Wired',
        path = device_path,
      }

      self:emit_signal('NetworkManagerDeviceWired::Speed', self._private.NetworkManagerDeviceWired.Speed)

      self.NetworkManagerDeviceWiredProperties = dbus_proxy.Proxy:new {
        bus = dbus_proxy.Bus.SYSTEM,
        name = 'org.freedesktop.NetworkManager',
        interface = 'org.freedesktop.DBus.Properties',
        path = device_path,
      }

      self.NetworkManagerDeviceWiredProperties:connect_signal(function(_, _, data)
        if data.Carrier then
          self:emit_signal('NetworkManagerDeviceWired::Carrier', data.Carrier)
        end
      end, 'PropertiesChanged')

    end
    return self
  end,
  __index = function(self, key)
    if key == 'DeviceType' then
      return self.NetworkManagerDevice.DeviceType
    elseif key == 'State' then
      return self.NetworkManagerDevice.State
    elseif key == 'StateReason' then
      return self.NetworkManagerDevice.StateReason
    elseif key == 'Bitrate' then
      if self.NetworkManagerDeviceWireless then
        return self.NetworkManagerDeviceWireless.Bitrate
      end
    elseif key == 'Managed' then
      return self.NetworkManagerDevice.Managed
    elseif key == 'ActiveConnection' then
      return self.NetworkManagerDevice.ActiveConnection
    end
  end,
})
