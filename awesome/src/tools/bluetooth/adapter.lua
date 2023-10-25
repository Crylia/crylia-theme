local setmetatable = setmetatable

local gtable = require('gears.table')
local gobject = require('gears.object')
local lgi = require('lgi')

local dbus_proxy = require('src.lib.lua-dbus_proxy.src.dbus_proxy')

local bluetooth = {}

function bluetooth:StartDiscovery()
  self.Adapter1:StartDiscovery()
  self:emit_signal('Bluetooth::DiscoveryStarted')
end

function bluetooth:StopDiscovery()
  self.Adapter1:StopDiscovery()
  self:emit_signal('Bluetooth::DiscoveryStopped')
end

function bluetooth:RemoveDevice(device)
  if not device then return end

  self.Adapter1:RemoveDevice(device)
end

function bluetooth:toggle_wifi()
  local powered = not self.Adapter1.Powered

  self.Adapter1:Set('org.bluez.Adapter1', 'Powered', lgi.GLib.Variant('b', powered))

  self.Adapter1.Powered = {
    signature = 'b',
    value = powered,
  }
end

return setmetatable(bluetooth, {
  __call = function(self)
    gtable.crush(self, gobject())

    self.ObjectManager = dbus_proxy.Proxy:new {
      bus = dbus_proxy.Bus.SYSTEM,
      name = 'org.bluez',
      interface = 'org.freedesktop.DBus.ObjectManager',
      path = '/',
    }

    self.Adapter1 = dbus_proxy.Proxy:new {
      bus = dbus_proxy.Bus.SYSTEM,
      name = 'org.bluez',
      interface = 'org.bluez.Adapter1',
      path = '/org/bluez/hci0',
    }

    self.Adapter1Properties = dbus_proxy.Proxy:new {
      bus = dbus_proxy.Bus.SYSTEM,
      name = 'org.bluez',
      interface = 'org.freedesktop.DBus.Properties',
      path = '/org/bluez/hci0',
    }

    self.Adapter1Properties:connect_signal(function(_, _, data)
      if data.Powered ~= nil then
        self:emit_signal('Bluetooth::Powered', data.Powered)
      end
    end, 'PropertiesChanged')

    self.ObjectManager:connect_signal(function(_, path)
      self:emit_signal('Bluetooth::DeviceAdded', path)
    end, 'InterfacesAdded')

    self.ObjectManager:connect_signal(function(_, path)
      self:emit_signal('Bluetooth::DeviceRemoved', path)
    end, 'InterfacesRemoved')

    setmetatable(self, {
      __index = function(_, key)
        if key == 'Powered' then
          return self.Adapter1.Powered
        elseif key == 'Alias' then
          return self.Adapter1.Alias
        elseif key == 'PowerState' then
          return self.Adapter1.PowerState
        end
      end,
    })

    return self
  end,
})
