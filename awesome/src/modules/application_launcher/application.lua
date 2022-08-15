--------------------------------------
-- This is the application launcher --
--------------------------------------

-- Awesome Libs
local awful = require("awful")
local Gio = require("lgi").Gio
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")

local json = require("src.lib.json-lua.json-lua")

local cm = require("src.modules.context_menu")

local icondir = awful.util.getdir("config") .. "src/assets/icons/context_menu/"

return function()

  local application_grid = wibox.widget {
    homogenous = true,
    expand = false,
    spacing = dpi(10),
    id = "grid",
    forced_num_cols = 8,
    forced_num_rows = 7,
    orientation = "vertical",
    layout = wibox.layout.grid
  }
  -- Selected application position, default is first at 1,1
  -- The typo *might* be intentional
  local curser = {
    x = 1,
    y = 1
  }

  local filter = ""

  ---Executes only once to create a widget from each desktop file
  ---@return table widgets Unsorted widget table
  local function get_applications_from_file()
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

        local context_menu = cm({
          entries = {
            {
              name = "Execute as sudo",
              icon = gears.color.recolor_image(icondir .. "launch.svg", Theme_config.context_menu.icon_color),
              callback = function()
                awesome.emit_signal("application_launcher::show")
                awful.spawn("/home/crylia/.config/awesome/src/scripts/start_as_admin.sh " .. app_widget.exec)
              end
            },
            {
              name = "Pin to dock",
              icon = gears.color.recolor_image(icondir .. "pin.svg", Theme_config.context_menu.icon_color),
              callback = function()
                local handler = io.open("/home/crylia/.config/awesome/src/config/dock.json", "r")
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
                awesome.emit_signal("dock::changed")
              end
            },
            {
              name = "Add to desktop",
              icon = gears.color.recolor_image(icondir .. "desktop.svg", Theme_config.context_menu.icon_color),
              callback = function()
                awesome.emit_signal("application_launcher::show")
                --!TODO: Add to desktop
              end
            }
          }
        })

        -- Execute command on left click and hide launcher
        app_widget:buttons(
          gears.table.join(
            awful.button({
              modifiers = {},
              button = 1,
              on_release = function()
                Gio.AppInfo.launch_uris_async(app)
                awesome.emit_signal("application_launcher::show")
              end
            }),
            awful.button({
              modifiers = {},
              button = 3,
              on_release = function()
                if not context_menu then
                  return
                end
                -- add offset so mouse is above widget, this is so the mouse::leave event triggers always
                context_menu.x = mouse.coords().x - 10
                context_menu.y = mouse.coords().y - 10
                context_menu.visible = not context_menu.visible
              end
            })
          )
        )
        Hover_signal(app_widget)
        table.insert(list, app_widget)
      end
    end
    return list
  end

  -- Table to hold all application widgets unsorted
  local application_list = get_applications_from_file()

  ---Function to filter the applications and sort them into a widget grid
  ---@param search_filter string Filter string from the searchbar
  ---@return wibox.layout.grid wibox.layout.grid Sorted grid with all applications matching the filter
  local function get_applications(search_filter)
    filter = search_filter or filter
    --Clear grid from previous widgets
    application_grid:reset()
    -- Reset to first position
    curser = {
      x = 1,
      y = 1
    }
    for _, application in ipairs(application_list) do
      -- Match the filter
      if string.match(string.lower(application.name), string.lower(filter)) or
          string.match(string.lower(application.categories), string.lower(filter)) or
          string.match(string.lower(application.keywords), string.lower(filter)) then
        application_grid:add(application)

        -- Get the current position in the grid of the application as a table
        local pos = application_grid:get_widget_position(application)

        -- Check if the curser is currently at the same position as the application
        awesome.connect_signal(
          "update::selected",
          function()
            if curser.y == pos.row and curser.x == pos.col then
              application.border_color = Theme_config.application_launcher.application.border_color_active
            else
              application.border_color = Theme_config.application_launcher.application.border_color
            end
          end
        )
        awesome.emit_signal("update::selected")
      end
    end

    return application_grid
  end

  application_grid = get_applications(filter)

  awesome.connect_signal(
    "application::left",
    function()
      curser.x = curser.x - 1
      if curser.x < 1 then
        curser.x = 1
      end
      awesome.emit_signal("update::selected")
    end
  )

  awesome.connect_signal(
    "application::right",
    function()
      curser.x = curser.x + 1
      local _, grid_cols = application_grid:get_dimension()
      if curser.x > grid_cols then
        curser.x = grid_cols
      end
      awesome.emit_signal("update::selected")
    end
  )

  awesome.connect_signal(
    "application::up",
    function()
      curser.y = curser.y - 1
      if curser.y < 1 then
        curser.y = 1
      end
      awesome.emit_signal("update::selected")
    end
  )

  awesome.connect_signal(
    "application::down",
    function()
      curser.y = curser.y + 1
      local grid_rows, _ = application_grid:get_dimension()
      if curser.y > grid_rows then
        curser.y = grid_rows
      end
      awesome.emit_signal("update::selected")
    end
  )

  awesome.connect_signal(
    "update::application_list",
    function(f)
      application_grid = get_applications(f)
    end
  )

  awesome.connect_signal(
    "application_launcher::execute",
    function()
      awesome.emit_signal("searchbar::stop")

      local selected_widget = application_grid:get_widgets_at(curser.y, curser.x)[1]
      Gio.AppInfo.launch_uris_async(Gio.AppInfo.create_from_commandline(selected_widget.exec, nil, 0))
    end
  )

  return application_grid
end
