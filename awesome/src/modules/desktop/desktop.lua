local Gio = require('lgi').Gio
local awful = require('awful')
local dpi = require('beautiful').xresources.apply_dpi
local beautiful = require('beautiful')
local gcolor = require('gears.color')
local gfilesystem = require('gears.filesystem')
local grid = require('wibox.layout.grid')
local gshape = require('gears.shape')
local gtable = require('gears.table')
local wibox = require('wibox')

local config = require('src.tools.config')
local element = require('src.modules.desktop.element')
local cm = require('src.modules.context_menu')

local capi = {
  mouse = mouse,
  awesome = awesome,
  screen = screen,
}

local icondir = gfilesystem.get_configuration_dir() .. 'src/assets/icons/desktop/'

local desktop = { mt = {} }

function desktop:save_layout()
  local layout = {}

  local dir = gfilesystem.get_configuration_dir() .. 'src/config/files/desktop/icons/'
  if not gfilesystem.dir_readable(dir) then
    gfilesystem.make_directories(dir)
  end

  for i, widget in ipairs(self.widget.mrgn.grid.children) do
    local pos = self.widget.mrgn.grid:get_widget_position(widget)

    layout[i] = {
      row = pos.row,
      col = pos.col,
      widget = {
        icon = widget.icon,
        label = widget.label,
        exec = widget.exec,
        icon_size = widget.icon_size,
      },
    }
  end

  dir = gfilesystem.get_configuration_dir() .. 'src/config/desktop.json'
  gfilesystem.make_directories(dir)
  config.write_json(dir, layout)
end

function desktop:load_layout()
  local dir = gfilesystem.get_configuration_dir() .. 'src/config/desktop.json'
  if not gfilesystem.file_readable(dir) then return end

  local data = config.read_json(dir)
  if not data then return end
  for _, value in pairs(data) do
    self:add_element(value.widget, { x = value.row, y = value.col })
  end
end

function desktop:get_element_at(x, y)
  local w = self.widget.mrgn.grid:get_widgets_at(x, y)
  return w and w[1] or nil
end

function desktop:add_desktop_file(app_info)
  self:add_element {
    icon = app_info.icon,
    label = app_info.label,
    exec = app_info.exec,
    icon_size = dpi(48),
    desktop_file = app_info.desktop_file,
    parent = self.widget.mrgn.grid,
    width = self.widget_width,
    height = self.widget_height,
  }
end

--[[
  Removes a given widget and returns it
]]
function desktop:remove_element(e)
  return (self.widget.mrgn.grid:remove(e) and e) or nil
end

function desktop:get_grid_index_at(y, x)
  local margin_x, margin_y = dpi(10), dpi(10)
  local screen_width, screen_height = self.args.screen.geometry.width - margin_x * 2, self.args.screen.geometry.height - dpi(75) - dpi(95) - margin_y * 2
  local cell_width, cell_height = screen_width / 15, screen_height / 8

  local col = math.floor((x - margin_x) / cell_width) + 1
  col = math.min(col, 15)
  col = math.max(col, 1)

  local row = math.floor((y - margin_y) / cell_height) + 1
  row = math.min(row, 8)
  row = math.max(row, 1)

  return col, row
end

