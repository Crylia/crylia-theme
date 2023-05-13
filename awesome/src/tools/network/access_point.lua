local gtable = require('gears.table')
local gobject = require('gears.object')
local NM = require('lgi').NM

local dbus_proxy = require('src.lib.lua-dbus_proxy.src.dbus_proxy')

local instance = nil
if not instance then
  instance = setmetatable({}, {
    __call = function(_, device_path)
      local self = gobject {}
      self.object_path = device_path
      self.NetworkManagerAccessPoint = dbus_proxy.Proxy:new {
        bus = dbus_proxy.Bus.SYSTEM,
        name = 'org.freedesktop.NetworkManager',
        interface = 'org.freedesktop.NetworkManager.AccessPoint',
        path = device_path,
      }
      if not NM.utils_ssid_to_utf8(self.NetworkManagerAccessPoint.Ssid) then
        self.NetworkManagerAccessPoint = nil
        self = nil
        return nil
      end

      self.NetworkManagerAccessPointProperties = dbus_proxy.Proxy:new {
        bus = dbus_proxy.Bus.SYSTEM,
        name = 'org.freedesktop.NetworkManager',
        interface = 'org.freedesktop.DBus.Properties',
        path = device_path,
      }

      self.NetworkManagerAccessPointProperties:connect_signal(function(_, _, data)
        if data.Strength then
          self:emit_signal('NetworkManagerAccessPoint::Strength', data.Strength)
        elseif data.LastSeen then
          self:emit_signal('NetworkManagerAccessPoint::LastSeen', data.LastSeen)
        end
      end, 'PropertiesChanged')
      self:emit_signal('NetworkManagerAccessPoint::Strength', self.NetworkManagerAccessPoint.Strength)


      setmetatable(self, {
        __index = function(s, key)
          if key == 'SSID' then
            return NM.utils_ssid_to_utf8(s.NetworkManagerAccessPoint.Ssid)
          elseif key == 'Frequency' then
            return s.NetworkManagerAccessPoint.Frequency
          elseif key == 'MaxBitrate' then
            return s.NetworkManagerAccessPoint.MaxBitrate
          elseif key == 'HwAddress' then
            return s.NetworkManagerAccessPoint.HwAddress
          elseif key == 'Strength' then
            return s.NetworkManagerAccessPoint.Strength
          elseif key == 'Security' then
            local str = ''

            if s.Flags == 1 and s.WpaFlags == 0 and s.RsnFlags == 0 then
              str = str .. ' WEP'
            end
            if s.WpaFlags ~= 0 then
              str = str .. ' WPA1'
            end
            if not s.RsnFlags ~= 0 then
              str = str .. ' WPA2'
            end
            if s.WpaFlags == 512 or s.RsnFlags == 512 then
              str = str .. ' 802.1X'
            end

            return (str:gsub('^%s', ''))
          end
        end,
      })

      return self
    end,
  })
end
return instance
