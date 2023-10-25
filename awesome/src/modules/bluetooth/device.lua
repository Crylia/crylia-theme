--------------------------------------
-- This is the bluetooth controller --
--------------------------------------

-- Awesome Libs
local abutton = require('awful.button')
local awidget = require('awful.widget')
local base = require('wibox.widget.base')
local beautiful = require('beautiful')
local dpi = require('beautiful').xresources.apply_dpi
local gcolor = require('gears').color
local gfilesystem = require('gears').filesystem
local gtable = require('gears').table
local lgi = require('lgi')
local wibox = require('wibox')

-- Own libs
local context_menu = require('src.modules.context_menu')
local hover = require('src.tools.hover')
local input = require('src.modules.inputbox')

local icondir = gfilesystem.get_configuration_dir() .. 'src/assets/icons/bluetooth/'

local capi = {
  awesome = awesome,
}

local device = { mt = {} }

--#region wibox.widget.base boilerplate

function device:layout(_, width, height)
  if self._private.widget then
    return { base.place_widget_at(self._private.widget, 0, 0, width, height) }
  end
end

function device:fit(context, width, height)
  local w, h = 0, 0 ---@type number|nil, number|nil
  if self._private.widget then
    w, h = base.fit_widget(self, context, self._private.widget, width, height)
  end
  return w, h
end

device.set_widget = base.set_widget_common

function device:get_widget()
  return self._private.widget
end

--#endregion

local dbus_proxy = require('src.lib.lua-dbus_proxy.src.dbus_proxy')
--- Connect to a device if not connected else disconnect
function device:toggle_connect()
  if not self.device.Paired then
    self:toggle_pair()
    return
  end
  if not self.device.Connected then
    self.device:ConnectAsync()
  else
    self.device:DisconnectAsync()
  end
end

--- Pair to a device if not paired else unpair
function device:toggle_pair()
  if not self.device.Paired then
    self._private.AgentManager1 = dbus_proxy.Proxy:new {
      bus = dbus_proxy.Bus.SYSTEM,
      name = 'org.bluez',
      path = '/org/bluez',
      interface = 'org.bluez.AgentManager1',
    }

    self._private.Agent1 = dbus_proxy.Proxy:new {
      bus = dbus_proxy.Bus.SYSTEM,
      name = 'org.bluez',
      path = '/org/bluez',
      interface = 'org.bluez.Agent1',
    }

    self._private.AgentManager1:RegisterAgent(self._private.Agent1.object_path, 'KeyboardDisplay')
    self.device:PairAsync()
  else
    --Remove via adapter
  end
end

--- Trust a device if not trusted else untrust
function device:toggle_trusted()
  self.device:Set('org.bluez.Device1', 'Trusted', lgi.GLib.Variant('b', not self.device.Trusted))
  self.device.Trusted = { signature = 'b', value = not self.device.Trusted }
end

---Rename a device alias
---@param newname string New name, if empty the device name will be reset
---@return string name The new or old name depending if the string was empty or not
function device:rename(newname)
  self.device:Set('org.bluez.Device1', 'Alias', lgi.GLib.Variant('s', newname))
  self.device.Alias = { signature = 's', value = newname }
  return self.device:Get('org.bluez.Device1', 'Alias')
end