---Main function to add an element to the desktop
---it will automatically place it on an empty spot and save it
---@param args table widget arguments
---@param pos table|nil {x = , y = }
function desktop:add_element(args, pos)
  -- add into next available position
  local x, y = self.widget.mrgn.grid:get_next_empty()

  if pos then
    x = pos.x
    y = pos.y
  end

  local e = element {
    icon = args.icon,
    label = args.label,
    exec = args.exec,
    icon_size = args.icon_size,
    desktop_file = args.desktop_file,
    parent = args.parent,
    width = self.widget_width,
    height = self.widget_height,
  }

  local cm_popup = cm {
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
        name = 'Open with',
        icon = gcolor.recolor_image(icondir .. 'launch.svg', beautiful.colorscheme.bg_purple),
        submenu = {
          --!TODO: Fetch programs and add them as entries
        },
      },
      {
        name = 'Copy',
        icon = gcolor.recolor_image(icondir .. 'copy.svg', beautiful.colorscheme.bg_purple),
        callback = function()
        end,
      },
      {
        name = 'Cut',
        icon = gcolor.recolor_image(icondir .. 'cut.svg', beautiful.colorscheme.bg_purple),
        callback = function()
        end,
      },
      {
        name = 'Rename',
        icon = gcolor.recolor_image(icondir .. 'edit.svg', beautiful.colorscheme.bg_purple),
        callback = function()
        end,
      },
      {
        name = 'Remove',
        icon = gcolor.recolor_image(icondir .. 'delete.svg', beautiful.colorscheme.bg_purple),
        callback = function()
          self:remove_element(e)
          self:save_layout()
        end,
      },
      {
        name = 'Actions',
        icon = gcolor.recolor_image(icondir .. 'dots-vertical.svg', beautiful.colorscheme.bg_purple),
        submenu = {
          -- TODO: fetch actions from desktop file
        },
      },
    },
  }

  cm_popup:connect_signal('mouse::leave', function()
    cm_popup.visible = false
  end)

  -- While the mouse is down, remove the element from the grid and add it to manual then move it
  -- until the mouse is released and then add it back to the grid.
  e:connect_signal('button::press', function(_, _, _, b)
    if not mousegrabber.isrunning() then

      local dnd_widget = element {
        icon = args.icon,
        label = args.label,
        exec = args.exec,
        icon_size = args.icon_size,
        desktop_file = args.desktop_file,
        parent = args.parent,
        width = self.widget_width,
        height = self.widget_height,
      }
      dnd_widget.visible = false

      dnd_widget:get_children_by_id('icon_role')[1].opacity = 0.6

      local start_pos = capi.mouse.coords()
      dnd_widget.point = { x = math.floor(start_pos.x - self.args.screen.geometry.x), y = math.floor(start_pos.y - self.args.screen.geometry.y) }
      local old_pos = self.widget.mrgn.grid:get_widget_position(e)
      self.widget.manual:add(dnd_widget)
      mousegrabber.run(function(m)
        if (math.abs(m.x - start_pos.x) > 10 or
            math.abs(m.x - start_pos.x) < -10 or
            math.abs(m.y - start_pos.y) > 10 or
            math.abs(m.y - start_pos.y) < -10) and
            m.buttons[1] then
          self:remove_element(e)
          dnd_widget.visible = true
          dnd_widget.bg = gcolor('#0ffff088')
          dnd_widget.border_color = gcolor('#0ffff0')

          self.widget.manual:move_widget(dnd_widget, {
            x = (m.x - dnd_widget.width / 2) - self.args.screen.geometry.x,
            y = (m.y - dnd_widget.height / 2) - self.args.screen.geometry.y,
          })
        end

        if not m.buttons[1] then
          if b == 1 then
            dnd_widget.bg = gcolor('#0ffff088')
            dnd_widget.border_color = gcolor('#0ffff0')

            if dnd_widget.visible then
              dnd_widget.visible = false

              local newp_x, newp_y = self:get_grid_index_at(
                (m.y - dnd_widget.height / 2) - self.args.screen.geometry.y,
                (m.x - dnd_widget.width / 2) - self.args.screen.geometry.x
              )
              if not self.widget.mrgn.grid:get_widgets_at(newp_y, newp_x) then
                self.widget.mrgn.grid:add_widget_at(e, newp_y, newp_x)
                self:save_layout()
              else
                self.widget.mrgn.grid:add_widget_at(e, old_pos.row, old_pos.col)
              end
            else
              Gio.AppInfo.launch_uris_async(Gio.AppInfo.create_from_commandline(e.exec, nil, 0))
              self.widget.manual:reset()
            end
            mousegrabber.stop()
          elseif b == 3 then
            cm_popup:toggle()
            mousegrabber.stop()
          end
        end

        return m.buttons[1]
      end, 'left_ptr')
    end
  end)

  self.widget.mrgn.grid:add_widget_at(e, x, y)
  self:save_layout()
end

