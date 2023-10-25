local setmetatable = setmetatable
local table = table
local pairs = pairs
local ipairs = ipairs

local base = require('wibox.widget.base')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi
local gcolor = require('gears.color')
local gfilesystem = require('gears.filesystem')
local gshape = require('gears.shape')
local wibox = require('wibox')
local gtable = require('gears.table')
local abutton = require('awful.button')
local apopup = require('awful.popup')
local aplacement = require('awful.placement')

local rubato = require('src.lib.rubato')

local dnd_widget = require('awful.widget.toggle_widget')
local networkManager = require('src.tools.network')()
local inputbox = require('src.modules.inputbox')
local context_menu = require('src.modules.context_menu')

local icondir = gfilesystem.get_configuration_dir() .. 'src/assets/icons/network/'

local capi = {
  mouse = mouse,
}

local network = {}

--- Called when a connection does not exist yet and the user needs to ender a password
--- And Autoconnect or not.
---@param ap AccessPoint The access point to connect to
---@param callback function The callback to call when the conenct button is pressed
function network:open_connection_form(ap, callback)
  if self.form_popup then
    self.form_popup.visible = false
  end
  --Password inputbox
  local password = inputbox {
    mouse_focus = true,
    text = 'testtext',
  }

  --New form widget
  local w = base.make_widget_from_value {
    {
      {
        {
          { -- Header
            {
              nil,
              { -- SSID
                {
                  widget = wibox.widget.textbox,
                  text = ap.SSID,
                  halign = 'center',
                  valign = 'center',
                },
                widget = wibox.container.margin,
                margins = dpi(5),
              },
              { -- Close button
                {
                  {
                    {
                      widget = wibox.widget.imagebox,
                      image = gcolor.recolor_image(icondir .. 'close.svg', beautiful.colorscheme.bg),
                      resize = true,
                      valign = 'center',
                      halign = 'center',
                    },
                    widget = wibox.container.margin,
                    margins = dpi(5),
                  },
                  widget = wibox.container.background,
                  id = 'close_button',
                  bg = beautiful.colorscheme.bg_red,
                  shape = beautiful.shape[8],
                },
                widget = wibox.container.constraint,
                width = dpi(30),
                height = dpi(30),
                strategy = 'exact',
              },
              layout = wibox.layout.align.horizontal,
            },
            widget = wibox.container.background,
            fg = beautiful.colorscheme.bg_red,
          },
          { -- Form
            { -- Password text
              widget = wibox.widget.textbox,
              text = 'Password',
              halign = 'center',
              valign = 'center',
            },
            { -- Spacing
              widget = wibox.container.margin,
              left = dpi(20),
              right = dpi(20),
            },
            { -- Passwort inputbox
              {
                {
                  {
                    {
                      password.widget,
                      step = dpi(50),
                      scrollbar_width = 0,
                      id = 'scroll',
                      layout = require('src.lib.overflow_widget.overflow').horizontal,
                    },
                    widget = wibox.container.margin,
                    left = dpi(5),
                    right = dpi(5),
                  },
                  widget = wibox.container.place,
                  halign = 'left',
                },
                widget = wibox.container.background,
                bg = beautiful.colorscheme.bg,
                fg = beautiful.colorscheme.fg,
                border_color = beautiful.colorscheme.border_color,
                border_width = dpi(2),
                shape = beautiful.shape[8],
                id = 'password_container',
              },
              widget = wibox.container.constraint,
              strategy = 'exact',
              width = dpi(300),
              height = dpi(50),
            },
            layout = wibox.layout.align.horizontal,
          },
          { -- Actions
            { -- Auto Connect
              {
                {
                  {
                    checked = false,
                    shape = beautiful.shape[4],
                    color = beautiful.colorscheme.bg,
                    paddings = dpi(3),
                    check_color = beautiful.colorscheme.bg_red,
                    border_color = beautiful.colorscheme.bg_red,
                    border_width = dpi(2),
                    id = 'checkbox',
                    widget = wibox.widget.checkbox,
                  },
                  widget = wibox.container.constraint,
                  strategy = 'exact',
                  width = dpi(30),
                  height = dpi(30),
                },
                widget = wibox.container.place,
              },
              {
                widget = wibox.widget.textbox,
                text = 'Auto connect',
                halign = 'center',
                valign = 'center',
              },
              layout = wibox.layout.fixed.horizontal,
              spacing = dpi(10),
            },
            nil,
            { -- Connect
              {
                {
                  {
                    widget = wibox.widget.textbox,
                    text = 'Connect',
                    valign = 'center',
                    halign = 'center',
                  },
                  widget = wibox.container.margin,
                  margins = dpi(10),
                },
                widget = wibox.container.background,
                bg = beautiful.colorscheme.bg_blue,
                fg = beautiful.colorscheme.bg,
                shape = beautiful.shape[8],
                id = 'connect_button',
              },
              widget = wibox.container.margin,
              margins = dpi(10),
            },
            layout = wibox.layout.align.horizontal,
          },
          layout = wibox.layout.fixed.vertical,
          spacing = dpi(20),
        },
        widget = wibox.container.margin,
        margins = dpi(10),
      },
      bg = beautiful.colorscheme.bg,
      fg = beautiful.colorscheme.fg,
      widget = wibox.container.background,
    },
    widget = wibox.container.constraint,
    strategy = 'max',
    height = dpi(400),
    width = dpi(600),
    buttons = gtable.join {
      abutton({}, 1, function()
        password:unfocus()
      end),
    },
  }

  -- Popup for the form
  self.form_popup = apopup {
    widget = w,
    visible = true,
    type = 'dialog',
    screen = capi.mouse.screen,
    border_color = beautiful.colorscheme.border_color,
    border_width = dpi(2),
    ontop = true,
    placement = aplacement.centered,
  }

  -- Automatically scroll to the right when typing to keep the password visible
  local scroll_layout = w:get_children_by_id('scroll')[1]
  password:connect_signal('inputbox::keypressed', function(_, m, k)
    scroll_layout:set_scroll_factor(1)
  end)

  -- Connect button pressed when the user is done typing and ready to connect
  --TODO: Don't just close the form, try to connect first and check if the password is correct or not
  local connect_button = w:get_children_by_id('connect_button')[1]
  connect_button:buttons(gtable.join {
    abutton({}, 1, function()
      local res = {
        autoconnect = w:get_children_by_id('checkbox')[1].checked,
        passwd = password:get_text(),
        ssid = ap.SSID,
        security = ap.Security,
      }

      password:unfocus()

      networkManager:ConnectToAccessPointAsync(ap, self.device, networkManager.NetworkManagerSettings:NewConnectionProfile(res), function(succ)
        if succ then
          w = nil
          self.form_popup.visible = false
        else
          --TODO: Add a little text under/above the password box and make it visible here telling the user that the password was
          --TODO: wrong
        end
      end)
    end),
  })

  -- Autoconnect true/false
  local checkbox = w:get_children_by_id('checkbox')[1]
  checkbox:buttons(gtable.join {
    abutton({}, 1, function()
      checkbox.checked = not checkbox.checked
    end),
  })

  -- Close the form and do nothing
  local close_button = w:get_children_by_id('close_button')[1]
  close_button:buttons(gtable.join {
    abutton({}, 1, function()
      password:unfocus()
      w = nil
      self.form_popup.visible = false
    end),
  })

  -- Focus the inputbox when clicked
  --TODO: Add some keys to the inputbox to make it possible to lose focus on enter/escape etc
  local password_container = w:get_children_by_id('password_container')[1]
  password_container:buttons(gtable.join {
    abutton({}, 1, function()
      password:focus()
    end),
  })

