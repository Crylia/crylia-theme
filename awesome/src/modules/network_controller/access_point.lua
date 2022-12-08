------------------------------------
-- This is the network controller --
------------------------------------

-- Awesome Libs
local abutton = require("awful.button")
local awidget = require("awful.widget")
local dpi = require("beautiful").xresources.apply_dpi
local gtable = require("gears").table
local gfilesystem = require("gears").filesystem
local gcolor = require("gears").color
local lgi = require("lgi")
local wibox = require("wibox")
local base = require("wibox.widget.base")
local NM = lgi.NM

-- Third party libs
local dbus_proxy = require("src.lib.lua-dbus_proxy.src.dbus_proxy")

-- Own libs
local ap_form = require("src.modules.network_controller.ap_form")
local cm = require("src.modules.context_menu.init")

local icondir = gfilesystem.get_configuration_dir() .. "src/assets/icons/network/"

local access_point = { mt = {} }

local function flags_to_security(flags, wpa_flags, rsn_flags)
  local str = ""
  if flags == 1 and wpa_flags == 0 and rsn_flags == 0 then
    str = str .. " WEP"
  end
  if wpa_flags ~= 0 then
    str = str .. " WPA1"
  end
  if not rsn_flags ~= 0 then
    str = str .. " WPA2"
  end
  if wpa_flags == 512 or rsn_flags == 512 then
    str = str .. " 802.1X"
  end

  return (str:gsub("^%s", ""))
end

function access_point:get_access_point_connections(ssid)
  local cn = {}

  local connections = self.NetworkManagerSettings:ListConnections()
  for _, connection_path in ipairs(connections) do
    local NetworkManagerSettingsConnection = dbus_proxy.Proxy:new {
      bus = dbus_proxy.Bus.SYSTEM,
      name = "org.freedesktop.NetworkManager",
      interface = "org.freedesktop.NetworkManager.Settings.Connection",
      path = connection_path
    }

    if NetworkManagerSettingsConnection.Filename:find(ssid) then
      table.insert(cn, NetworkManagerSettingsConnection)
    end
  end

  return cn
end

