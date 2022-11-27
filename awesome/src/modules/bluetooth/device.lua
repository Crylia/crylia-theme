--------------------------------------
-- This is the bluetooth controller --
--------------------------------------

-- Awesome Libs
local awful = require("awful")
local dpi = require("beautiful").xresources.apply_dpi
local gtable = require("gears").table
local gcolor = require("gears").color
local gshape = require("gears").shape
local gfilesystem = require("gears").filesystem
local wibox = require("wibox")
local base = require("wibox.widget.base")
local lgi = require("lgi")
local dbus_proxy = require("dbus_proxy")

local context_menu = require("src.modules.context_menu")

local icondir = gfilesystem.get_configuration_dir() .. "src/assets/icons/bluetooth/"

local capi = {
  awesome = awesome
}

local device = { mt = {} }

function device:layout(_, width, height)
  if self._private.widget then
    return { base.place_widget_at(self._private.widget, 0, 0, width, height) }
  end
end

function device:fit(context, width, height)
  local w, h = 0, 0
  if self._private.widget then
    w, h = base.fit_widget(self, context, self._private.widget, width, height)
  end
  return w, h
end

device.set_widget = base.set_widget_common

function device:get_widget()
  return self._private.widget
end

function device:toggle_connect()
  if not self.device.Connected then

    --TODO: Implement device passcode support, I have no idea how to get the
    --TODO: Methods from Agent1 implemented
    --[[ self._private.AgentManager1 = dbus_proxy.Proxy:new {
      bus = dbus_proxy.Bus.SYSTEM,
      name = "org.bluez",
      path = "/org/bluez",
      interface = "org.bluez.AgentManager1"
    }

    self._private.Agent1 = dbus_proxy.Proxy:new {
      bus = dbus_proxy.Bus.SYSTEM,
      name = "org.bluez",
      path = "/org/bluez",
      interface = "org.bluez.Agent1",
    }

    self._private.AgentManager1:RegisterAgent(self._private.Agent1.object_path, "")
    self._private.AgentManager1:RequestDefaultAgent(self._private.Agent1.object_path) ]]

    self.device:ConnectAsync()
  else
    self.device:DisconnectAsync()
  end
end

function device:toggle_pair()
  if self.device.Paired then
    self.device:PairAsync()
  else
    self.device:CancelPairingAsync()
  end
end

function device:toggle_trusted()
  self.device:Set("org.bluez.Device1", "Trusted", lgi.GLib.Variant("b", not self.device.Trusted))
  self.device.Trusted = { signature = "b", value = not self.device.Trusted }

end

function device:rename(newname)
  self.device:Set("org.bluez.Device1", "Alias", lgi.GLib.Variant("s", newname))
  self.device.Alias = { signature = "s", value = newname }
  return self.device:Get("org.bluez.Device1", "Alias")
end

