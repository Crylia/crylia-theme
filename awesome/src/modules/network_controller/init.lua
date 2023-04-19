------------------------------------
-- This is the network controller --
------------------------------------

-- Awesome Libs
local abutton = require('awful.button')
local base = require('wibox.widget.base')
local dbus_proxy = require('src.lib.lua-dbus_proxy.src.dbus_proxy')
local beautiful = require('beautiful')
local dpi = require('beautiful').xresources.apply_dpi
local gcolor = require('gears.color')
local gfilesystem = require('gears.filesystem')
local gshape = require('gears.shape')
local gtable = require('gears.table')
local gtimer = require('gears.timer')
local lgi = require('lgi')
local NM = lgi.NM
local naughty = require('naughty')
local wibox = require('wibox')

-- Third party libs
local rubato = require('src.lib.rubato')
local hover = require('src.tools.hover')

-- Local libs
local access_point = require('src.modules.network_controller.access_point')
local dnd_widget = require('awful.widget.toggle_widget')

local icondir = gfilesystem.get_configuration_dir() .. 'src/assets/icons/network/'

local network = { mt = {} }

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

---Get the wifi and or ethernet proxy and connect to their PropertiesChanged signal
-- The signals will return the following
-- wifi: { "Bitrate", "Strength" }
-- ethernet: { "Carrier", "Speed" }
function network:get_active_device()
  --Get all devices
  local devices = self._private.NetworkManager:GetDevices()
  if (not devices) or (#devices == 0) then return end
  -- Loop trough every found device
  for _, path in ipairs(devices) do
    --Create a new proxy for every device
    local NetworkManagerDevice = dbus_proxy.Proxy:new {
      bus = dbus_proxy.Bus.SYSTEM,
      name = 'org.freedesktop.NetworkManager',
      interface = 'org.freedesktop.NetworkManager.Device',
      path = path,
    }

    --Check if the device is either a wifi or ethernet device, and if its activated
    -- if its activated then its currently in use
    if (NetworkManagerDevice.DeviceType == network.DeviceType.WIFI) and
        (NetworkManagerDevice.State == network.DeviceState.ACTIVATED) then
      -- Set the wifi device as the main device
      self._private.NetworkManagerDevice = NetworkManagerDevice
      --New wifi proxy to check the bitrate
      self._private.NetworkManagerDeviceWireless = dbus_proxy.Proxy:new {
        bus = dbus_proxy.Bus.SYSTEM,
        name = 'org.freedesktop.NetworkManager',
        interface = 'org.freedesktop.NetworkManager.Device.Wireless',
        path = path,
      }
      -- Watch PropertiesChanged and update the bitrate
      local NetworkManagerDeviceWirelessProperties = dbus_proxy.Proxy:new {
        bus = dbus_proxy.Bus.SYSTEM,
        name = 'org.freedesktop.NetworkManager',
        interface = 'org.freedesktop.DBus.Properties',
        path = self._private.NetworkManagerDeviceWireless.object_path,
      }

      NetworkManagerDeviceWirelessProperties:connect_signal(function(_, properties, data)
        if data.Bitrate then
          self:emit_signal('NM::Bitrate', data.Bitrate)
        end
      end, 'PropertiesChanged')
      -- Watch the StateChanged signal, update and notify when a new AP is connected
      self._private.NetworkManagerDevice:connect_signal(function(proxy, new_state)
        local NetworkManagerAccessPoint = dbus_proxy.Proxy:new {
          bus = dbus_proxy.Bus.SYSTEM,
          name = 'org.freedesktop.NetworkManager',
          interface = 'org.freedesktop.NetworkManager.AccessPoint',
          path = self._private.NetworkManagerDeviceWireless.ActiveAccessPoint,
        }

        if new_state == network.DeviceState.ACTIVATED then
          local ssid = NM.utils_ssid_to_utf8(NetworkManagerAccessPoint.Ssid)
          self:emit_signal('NM::AccessPointConnected', ssid, NetworkManagerAccessPoint.Strength)
        end
      end, 'StateChanged')

    elseif (NetworkManagerDevice.DeviceType == network.DeviceType.ETHERNET) and
        (NetworkManagerDevice.State == network.DeviceState.ACTIVATED) then
      self._private.NetworkManagerDevice = NetworkManagerDevice
      self._private.NetworkManagerDeviceWired = dbus_proxy.Proxy:new {
        bus = dbus_proxy.Bus.SYSTEM,
        name = 'org.freedesktop.NetworkManager',
        interface = 'org.freedesktop.NetworkManager.Device.Wired',
        path = path,
      }
      if self._private.NetworkManagerDevice.State == network.DeviceState.ACTIVATED then
        awesome.emit_signal('NM::EthernetStatus', true, self._private.NetworkManagerDeviceWired.Speed)
      end
      -- Connect to the StateChanged signal and notify when the wired connection is ready
      self._private.NetworkManagerDevice:connect_signal(function(_, new_state)
        if new_state == network.DeviceState.ACTIVATED then
          awesome.emit_signal('NM::EthernetStatus', true, self._private.NetworkManagerDeviceWired.Speed)
        elseif new_state == network.DeviceState.DISCONNECTED then
          awesome.emit_signal('NM::EthernetStatus', false)
        end
      end, 'StateChanged')
    end
  end
end

function network:get_active_ap_ssid()
  local d = dbus_proxy.Proxy:new {
    bus = dbus_proxy.Bus.SYSTEM,
    name = 'org.freedesktop.NetworkManager',
    interface = 'org.freedesktop.NetworkManager.Device.Wireless',
    path = self._private.NetworkManagerDeviceWireless.ActiveAccessPoint,
  }

  return NM.utils_ssid_to_utf8(d.Ssid)
end

---Scan for access points and create a widget for each one.
function network:scan_access_points()
  if not self._private.NetworkManagerDeviceWireless then return end
  local ap_list = self:get_children_by_id('wifi_ap_list')[1]
  ap_list:reset()
  local ap_table = {}
  self._private.NetworkManagerDeviceWireless:RequestScanAsync(function(_, _, _, failure)
    if failure then
      naughty.notification {
        app_icon = icondir .. 'ethernet.svg',
        app_name = 'Network Manager',
        title = 'Error: Scan failed!',
        message = 'Failed to scan for access points.\n' .. failure,
        icon = gcolor.recolor_image(icondir .. 'ethernet.svg', beautiful.colorscheme.bg),
        timeout = 5,
      }
      return
    end

    -- Get every access point even those who hide their ssid
    for _, ap in ipairs(self._private.NetworkManagerDeviceWireless:GetAllAccessPoints()) do
      -- Create a new proxy for every ap
      local NetworkManagerAccessPoint = dbus_proxy.Proxy:new {
        bus = dbus_proxy.Bus.SYSTEM,
        name = 'org.freedesktop.NetworkManager',
        interface = 'org.freedesktop.NetworkManager.AccessPoint',
        path = ap,
      }

      -- We are only interested in those with a ssid
      if NM.utils_ssid_to_utf8(NetworkManagerAccessPoint.Ssid) and NetworkManagerAccessPoint.Strength then
        if (ap_table[NetworkManagerAccessPoint.Ssid] == nil) or
            NetworkManagerAccessPoint.Strength > ap_table[NetworkManagerAccessPoint.Ssid].Strength then
          ap_table[NetworkManagerAccessPoint.Ssid] = NetworkManagerAccessPoint
        end
      end
    end

    --sort ap_table first by strength
    local sorted_ap_table = {}
    for _, NetworkManagerAccessPoint in pairs(ap_table) do
      table.insert(sorted_ap_table, NetworkManagerAccessPoint)
    end
    --sort the table by strength but have the active_ap at the top
    table.sort(sorted_ap_table, function(a, b)
      if a.object_path == self._private.NetworkManagerDeviceWireless.ActiveAccessPoint then
        return true
      else
        return a.Strength > b.Strength
      end
    end)
    for _, NetworkManagerAccessPoint in ipairs(sorted_ap_table) do
      ap_list:add(access_point {
        NetworkManagerAccessPoint = NetworkManagerAccessPoint,
        NetworkManagerDevice = self._private.NetworkManagerDevice,
        NetworkManagerSettings = self._private.NetworkManagerSettings,
        NetworkManager = self._private.NetworkManager,
        NetworkManagerDeviceWireless = self._private.NetworkManagerDeviceWireless,
      })
    end
  end, { call_id = 'my-id' }, {})
end

---Toggles networking on or off
function network:toggle_wifi()
  local enable = not self._private.NetworkManager.WirelessEnabled
  self._private.NetworkManager:Set('org.freedesktop.NetworkManager', 'WirelessEnabled', lgi.GLib.Variant('b', enable))
  self._private.NetworkManager.WirelessEnabled = { signature = 'b', value = enable }
end

function network.new(args)
  args = args or {}

  local ret = base.make_widget_from_value(wibox.widget {
    {
      {
        {
          {
            {
              {
                {
                  {
                    resize = false,
                    image = gcolor.recolor_image(icondir .. 'menu-down.svg',
                      beautiful.colorscheme.bg_red),
                    widget = wibox.widget.imagebox,
                    valign = 'center',
                    halign = 'center',
                    id = 'icon',
                  },
                  id = 'center',
                  halign = 'center',
                  valign = 'center',
                  widget = wibox.container.place,
                },
                {
                  {
                    text = 'Wifi Networks',
                    widget = wibox.widget.textbox,
                    id = 'ap_name',
                  },
                  margins = dpi(5),
                  widget = wibox.container.margin,
                },
                id = 'wifi',
                layout = wibox.layout.fixed.horizontal,
              },
              id = 'wifi_bg',
              bg = beautiful.colorscheme.bg1,
              fg = beautiful.colorscheme.bg_red,
              shape = beautiful.shape[4],
              widget = wibox.container.background,
            },
            id = 'wifi_margin',
            widget = wibox.container.margin,
          },
          {
            id = 'wifi_list',
            {
              {
                step = dpi(50),
                spacing = dpi(10),
                layout = require('src.lib.overflow_widget.overflow').vertical,
                scrollbar_width = 0,
                id = 'wifi_ap_list',
              },
              id = 'margin',
              margins = dpi(10),
              widget = wibox.container.margin,
            },
            border_color = beautiful.colorscheme.border_color,
            border_width = dpi(2),
            shape = function(cr, width, height)
              gshape.partially_rounded_rect(cr, width, height, false, false, true, true, dpi(4))
            end,
            widget = wibox.container.background,
            forced_height = 0,
          },
          {
            { -- action buttons
              {
                dnd_widget {
                  color = beautiful.colorscheme.bg_red,
                  size = dpi(40),
                },
                id = 'dnd',
                widget = wibox.container.place,
                valign = 'center',
                halign = 'center',
              },
              nil,
              { -- refresh
                {
                  {
                    image = gcolor.recolor_image(icondir .. 'refresh.svg',
                      beautiful.colorscheme.bg_red),
                    resize = false,
                    valign = 'center',
                    halign = 'center',
                    widget = wibox.widget.imagebox,
                    id = 'icon',
                  },
                  widget = wibox.container.margin,
                  margins = dpi(5),
                  id = 'center',
                },
                border_width = dpi(2),
                border_color = beautiful.colorscheme.border_color,
                shape = beautiful.shape[4],
                bg = beautiful.colorscheme.bg,
                widget = wibox.container.background,
                id = 'refresh',
              },
              layout = wibox.layout.align.horizontal,
            },
            widget = wibox.container.margin,
            top = dpi(10),
            id = 'action_buttons',
          },
          id = 'layout1',
          layout = wibox.layout.fixed.vertical,
        },
        id = 'margin',
        margins = dpi(15),
        widget = wibox.container.margin,
      },
      shape = beautiful.shape[8],
      border_color = beautiful.colorscheme.border_color,
      border_width = dpi(2),
      bg = beautiful.colorscheme.bg,
      id = 'background',
      widget = wibox.container.background,
    },
    width = dpi(400),
    strategy = 'exact',
    widget = wibox.container.constraint,
  })

  assert(type(ret) == 'table', 'NetworkManager is not running')

  local dnd = ret:get_children_by_id('dnd')[1]:get_widget()

  dnd:connect_signal('dnd::toggle', function(enable)
    ret:toggle_wifi()
  end)

  gtable.crush(ret, network, true)

  --#region Wifi Proxies

  ret._private.NetworkManager = dbus_proxy.Proxy:new {
    bus = dbus_proxy.Bus.SYSTEM,
    name = 'org.freedesktop.NetworkManager',
    interface = 'org.freedesktop.NetworkManager',
    path = '/org/freedesktop/NetworkManager',
  }

  ret._private.NetworkManagerSettings = dbus_proxy.Proxy:new {
    bus = dbus_proxy.Bus.SYSTEM,
    name = 'org.freedesktop.NetworkManager',
    interface = 'org.freedesktop.NetworkManager.Settings',
    path = '/org/freedesktop/NetworkManager/Settings',
  }

  ret._private.NetworkManagerProperties = dbus_proxy.Proxy:new {
    bus = dbus_proxy.Bus.SYSTEM,
    name = 'org.freedesktop.NetworkManager',
    interface = 'org.freedesktop.DBus.Properties',
    path = '/org/freedesktop/NetworkManager',
  }

  ret._private.NetworkManagerProperties:connect_signal(function(_, properties, data)
    if data.WirelessEnabled ~= nil and ret._private.WirelessEnabled ~= data.WirelessEnabled then
      ret._private.WirelessEnabled = data.WirelessEnabled

      if ret._private.WirelessEnabled then
        dnd:set_enabled()
      else
        dnd:set_disabled()
      end

      ret:emit_signal('NetworkManager::status', ret._private.WirelessEnabled)

      if data.WirelessEnabled then
        gtimer {
          timeout = 5,
          autostart = true,
          call_now = false,
          single_shot = true,
          callback = function()
            ret:scan_access_points()
          end,
        }
      end
    end
  end, 'PropertiesChanged')

  ret:get_active_device()

  ret:scan_access_points()

  if ret._private.NetworkManager.WirelessEnabled then
    dnd:set_enabled()
  else
    dnd:set_disabled()
  end

  --#endregion

  --#region Dropdown logic
  local wifi_margin = ret:get_children_by_id('wifi_margin')[1]
  local wifi_list = ret:get_children_by_id('wifi_list')[1]
  local wifi = ret:get_children_by_id('wifi')[1].center

  local rubato_timer = rubato.timed {
    duration = 0.2,
    pos = wifi_list.forced_height,
    easing = rubato.linear,
    subscribed = function(v)
      wifi_list.forced_height = v
    end,
  }

  wifi_margin:buttons(gtable.join(
    abutton({}, 1, nil,
      function()
        if wifi_list.forced_height == 0 then
          if not ret:get_children_by_id('wifi_ap_list')[1].children then
            return
          end
          local size = (5 * 49) + 1

          size = size > 210 and 210 or size

          rubato_timer.target = dpi(size)
          wifi_margin.wifi_bg.shape = function(cr, width, height)
            gshape.partially_rounded_rect(cr, width, height, true, true, false, false, dpi(4))
          end
          wifi.icon:set_image(gcolor.recolor_image(icondir .. 'menu-up.svg',
            beautiful.colorscheme.bg_red))
        else
          rubato_timer.target = 0
          wifi_margin.wifi_bg.shape = function(cr, width, height)
            gshape.partially_rounded_rect(cr, width, height, true, true, true, true, dpi(4))
          end
          wifi.icon:set_image(gcolor.recolor_image(icondir .. 'menu-down.svg',
            beautiful.colorscheme.bg_red))
        end
      end
    )
  ))
  hover.bg_hover { widget = wifi_margin.wifi_bg }
  --#endregion

  local refresh_button = ret:get_children_by_id('refresh')[1]
  refresh_button:buttons(gtable.join(
    abutton({}, 1, nil, function()
      ret:scan_access_points()
    end)
  ))
  hover.bg_hover { widget = refresh_button }

  return ret
end

function network.mt:__call(...)
  return network.new(...)
end

return setmetatable(network, network.mt)
