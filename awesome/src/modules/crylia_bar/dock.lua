local setmetatable = setmetatable
local table = table
local ipairs = ipairs
local pairs = pairs

-- Awesome Libs
local abutton = require('awful.button')
local aplacement = require('awful.placement')
local apopup = require('awful.popup')
local awidget = require('awful.widget')
local beautiful = require('beautiful')
local dpi = require('beautiful').xresources.apply_dpi
local gcolor = require('gears.color')
local gfilesystem = require('gears.filesystem')
local gtable = require('gears.table')
local gtimer = require('gears.timer')
local lgi = require('lgi')
local Gio = lgi.Gio
local wibox = require('wibox')

-- Local libs
local config = require('src.tools.config')
local context_menu = require('src.modules.context_menu')
local hover = require('src.tools.hover')
local icon_lookup = require('src.tools.gio_icon_lookup')()

local capi = {
  awesome = awesome,
  client = client,
  mouse = mouse,
  screen = screen,
}

local icondir = gfilesystem.get_configuration_dir() .. 'src/assets/icons/'

local elements = {
  ['pinned'] = {},
  ['applauncher_starter'] = {},
  ['running'] = {},
}

local instances = {}

local dock = { mt = {} }

--[[ Json format of dock.json, running apps won't be saved
  [
    {
      "applauncher_starter": {
        {
          "name": "Application Launcher",
          "icon": "/usr/share/icons/Papirus/48x48/apps/xfce4-appfinder.svg",
        }
      },
      "pinned": [
        {
          "name": "firefox",
          "icon": "/usr/share/icons/Papirus/48x48/apps/firefox.svg",
          "exec": "firefox",
          "desktop_file": "/usr/share/applications/firefox.desktop"
        },
        {
          "name": "discord",
          "icon": "/usr/share/icons/Papirus/48x48/apps/discord.svg",
          "exec": "discord",
          "desktop_file": "/usr/share/applications/discord.desktop"
        }
      ],
    }
  ]
]]

function dock:toggle()
  self.popup.visible = not self.popup.visible
end

function dock:write_elements_to_file_async()
  --create a local copy of the elements["pinned"] table and only set the desktop_file key from its children
  local elements_copy = { pinned = {} }
  for _, element in ipairs(elements['pinned']) do
    table.insert(elements_copy['pinned'], { desktop_file = element.desktop_file })
  end

  config.write_json(gfilesystem.get_configuration_dir() .. 'src/config/dock_' .. self.screen.index .. '.json', elements_copy['pinned'])
end

---Read the content of dock.json and get the content as a table
function dock:read_elements_from_file_async()
  local data = config.read_json(gfilesystem.get_configuration_dir() .. 'src/config/dock_' .. self.screen.index .. '.json')
  -- Make sure to not set the running key to nil on accident
  for _, v in ipairs(data) do
    local w = self:get_element_widget(v.desktop_file)
    table.insert(elements['pinned'], w)
  end
end

