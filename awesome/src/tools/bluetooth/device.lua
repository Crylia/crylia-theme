local setmetatable = setmetatable

local gtable = require('gears.table')
local gobject = require('gears.object')
local lgi = require('lgi')

local dbus_proxy = require('src.lib.lua-dbus_proxy.src.dbus_proxy')

local device = {}

function device:Connect()
  self.Device1:ConnectAsync()
end

function device:Disconnect()
  self.Device1:DisconnectAsync()
end

function device:Pair()
  self.AgentManager1:RegisterAgent(self.Agent1.object_path, 'KeyboardDisplay')
  self.Device1:PairAsync()
end

function device:CancelPair()
  self.Device1:CancelPairAsync()
end

function device:Rename(newname)
  self.Device1:Set('org.bluez.Device1', 'Alias', lgi.GLib.Variant('s', newname))
  self.Device1.Alias = { signature = 's', value = newname }
  return self.Device1:Get('org.bluez.Device1', 'Alias')
end

function device:ToggleTrusted()
  local trusted = not self.Device1.Trusted
  self.Device1:Set('org.bluez.Device1', 'Trusted', lgi.GLib.Variant('b', trusted))
  self.Device1.Trusted = { signature = 'b', value = trusted }
end

return setmetatable(device, {
  __call = function(_, path)
    if not path then return end
    local self = gobject {}
    gtable.crush(self, device, true)

    self.Device1 = dbus_proxy.Proxy:new {
      bus = dbus_proxy.Bus.SYSTEM,
      name = 'org.bluez',
      interface = 'org.bluez.Device1',
      path = path,
    }
    if not self.Device1 then return end

    self.Agent1 = dbus_proxy.Proxy:new {
      bus = dbus_proxy.Bus.SYSTEM,
      name = 'org.bluez',
      interface = 'org.bluez.Agent1',
      path = '/org/bluez/agent',
    }

    self.AgentManager1 = dbus_proxy.Proxy:new {
      bus = dbus_proxy.Bus.SYSTEM,
      name = 'org.bluez',
      interface = 'org.bluez.AgentManager1',
      path = '/org/bluez',
    }

    setmetatable(self, {
      __index = function(_, key)
        if key == 'Alias' then
          return self.Device1.Alias
        elseif key == 'Icon' then
          return self.Device1.Icon
        elseif key == 'Paired' then
          return self.Device1.Paired
        elseif key == 'Connected' then
          return self.Device1.Connected
        elseif key == 'Trusted' then
          return self.Device1.Trusted
        elseif key == 'RSSI' then
          return self.Device1.RSSI
        end
      end,
    })

    return self
  end,
})
