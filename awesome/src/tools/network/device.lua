local dbus_proxy = require('src.lib.lua-dbus_proxy.src.dbus_proxy')
local gtable = require('gears.table')
local gobject = require('gears.object')

local access_point = require('src.tools.network.access_point')

local device = {}
device._private = {}
local WIRELESS = {}

device._private.DeviceType = {
  ETHERNET = 1,
  WIFI = 2,
}

device._private.DeviceState = {
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

function WIRELESS:IsApActive(ap)
  return self.NetworkManagerDeviceWireless.ActiveAccessPoint == ap.object_path
end

function WIRELESS:GetAllAccessPoints()
  return self.NetworkManagerDeviceWireless:GetAllAccessPoints()
end

--- If we scan we simply update the list that holds all access points
--- We can then get the list and create a new access point for all devices
---@param callback any
function WIRELESS:RequestScan(callback)
  local ap_list = {}
  self.NetworkManagerDeviceWireless:RequestScanAsync(function(_, _, _, failure)
    for _, value in ipairs(self.NetworkManagerDeviceWireless:GetAllAccessPoints()) do
      table.insert(ap_list, access_point(value))
    end
    callback(ap_list)
  end, { call_id = 'AMOGUS' }, {})
end

return setmetatable(device, {
  __call = function(_, device_path)
    local self = gobject {}
    gtable.crush(self, device, true)
    self.object_path = device_path
    self.NetworkManagerDevice = dbus_proxy.Proxy:new {
      bus = dbus_proxy.Bus.SYSTEM,
      name = 'org.freedesktop.NetworkManager',
      interface = 'org.freedesktop.NetworkManager.Device',
      path = device_path,
    }

    self.NetworkManagerDevice:connect_signal(function(_, new_state, reason)
      self:emit_signal('NetworkManagerDevice::StateChanged', new_state, reason)
    end, 'StateChanged')

    if self.NetworkManagerDevice.DeviceType == self._private.DeviceType.WIFI then
      gtable.crush(self, WIRELESS, true)

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
          self:emit_signal('NetworkManagerDeviceWireless::ActiveAccessPoint', self.current_ap, data.ActiveAccessPoint)
          self.current_ap = data.ActiveAccessPoint
        end
      end, 'PropertiesChanged')
      self.current_ap = self.NetworkManagerDeviceWireless.ActiveAccessPoint

      self.ap_list = {}
      self.NetworkManagerDeviceWireless:connect_signal(function(_, path)
        --check if path is already in list
        for _, value in ipairs(self.ap_list) do
          if value == path then
            return
          end
        end
        table.insert(self.ap_list, path)
        self:emit_signal('NetworkManagerDeviceWireless::AccessPointAdded', access_point(path))
      end, 'AccessPointAdded')

      self.NetworkManagerDeviceWireless:connect_signal(function(_, path)
        self:emit_signal('NetworkManagerDeviceWireless::AccessPointRemoved', path)
        for i, value in ipairs(self.ap_list) do
          if value == path then
            table.remove(self.ap_list, i)
            return
          end
        end
      end, 'AccessPointRemoved')

    elseif self.NetworkManagerDevice.DeviceType == self._private.DeviceType.ETHERNET then

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

    setmetatable(self, {
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
        elseif key == 'Speed' then
          if self.NetworkManagerDeviceWired then
            return self.NetworkManagerDeviceWired.Speed
          end
        elseif key == 'Managed' then
          return self.NetworkManagerDevice.Managed
        elseif key == 'ActiveConnection' then
          return self.NetworkManagerDevice.ActiveConnection
        end
      end,
    })

    return self
  end,
})