---Creates a pinned widget for the dock and adds it into the elements table
---@param desktop_file string .desktop file path
---@return nil
function dock:get_element_widget(desktop_file)
  if not desktop_file then return end

  local GDesktopAppInfo = Gio.DesktopAppInfo.new_from_filename(desktop_file)
  if not GDesktopAppInfo then
    return 
  end
  local icon = icon_lookup:get_gicon_path(nil, GDesktopAppInfo.get_string(GDesktopAppInfo, 'Icon')) or
      icon_lookup:get_gicon_path(nil, Gio.DesktopAppInfo.get_string(GDesktopAppInfo, 'X-AppImage-Old-Icon')) or ''

  local widget = wibox.widget {
    {
      {
        {
          {
            widget = wibox.widget.imagebox,
            image = icon,
            valign = 'center',
            halign = 'center',
            resize = true,
            id = 'icon_role',
          },
          widget = wibox.container.constraint,
          width = beautiful.user_config.dock_icon_size,
          height = beautiful.user_config.dock_icon_size,
        },
        widget = wibox.container.margin,
        margins = dpi(5),
      },
      widget = wibox.container.constraint,
      width = beautiful.user_config.dock_icon_size + dpi(10), -- + margins
      height = beautiful.user_config.dock_icon_size + dpi(10),
      strategy = 'exact',
    },
    bg = beautiful.colorscheme.bg1,
    shape = beautiful.shape[8],
    widget = wibox.container.background,
    desktop_file = desktop_file,
  }

  local action_entries = {}
  for _, action in ipairs(Gio.DesktopAppInfo.list_actions(GDesktopAppInfo)) do
    table.insert(action_entries, {
      name = Gio.DesktopAppInfo.get_action_name(GDesktopAppInfo, action) or '',
      icon = icon_lookup:get_gicon_path(nil, GDesktopAppInfo.get_string(GDesktopAppInfo, 'Icon')) or
          icon_lookup:get_gicon_path(nil, Gio.DesktopAppInfo.get_string(GDesktopAppInfo, 'X-AppImage-Old-Icon')) or
          gcolor.recolor_image(icondir .. 'entry.svg', beautiful.colorscheme.bg_yellow),
      callback = function()
        Gio.DesktopAppInfo.launch_action(GDesktopAppInfo, action)
      end,
    })
  end

  table.insert(action_entries, {
    name = 'Remove from Dock',
    icon = gcolor.recolor_image(icondir .. 'context_menu/entry.svg', beautiful.colorscheme.bg_yellow),
    callback = function()
      local data = config.read_json(gfilesystem.get_configuration_dir() .. 'src/config/dock_' .. self.screen.index .. '.json')
      for i, v in ipairs(data) do
        if v.desktop_file == desktop_file then
          if type(data) == 'table' then
            table.remove(data, i)
          end
          break
        end
      end
      config.write_json(gfilesystem.get_configuration_dir() .. 'src/config/dock_' .. self.screen.index .. '.json', data)
      self:remove_element_widget(widget)
    end,
  })

  widget.cm = context_menu {
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
    }, spacing = dpi(10),
    entries = action_entries,
  }

  widget.cm:connect_signal('mouse::leave', function()
    widget.cm.visible = false
    self.cm_open = widget.cm.visible
  end)

  hover.bg_hover {
    widget = widget,
    overlay = 12,
    press_overlay = 24,
  }

  local exec = Gio.DesktopAppInfo.get_string(GDesktopAppInfo, 'Exec')

  widget:buttons(gtable.join {
    abutton({}, 1, function()
      Gio.AppInfo.launch_uris_async(Gio.AppInfo.create_from_commandline(exec, nil, 0))
    end),
    abutton({}, 3, function()
      widget.cm:toggle()
      self.cm_open = widget.cm.visible
    end),
  })

  table.insert(elements['pinned'], widget)
  self:emit_signal('dock::element_added', widget)
end

---Removes a given widget from the dock
---@param widget wibox.widget The widget to remove
function dock:remove_element_widget(widget)
  if not widget then return end
  for k, v in pairs(elements['pinned']) do
    if v == widget then
      table.remove(elements['pinned'], k)
      self:emit_signal('dock::element_removed', widget)
      return
    end
  end
end

---Pins an element to the dock by adding it to the pinned table, then writes the table to the file
---emits the signal `dock::pin_element` then successfully added to the table
---@param args {desktop_file: string} The path to the .desktop file
function dock:pin_element(args)
  if not args then return end
  local e = args.desktop_file

  self:emit_signal('dock::pin_element', e)

  self:write_elements_to_file_async()
end

