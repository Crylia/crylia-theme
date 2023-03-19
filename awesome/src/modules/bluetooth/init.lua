--------------------------------------
-- This is the bluetooth controller --
--------------------------------------

-- Awesome Libs
local abutton = require('awful.button')
local aspawn = require('awful.spawn')
local base = require('wibox.widget.base')
local dbus_proxy = require('src.lib.lua-dbus_proxy.src.dbus_proxy')
local dpi = require('beautiful').xresources.apply_dpi
local gcolor = require('gears').color
local gfilesystem = require('gears').filesystem
local gshape = require('gears').shape
local gtable = require('gears').table
local gtimer = require('gears.timer')
local lgi = require('lgi')
local naughty = require('naughty')
local wibox = require('wibox')

-- Third party libs
local rubato = require('src.lib.rubato')
local hover = require('src.tools.hover')

-- Own libs
local bt_device = require('src.modules.bluetooth.device')
local dnd_widget = require('awful.widget.toggle_widget')

local icondir = gfilesystem.get_configuration_dir() .. 'src/assets/icons/bluetooth/'

local capi = {
  awesome = awesome,
  mouse = mouse,
  mousegrabber = mousegrabber,
}

local bluetooth = { mt = {} }

--#region wibox.widget.base boilerplate

function bluetooth:layout(_, width, height)
  if self._private.widget then
    return { base.place_widget_at(self._private.widget, 0, 0, width, height) }
  end
end

function bluetooth:fit(context, width, height)
  local w, h = 0, 0
  if self._private.widget then
    w, h = base.fit_widget(self, context, self._private.widget, width, height)
  end
  return w, h
end

bluetooth.set_widget = base.set_widget_common

function bluetooth:get_widget()
  return self._private.widget
end

--#endregion

---Get the list of paired devices
---@return table devices table of paired devices
function bluetooth:get_paired_devices()
  return self:get_children_by_id('connected_device_list')[1].children
end

---Get the list of discovered devices
---@return table devices table of discovered devices
function bluetooth:get_discovered_devices()
  return self:get_children_by_id('discovered_device_list')[1].children
end

--- Remove a device by first disconnecting it async then removing it
function bluetooth:remove_device_information(device)
  device:DisconnectAsync(function(_, _, out, err)
    self._private.Adapter1:RemoveDevice(device.object_path)
  end)
end

--- Add a new device into the devices list
function bluetooth:add_device(device, object_path)

  -- Get a reference to both lists
  local plist = self:get_children_by_id('connected_device_list')[1]
  local dlist = self:get_children_by_id('discovered_device_list')[1]

  -- For the first list check if the device already exists and if its connection state changed
  -- if it changed then remove it from the current list and put it into the other one
  for _, value in pairs(dlist.children) do
    -- I'm not sure why Connected is in both cases true when its a new connection but eh just take it, it works
    if value.device.Address:match(device.Address) and (device.Connected ~= value.device.Connected) then
      return
    elseif value.device.Address:match(device.Address) and (device.Connected == value.device.Connected) then
      dlist:remove_widgets(value)
      plist:add(plist:add(bt_device {
        device = device,
        path = object_path,
        remove_callback = function()
          self:remove_device_information(device)
        end,
      }))
      return;
    end
  end
  -- Just check if the device already exists in the list
  for _, value in pairs(plist.children) do
    if value.device.Address:match(device.Address) then return end
  end

  -- If its paired add it to the paired list
  -- else add it to the discovered list
  if device.Paired then
    plist:add(bt_device {
      device = device,
      path = object_path,
      remove_callback = function()
        self:remove_device_information(device)
      end,
    })
    self:emit_signal('device::added_connected')
  else
    dlist:add(bt_device {
      device = device,
      path = object_path,
      remove_callback = function()
        self:remove_device_information(device)
      end,
    })
    self:emit_signal('device::added_discovered')
  end
end

