local base = require("wibox.widget.base")
local dpi = require("beautiful").xresources.apply_dpi
local gtable = require("gears.table")
local gshape = require("gears.shape")
local grid = require("wibox.layout.grid")
local wibox = require("wibox")
local abutton = require("awful.button")
local awful = require("awful")
local gcolor = require("gears.color")
local json = require("src.lib.json-lua.json-lua")
local gfilesystem = require("gears.filesystem")
local Gio = require("lgi").Gio

local element = require("src.modules.desktop.element")
local cm = require("src.modules.context_menu.init")

local capi = {
  mouse = mouse,
  awesome = awesome
}

local icondir = gfilesystem.get_configuration_dir() .. "src/assets/icons/desktop/"

local desktop = { mt = {} }

function desktop:save_layout()
  local layout = {}

  local dir = gfilesystem.get_configuration_dir() .. "src/config/files/desktop/icons/"
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
        label = widget:get_children_by_id("text_role")[1].text,
        exec = widget.exec,
        icon_size = widget.icon_size
      }
    }
  end

  local dir = gfilesystem.get_configuration_dir() .. "src/config"
  gfilesystem.make_directories(dir)
  if not gfilesystem.file_readable(dir .. "/desktop.json") then
    os.execute("touch " .. dir .. "/desktop.json")
  end
  local handler = io.open(dir .. "/desktop.json", "w")
  if not handler then return end

  handler:write(json:encode(layout))
  handler:close()
end

function desktop:load_layout()
  local dir = gfilesystem.get_configuration_dir() .. "src/config"
  if not gfilesystem.file_readable(dir .. "/desktop.json") then
    return
  end
  local handler = io.open(dir .. "/desktop.json", "r")
  if not handler then return end

  local layout = json:decode(handler:read("*all"))
  handler:close()
  if not layout then return end
  for i, value in pairs(layout) do
    self:add_element(value.widget, { x = value.row, y = value.col })
  end
end

function desktop:get_element_at(x, y)
  return self.widget.mrgn.grid:get_widgets_at(x, y)[1]
end

function desktop:add_desktop_file(app_info)
  self:add_element({
    icon = app_info.icon,
    label = app_info.label,
    exec = app_info.exec,
    icon_size = dpi(96),
    desktop_file = app_info.desktop_file,
    parent = self.widget.mrgn.grid,
  })
end

--[[
  Removes a given widget and returns it
]]
function desktop:remove_element(e)
  return (self.widget.mrgn.grid:remove(e) and e) or nil
end

function desktop:get_grid_index_at(y, x)
  local col, row = 1, 1

  local width = dpi(96) * 1.75 * (4 / 3)
  local height = dpi(96) * 1.75
  local spacing = dpi(10)

  while width * col + spacing * (col - 1) < x do
    col = col + 1
  end
  while height * row + spacing * (row - 1) < y do
    row = row + 1
  end

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
    parent = args.parent
  }

  local cm_popup = cm {
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
    },
    spacing = dpi(10),
    entries = {
      {
        name = "Open with",
        icon = gcolor.recolor_image(icondir .. "launch.svg", Theme_config.desktop.context_menu.icon_color),
        submenu = {
          --!TODO: Fetch programs and add them as entries
        }
      },
      {
        name = "Copy",
        icon = gcolor.recolor_image(icondir .. "copy.svg", Theme_config.desktop.context_menu.icon_color),
        callback = function()
        end
      },
      {
        name = "Cut",
        icon = gcolor.recolor_image(icondir .. "cut.svg", Theme_config.desktop.context_menu.icon_color),
        callback = function()
        end
      },
      {
        name = "Rename",
        icon = gcolor.recolor_image(icondir .. "edit.svg", Theme_config.desktop.context_menu.icon_color),
        callback = function()
        end
      },
      {
        name = "Remove",
        icon = gcolor.recolor_image(icondir .. "delete.svg", Theme_config.desktop.context_menu.icon_color),
        callback = function()
          self:remove_element(e)
          self:save_layout()
        end
      },
      {
        name = "Actions",
        icon = gcolor.recolor_image(icondir .. "dots-vertical.svg", Theme_config.desktop.context_menu.icon_color),
        submenu = {
          -- TODO: fetch actions from desktop file
        }
      },
    }
  }

  cm_popup:connect_signal("mouse::leave", function()
    cm_popup.visible = false
  end)

  -- While the mouse is down, remove the element from the grid and add it to manual then move it
  -- until the mouse is released and then add it back to the grid.
  e:connect_signal("button::press", function(_, _, _, b)
    local start_pos = mouse.coords()

    if not mousegrabber.isrunning() then

      local width = args.icon_size * 1.75 * (4 / 3)
      local height = args.icon_size * 1.75

      local dnd_widget = element {
        icon = args.icon,
        label = args.label,
        on_click = args.on_click,
        icon_size = args.icon_size,
        parent = args.parent,
        width = width,
        height = height,
      }
      dnd_widget.visible = false

      dnd_widget:get_children_by_id("icon_role")[1].opacity = 0.6

      local xp, yp = capi.mouse.coords()
      dnd_widget.point = { x = xp, y = yp }

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
          dnd_widget.bg = gcolor("#0ffff088")
          dnd_widget.border_color = gcolor("#0ffff0")
          self.widget.manual:move_widget(dnd_widget, { x = m.x - dnd_widget.width / 2, y = m.y - dnd_widget.height / 2 })
        end

        if not m.buttons[1] then
          if b == 1 then
            dnd_widget.bg = gcolor("#0ffff088")
            dnd_widget.border_color = gcolor("#0ffff0")

            if dnd_widget.visible then
              dnd_widget.visible = false

              local np_x, np_y = self:get_grid_index_at(m.y, m.x)
              if not self.widget.mrgn.grid:get_widgets_at(np_y, np_x) then
                self.widget.mrgn.grid:add_widget_at(e, np_y, np_x)
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
      end, "left_ptr")
    end
  end)

  self.widget.mrgn.grid:add_widget_at(e, x, y)
  self:save_layout()
