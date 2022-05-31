local dbus_proxy = require("dbus_proxy")
local naughty = require("naughty")

return function()

  local function get_device_info(self, object_path)
    if object_path ~= nil and object_path:match("/org/bluez/hci0/dev") then
      local device_proxy = dbus_proxy.Proxy:new {
        bus = dbus_proxy.Bus.SYSTEM,
        name = "org.bluez",
        interface = "org.bluez.Device1",
        path = object_path
      }

      local bat_proxy = dbus_proxy.Proxy:new {
        bus = dbus_proxy.Bus.SYSTEM,
        name = "org.bluez",
        interface = "org.bluez.Battery1",
        path = object_path
      }

      local device_properties_proxy = dbus_proxy.Proxy:new {
        bus = dbus_proxy.Bus.SYSTEM,
        name = "org.bluez",
        interface = "org.freedesktop.DBus.Properties",
        path = object_path
      }

      if device_proxy.Name ~= "" and device_proxy.Name ~= nil then
        --[[         device_properties_proxy:connect_signal("PropertiesChanged", function()
          awesome.emit_signal(object_path .. "_updated", device_proxy)
          naughty.notify({ title = "hi" })
        end) ]]
        naughty.notify({ title = device_proxy.Name })
      end
    end
  end

  local ret = dbus_proxy.Proxy:new {
    bus = dbus_proxy.Bus.SYSTEM,
    name = "org.bluez",
    interface = "org.freedesktop.Dbus.ObjectManager",
    path = "/"
  }

  local objects = ret:GetManagedObjects()

  for object_path, _ in pairs(objects) do
    get_device_info(ret, object_path)
  end

end
