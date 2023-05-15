local lgi = require('lgi')
local gobject = require('gears.object')
local NM = require('lgi').NM

local dbus_proxy = require('src.lib.lua-dbus_proxy.src.dbus_proxy')

local nmdevice = require('src.tools.network.device')
local settings = require('src.tools.network.settings')

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

---Will try to connect to an access point by first searching if the connection already exists
--- and then adding the connection if its not.
---@param ap any
---@param connection any
---@param callback any
function network:ConnectToAccessPointAsync(ap, device, connection, callback)
  print(ap, connection)

  for path, value in pairs(self.NetworkManagerSettings.ConnectionList or {}) do
    print(--[[ connection.connection.id.value,  ]] ap.SSID, value:GetSettings().connection.id)
    if (connection and connection.connection.id.value or ap.SSID) == value:GetSettings().connection.id then
      if connection then
        value:Update(connection)
      end
      self.NetworkManager:ActivateConnectionAsync(function(_, _, succ, failure)
        print(failure, succ)
        if failure then
          callback(false)
          return
        else
          callback(true)
          return
        end
      end, { call_id = 'amogus' }, path, device.object_path, ap.object_path)
      return
    end
  end

  if not connection then
    callback(false)
    return
  end

  self.NetworkManager:AddAndActivateConnectionAsync(function(_, _, succ, fail)
    if fail then
      callback(false)
      return
    else
      callback(true)
      return
    end
  end, { call_id = 'amogus' }, connection, device.object_path, ap.object_path)

end

function network:DisconnectFromAP()
  self.NetworkManager:DeactivateConnection(self:get_wireless_device().ActiveConnection)
end

--TODO: Make sure this works, I don't know how its going
--TODO: to work if there were multiple wireless devices, probably try
--TODO: to find the one that is active or something like that
---Returns the current wifi device, if none if found returns the ethernet devie, else nil
---@return wifi|ethernet|nil device
function network:get_wireless_device()
  local ethernet_device = nil
  for _, device in pairs(self.Devices) do
    print(device.DeviceType, device.device_path)
    if device.DeviceType == self.DeviceType.WIFI then
      return device
    elseif device.DeviceType == self.DeviceType.ETHERNET then
      ethernet_device = device
    end
  end
  return ethernet_device
end

function network:get_devices()
  local devices = self.NetworkManager:GetDevices() or {}
  self.Devices = {}
  for _, device in ipairs(devices) do
    self.Devices[device] = nmdevice(device)
    self.Devices[device]:connect_signal('NetworkManagerDevice::StateChanged', function(_, s, r)
    end)
  end
end

function network:toggle_network()
  self.NetworkManager:Set('org.freedesktop.NetworkManager', 'NetworkingEnabled', lgi.GLib.Variant('b', not self.NetworkingEnabled))
end

function network:toggle_wifi()
  if self.NetworkingEnabled == false then
    self:toggle_network()
  end
  self.NetworkManager:Set('org.freedesktop.NetworkManager', 'WirelessEnabled', lgi.GLib.Variant('b', not self.WirelessEnabled))
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

      self.NetworkManagerSettings = settings()

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

      -- Init values because signal isn't emitted on startup
      self:emit_signal('NetworkManager::WirelessEnabled', self.NetworkManager.WirelessEnabled)
      self:emit_signal('NetworkManager::NetworkingEnabled', self.NetworkManager.NetworkingEnabled)
      self.WirelessEnabled = self.NetworkManager.WirelessEnabled
      self.NetworkingEnabled = self.NetworkManager.NetworkingEnabled


      self:get_devices()


      return self
    end,
  })
end
return instance