function device.new(args)
  args = args or {}
  args.device = args.device or {}

  local icon = device.Icon or "bluetooth-on"

  local inputbox = awful.widget.inputbox {
    text = args.device.Alias or args.device.Name,
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
                icondir .. icon .. ".svg", Theme_config.bluetooth_controller.icon_color),
              id = "icon",
              resize = false,
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
              {
                inputbox,
                widget = wibox.container.constraint,
                strategy = "min",
                width = dpi(400),
                id = "const"
              },
              {
                text = "Connecting...",
                id = "connecting",
                visible = false,
                font = User_config.font.specify .. ", regular 10",
                widget = wibox.widget.textbox
              },
              id = "alias_container",
              layout = wibox.layout.fixed.horizontal
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
            id = "backgr",
            shape = function(cr, width, height)
              gshape.rounded_rect(cr, width, height, dpi(4))
            end,
            bg = Theme_config.bluetooth_controller.con_button_color,
            widget = wibox.container.background
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
    bg = Theme_config.bluetooth_controller.device_bg,
    fg = Theme_config.bluetooth_controller.device_fg,
    border_color = Theme_config.bluetooth_controller.device_border_color,
    border_width = Theme_config.bluetooth_controller.device_border_width,
    id = "background",
    shape = function(cr, width, height)
      gshape.rounded_rect(cr, width, height, dpi(4))
    end,
    widget = wibox.container.background
  })

  gtable.crush(ret, device, true)

  if args.device then
    ret.device = args.device
  end

  ret:get_children_by_id("con")[1].image = gcolor.recolor_image(ret.device.Connected and icondir .. "link.svg" or
    icondir .. "link-off.svg",
    Theme_config.bluetooth_controller.icon_color_dark)

  local cm = context_menu {
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
      {
        name = ret.device.Connected and "Disconnect" or "Connect",
        icon = gcolor.recolor_image(ret.device.Connected and icondir .. "bluetooth-off.svg" or
          icondir .. "bluetooth-on.svg",
          Theme_config.bluetooth_controller.icon_color),
        callback = function()
          ret:toggle_connect()
        end,
        id = "connected"
      },
      {
        name = "Pair",
        icon = gcolor.recolor_image(ret.device.Paired and icondir .. "link-off.svg" or
          icondir .. "link.svg",
          Theme_config.bluetooth_controller.icon_color),
        callback = function()
          ret:toggle_pair()
        end
      },
      {
        name = ret.device.Trusted and "Untrust" or "Trust",
        icon = gcolor.recolor_image(ret.device.Trusted and icondir .. "untrusted.svg" or icondir .. "trusted.svg",
          Theme_config.bluetooth_controller.icon_color),
        callback = function()
          ret:toggle_trusted()
        end,
        id = "trusted"
      },
      {
        name = "Rename",
        icon = gcolor.recolor_image(icondir .. "edit.svg", Theme_config.bluetooth_controller.icon_color),
        callback = function()
          inputbox:focus()
          inputbox:connect_signal("submit", function(text)
            text = text:get_text()
            inputbox.markup = ret:rename(text)
          end)
        end
      },
      {
        name = "Remove",
        icon = gcolor.recolor_image(icondir .. "delete.svg", Theme_config.bluetooth_controller.icon_color),
        callback = function()
          args.remove_callback(ret.device)
        end
      }
    }
  }

  ret:buttons(
    gtable.join(
      awful.button({}, 1, function()
        ret:toggle_connect()
      end),
      awful.button({}, 3, function()
        for _, value in ipairs(cm.widget.children) do
          value.id = value.id or ""
          if value.id:match("connected") then
            value:get_children_by_id("text_role")[1].text = ret.device.Connected and "Disconnect" or "Connect"
            value:get_children_by_id("icon_role")[1].image = gcolor.recolor_image(ret.device.Connected and
              icondir .. "bluetooth-off.svg" or icondir .. "bluetooth-on.svg",
              Theme_config.bluetooth_controller.icon_color)
          elseif value.id:match("trusted") then
            value:get_children_by_id("text_role")[1].text = ret.device.Trusted and "Untrust" or "Trust"
            value:get_children_by_id("icon_role")[1].image = gcolor.recolor_image(ret.device.Trusted and
              icondir .. "untrusted.svg" or icondir .. "trusted.svg", Theme_config.bluetooth_controller.icon_color)
          elseif value.id:match("paired") then
            value:get_children_by_id("icon_role")[1].image = gcolor.recolor_image(ret.device.Paired and
              icondir .. "link-off.svg" or icondir .. "link.svg", Theme_config.bluetooth_controller.icon_color)
          end
        end
        cm:toggle()
      end)
    )
  )

  capi.awesome.connect_signal(ret.device.object_path .. "_updated", function(d)
    ret:get_children_by_id("con")[1].image = gcolor.recolor_image(d.Connected and icondir .. "link.svg" or
      icondir .. "link-off.svg",
      Theme_config.bluetooth_controller.icon_color_dark)
  end)

  Hover_signal(ret)

  return ret
end

function device.mt:__call(...)
  return device.new(...)
end

return setmetatable(device, device.mt)
