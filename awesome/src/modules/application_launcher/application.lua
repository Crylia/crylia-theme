--------------------------------------
-- This is the application launcher --
--------------------------------------

-- Awesome Libs
local awful = require("awful")
local Gio = require("lgi").Gio
local gfilesystem = require("gears").filesystem
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")
local base = require("wibox.widget.base")
local gtable = require("gears.table")

local json = require("src.lib.json-lua.json-lua")
local cm = require("src.modules.context_menu.init")

local capi = {
  awesome = awesome,
  mouse = mouse,
}

local icondir = gears.filesystem.get_configuration_dir() .. "src/assets/icons/context_menu/"

local application_grid = { mt = {} }

function application_grid:layout(_, width, height)
  if self._private.widget then
    return { base.place_widget_at(self._private.widget, 0, 0, width, height) }
  end
end

function application_grid:fit(context, width, height)
  local w, h = 0, 0
  if self._private.widget then
    w, h = base.fit_widget(self, context, self._private.widget, width, height)
  end
  return w, h
end

application_grid.set_widget = base.set_widget_common

function application_grid:get_widget()
  return self._private.widget
end

local function levenshtein_distance(str1, str2)
  local len1 = string.len(str1)
  local len2 = string.len(str2)
  local matrix = {}
  local cost = 0

  if (len1 == 0) then
    return len2
  elseif (len2 == 0) then
    return len1
  elseif (str1 == str2) then
    return 0
  end

  for i = 0, len1, 1 do
    matrix[i] = {}
    matrix[i][0] = i
  end
  for j = 0, len2, 1 do
    matrix[0][j] = j
  end

  for i = 1, len1, 1 do
    for j = 1, len2, 1 do
      if str1:byte(i) == str2:byte(j) then
        cost = 0
      else
        cost = 1
      end

      matrix[i][j] = math.min(
        matrix[i - 1][j] + 1,
        matrix[i][j - 1] + 1,
        matrix[i - 1][j - 1] + cost
      )
    end
  end

  return matrix[len1][len2]
end