function device.new(args)
  args = args or {}

  local icon = device.Icon or 'bluetooth-on'

  local inputbox = input {
    text = args.device.Alias or args.device.Name,
    font = beautiful.user_config.font .. ' 12',
    fg = beautiful.colorscheme.bg_blue,
  }

  local ret = base.make_widget_from_value(wibox.widget {
    {
      {
        {
          {
            {
              image = gcolor.recolor_image(
                icondir .. icon .. '.svg', beautiful.colorscheme.bg_purple),
              resize = false,
              valign = 'center',
              halign = 'center',
              widget = wibox.widget.imagebox,
            },
            strategy = 'exact',
            width = dpi(24),
            height = dpi(24),
            widget = wibox.container.constraint,
          },
          {
            inputbox.widget,
            widget = wibox.container.constraint,
            strategy = 'exact',
            width = dpi(300),
            id = 'const',
          },
          spacing = dpi(10),
          layout = wibox.layout.fixed.horizontal,
        },
        { -- Spacing
          forced_width = dpi(10),
          widget = wibox.container.background,
        },
        {
          {
            {
              {
                {
                  id = 'con',
                  resize = false,
                  valign = 'center',
                  halign = 'center',
                  widget = wibox.widget.imagebox,
                },
                strategy = 'exact',
                width = dpi(24),
                height = dpi(24),
                widget = wibox.container.constraint,
              },
              margins = dpi(2),
              widget = wibox.container.margin,
            },
            shape = beautiful.shape[4],
            bg = beautiful.colorscheme.bg_blue,
            widget = wibox.container.background,
          },
          margin = dpi(5),
          widget = wibox.container.margin,
        },
        layout = wibox.layout.align.horizontal,
      },
      margins = dpi(5),
      widget = wibox.container.margin,
    },
    bg = beautiful.colorscheme.bg,
    fg = beautiful.colorscheme.bg_blue,
    border_color = beautiful.colorscheme.border_color,
    border_width = dpi(2),
    id = 'background',
    shape = beautiful.shape[4],
    widget = wibox.container.background,
  })

  assert(ret, 'Failed to create widget')

  gtable.crush(ret, device, true)

  ret.device = args.device or {}

  -- Set the image of the connection button depending on the connection state
  ret:get_children_by_id('con')[1].image = gcolor.recolor_image(ret.device.Connected and icondir .. 'link.svg' or
    icondir .. 'link-off.svg',
    beautiful.colorscheme.bg)

  local cm = context_menu {
    widget_template = wibox.widget {
      {
        {
          {
            {
              widget = wibox.widget.imagebox,
              resize = true,
              valign = 'center',
              halign = 'center',
              id = 'icon_role',
            },
            widget = wibox.container.constraint,
            stragety = 'exact',
            width = dpi(24),
            height = dpi(24),
            id = 'const',
          },
          {
            widget = wibox.widget.textbox,
            valign = 'center',
            halign = 'left',
            id = 'text_role',
          },
          layout = wibox.layout.fixed.horizontal,
        },
        widget = wibox.container.margin,
      },
      widget = wibox.container.background,
    },
    spacing = dpi(10),
    entries = {
      { -- Connect/Disconnect a device
        name = ret.device.Connected and 'Disconnect' or 'Connect',
        icon = gcolor.recolor_image(ret.device.Connected and icondir .. 'bluetooth-off.svg' or
          icondir .. 'bluetooth-on.svg',
          beautiful.colorscheme.bg_purple),
        callback = function()
          ret:toggle_connect()
        end,
        id = 'connected',
      },
      { -- Pair/Unpair a device
        name = 'Pair',
        icon = gcolor.recolor_image(ret.device.Paired and icondir .. 'link-off.svg' or
          icondir .. 'link.svg',
          beautiful.colorscheme.bg_purple),
        callback = function()
          ret:toggle_pair()
        end,
      },
      { -- Trust/Untrust a device
        name = ret.device.Trusted and 'Untrust' or 'Trust',
        icon = gcolor.recolor_image(ret.device.Trusted and icondir .. 'untrusted.svg' or icondir .. 'trusted.svg',
          beautiful.colorscheme.bg_purple),
        callback = function()
          ret:toggle_trusted()
        end,
        id = 'trusted',
      },
      { -- Rename a device
        name = 'Rename',
        icon = gcolor.recolor_image(icondir .. 'edit.svg', beautiful.colorscheme.bg_purple),
        callback = function()
          inputbox:focus()
          inputbox:connect_signal('inputbox::keypressed', function(_, mod, key)
            if key == 'Return' then
              inputbox.markup = ret:rename(inputbox:get_text())
              inputbox:unfocus()
            end
          end)
        end,
      },
      { -- Remove a device
        name = 'Remove',
        icon = gcolor.recolor_image(icondir .. 'delete.svg', beautiful.colorscheme.bg_purple),
        callback = function()
          args.remove_callback(ret.device)
        end,
      },
    },
  }

  cm:connect_signal('mouse::leave', function()
    cm.visible = false
  end)

  ret:buttons(gtable.join(
    abutton({}, 1, function()
      -- Toggle the connection state
      ret:toggle_connect()
    end),
    abutton({}, 3, function()
      -- Show the context menu and update its entrie names
      for _, value in ipairs(cm.widget.children) do
        value.id = value.id or ''
        if value.id:match('connected') then
          value:get_children_by_id('text_role')[1].text = ret.device.Connected and 'Disconnect' or 'Connect'
          value:get_children_by_id('icon_role')[1].image = gcolor.recolor_image(ret.device.Connected and
            icondir .. 'bluetooth-off.svg' or icondir .. 'bluetooth-on.svg',
            beautiful.colorscheme.bg_purple)
        elseif value.id:match('trusted') then
          value:get_children_by_id('text_role')[1].text = ret.device.Trusted and 'Untrust' or 'Trust'
          value:get_children_by_id('icon_role')[1].image = gcolor.recolor_image(ret.device.Trusted and
            icondir .. 'untrusted.svg' or icondir .. 'trusted.svg', beautiful.colorscheme.bg_purple)
        elseif value.id:match('paired') then
          value:get_children_by_id('icon_role')[1].image = gcolor.recolor_image(ret.device.Paired and
            icondir .. 'link-off.svg' or icondir .. 'link.svg', beautiful.colorscheme.bg_purple)
        end
      end
      cm:toggle()
    end)
  ))

  -- Update the updated device icon
  capi.awesome.connect_signal(ret.device.object_path .. '_updated', function(d)
    ret:get_children_by_id('con')[1].image = gcolor.recolor_image(d.Connected and icondir .. 'link.svg' or
      icondir .. 'link-off.svg',
      beautiful.colorscheme.bg)
  end)

  hover.bg_hover { widget = ret }

  return ret
end

function device.mt:__call(...)
  return device.new(...)
end

return setmetatable(device, device.mt)