function dock:add_start_element()
  local widget = wibox.widget {
    {
      {
        {
          {
            widget = wibox.widget.imagebox,
            image = gfilesystem.get_configuration_dir() .. 'src/assets/CT.svg',
            valign = 'center',
            halign = 'center',
            resize = true,
            id = 'icon_role',
          },
          widget = wibox.container.constraint,
          width = beautiful.user_config.dock_icon_size,
          height = beautiful.user_config.dock_icon_size,
        },
        widget = wibox.container.margin,
        margins = dpi(5),
      },
      widget = wibox.container.constraint,
      width = beautiful.user_config.dock_icon_size + dpi(10), -- + margins
      height = beautiful.user_config.dock_icon_size + dpi(10),
      strategy = 'exact',
    },
    bg = beautiful.colorscheme.bg1,
    shape = beautiful.shape[8],
    widget = wibox.container.background,
  }

  hover.bg_hover {
    widget = widget,
    overlay = 12,
    press_overlay = 24,
  }

  widget:buttons(gtable.join {
    abutton({}, 1, function()
      capi.awesome.emit_signal('application_launcher::show')
    end),
  })
  return widget
end

function dock:unpin_element(args)
  if not args then return end

  for index, value in ipairs(elements['pinned']) do
    if value == args.desktop_file then
      table.remove(elements['pinned'], index)
      break;
    end
  end
  self:emit_signal('dock::unpin_element', args.desktop_file)

  self:write_elements_to_file_async()
end

function dock:get_all_elements()
  return elements
end

function dock:get_applauncher_starter_element()
  return elements['applauncher_starter']
end

function dock:get_pinned_elements()
  return elements['pinned']
end

function dock:get_running_elements()
  return elements['running']
end

function dock:get_dock_for_screen(screen)
  return instances[screen]
end

local function check_for_dock_hide(self, a_popup)
  if self.cm_open then return end
  local clients_on_tag = self.screen.selected_tag:clients()

  -- If there is no client on the current tag show the dock
  if #clients_on_tag < 1 then
    self.visible = true
    return
  end

  -- If there is a maximized client hide the dock and if fullscreened hide the activation area
  for _, client in ipairs(clients_on_tag) do
    if client.maximized or client.fullscreen then
      dock.visible = false
      if client.fullscreen then
        a_popup.visible = false
        capi.awesome.emit_signal('notification_center_activation::toggle', self.screen, false)
      end
    elseif not client.fullscreen then
      a_popup.visible = true
      capi.awesome.emit_signal('notification_center_activation::toggle', self.screen, true)
    end
  end

  if self.screen == capi.mouse.screen then
    local minimized = false
    for _, c in ipairs(clients_on_tag) do
      if c.minimized then
        minimized = true
      else
        minimized = false
        local y = c:geometry().y
        local h = c.height
        if (y + h) >= self.screen.geometry.height - beautiful.user_config.dock_icon_size - 35 then
          self.visible = false
          return
        else
          self.visible = true
        end
      end
    end
    if minimized then
      self.visible = true
    end
  else
    self.visible = false
  end
end

function dock:activation_area()
  local activation = apopup {
    widget = {
      width = self.screen.geometry.width / 4,
      height = 1,
      strategy = 'exact',
      widget = wibox.container.constraint,
    },
    ontop = true,
    bg = gcolor.transparent,
    visible = false,
    screen = self.screen,
    type = 'dock',
    placement = function(c) aplacement.bottom(c) end,
  }

  -- Call the function every second to check if the dock needs to be hidden
  local dock_hide = gtimer {
    timeout = 1,
    autostart = true,
    call_now = true,
    callback = function()
      check_for_dock_hide(self, activation)
    end,
  }

  activation:connect_signal('mouse::enter', function()
    if #self.screen.clients < 1 then
      self.visible = true
      dock_hide:stop()
      return
    end
    for _, c in ipairs(self.screen.clients) do
      if not c.fullscreen then
        self.visible = true
        dock_hide:stop()
      end
    end
  end)

  self:connect_signal('mouse::enter', function()
    dock_hide:stop()
  end)

  self:connect_signal('mouse::leave', function()
    --[[ if cm_open then
        return
      end ]]
    check_for_dock_hide(self, activation)
    dock_hide:again()
  end)