function application_grid:get_applications_from_file()
  local list = {}
  local app_info = Gio.AppInfo
  local apps = app_info.get_all()
  for _, app in ipairs(apps) do
    if app.should_show(app) then -- check no display
      local desktop_app_info = Gio.DesktopAppInfo.new(app_info.get_id(app))
      local app_widget = wibox.widget {
        {
          {
            {
              {
                { -- Icon
                  valign = "center",
                  halign = "center",
                  image = Get_gicon_path(app_info.get_icon(app)),
                  resize = true,
                  widget = wibox.widget.imagebox
                },
                height = dpi(64),
                width = dpi(64),
                strategy = "exact",
                widget = wibox.container.constraint
              },
              {
                { -- Name
                  text = app_info.get_name(app),
                  align = "center",
                  valign = "center",
                  widget = wibox.widget.textbox
                },
                strategy = "exact",
                width = dpi(170),
                -- Prevents widget from overflowing
                height = dpi(40),
                widget = wibox.container.constraint
              },
              layout = wibox.layout.fixed.vertical
            },
            halign = "center",
            valign = "center",
            widget = wibox.container.place
          },
          margins = dpi(10),
          widget = wibox.container.margin
        },
        name = app_info.get_name(app),
        comment = Gio.DesktopAppInfo.get_string(desktop_app_info, "Comment") or "",
        exec = Gio.DesktopAppInfo.get_string(desktop_app_info, "Exec"),
        keywords = Gio.DesktopAppInfo.get_string(desktop_app_info, "Keywords") or "",
        categories = Gio.DesktopAppInfo.get_categories(desktop_app_info) or "",
        terminal = Gio.DesktopAppInfo.get_string(desktop_app_info, "Terminal") == "true",
        actions = Gio.DesktopAppInfo.list_actions(desktop_app_info),
        border_color = Theme_config.application_launcher.application.border_color,
        border_width = Theme_config.application_launcher.application.border_width,
        bg = Theme_config.application_launcher.application.bg,
        fg = Theme_config.application_launcher.application.fg,
        desktop_file = Gio.DesktopAppInfo.get_filename(desktop_app_info) or "",
        shape = function(cr, width, height)
          gears.shape.rounded_rect(cr, width, height, dpi(8))
        end,
        widget = wibox.container.background
      }

      local context_menu = cm {
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
            name = "Execute as sudo",
            icon = gears.color.recolor_image(icondir .. "launch.svg",
              Theme_config.application_launcher.application.cm_icon_color),
            callback = function()
              capi.awesome.emit_signal("application_launcher::show")
              awful.spawn("/home/crylia/.config/awesome/src/scripts/start_as_admin.sh " .. app_widget.exec)
            end
          },
          {
            name = "Pin to dock",
            icon = gears.color.recolor_image(icondir .. "pin.svg",
              Theme_config.application_launcher.application.cm_icon_color),
            callback = function()
              local dir = gears.filesystem.get_configuration_dir() .. "src/config"
              gfilesystem.make_directories(dir)
              if not gfilesystem.file_readable(dir) then
                os.execute("touch " .. dir .. "/dock.json")
              end
              local handler = io.open(dir .. "/dock.json", "r")
              if not handler then
                return
              end
              local dock_table = json:decode(handler:read("a")) or {}
              handler:close()

              ---@diagnostic disable-next-line: param-type-mismatch
              table.insert(dock_table, {
                name = app_widget.name or "",
                icon = Get_gicon_path(app_info.get_icon(app)) or "",
                comment = app_widget.comment or "",
                exec = app_widget.exec or "",
                keywords = app_widget.keywords or "",
                categories = app_widget.categories or "",
                terminal = app_widget.terminal or "",
                actions = app_widget.actions or "",
                desktop_file = Gio.DesktopAppInfo.get_filename(desktop_app_info) or ""
              })
              local dock_encoded = json:encode(dock_table)
              handler = io.open("/home/crylia/.config/awesome/src/config/dock.json", "w")
              if not handler then
                return
              end
              handler:write(dock_encoded)
              handler:close()
              capi.awesome.emit_signal("dock::changed")
            end
          },
          {
            name = "Add to desktop",
            icon = gears.color.recolor_image(icondir .. "desktop.svg",
              Theme_config.application_launcher.application.cm_icon_color),
            callback = function()
              capi.awesome.emit_signal("application_launcher::show")
              capi.awesome.emit_signal("desktop::add_to_desktop", {
                label = app_info.get_name(app),
                icon = Get_gicon_path(app_info.get_icon(app)) or "",
                exec = Gio.DesktopAppInfo.get_string(desktop_app_info, "Exec"),
                desktop_file = Gio.DesktopAppInfo.get_filename(desktop_app_info) or ""
              })
            end
          }
        }
      }

      context_menu:connect_signal("mouse::leave", function()
        context_menu.visible = false
      end)

      -- Execute command on left click and hide launcher
      app_widget:buttons(
        gears.table.join(
          awful.button({
            modifiers = {},
            button = 1,
            on_release = function()
              Gio.AppInfo.launch_uris_async(app)
              --!Change!
              capi.awesome.emit_signal("application_launcher::show")
            end
          }),
          awful.button({
            modifiers = {},
            button = 3,
            on_release = function()
              context_menu:toggle()
            end
          })
        )
      )
      Hover_signal(app_widget)
      table.insert(list, app_widget)
    end
  end
  self.app_list = list
end