end

---Sort the wifi list by active access point first, then by strength descending
function network:resort_wifi_list()
  local wifi_list = self:get_children_by_id('wifi_list')[1]

  --Make sure that the active AP is always on top, there is only one active AP
  table.sort(wifi_list.children, function(a, b)
    if self.device:IsApActive(a) then
      return true
    elseif self.device:IsApActive(b) then
      return false
    end

    return a.Strength > b.Strength
  end)
end

---If an Access Point is lost then remove it from the list
---@param ap AccessPoint Lost AP
---@return boolean deleted
function network:delete_ap_from_list(ap)
  local wifi_list = self:get_children_by_id('wifi_list')[1]
  for i, w in ipairs(wifi_list.children) do
    if w.object_path == ap then
      table.remove(wifi_list.children, i)
      return true
    end
  end
  return false
end

---If an access point needs to be added to the list
---@param ap AccessPoint
function network:add_ap_to_list(ap)
  if not ap then return end
  local wifi_list = self:get_children_by_id('wifi_list')[1]
  local fg, bg

  if self.device:IsApActive(ap) then
    fg = beautiful.colorscheme.bg
    bg = beautiful.colorscheme.bg_red
  else
    fg = beautiful.colorscheme.bg_red
    bg = beautiful.colorscheme.bg
  end

  -- New AP widget
  local w = base.make_widget_from_value {
    {
      {
        {
          {
            {
              id = 'icon_role',
              image = gcolor.recolor_image(icondir .. 'wifi-strength-1.svg', fg),
              resize = true,
              valign = 'center',
              halign = 'center',
              widget = wibox.widget.imagebox,
            },
            strategy = 'max',
            width = dpi(24),
            height = dpi(24),
            widget = wibox.container.constraint,
          },
          {
            {
              {
                text = ap.SSID,
                widget = wibox.widget.textbox,
              },
              strategy = 'exact',
              width = dpi(300),
              widget = wibox.container.constraint,
            },
            width = dpi(260),
            height = dpi(40),
            strategy = 'max',
            widget = wibox.container.constraint,
          },
          spacing = dpi(10),
          layout = wibox.layout.fixed.horizontal,
        },
        { -- Spacing
          width = dpi(10),
          widget = wibox.container.constraint,
        },
        {
          {
            {
              resize = false,
              id = 'con_icon',
              image = gcolor.recolor_image(icondir .. 'link-off.svg', fg),
              valign = 'center',
              halign = 'center',
              widget = wibox.widget.imagebox,
            },
            strategy = 'exact',
            height = dpi(24),
            width = dpi(24),
            widget = wibox.container.constraint,
          },
          margins = dpi(5),
          widget = wibox.container.margin,
        },
        layout = wibox.layout.align.horizontal,
      },
      margins = dpi(5),
      widget = wibox.container.margin,
    },
    shape = beautiful.shape[4],
    bg = bg,
    fg = fg,
    border_color = beautiful.colorscheme.border_color,
    border_width = dpi(2),
    widget = wibox.container.background,
    Strength = ap.Strength,
    object_path = ap.object_path,
  }

  local icon = w:get_children_by_id('icon_role')[1]
  local con_icon = w:get_children_by_id('con_icon')[1]

  -- Update the strength icon and resort the list afterwards
  ap:connect_signal('NetworkManagerAccessPoint::Strength', function(_, strength)
    local s
    if strength >= 80 then
      s = 5
    elseif strength >= 60 and strength < 80 then
      s = 4
    elseif strength >= 40 and strength < 60 then
      s = 3
    elseif strength >= 20 and strength < 40 then
      s = 2
    else
      s = 1
    end
    w.Strength = strength
    icon.image = gcolor.recolor_image(icondir .. 'wifi-strength-' .. s .. '.svg', fg)

    self:resort_wifi_list()
  end)
  -- Manually fire once to set the icon, as some AP's need a few seconds to update
  ap:emit_signal('NetworkManagerAccessPoint::Strength', ap.Strength)

  -- Update the active connection, and the old one (color and icon change)
  self.device:connect_signal('NetworkManagerDeviceWireless::ActiveAccessPoint', function(_, old_ap, new_ap)
    local function active_ap_signal(_, strength)
      self:emit_signal('ActiveAccessPointStrength', strength)
      --!Why does the above signal not work outside of this module?
      --This is a workaournd until I foundout why it doesn't work
      awesome.emit_signal('ActiveAccessPointStrength', strength)
    end

    if old_ap == ap.object_path then
      w.bg = beautiful.colorscheme.bg
      w.fg = beautiful.colorscheme.bg_red
      bg = beautiful.colorscheme.bg
      fg = beautiful.colorscheme.bg_red
      con_icon.image = gcolor.recolor_image(icondir .. 'link-off.svg', fg)
      icon.image = gcolor.recolor_image(icondir .. 'wifi-strength-1.svg', fg)
      ap:disconnect_signal('NetworkManagerAccessPoint::Strength', active_ap_signal)
    end
    if new_ap == ap.object_path then
      w.bg = beautiful.colorscheme.bg_red
      w.fg = beautiful.colorscheme.bg
      fg = beautiful.colorscheme.bg
      bg = beautiful.colorscheme.bg_red
      con_icon.image = gcolor.recolor_image(icondir .. 'link.svg', fg)
      icon.image = gcolor.recolor_image(icondir .. 'wifi-strength-1.svg', fg)
      ap:connect_signal('NetworkManagerAccessPoint::Strength', active_ap_signal)
    end
  end)
  -- Again manually update
  self.device:emit_signal('NetworkManagerDeviceWireless::ActiveAccessPoint', nil, self.device.NetworkManagerDeviceWireless.ActiveAccessPoint)

  -- Context menu for connecting, disconnecting, etc.
  --TODO: Needs to update its entries when the active AP changes to it has a disconnect button
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
      {
        name = self.device:IsApActive(ap) and 'Disconnect' or 'Connect',
        icon = self.device:IsApActive(ap) and gcolor.recolor_image(icondir .. 'link-off.svg', bg) or gcolor.recolor_image(icondir .. 'link.svg', fg),
        callback = function()
          if self.device:IsApActive(ap) then
            networkManager:DisconnectFromAP();
          else
            networkManager:ConnectToAccessPointAsync(ap, self.device, nil, function(res)
              if not res then
                self:open_connection_form(ap, function(res)
                end)
              end
            end)
          end
        end,
      },
      {
        name = 'Remove connection',
        icon = gcolor.recolor_image(icondir .. 'delete.svg', bg),
        callback = function()
          for path, value in pairs(networkManager.NetworkManagerSettings.ConnectionList or {}) do
            if ap.SSID == value:GetSettings().connection.id then
              networkManager.NetworkManagerSettings:RemoveConnection(value)
            end
          end
        end,
      },
    },
  }

  -- Hide context menu on leave
  cm:connect_signal('mouse::leave', function()
    cm.visible = false
  end)

  -- Left click should try to connect/disconnect to AP
  --TODO: Check if active ap is clicked and try to disconnect, instead of trying to reconnect to the same AP
  -- Right click toggles the context menu
  w:buttons(gtable.join {
    abutton({}, 1, function()
      networkManager:ConnectToAccessPointAsync(ap, self.device, nil, function(res)
        if not res then
          self:open_connection_form(ap, function(res)
          end)
        end
      end)
    end),
    abutton({}, 3, function()
      cm:toggle()
    end),
  })

  -- Add ap into table
  table.insert(wifi_list.children, w)

  -- Resort after adding the new AP
  self:resort_wifi_list()
