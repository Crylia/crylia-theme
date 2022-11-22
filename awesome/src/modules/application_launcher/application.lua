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

  for _, application in ipairs(self.app_list) do
    -- Match the filter
    if string.match(string.lower(application.name or ""), string.lower(filter)) or
        string.match(string.lower(application.categories or ""), string.lower(filter)) or
        string.match(string.lower(application.keywords or ""), string.lower(filter)) then
      grid:add(application)

      -- Get the current position in the grid of the application as a table
      local pos = grid:get_widget_position(application)

      -- Check if the curser is currently at the same position as the application
      capi.awesome.connect_signal(
        "update::selected",
        function()
          if self._private.curser.y == pos.row and self._private.curser.x == pos.col then
            application.border_color = Theme_config.application_launcher.application.border_color_active
          else
            application.border_color = Theme_config.application_launcher.application.border_color
          end
        end
      )
    end
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
  print(self._private.curser.y)
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

  w:get_applications_from_file()

  w:set_applications()

  return w
end

function application_grid.mt:__call(...)
  return application_grid.new(...)
end

return setmetatable(application_grid, application_grid.mt)