function desktop:draw_selector()
  local start_pos = capi.mouse.coords()
  if not mousegrabber.isrunning() then
    local selector = wibox.widget {
      widget = wibox.container.background,
      bg = gcolor('#0ffff088'),
      border_color = gcolor('#0ffff0'),
      border_width = dpi(2),
      forced_width = 0,
      forced_height = 0,
      x = start_pos.x - self.args.screen.geometry.x,
      y = start_pos.y - self.args.screen.geometry.y,
      visible = true,
      shape = beautiful.shape[10],
    }
    selector.point = { x = start_pos.x - self.args.screen.geometry.x, y = start_pos.y - self.args.screen.geometry.y }
    self.widget.manual:add(selector)
    mousegrabber.run(function(m)
      if m.buttons[1] then
        selector.visible = true
      end
      if not m.buttons[1] then
        mousegrabber.stop()
        selector.visible = false
        self.widget.manual:reset()
      end
      local dx = m.x - start_pos.x
      local dy = m.y - start_pos.y
      local gx, gy = self:get_grid_index_at(math.abs(dy), math.abs(dx))
      selector.forced_width = math.abs(dx)
      selector.forced_height = math.abs(dy)
      --if the mouse is moving to the left, move the widget to the left
      if dx < 0 then
        selector.x = start_pos.x - self.args.screen.geometry.x + dx
        selector.point.x = start_pos.x - self.args.screen.geometry.x + dx
        gx, gy = self:get_grid_index_at(selector.point.y, selector.point.x)
      end
      --if the mouse is moving up, move the widget up
      if dy < 0 then
        selector.y = start_pos.y - self.args.screen.geometry.y + dy
        selector.point.y = start_pos.y - self.args.screen.geometry.y + dy
        gx, gy = self:get_grid_index_at(selector.point.y, selector.point.x)
      end
      -- check if a widget is inside the selector
      local w = self:get_element_at(gx, gy)
      if w then
        w.bg = gcolor('#0ffff088')
        w.border_color = gcolor('#0ffff0')
      end
      return m.buttons[1]
    end, 'left_ptr')
  end
end

function desktop:add_xdg()
  self:add_element {
    icon = '/usr/share/icons/Papirus-Dark/96x96/places/user-trash.svg',
    label = 'Papierkorb',
    exec = 'nautilus trash:/',
    icon_size = dpi(48),
  }

  self:add_element {
    icon = '/usr/share/icons/Papirus-Dark/96x96/places/user-home.svg',
    label = 'Persönlicher Ordner',
    exec = 'nautilus file:/home/crylia',
    icon_size = dpi(48),
  }
end