function access_point:create_profile(ap, password, auto_connect)
  local s_wsec = {}
  local security = flags_to_security(ap.Flags, ap.WpaFlags, ap.RsnFlags)
  if security ~= "" then
    if security:match("WPA") then
      s_wsec["key-mgmt"] = lgi.GLib.Variant("s", "wpa-psk")
      s_wsec["auth-alg"] = lgi.GLib.Variant("s", "open")
      s_wsec["psk"] = lgi.GLib.Variant("s", password)
    else
      s_wsec["key-mgmt"] = lgi.GLib.Variant("s", "None")
      s_wsec["wep-key-type"] = lgi.GLib.Variant("s", NM.WepKeyType.PASSPHRASE)
      s_wsec["wep-key0"] = lgi.GLib.Variant("s", password)
    end
  end

  return {
    ["connection"] = {
      -- ["interface-name"] = lgi.GLib.Variant("s", ap.device_interface),
      ["uuid"] = lgi.GLib.Variant("s", string.gsub('xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx', '[xy]', function(c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
      end)),
      ["id"] = lgi.GLib.Variant("s", NM.utils_ssid_to_utf8(ap.Ssid)),
      ["type"] = lgi.GLib.Variant("s", "802-11-wireless"),
      ["autoconnect"] = lgi.GLib.Variant("b", auto_connect),
    },
    ["ipv4"] = {
      ["method"] = lgi.GLib.Variant("s", "auto")
    },
    ["ipv6"] = {
      ["method"] = lgi.GLib.Variant("s", "auto"),
    },
    ["802-11-wireless"] = {
      ["mode"] = lgi.GLib.Variant("s", "infrastructure"),
    },
    ["802-11-wireless-security"] = s_wsec
  }
end

function access_point:disconnect_ap()
  self.NetworkManager:DeactivateConnection(self.NetworkManagerDevice.ActiveConnection)
end

function access_point:connect(ap, password, auto_connect)
  local connections = self:get_access_point_connections(NM.utils_ssid_to_utf8(ap.Ssid))
  local profile = self:create_profile(self.NetworkManagerAccessPoint, password, auto_connect)

  if #connections == 0 then
    self.NetworkManager:AddAndActivateConnectionAsync(function(proxy, context, success, fail)
      if fail ~= nil then
        print("Error: " .. tostring(fail), tostring(fail.code))
        self:emit_signal("NetworkManager::failed", tostring(fail), tostring(fail.code))
        return
      end

      self:emit_signal("NetworkManager::connected", success)
    end, { call_id = "my-id" }, profile, self.NetworkManagerDevice.object_path,
      self.NetworkManagerAccessPoint.object_path)
    --88ALYLNxo9Kk*RwRxMfN
  else
    connections[1]:Update(profile)
    self.NetworkManager:ActivateConnectionAsync(function(proxy, context, success, failure)
      if failure then
        self:emit_signal("NM::AccessPointFailed", tostring(failure))
        return
      end

      self:emit_signal("NM::AccessPointConnected", NM.utils_ssid_to_utf8(ap.Ssid))
    end,
      { call_id = "my-id" }, connections[1].object_path, self.NetworkManagerDevice.object_path,
      self.NetworkManagerAccessPoint.object_path)
  end
end

function access_point:toggle_access_point(ap, password, auto_connect)
  if self:is_ap_active(ap) then
    self:disconnect_ap()
  else
    self:connect_ap(ap, password, auto_connect)
  end
end

function access_point:is_ap_active(ap)
  return ap.path == self.NetworkManagerDeviceWireless.ActiveAccessPoint
end

function access_point.new(args)
  args = args or {}

  if not args.NetworkManagerAccessPoint then return end

  local bg, fg, icon_color = Theme_config.network_manager.access_point.bg, Theme_config.network_manager.access_point.fg,
      Theme_config.network_manager.access_point.icon_color

  --[[ if get_active_access_point() == args.NetworkManagerAccessPoint.access_point_path then
    bg, fg, icon_color = Theme_config.network_manager.access_point.fg, Theme_config.network_manager.access_point.bg,
        Theme_config.network_manager.access_point.icon_color2
  end ]]

  local ssid_text = awidget.inputbox {
    text = NM.utils_ssid_to_utf8(args.NetworkManagerAccessPoint.Ssid) or
        args.NetworkManagerAccessPoint.hw_address or "Unknown",
    halign = "left",
    valign = "center",
  }

  local ret = base.make_widget_from_value(wibox.widget {
    {
      {
        {
          {
            {
              image = gcolor.recolor_image(
                icondir .. "wifi-strength-" .. math.floor(args.NetworkManagerAccessPoint.Strength / 25) + 1 .. ".svg",
                icon_color),
              id = "icon",
              resize = true,
              valign = "center",
              halign = "center",
              forced_width = dpi(24),
              forced_height = dpi(24),
              widget = wibox.widget.imagebox
            },
            id = "icon_container",
            strategy = "max",
            width = dpi(24),
            height = dpi(24),
            widget = wibox.container.constraint
          },
          {
            {
              ssid_text,
              widget = wibox.container.constraint,
              strategy = "exact",
              width = dpi(300),
              id = "alias"
            },
            width = dpi(260),
            height = dpi(40),
            strategy = "max",
            widget = wibox.container.constraint
          },
          spacing = dpi(10),
          layout = wibox.layout.fixed.horizontal
        },
        { -- Spacing
          forced_width = dpi(10),
          widget = wibox.container.background
        },
        {
          {
            {
              {
                id = "con",
                resize = false,
                valign = "center",
                halign = "center",
                forced_width = dpi(24),
                forced_height = dpi(24),
                widget = wibox.widget.imagebox
              },
              id = "place",
              strategy = "max",
              width = dpi(24),
              height = dpi(24),
              widget = wibox.container.constraint
            },
            id = "margin",
            margins = dpi(2),
            widget = wibox.container.margin
          },
          id = "margin0",
          margin = dpi(5),
          widget = wibox.container.margin
        },
        id = "device_layout",
        layout = wibox.layout.align.horizontal
      },
      id = "device_margin",
      margins = dpi(5),
      widget = wibox.container.margin
    },
    bg = bg,
    fg = fg,
    border_color = Theme_config.network_manager.access_point.border_color,
    border_width = Theme_config.network_manager.access_point.border_width,
    id = "background",
    shape = Theme_config.network_manager.access_point.device_shape,
    widget = wibox.container.background
  })

  gtable.crush(ret, access_point, true)

  ret.NetworkManagerAccessPoint = args.NetworkManagerAccessPoint
  ret.NetworkManagerSettings = args.NetworkManagerSettings
  ret.NetworkManagerDeviceWireless = args.NetworkManagerDeviceWireless
  ret.NetworkManagerDevice = args.NetworkManagerDevice
  ret.NetworkManager = args.NetworkManager

  ret.ap_form = ap_form {
    screen = args.screen,
    NetworkManagerAccessPoint = args.NetworkManagerAccessPoint,
    ap = ret
  }

  ret.cm = cm {
    widget_template = wibox.widget {
      {
        {
          {
            {
              widget = wibox.widget.imagebox,
              resize = true,
              valign = "center",
              halign = "center",
              id = "icon_role",
            },
            widget = wibox.container.constraint,
            stragety = "exact",
            width = dpi(24),
            height = dpi(24),
            id = "const"
          },
          {
            widget = wibox.widget.textbox,
            valign = "center",
            halign = "left",
            id = "text_role"
          },
          layout = wibox.layout.fixed.horizontal
        },
        widget = wibox.container.margin
      },
      widget = wibox.container.background,
    }, spacing = dpi(10),
    entries = {
      { -- Connect/Disconnect a device
        name = "ret.device.Connected" and "Disconnect" or "Connect",
        icon = gcolor.recolor_image("ret.device.Connected" and icondir .. "link-off.svg" or
          icondir .. "link.svg",
          Theme_config.network_manager.access_point.icon_color),
        callback = function()
          ret:toggle_access_point()
        end,
        id = "connected"
      },
      { -- Rename a device
        name = "Rename",
        icon = gcolor.recolor_image(icondir .. "edit.svg", Theme_config.network_manager.icon_color),
        callback = function()
          ssid_text:focus()
          ssid_text:connect_signal("submit", function(text)
            text = text:get_text()
            ssid_text.markup = ret:rename(text)
          end)
        end
      },
      { -- Remove a device
        name = "Remove",
        icon = gcolor.recolor_image(icondir .. "delete.svg", Theme_config.network_manager.icon_color),
        callback = function()

        end
      }
    }
  }

  ret:buttons(gtable.join(
    abutton({}, 1, nil,
      function()
        --TODO:Check if there are any connection details, else open the popup
        ret.ap_form:popup_toggle()
      end
    ),
    abutton({}, 3, nil,
      function()
        ret.cm:toggle()
      end
    )
  ))

  ret:get_children_by_id("con")[1].image = gcolor.recolor_image(
    icondir .. "link.svg", icon_color)

  Hover_signal(ret)

  return ret
end

function access_point.mt:__call(...)
  return access_point.new(...)
end

return setmetatable(access_point, access_point.mt)