end

---Check if an AP is already in the list by comparing its object path
---@param ap AccessPoint
---@return boolean inlist Is in list or not
function network:is_ap_in_list(ap)
  if not ap then return false end
  local wifi_list = self:get_children_by_id('wifi_list')[1]
  for _, w in ipairs(wifi_list.children) do
    if w.object_path == ap.object_path then
      return true
    end
  end
  return false
end

---Add the list to the widget hierarchy, and clears the previous entries
---Usually used when the user requests a new scan
---@param ap_list table<ap_list>
function network:set_wifi_list(ap_list)
  if not ap_list or #ap_list < 1 then return end
  local wifi_list = self:get_children_by_id('wifi_list')[1]
  wifi_list:reset()

  for _, ap in ipairs(ap_list) do
    self:add_ap_to_list(ap)
  end
end

return setmetatable(network, {
  __call = function(self)

    local dnd = dnd_widget {
      color = beautiful.colorscheme.bg_red,
      size = dpi(40),
    }

    local w = base.make_widget_from_value {
      {
        {
          {
            {
              {
                {
                  {
                    widget = wibox.widget.imagebox,
                    resize = false,
                    id = 'wifi_icon',
                    image = gcolor.recolor_image(icondir .. 'menu-down.svg', beautiful.colorscheme.bg_red),
                  },
                  widget = wibox.container.place,
                },
                {
                  {
                    text = 'Wifi Networks',
                    widget = wibox.widget.textbox,
                  },
                  margins = dpi(5),
                  widget = wibox.container.margin,
                },
                layout = wibox.layout.fixed.horizontal,
              },
              id = 'wifi_list_bar',
              bg = beautiful.colorscheme.bg1,
              fg = beautiful.colorscheme.bg_red,
              shape = beautiful.shape[4],
              widget = wibox.container.background,
            },
            {
              {
                {
                  {
                    step = dpi(50),
                    spacing = dpi(10),
                    scrollbar_width = 0,
                    id = 'wifi_list',
                    layout = require('src.lib.overflow_widget.overflow').vertical,
                  },
                  margins = dpi(10),
                  widget = wibox.container.margin,
                },
                border_color = beautiful.colorscheme.border_color,
                border_width = dpi(2),
                shape = function(cr, width, height)
                  gshape.partially_rounded_rect(cr, width, height, false, false, true, true, dpi(4))
                end,
                widget = wibox.container.background,
              },
              id = 'wifi_list_height',
              strategy = 'exact',
              height = 0,
              widget = wibox.container.constraint,
            },
            {
              {
                {
                  dnd,
                  widget = wibox.container.place,
                },
                nil,
                {
                  {
                    {
                      image = gcolor.recolor_image(icondir .. 'refresh.svg', beautiful.colorscheme.bg_red),
                      resize = false,
                      valign = 'center',
                      halign = 'center',
                      widget = wibox.widget.imagebox,
                    },
                    widget = wibox.container.margin,
                    margins = dpi(5),
                  },
                  id = 'refresh_button',
                  border_color = beautiful.colorscheme.border_color,
                  border_width = dpi(2),
                  bg = beautiful.colorscheme.bg,
                  shape = beautiful.shape[4],
                  widget = wibox.container.background,
                },
                layout = wibox.layout.align.horizontal,
              },
              top = dpi(10),
              widget = wibox.container.margin,
            },
            layout = wibox.layout.fixed.vertical,
          },
          margins = dpi(15),
          widget = wibox.container.margin,
        },
        shape = beautiful.shape[8],
        border_color = beautiful.colorscheme.border_color,
        bg = beautiful.colorscheme.bg,
        border_width = dpi(2),
        widget = wibox.container.background,
      },
      strategy = 'exact',
      width = dpi(400),
      widget = wibox.container.constraint,
    }
    gtable.crush(self, w)

    --- Get the current wifi device.
    ---! In theory its not needed to update, why would the wifi card change? Needs validation.
    self.device = networkManager:get_wireless_device()

    local wifi_list = w:get_children_by_id('wifi_list')[1]
    local wifi_list_height = w:get_children_by_id('wifi_list_height')[1]
    local wifi_list_bar = w:get_children_by_id('wifi_list_bar')[1]
    local wifi_icon = w:get_children_by_id('wifi_icon')[1]

    -- Dropdown animation
    local wifi_list_anim = rubato.timed {
      duration = 0.2,
      pos = wifi_list_height.height,
      clamp_position = true,
      rate = 24,
      subscribed = function(v)
        wifi_list_height.height = v
      end,
    }

    -- Dropdown toggle
    wifi_list_bar:buttons(gtable.join {
      abutton({}, 1, function()
        if wifi_list_height.height == 0 then
          local size = (wifi_list.children and #wifi_list.children or 0) * dpi(50)
          if size > dpi(330) then
            size = dpi(330)
          end
          wifi_list_anim.target = dpi(size)
          wifi_list_bar.shape = function(cr, width, height)
            gshape.partially_rounded_rect(cr, width, height, true, true, false, false, dpi(4))
          end
          if #wifi_list.children > 0 then
            wifi_icon:set_image(gcolor.recolor_image(icondir .. 'menu-up.svg',
              beautiful.colorscheme.bg_red))
          else
            wifi_icon:set_image(gcolor.recolor_image(icondir .. 'menu-down.svg',
              beautiful.colorscheme.bg_red))
          end
        else
          wifi_list_anim.target = 0
          wifi_list_bar.shape = function(cr, width, height)
            gshape.partially_rounded_rect(cr, width, height, true, true, true, true, dpi(4))
          end
          wifi_icon:set_image(gcolor.recolor_image(icondir .. 'menu-down.svg',
            beautiful.colorscheme.bg_red))
        end
      end),
    })

    --- Manual rescan request, this gets all AP's and updates the list
    local refresh_button = w:get_children_by_id('refresh_button')[1]
    refresh_button:buttons(gtable.join {
      abutton({}, 1, nil, function()
        local wifi_device = networkManager:get_wireless_device()
        if not wifi_device then return end

        wifi_device:RequestScan(function(ap_list)
          self:set_wifi_list(ap_list)
        end)
      end),
    })
    do
      local wifi_device = networkManager:get_wireless_device()
      if not wifi_device then return end

      wifi_device:RequestScan(function(ap_list)
        self:set_wifi_list(ap_list)
      end)

      dnd:buttons(gtable.join {
        abutton({}, 1, function()
          networkManager:toggle_wifi()
        end),
      })
    end

    --- Automatically toggle the Wifi toggle when the wifi state changed
    networkManager:connect_signal('NetworkManager::WirelessEnabled', function(_, enabled)
      if enabled then
        dnd:set_enabled()
      else
        dnd:set_disabled()
      end
    end)
    ---TODO:Toggle a general network switch, where should the widget be added?
    networkManager:connect_signal('NetworkManager::NetworkingEnabled', function(_, enabled)
      --[[ if enabled then
        dnd:set_enabled()
      else
        dnd:set_disabled()
      end ]]
    end)
    --- Automatically delete a lost AP from the list
    self.device:connect_signal('NetworkManagerDeviceWireless::AccessPointRemoved', function(_, ap)
      self:delete_ap_from_list(ap)
    end)
    --- Automatically add a new AP to the list, if it is not already in the list
    self.device:connect_signal('NetworkManagerDeviceWireless::AccessPointAdded', function(_, ap)
      if not self:is_ap_in_list(ap) then
        self:add_ap_to_list(ap)
      end
    end)
    --- Automatically resort the list when the active AP changed
    --- This is needed because otherwise the active AP would be where the new one currently is in the list
    self.device:connect_signal('NetworkManagerDeviceWireless::ActiveAccessPoint', function()
      self:resort_wifi_list()
    end)

    return self
  end,
})