function desktop.new(args)
  args = args or {}

  args.icon_size = dpi(48)

  local rows = 15
  local cols = 8
  local h_spacing = dpi(10)
  local v_spacing = dpi(20)

  --[[
    The wibox has a stacked layout with a manual layout over a grid.
    
    stacked
      manual
      grid
    
    manual: For positioning the dragged element since this layout allows for arbitrary positioning.
    grid: For positioning the elements in a grid.
  ]]
  local w = wibox {
    ontop = false,
    visible = true,
    type = 'desktop',
    input_passthrough = false,
    x = args.screen.geometry.x,
    y = args.screen.geometry.y,
    bg = gcolor.transparent,
    width = args.screen.geometry.width,
    height = args.screen.geometry.height,
    screen = args.screen,
    widget = wibox.widget {
      {
        {
          layout = grid,
          homogeneous = true,
          horizontal_spacing = h_spacing,
          vertical_spacing = v_spacing,
          expand = false,
          orientation = 'horizontal',
          forced_num_cols = rows,
          forced_num_rows = cols,
          id = 'grid',
        },
        widget = wibox.container.margin,
        left = dpi(10),
        right = dpi(10),
        top = dpi(75),
        bottom = dpi(95),
        id = 'mrgn',
      },
      {
        layout = wibox.layout.manual,
        id = 'manual',
      },
      layout = wibox.layout.stack,
    },
  }

  w.args = args

  local cm_popup = cm {
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
        name = 'Create new',
        icon = gcolor.recolor_image(icondir .. 'file_add.svg', beautiful.colorscheme.bg_purple),
        submenu = {
          {
            name = 'Folder',
            icon = gcolor.recolor_image(icondir .. 'folder.svg', beautiful.colorscheme.bg_purple),
            callback = function()
              --create a new folder and if it exists add a number to the end
              local folder_name = 'New folder'
              local folder_path = os.getenv('HOME') .. '/Desktop/' .. folder_name
              local i = 1
              while gfilesystem.dir_readable(folder_path) do
                folder_name = 'New folder ' .. '(' .. i .. ')'
                folder_path = os.getenv('HOME') .. '/Desktop/' .. folder_name
                i = i + 1
              end
              gfilesystem.make_directories(folder_path)
              w:add_element {
                icon = '/usr/share/icons/Papirus-Dark/24x24/places/folder.svg',
                label = folder_name,
                exec = 'nautilus file:\"' .. folder_path .. '\"',
                icon_size = dpi(48),
              }
            end,
          },
          {
            name = 'File',
            icon = gcolor.recolor_image(icondir .. 'file.svg', beautiful.colorscheme.bg_purple),
            callback = function()
              --create new text file and if it exists add a number to the end
              local file_name = 'New file.txt'
              local file_path = os.getenv('HOME') .. '/Desktop/' .. file_name
              local i = 1
              while gfilesystem.file_readable(file_path) do
                file_name = 'New file ' .. '(' .. i .. ')'
                file_path = os.getenv('HOME') .. '/Desktop/' .. file_name
                i = i + 1
              end
              awful.spawn.with_shell('touch ' .. file_path)
              w:add_element {
                icon = '/usr/share/icons/Papirus-Dark/24x24/mimetypes/text-plain.svg',
                label = file_name,
                exec = 'xdg-open ' .. file_path,
                icon_size = dpi(48),
              }
            end,
          },
        },
      },
      {
        name = 'Terminal',
        icon = gcolor.recolor_image(icondir .. 'terminal.svg', beautiful.colorscheme.bg_purple),
        callback = function()
          awful.spawn(beautiful.user_config.terminal)
        end,
      },
      {
        name = 'Web Browser',
        icon = gcolor.recolor_image(icondir .. 'web_browser.svg', beautiful.colorscheme.bg_purple),
        callback = function()
          awful.spawn(beautiful.user_config.web_browser)
        end,
      },
      {
        name = 'File Manager',
        icon = gcolor.recolor_image(icondir .. 'file_manager.svg', beautiful.colorscheme.bg_purple),
        callback = function()
          awful.spawn(beautiful.user_config.file_manager)
        end,
      },
      {
        name = 'Text Editor',
        icon = gcolor.recolor_image(icondir .. 'text_editor.svg', beautiful.colorscheme.bg_purple),
        callback = function()
          awful.spawn(beautiful.user_config.text_editor)
        end,
      },
      {
        name = 'Music Player',
        icon = gcolor.recolor_image(icondir .. 'music_player.svg', beautiful.colorscheme.bg_purple),
        callback = function()
          awful.spawn(beautiful.user_config.music_player)
        end,
      },
      {
        name = 'Applications',
        icon = gcolor.recolor_image(icondir .. 'application.svg', beautiful.colorscheme.bg_purple),
        callback = function()
        end,
      },
      {
        name = 'GTK Settings',
        icon = gcolor.recolor_image(icondir .. 'gtk_settings.svg', beautiful.colorscheme.bg_purple),
        callback = function()
          awful.spawn(beautiful.user_config.gtk_settings)
        end,
      },
      {
        name = 'Energy Settings',
        icon = gcolor.recolor_image(icondir .. 'energy_settings.svg', beautiful.colorscheme.bg_purple),
        callback = function()
          awful.spawn(beautiful.user_config.energy_manager)
        end,
      },
      {
        name = 'Screen Settings',
        icon = gcolor.recolor_image(icondir .. 'screen_settings.svg', beautiful.colorscheme.bg_purple),
        callback = function()
          awful.spawn(beautiful.user_config.screen_settings)
        end,
      },
      {
        name = 'Reload Awesome',
        icon = gcolor.recolor_image(icondir .. 'refresh.svg', beautiful.colorscheme.bg_purple),
        callback = function()
          capi.awesome.restart()
        end,
      },
      {
        name = 'Quit',
        icon = gcolor.recolor_image(icondir .. 'quit.svg', beautiful.colorscheme.bg_purple),
        callback = function()
          capi.awesome.quit()
        end,
      },
      --cm_awesome
    },
  }

  w.widget.manual:buttons(gtable.join(
    awful.button({}, 1, function()
      cm_popup.visible = false
      if capi.mouse.current_widgets[4] == w.widget.manual then
        w:draw_selector()
      end
    end),
    awful.button({}, 3, function()
      if capi.mouse.current_widgets[4] == w.widget.manual then
        cm_popup:toggle()
      end
    end)
  ))

  gtable.crush(w, desktop, true)

  w.widget_width = (args.screen.geometry.width - 20 - ((h_spacing - 1) * rows)) / rows
  w.widget_height = (args.screen.geometry.height - 170 - ((v_spacing - 1) * cols)) / cols

  w:load_layout()

  capi.awesome.connect_signal('desktop::add_to_desktop', function(args2)
    w:add_desktop_file(args2)
  end)

  return w
end

function desktop.mt:__call(...)
  return desktop.new(...)
end

return setmetatable(desktop, desktop.mt)