function application_grid:set_applications(search_filter)
  local filter = search_filter or self.filter or ""
  -- Reset to first position
  self._private.curser = {
    x = 1,
    y = 1
  }

  local grid = wibox.widget {
    homogenous = true,
    expand = false,
    spacing = dpi(10),
    id = "grid",
    -- 200 is the application element width + 10 spacing
    forced_num_cols = math.floor((capi.mouse.screen.geometry.width / 100 * 60) / (200)),
    forced_num_rows = 7,
    orientation = "vertical",
    layout = wibox.layout.grid
  }

  local dir = gfilesystem.get_configuration_dir() .. "src/config/applications.json"
  if not gfilesystem.file_readable(dir) then return end

  local handler = io.open(dir, "r")
  if not handler then return end
  local dock_encoded = handler:read("a") or "{}"
  local dock = json:decode(dock_encoded)
  if type(dock) ~= "table" then return end
  local mylist = {}
  for _, application in ipairs(self.app_list) do
    -- Match the filter
    if string.match(string.lower(application.name or ""), string.lower(filter)) or
        string.match(string.lower(application.categories or ""), string.lower(filter)) or
        string.match(string.lower(application.keywords or ""), string.lower(filter)) then

      if #dock == 0 then
        application.counter = 0
      end
      for _, app in ipairs(dock) do
        if app.desktop_file == application.desktop_file then
          application.counter = app.counter or 0
          break;
        else
          application.counter = 0
        end
      end

      table.insert(mylist, application)
    end
  end

  table.sort(mylist, function(a, b)
    return levenshtein_distance(filter, a.name) < levenshtein_distance(filter, b.name)
  end)
  --sort mytable by counter
  table.sort(mylist, function(a, b)
    return a.counter > b.counter
  end)

  for _, app in ipairs(mylist) do
    grid:add(app)

    -- Get the current position in the grid of the app as a table
    local pos = grid:get_widget_position(app)

    -- Check if the curser is currently at the same position as the app
    capi.awesome.connect_signal(
      "update::selected",
      function()
        if self._private.curser.y == pos.row and self._private.curser.x == pos.col then
          app.border_color = Theme_config.application_launcher.application.border_color_active
        else
          app.border_color = Theme_config.application_launcher.application.border_color
        end
      end
    )
  end

  capi.awesome.emit_signal("update::selected")
  self:set_widget(grid)
end

function application_grid:move_up()
  self._private.curser.y = self._private.curser.y - 1
  if self._private.curser.y < 1 then
    self._private.curser.y = 1
  end
  capi.awesome.emit_signal("update::selected")
end

function application_grid:move_down()
  self._private.curser.y = self._private.curser.y + 1
  local grid_rows, _ = self:get_widget():get_dimension()
  if self._private.curser.y > grid_rows then
    self._private.curser.y = grid_rows
  end
  capi.awesome.emit_signal("update::selected")
end

function application_grid:move_left()
  self._private.curser.x = self._private.curser.x - 1
  if self._private.curser.x < 1 then
    self._private.curser.x = 1
  end
  capi.awesome.emit_signal("update::selected")
end

function application_grid:move_right()
  self._private.curser.x = self._private.curser.x + 1
  local _, grid_cols = self:get_widget():get_dimension()
  if self._private.curser.x > grid_cols then
    self._private.curser.x = grid_cols
  end
  capi.awesome.emit_signal("update::selected")
end

function application_grid:execute()
  local selected_widget = self:get_widget():get_widgets_at(self._private.curser.y,
    self._private.curser.x)[1]
  Gio.AppInfo.launch_uris_async(Gio.AppInfo.create_from_commandline(selected_widget.exec, nil, 0))

  local dir = gfilesystem.get_configuration_dir() .. "src/config/applications.json"
  if not gfilesystem.file_readable(dir) then return end

  local handler = io.open(dir, "r")
  if not handler then return end
  local dock_encoded = handler:read("a") or "{}"
  local dock = json:decode(dock_encoded)
  if type(dock) ~= "table" then return end
  for _, prog in ipairs(dock) do
    if prog.desktop_file:match(selected_widget.desktop_file) then
      prog.counter = prog.counter + 1
      goto continue
    end
  end
  do
    local prog = {
      name = selected_widget.name,
      desktop_file = selected_widget.desktop_file,
      counter = 1
    }
    table.insert(dock, prog)
  end
  ::continue::
  handler:close()
  handler = io.open(dir, "w")
  if not handler then return end
  handler:write(json:encode_pretty(dock))
  handler:close()
end

function application_grid:reset()
  self._private.curser = {
    x = 1,
    y = 1
  }
  capi.awesome.emit_signal("update::selected")
end

function application_grid.new(args)
  args = args or {}

  local w = base.make_widget(nil, nil, { enable_properties = true })

  gtable.crush(w, application_grid, true)

  w._private.curser = {
    x = 1,
    y = 1
  }

  -- Create folder and file if it doesn't exist
  local dir = gfilesystem.get_configuration_dir() .. "src/config"
  gfilesystem.make_directories(dir)
  dir = dir .. "/applications.json"
  if not gfilesystem.file_readable(dir) then
    os.execute("touch " .. dir)
  end

  w:get_applications_from_file()

  w:set_applications()
  return w
end

function application_grid.mt:__call(...)
  return application_grid.new(...)
end

return setmetatable(application_grid, application_grid.mt)