end

function dock.new(args)
  args = args or {}

  local w = apopup {
    widget = {
      {
        {
          spacing = dpi(5),
          id = 'applauncher_starter',
          layout = wibox.layout.fixed.horizontal,
        },
        wibox.widget.separator {
          forced_width = dpi(2),
          forced_height = dpi(20),
          thickness = dpi(2),
          color = beautiful.colorscheme.border_color,
        },
        {
          spacing = dpi(5),
          id = 'pinned',
          layout = wibox.layout.fixed.horizontal,
        },
        {
          id = 'running',
          spacing = dpi(5),
          layout = wibox.layout.fixed.horizontal,
        },
        spacing = dpi(10),
        id = 'elements',
        layout = wibox.layout.fixed.horizontal,
      },
      widget = wibox.container.margin,
      margins = dpi(5),
    },
    ontop = true,
    visible = true,
    placement = function(c) aplacement.bottom(c, { margins = dpi(10) }) end,
    bg = beautiful.colorscheme.bg,
    screen = args.screen,
  }

  gtable.crush(w, dock)

  instances[args.screen] = w

  w:activation_area()

  w.task_list = awidget.tasklist {
    screen = args.screen,
    layout = wibox.layout.fixed.horizontal,
    filter = awidget.tasklist.filter.alltags,
    update_function = function(widget, _, _, _, clients)
      widget:reset()

      if #clients == 0 then
        return widget
      end

      widget:add {
        {
          widget = wibox.widget.separator,
          forced_height = dpi(20),
          forced_width = dpi(2),
          thickness = dpi(2),
          color = beautiful.colorscheme.border_color,
        },
        widget = wibox.container.margin,
        right = dpi(5),
      }

      for _, client in ipairs(clients) do
        local element = wibox.widget {
          {
            {
              {
                {
                  widget = wibox.widget.imagebox,
                  image = client.icon,
                  valign = 'center',
                  halign = 'center',
                  resize = true,
                  id = 'icon_role',
                },
                widget = wibox.container.constraint,
                width = beautiful.user_config.dock_icon_size,
                height = beautiful.user_config.dock_icon_size,
              },
              widget = wibox.container.margin,
              margins = dpi(5),
            },
            widget = wibox.container.constraint,
            width = beautiful.user_config.dock_icon_size + dpi(10), -- + margins
            height = beautiful.user_config.dock_icon_size + dpi(10),
            strategy = 'exact',
          },
          bg = beautiful.colorscheme.bg1,
          shape = beautiful.shape[8],
          widget = wibox.container.background,
        }

        hover.bg_hover {
          widget = element,
          overlay = 12,
          press_overlay = 24,
        }

        element:buttons(gtable.join(
          abutton({}, 1, function()
            if client == client.focus then
              client.minimized = true
            else
              if client.first_tag then
                client.first_tag:view_only()
              end
              client:emit_signal('request::activate')
              client:raise()
            end
          end),
          abutton({}, 3, function()
            --TODO: Add context menu with options
          end)
        ))

        widget:add(element)
        widget:set_spacing(dpi(5))
      end

      return widget
    end,
  }

  w.widget.elements.applauncher_starter:add(w:add_start_element())

  w.widget.elements.running:add(w.task_list)

  w:connect_signal('dock::element_added', function(_, widget)
    w.widget.elements.pinned:add(widget)
  end)

  w:connect_signal('dock::element_removed', function(_, widget)
    w.widget.elements.pinned:remove_widgets(widget)
  end)

  w:connect_signal('dock::pin_element', function(_, element)
    w:get_element_widget(element)
  end)

  capi.awesome.connect_signal('dock::pin_element', function(args)
    w:pin_element(args)
  end)

  w:connect_signal('dock::unpin_element', function(_, widget)
    w:remove_element_widget(widget)
  end)

  w:read_elements_from_file_async()

  return w
end

return setmetatable(dock, { __call = function(_, ...) return dock.new(...) end })