---Remove a device from any list
---@param object_path string the object path of the device
function bluetooth:remove_device(object_path)
  local plist = self:get_children_by_id('connected_device_list')[1]
  local dlist = self:get_children_by_id('discovered_device_list')[1]
  for _, d in ipairs(dlist.children) do
    if d.device.object_path == object_path then
      dlist:remove_widgets(d)
      self:emit_signal('device::removed_discovered')
    end
  end
  for _, d in ipairs(plist.children) do
    if d.device.object_path == object_path and (not d.device.Paired) then
      plist:remove_widgets(d)
      self:emit_signal('device::removed_connected')
    end
  end
end

---Start scanning for devices
function bluetooth:scan()
  self._private.Adapter1:StartDiscovery()
end

---Stop scanning for devices
function bluetooth:stop_scan()
  self._private.Adapter1:StopDiscovery()
end

---Toggle bluetooth on or off
function bluetooth:toggle()
  local powered = self._private.Adapter1.Powered

  self._private.Adapter1:Set('org.bluez.Adapter1', 'Powered', lgi.GLib.Variant('b', not powered))
  self._private.Adapter1.Powered = {
    signature = 'b',
    value = not powered,
  }
end

--- Open blueman-manager
function bluetooth:open_settings()
  aspawn('blueman-manager')
end

---Get a new device proxy and connect a PropertyChanged signal to it and
---add the device to the list
---@param object_path string the object path of the device
function bluetooth:get_device_info(object_path)
  if (not object_path) or (not object_path:match('/org/bluez/hci0/dev')) then return end

  -- New Device1 proxy
  local Device1 = dbus_proxy.Proxy:new {
    bus = dbus_proxy.Bus.SYSTEM,
    name = 'org.bluez',
    interface = 'org.bluez.Device1',
    path = object_path,
  }

  -- New Properties proxy for the object_path
  local Device1Properties = dbus_proxy.Proxy:new {
    bus = dbus_proxy.Bus.SYSTEM,
    name = 'org.bluez',
    interface = 'org.freedesktop.DBus.Properties',
    path = object_path,
  }

  -- Just return if the Device1 has no name, this usually means random devices with just a mac address
  if (not Device1.Name) or (Device1.Name == '') then return end

  -- For some reason it notifies twice or thrice
  local just_notified = false

  local notify_timer = gtimer {
    timeout = 3,
    autostart = false,
    single_shot = true,
    callback = function()
      just_notified = false
    end,
  }

  -- Connect the PropertyChanged signal to update the device when a property changes and send a notification
  Device1Properties:connect_signal(function(_, _, changed_props)
    if changed_props['Connected'] ~= nil then
      if not just_notified then
        naughty.notification {
          app_icon = icondir .. 'bluetooth-on.svg',
          app_name = 'Bluetooth',
          title = Device1.Name,
          icon = icondir .. Device1.Icon .. '.svg',
          timeout = 5,
          message = 'Device ' ..
              Device1.Name .. ' is now ' .. (changed_props['Connected'] and 'connected' or 'disconnected'),
          category = Device1.Connected and 'device.added' or 'device.removed',
        }
        just_notified = true
        notify_timer:start()
      end
    end
    capi.awesome.emit_signal(object_path .. '_updated', Device1)
  end, 'PropertiesChanged')

  self:add_device(Device1, object_path)
end

---Send a notification
---@param powered boolean the powered state of the adapter
local function send_state_notification(powered)
  naughty.notification {
    app_icon = icondir .. 'bluetooth-on.svg',
    app_name = 'Bluetooth',
    title = 'Bluetooth',
    message = powered and 'Enabled' or 'Disabled',
    icon = powered and icondir .. 'bluetooth-on.svg' or icondir .. 'bluetooth-off.svg',
    category = powered and 'device.added' or 'device.removed',
  }
end

