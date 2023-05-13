local gobject = require('gears.object')
local gtable = require('gears.table')
local lgi = require('lgi')
local NM = require('lgi').NM

local dbus_proxy = require('src.lib.lua-dbus_proxy.src.dbus_proxy')

local settings = gobject {}

---Get a connection path by uuid
---@param uuid string
---@return string connection_path
function settings:GetConnectionByUUID(uuid)
  return self.NetworkManagerSettings:GetConnectionByUuid(uuid) or ''
end

function settings:GetConnectionForSSID(ssid)
  for _, con in pairs(self.ConnectionList) do
    if con:GetSettings().connection.id == ssid then
      return con
    end
  end
end

--! For some reason not working, using AddAndActivateConnection instead works and adds the connection just fine
---Tries to add a new connection to the connections and returns the path if successfull
---@param con table connection
---@return string?
function settings:AddConnection(con)
  --[[ local c = dbus_proxy.Proxy:new {
    bus = dbus_proxy.Bus.SYSTEM,
    name = 'org.freedesktop.NetworkManager',
    interface = 'org.freedesktop.NetworkManager.Settings.Connection',
    path = '/org/freedesktop/NetworkManager/Settings/',
  } ]]

  --[[ c:Update(con)
  print('No Problem')
  print(c:GetSettings().connection.id) ]]
  --local path = self.NetworkManagerSettings:AddConnection(con)
  --print(path)
  --return path
end

function settings:RemoveConnection(con)
  if not con then return end

  con:Delete()
end

---Returns a new and valid connection table
---@param args {passwd: string, security: string, autoconnect: boolean, ssid: string}
---@return table
function settings:NewConnectionProfile(args)
  local security = {}

  if args.security:match('WPA') then
    security = {
      ['key-mgmt'] = lgi.GLib.Variant('s', 'wpa-psk'),
      ['auth-alg'] = lgi.GLib.Variant('s', 'open'),
      ['psk'] = lgi.GLib.Variant('s', args.passwd),
    }
  else
    security = {
      ['key-mgmt'] = lgi.GLib.Variant('s', 'wpa-psk'),
      ['wep-key-type'] = lgi.GLib.Variant('s', NM.WepKeyType.PASSPHRASE),
      ['wep-key0'] = lgi.GLib.Variant('s', args.passwd),
    }
  end

  return {
    ['connection'] = {
      ['uuid'] = lgi.GLib.Variant('s', string.gsub('xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx', '[xy]', function(c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
      end)),
      ['id'] = lgi.GLib.Variant('s', args.ssid),
      ['type'] = lgi.GLib.Variant('s', '802-11-wireless'),
      ['autoconnect'] = lgi.GLib.Variant('b', args.autoconnect),
    },
    ['ipv4'] = {
      ['method'] = lgi.GLib.Variant('s', 'auto'),
    },
    ['ipv6'] = {
      ['method'] = lgi.GLib.Variant('s', 'auto'),
    },
    ['802-11-wireless'] = {
      ['mode'] = lgi.GLib.Variant('s', 'infrastructure'),
    },
    ['802-11-wireless-security'] = security,
  }
end

local instance = nil
if not instance then
  instance = setmetatable(settings, {
    __call = function(self)
      self.NetworkManagerSettings = dbus_proxy.Proxy:new {
        bus = dbus_proxy.Bus.SYSTEM,
        name = 'org.freedesktop.NetworkManager',
        interface = 'org.freedesktop.NetworkManager.Settings',
        path = '/org/freedesktop/NetworkManager/Settings',
      }

      self.ConnectionList = {}
      for _, value in pairs(self.NetworkManagerSettings:ListConnections()) do
        local c = dbus_proxy.Proxy:new {
          bus = dbus_proxy.Bus.SYSTEM,
          name = 'org.freedesktop.NetworkManager',
          interface = 'org.freedesktop.NetworkManager.Settings.Connection',
          path = value,
        }
        if c then self.ConnectionList[value] = c end
      end

      self.NetworkManagerSettings:connect_signal(function(_, con)
        print('New!', con)
        local c = dbus_proxy.Proxy:new {
          bus = dbus_proxy.Bus.SYSTEM,
          name = 'org.freedesktop.NetworkManager',
          interface = 'org.freedesktop.NetworkManager.Settings.Connection',
          path = con,
        }
        self.ConnectionList[con] = c
      end, 'NewConnection')

      self.NetworkManagerSettings:connect_signal(function(_, con)
        print('Removed!', con)
        self.ConnectionList[con] = nil
      end, 'ConnectionRemoved')

      return self
    end,
  })
end
return instance
