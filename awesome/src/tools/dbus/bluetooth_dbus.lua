local awful = require("awful")
local gears = require("gears")
local dbus_proxy = require("dbus_proxy")
local lgi = require("lgi")
local naughty = require("naughty")

return function()

  local function get_device_info(object_path)
    if object_path ~= nil and object_path:match("/org/bluez/hci0/dev") then
      local device = dbus_proxy.Proxy:new {
        bus = dbus_proxy.Bus.SYSTEM,
        name = "org.bluez",
        interface = "org.bluez.Device1",
        path = object_path
      }

      local battery = dbus_proxy.Proxy:new {
        bus = dbus_proxy.Bus.SYSTEM,
        name = "org.bluez",
        interface = "org.bluez.Battery1",
        path = object_path
      }

      local device_properties = dbus_proxy.Proxy:new {
        bus = dbus_proxy.Bus.SYSTEM,
        name = "org.bluez",
        interface = "org.freedesktop.DBus.Properties",
        path = object_path
      }
      awesome.emit_signal("bluetooth::scan")
      if device.Name ~= nil or device.Alias ~= nil then
        device_properties:connect_signal(function()
          awesome.emit_signal("bluetooth::device_changed", device, battery)
        end, "PropertiesChanged")
        awesome.emit_signal("bluetooth::device_changed", device, battery)
      end
    end
  end

  awful.spawn.easy_async_with_shell(
    "lsusb | grep Bluetooth",
    function(stdout)
      stdout = stdout:gsub("\n", "")
      if stdout ~= "" or stdout == nil then
        local ObjectManager = dbus_proxy.Proxy:new {
          bus = dbus_proxy.Bus.SYSTEM,
          name = "org.bluez",
          interface = "org.freedesktop.DBus.ObjectManager",
          path = "/"
        }

        local Adapter = dbus_proxy.Proxy:new {
          bus = dbus_proxy.Bus.SYSTEM,
          name = "org.bluez",
          interface = "org.bluez.Adapter1",
          path = "/org/bluez/hci0"
        }

        local AdapterProperties = dbus_proxy.Proxy:new {
          bus = dbus_proxy.Bus.SYSTEM,
          name = "org.bluez",
          interface = "org.freedesktop.DBus.Properties",
          path = "/org/bluez/hci0"
        }

        ObjectManager:connect_signal(
          function(interface)
            get_device_info(interface)
          end,
          "InterfacesAdded"
        )

        ObjectManager:connect_signal(
          function(interface)
            awesome.emit_signal("device_removed", interface)
          end,
          "InterfacesRemoved"
        )

        Adapter:connect_signal(
          function(data)
            if data.Powered ~= nil then
              awesome.emit_signal("state", data.Powered)
            end
          end,
          "PropertiesChanged"
        )

        awesome.connect_signal(
          "bluetooth::scan",
          function()
            Adapter:StartDiscovery()
          end
        )

        AdapterProperties:connect_signal(
          function(data)
            if data.Powered ~= nil then
              if data.Powered then
                Adapter:StartDiscovery()
              end
            end
          end,
          "PropertiesChanged"
        )

        awesome.connect_signal("toggle_bluetooth",
          function()
            local is_powered = Adapter.Powered
            Adapter:Set(
              "org.bluez.Adapter1",
              "Powered",
              lgi.GLib.Variant("b", not is_powered)
            )
            Adapter.Powered = { signature = "b", value = not is_powered }
            awesome.emit_signal("state", Adapter.Powered)
          end)

        gears.timer.delayed_call(
          function()
            local objects = ObjectManager:GetManagedObjects()

            for object_path, _ in pairs(objects) do
              get_device_info(object_path)
            end

            awesome.emit_signal("state", Adapter.Powered)
          end
        )
      end
    end
  )

end