function bluetooth.new(args)
  args = args or {}

  -- For some reason the first widget isn't read so the first container is a duplicate
  local ret = base.make_widget_from_value {
    {
      {
        {
          {
            {
              {
                resize = false,
                image = gcolor.recolor_image(icondir .. 'menu-down.svg',
                  Theme_config.bluetooth_controller.connected_icon_color),
                widget = wibox.widget.imagebox,
                valign = 'center',
                halign = 'center',
                id = 'connected_icon',
              },
              {
                {
                  text = 'Paired Devices',
                  valign = 'center',
                  halign = 'center',
                  widget = wibox.widget.textbox,
                },
                margins = dpi(5),
                widget = wibox.container.margin,
              },
              layout = wibox.layout.fixed.horizontal,
            },
            bg = Theme_config.bluetooth_controller.connected_bg,
            fg = Theme_config.bluetooth_controller.connected_fg,
            shape = Theme_config.bluetooth_controller.connected_shape,
            widget = wibox.container.background,
            id = 'connected_bg',
          },
          id = 'connected_margin',
          widget = wibox.container.margin,
        },
        {
          {
            {
              {
                step = dpi(50),
                spacing = dpi(10),
                layout = require('src.lib.overflow_widget.overflow').vertical,
                scrollbar_width = 0,
                id = 'connected_device_list',
              },
              id = 'margin',
              margins = dpi(10),
              widget = wibox.container.margin,
            },
            border_color = Theme_config.bluetooth_controller.con_device_border_color,
            border_width = Theme_config.bluetooth_controller.con_device_border_width,
            shape = Theme_config.bluetooth_controller.con_device_shape,
            widget = wibox.container.background,
          },
          widget = wibox.container.constraint,
          strategy = 'exact',
          height = 0,
          id = 'connected_list',
        },
        {
          {
            {
              {
                resize = false,
                image = gcolor.recolor_image(icondir .. 'menu-down.svg',
                  Theme_config.bluetooth_controller.discovered_icon_color),
                widget = wibox.widget.imagebox,
                valign = 'center',
                halign = 'center',
                id = 'discovered_icon',
              },
              {
                {
                  text = 'Nearby Devices',
                  valign = 'center',
                  halign = 'center',
                  widget = wibox.widget.textbox,
                },
                margins = dpi(5),
                widget = wibox.container.margin,
              },
              layout = wibox.layout.fixed.horizontal,
            },
            id = 'discovered_bg',
            bg = Theme_config.bluetooth_controller.discovered_bg,
            fg = Theme_config.bluetooth_controller.discovered_fg,
            shape = Theme_config.bluetooth_controller.discovered_shape,
            widget = wibox.container.background,
          },
          id = 'discovered_margin',
          top = dpi(10),
          widget = wibox.container.margin,
        },
        {
          {
            {
              id = 'discovered_device_list',
              spacing = dpi(10),
              step = dpi(50),
              layout = require('src.lib.overflow_widget.overflow').vertical,
              scrollbar_width = 0,
            },
            margins = dpi(10),
            widget = wibox.container.margin,
          },
          border_color = Theme_config.bluetooth_controller.con_device_border_color,
          border_width = Theme_config.bluetooth_controller.con_device_border_width,
          shape = Theme_config.bluetooth_controller.con_device_shape,
          widget = wibox.container.background,
          forced_height = 0,
          id = 'discovered_list',
        },
        {
          { -- action buttons
            {
              dnd_widget {
                color = Theme_config.bluetooth_controller.power_bg,
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
                    Theme_config.bluetooth_controller.refresh_icon_color),
                  resize = false,
                  valign = 'center',
                  halign = 'center',
                  widget = wibox.widget.imagebox,
                },
                widget = wibox.container.margin,
                margins = dpi(5),
              },
              shape = Theme_config.bluetooth_controller.refresh_shape,
              bg = Theme_config.bluetooth_controller.refresh_bg,
              id = 'scan',
              widget = wibox.container.background,
            },
            layout = wibox.layout.align.horizontal,
          },
          widget = wibox.container.margin,
          top = dpi(10),
        },
        layout = wibox.layout.fixed.vertical,
      },
      margins = dpi(15),
      widget = wibox.container.margin,
    },
    margins = dpi(15),
    widget = wibox.container.margin,
  }

  assert(type(ret) == 'table', 'bluetooth_controller: ret is not a table')

  -- Get a reference to the dnd button
  local dnd = ret:get_children_by_id('dnd')[1]:get_widget()

  -- Toggle bluetooth on or off
  dnd:connect_signal('dnd::toggle', function()
    ret:toggle()
  end)

  gtable.crush(ret, bluetooth, true)

  --#region Bluetooth Proxies
  -- Create a proxy for the freedesktop ObjectManager
  ret._private.ObjectManager = dbus_proxy.Proxy:new {
    bus = dbus_proxy.Bus.SYSTEM,
    name = 'org.bluez',
    interface = 'org.freedesktop.DBus.ObjectManager',
    path = '/',
  }

  -- Create a proxy for the bluez Adapter1 interface
  ret._private.Adapter1 = dbus_proxy.Proxy:new {
    bus = dbus_proxy.Bus.SYSTEM,
    name = 'org.bluez',
    interface = 'org.bluez.Adapter1',
    path = '/org/bluez/hci0',
  }

  if not ret._private.Adapter1.Powered then return end

  -- Create a proxy for the bluez Adapter1 Properties interface
  ret._private.Adapter1Properties = dbus_proxy.Proxy:new {
    bus = dbus_proxy.Bus.SYSTEM,
    name = 'org.bluez',
    interface = 'org.freedesktop.DBus.Properties',
    path = '/org/bluez/hci0',
  }

  -- Connect to the ObjectManager's InterfacesAdded signal
  ret._private.ObjectManager:connect_signal(function(_, interface)
    ret:get_device_info(interface)
  end, 'InterfacesAdded')

  -- Connect to the ObjectManager's InterfacesRemoved signal
  ret._private.ObjectManager:connect_signal(function(_, interface)
    ret:remove_device(interface)
  end, 'InterfacesRemoved')

  -- Connect to the Adapter1's PropertiesChanged signal
  ret._private.Adapter1Properties:connect_signal(function(_, _, data)
    if data.Powered ~= nil then
      send_state_notification(data.Powered)
      if data.Powered then
        dnd:set_enabled()
        ret:scan()
      else
        dnd:set_disabled()
      end
      ret:emit_signal('bluetooth::status', data.Powered)
    end
  end, 'PropertiesChanged')

  gtimer.delayed_call(function()
    for path, _ in pairs(ret._private.ObjectManager:GetManagedObjects()) do
      ret:get_device_info(path)
    end
    if ret._private.Adapter1.Powered then
      dnd:set_enabled()
      ret:scan()
    else
      dnd:set_disabled()
    end
    ret:emit_signal('bluetooth::status', ret._private.Adapter1.Powered)
    send_state_notification(ret._private.Adapter1.Powered)
  end)
  --#endregion

  --#region Dropdown logic
  local connected_margin = ret:get_children_by_id('connected_margin')[1]
  local connected_list = ret:get_children_by_id('connected_list')[1]
  local connected_icon = ret:get_children_by_id('connected_icon')[1]

  local connected_animation = rubato.timed {
    duration = 0.2,
    pos = connected_list.height,
    clamp_position = true,
    subscribed = function(v)
      connected_list.height = v
    end,
  }

  ret:connect_signal('device::added_connected', function(device)
    if device.Connected then
      local size = (#ret:get_paired_devices() * 60)
      if size < 210 then
        connected_animation.target = dpi(size)

        connected_margin.connected_bg.shape = function(cr, width, height)
          gshape.partially_rounded_rect(cr, width, height, true, true, false, false, dpi(4))
        end

        connected_icon:set_image(gcolor.recolor_image(icondir .. 'menu-up.svg',
          Theme_config.bluetooth_controller.connected_icon_color))
      end
    end
  end)

  ret:connect_signal('device::removed_connected', function(device)
    local size = (#ret:get_paired_devices() * 60)
    if size < 210 then
      connected_animation.target = dpi(size)

      connected_margin.connected_bg.shape = function(cr, width, height)
        gshape.partially_rounded_rect(cr, width, height, true, true, false, false, dpi(4))
      end

      connected_icon:set_image(gcolor.recolor_image(icondir .. 'menu-up.svg',
        Theme_config.bluetooth_controller.connected_icon_color))
    end
  end)

  connected_margin:connect_signal('button::press', function()
    if connected_list.height == 0 then
      local size = (#ret:get_paired_devices() * 60)
      if size < 210 then
        connected_animation.target = dpi(size)

        connected_margin.connected_bg.shape = function(cr, width, height)
          gshape.partially_rounded_rect(cr, width, height, true, true, false, false, dpi(4))
        end

        connected_icon:set_image(gcolor.recolor_image(icondir .. 'menu-up.svg',
          Theme_config.bluetooth_controller.connected_icon_color))
      end
    else
      connected_animation.target = 0
      connected_margin.connected_bg.shape = function(cr, width, height)
        gshape.rounded_rect(cr, width, height, 4)
      end

      connected_icon:set_image(gcolor.recolor_image(icondir .. 'menu-down.svg',
        Theme_config.bluetooth_controller.connected_icon_color))
    end
  end)

  local discovered_margin = ret:get_children_by_id('discovered_margin')[1]
  local discovered_list = ret:get_children_by_id('discovered_list')[1]
  local discovered_bg = ret:get_children_by_id('discovered_bg')[1]
  local discovered_icon = ret:get_children_by_id('discovered_icon')[1]

  local discovered_animation = rubato.timed {
    duration = 0.2,
    pos = discovered_list.forced_height,
    easing = rubato.linear,
    subscribed = function(v)
      discovered_list.forced_height = v
    end,
  }

  ret:connect_signal('device::added_discovered', function(device)
    if not device.Connected then
      local size = (#ret:get_discovered_devices() * 60)
      if size > 210 then
        size = 210
      end
      if size > 0 then
        discovered_animation.target = dpi(size)
        discovered_margin.discovered_bg.shape = function(cr, width, height)
          gshape.partially_rounded_rect(cr, width, height, true, true, false, false, dpi(4))
        end
        discovered_icon:set_image(gcolor.recolor_image(icondir .. 'menu-up.svg',
          Theme_config.bluetooth_controller.discovered_icon_color))
      end
    end
  end)

  ret:connect_signal('device::removed_discovered', function(device)
    local size = (#ret:get_discovered_devices() * 60)
    if size > 210 then
      size = 210
    end
    if size > 0 then
      discovered_animation.target = dpi(size)
      discovered_margin.discovered_bg.shape = function(cr, width, height)
        gshape.partially_rounded_rect(cr, width, height, true, true, false, false, dpi(4))
      end
      discovered_icon:set_image(gcolor.recolor_image(icondir .. 'menu-up.svg',
        Theme_config.bluetooth_controller.discovered_icon_color))
    end
  end)

  discovered_margin:connect_signal('button::press', function()
    if discovered_list.forced_height == 0 then
      local size = (#ret:get_discovered_devices() * 60)
      if size > 210 then
        size = 210
      end
      if size > 0 then
        discovered_animation.target = dpi(size)
        discovered_margin.discovered_bg.shape = function(cr, width, height)
          gshape.partially_rounded_rect(cr, width, height, true, true, false, false, dpi(4))
        end
        discovered_icon:set_image(gcolor.recolor_image(icondir .. 'menu-up.svg',
          Theme_config.bluetooth_controller.discovered_icon_color))
      end
    else
      discovered_animation.target = 0
      discovered_bg.shape = function(cr, width, height)
        gshape.rounded_rect(cr, width, height, 4)
      end
      discovered_icon:set_image(gcolor.recolor_image(icondir .. 'menu-down.svg',
        Theme_config.bluetooth_controller.discovered_icon_color))
    end
  end)
  --#endregion

  -- Add buttons to the scan button
  ret:get_children_by_id('scan')[1]:buttons {
    abutton({}, 1, function()
      ret:scan()
    end),
  }

  hover.bg_hover { widget = ret:get_children_by_id('scan')[1] }
  hover.bg_hover { widget = connected_margin.connected_bg }
  hover.bg_hover { widget = discovered_bg }

  return ret
end

function bluetooth.mt:__call(...)
  return bluetooth.new(...)
end

return setmetatable(bluetooth, bluetooth.mt)