end

function desktop:draw_selector()
  local start_pos = mouse.coords()
  if not mousegrabber.isrunning() then
    local selector = wibox.widget {
      widget = wibox.container.background,
      bg = gcolor("#0ffff088"),
      border_color = gcolor("#0ffff0"),
      border_width = dpi(2),
      width = 100,
      height = 100,
      visible = true,
      shape = function(cr, w, h)
        gshape.rounded_rect(cr, w, h, dpi(10))
      end
    }

    local coords = capi.mouse.coords()
    selector.point = { x = coords.x, y = coords.y }
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
    end, "left_ptr")
  end
end

function desktop:add_xdg()
  self:add_element({
    icon = "/usr/share/icons/Papirus-Dark/96x96/places/user-trash.svg",
    label = "Papierkorb",
    exec = "nautilus trash:/",
    icon_size = 96,
  })

  self:add_element({
    icon = "/usr/share/icons/Papirus-Dark/96x96/places/user-home.svg",
    label = "Persönlicher Ordner",
    exec = "nautilus file:/home/crylia",
    icon_size = 96,
  })
end

function desktop.new(args)
  args = args or {}

  args.screen = args.screen or awful.screen.focused()

  local icon_size = args.icon_size or dpi(96)

  -- calculate the row and column count based on the screen size and icon size and aspect ratio of 16:9
  local screen_width = awful.screen.focused().geometry.width
  local screen_height = awful.screen.focused().geometry.height
  local aspect_ratio = 4 / 3

  local cols = math.floor(screen_width / (icon_size * 1.75 * aspect_ratio))
  local rows = math.floor((screen_height - (dpi(75 + 95))) / (icon_size * 1.75))

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
    type = "desktop",
    input_passthrough = false,
    x = 0,
    y = 0,
    bg = gcolor.transparent,
    width = 1920,
    height = 1080,
    screen = args.screen,
    widget = wibox.widget {
      {
        {
          layout = grid,
          homogeneous = true,
          spacing = dpi(10),
          expand = true,
          orientation = "horizontal",
          forced_num_cols = cols,
          forced_num_rows = rows,
          id = "grid",
        },
        widget = wibox.container.margin,
        left = dpi(10),
        right = dpi(10),
        top = dpi(75),
        bottom = dpi(95),
        id = "mrgn"
      },
      {
        layout = wibox.layout.manual,
        id = "manual",
      },
      layout = wibox.layout.stack,
    }
  }

  local cm_popup = cm {
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
    },
    spacing = dpi(10),
    entries = {
      {
        name = "Create new",
        icon = gcolor.recolor_image(icondir .. "file_add.svg", Theme_config.desktop.context_menu.icon_color),
        submenu = {
          {
            name = "Folder",
            icon = gcolor.recolor_image(icondir .. "folder.svg", Theme_config.desktop.context_menu.icon_color),
            callback = function()
              --create a new folder and if it exists add a number to the end
              local folder_name = "New folder"
              local folder_path = os.getenv("HOME") .. "/Desktop/" .. folder_name
              local i = 1
              while gfilesystem.dir_readable(folder_path) do
                folder_name = "New folder " .. "(" .. i .. ")"
                folder_path = os.getenv("HOME") .. "/Desktop/" .. folder_name
                i = i + 1
              end
              gfilesystem.make_directories(folder_path)
              w:add_element({
                icon = "/usr/share/icons/Papirus-Dark/24x24/places/folder.svg",
                label = folder_name,
                exec = "nautilus file:\"" .. folder_path .. "\"",
                icon_size = icon_size,
              })
            end
          },
          {
            name = "File",
            icon = gcolor.recolor_image(icondir .. "file.svg", Theme_config.desktop.context_menu.icon_color),
            callback = function()
              --create new text file and if it exists add a number to the end
              local file_name = "New file.txt"
              local file_path = os.getenv("HOME") .. "/Desktop/" .. file_name
              local i = 1
              while gfilesystem.file_readable(file_path) do
                file_name = "New file " .. "(" .. i .. ")"
                file_path = os.getenv("HOME") .. "/Desktop/" .. file_name
                i = i + 1
              end
              awful.spawn.with_shell("touch " .. file_path)
              w:add_element({
                icon = "/usr/share/icons/Papirus-Dark/24x24/mimetypes/text-plain.svg",
                label = file_name,
                exec = "xdg-open " .. file_path,
                icon_size = icon_size,
              })
            end
          }
        }
      },
      {
        name = "Terminal",
        icon = gcolor.recolor_image(icondir .. "terminal.svg", Theme_config.desktop.context_menu.icon_color),
        callback = function()
          awful.spawn(User_config.terminal)
        end
      },
      {
        name = "Web Browser",
        icon = gcolor.recolor_image(icondir .. "web_browser.svg", Theme_config.desktop.context_menu.icon_color),
        callback = function()
          awful.spawn(User_config.web_browser)
        end
      },
      {
        name = "File Manager",
        icon = gcolor.recolor_image(icondir .. "file_manager.svg", Theme_config.desktop.context_menu.icon_color),
        callback = function()
          awful.spawn(User_config.file_manager)
        end
      },
      {
        name = "Text Editor",
        icon = gcolor.recolor_image(icondir .. "text_editor.svg", Theme_config.desktop.context_menu.icon_color),
        callback = function()
          awful.spawn(User_config.text_editor)
        end
      },
      {
        name = "Music Player",
        icon = gcolor.recolor_image(icondir .. "music_player.svg", Theme_config.desktop.context_menu.icon_color),
        callback = function()
          awful.spawn(User_config.music_player)
        end
      },
      {
        name = "Applications",
        icon = gcolor.recolor_image(icondir .. "application.svg", Theme_config.desktop.context_menu.icon_color),
        callback = function()
        end
      },
      {
        name = "GTK Settings",
        icon = gcolor.recolor_image(icondir .. "gtk_settings.svg", Theme_config.desktop.context_menu.icon_color),
        callback = function()
          awful.spawn(User_config.gtk_settings)
        end
      },
      {
        name = "Energy Settings",
        icon = gcolor.recolor_image(icondir .. "energy_settings.svg", Theme_config.desktop.context_menu.icon_color),
        callback = function()
          awful.spawn(User_config.energy_manager)
        end
      },
      {
        name = "Screen Settings",
        icon = gcolor.recolor_image(icondir .. "screen_settings.svg", Theme_config.desktop.context_menu.icon_color),
        callback = function()
          awful.spawn(User_config.screen_settings)
        end
      },
      {
        name = "Reload Awesome",
        icon = gcolor.recolor_image(icondir .. "refresh.svg", Theme_config.desktop.context_menu.icon_color),
        callback = function()
          capi.awesome.restart()
        end
      },
      {
        name = "Quit",
        icon = gcolor.recolor_image(icondir .. "quit.svg", Theme_config.desktop.context_menu.icon_color),
        callback = function()
          capi.awesome.quit()
        end
      },
      --cm_awesome
    }
  }

  w.widget.manual:buttons(
    gtable.join(
      awful.button(
        {},
        1,
        function()
          cm_popup.visible = false
          if capi.mouse.current_widgets[4] == w.widget.manual then
            --w:draw_selector()
          end
        end
      ),
      awful.button(
        {},
        3,
        function()
          if capi.mouse.current_widgets[4] == w.widget.manual then
            cm_popup:toggle()
          end
        end
      )
    )
  )

  gtable.crush(w, desktop, true)

  w:load_layout()

  capi.awesome.connect_signal("desktop::add_to_desktop", function(args2)
    w:add_desktop_file(args2)
  end)

  return w
end

function desktop.mt:__call(...)
  return desktop.new(...)
end

return setmetatable(desktop, desktop.mt)
