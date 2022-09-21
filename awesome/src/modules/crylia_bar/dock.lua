--------------------------------------------------------------------------------------------------------------
-- This is the statusbar, every widget, module and so on is combined to all the stuff you see on the screen --
--------------------------------------------------------------------------------------------------------------
-- Awesome Libs
local awful = require("awful")
local dpi = require("beautiful").xresources.apply_dpi
local Gio = require("lgi").Gio
local gears = require("gears")
local wibox = require("wibox")

local capi = {
  awesome = awesome,
  client = client,
  mouse = mouse,
}

local json = require("src.lib.json-lua.json-lua")

local icondir = awful.util.getdir("config") .. "src/assets/icons/context_menu/"

local cm = require("src.modules.context_menu")

return function(screen)

  local cm_open = false

  local dock_element_ammount = 0

  ---Creates a new program widget for the dock
  ---@param program string | function The name of the .desktop file
  ---@param size number The size of the widget
  ---@return widox.widget | nil The widget or nil if the program is not found
  local function create_dock_element(program, size)

    local dock_element = wibox.widget {
      {
        {
          {
            {
              resize = true,
              widget = wibox.widget.imagebox,
              image = program.icon or "",
              valign = "center",
              halign = "center",
              id = "icon",
            },
            id = "icon_container",
            strategy = "exact",
            width = dpi(size),
            height = dpi(size),
            widget = wibox.container.constraint
          },
          margins = dpi(5),
          widget = wibox.container.margin,
          id = "margin"
        },
        shape = function(cr, width, height)
          gears.shape.rounded_rect(cr, width, height, dpi(10))
        end,
        bg = Theme_config.dock.element_bg,
        fg = "#000000",
        widget = wibox.container.background,
        id = "background"
      },
      top = dpi(5),
      left = dpi(5),
      right = dpi(5),
      widget = wibox.container.margin
    }

    Hover_signal(dock_element.background, Theme_config.dock.element_focused_bg .. "dd")

    local DAI = Gio.DesktopAppInfo.new_from_filename(program.desktop_file)
    if not DAI then return end
    local action_entries = {}
    for _, action in ipairs(program.actions) do
      table.insert(action_entries, {
        name = Gio.DesktopAppInfo.get_action_name(DAI, action) or "",
        icon = action.icon or icondir .. "entry.svg",
        callback = function()
          Gio.DesktopAppInfo.launch_action(DAI, action)
        end
      })
    end

    table.insert(action_entries, {
      name = "Remove from Dock",
      icon = icondir .. "entry.svg",
      callback = function()
        local data = io.open("/home/crylia/.config/awesome/src/config/dock.json", "r")
        if not data then
          return
        end
        local dock = json:decode(data:read("a"))
        data:close()
        for i, v in ipairs(dock) do
          if v.desktop_file == program.desktop_file then
            if type(dock) == "table" then
              table.remove(dock, i)
            end
            break
          end
        end
        data = io.open("/home/crylia/.config/awesome/src/config/dock.json", "w")
        if not data then
          return
        end
        data:write(json:encode(dock))
        data:close()
        capi.awesome.emit_signal("dock::changed")
      end
    })

    local context_menu = cm({
      entries = action_entries
    })

    dock_element:buttons(gears.table.join(
      awful.button({
        modifiers = {},
        button = 1,
        on_release = function()
          Gio.AppInfo.launch_uris_async(Gio.AppInfo.create_from_commandline(program.exec, nil, 0))
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
          context_menu.x = capi.mouse.coords().x - 10
          context_menu.y = capi.mouse.coords().y + 10 - context_menu.height
          context_menu.visible = not context_menu.visible
          cm_open = context_menu.visible
        end
      })
    ))

    capi.awesome.connect_signal(
      "context_menu::hide",
      function()
        cm_open = false
        capi.awesome.emit_signal("dock::check_for_dock_hide")
      end
    )

    awful.tooltip {
      objects = { dock_element },
      text = program.name,
      mode = "outside",
      preferred_alignments = "middle",
      margins = dpi(10)
    }
    dock_element_ammount = dock_element_ammount + 1

    return dock_element
  end

  --- Indicators under the elements to indicate various open states
  local function create_incicator_widget()
    local container = { layout = wibox.layout.flex.horizontal }

    local data = io.open("/home/crylia/.config/awesome/src/config/dock.json", "r")

    if not data then
      return
    end

    local prog = json:decode(data:read("a"))
    data:close()
    for _, pr in ipairs(prog) do
      local indicators = { layout = wibox.layout.flex.horizontal, spacing = dpi(5) }
      local col = Theme_config.dock.indicator_bg
      for _, c in ipairs(capi.client.get()) do
        local icon_name = string.lower(pr.icon)
        if not c or not c.valid then return end
        local cls = c.class or ""
        local class = string.lower(cls)
        icon_name = string.match(icon_name, ".*/(.*)%.[svg|png]")
        if class == icon_name or class:match(icon_name) or icon_name:match(class) then
          if c == capi.client.focus then
            col = Theme_config.dock.indicator_focused_bg
          elseif c.urgent then
            col = Theme_config.dock.indicator_urgent_bg
          elseif c.maximized then
            col = Theme_config.dock.indicator_maximized_bg
          elseif c.minimized then
            col = Theme_config.dock.indicator_minimized_bg
          elseif c.fullscreen then
            col = Theme_config.dock.indicator_fullscreen_bg
          else
            col = Theme_config.dock.indicator_bg
          end
          table.insert(indicators, wibox.widget {
            widget = wibox.container.background,
            shape = gears.shape.rounded_rect,
            forced_height = dpi(3),
            bg = col,
            forced_width = dpi(5),
          })
        end
      end
      table.insert(container, wibox.widget {
        indicators,
        forced_height = dpi(5),
        forced_width = dpi(User_config.dock_icon_size),
        left = dpi(5),
        right = dpi(5),
        widget = wibox.container.margin,
      })
    end
    return wibox.widget {
      container,
      bottom = dpi(5),
      widget = wibox.container.margin,
    }
  end

  --- The container bar where the elements/program widgets sit in
  local dock = awful.popup {
    widget = wibox.container.background,
    ontop = true,
    bg = Theme_config.dock.bg,
    visible = true,
    screen = screen,
    type = "dock",
    height = dpi(User_config.dock_icon_size + 10),
    placement = function(c) awful.placement.bottom(c, { margins = dpi(10) }) end,
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(16))
    end
  }

  --- A fakedock to send a signal when the mouse is over it
  local fakedock = awful.popup {
    widget = wibox.container.background,
    ontop = true,
    bg = '#00000000',
    visible = true,
    screen = screen,
    type = "dock",
    id = "fakedock",
    height = dpi(10),
    placement = function(c) awful.placement.bottom(c) end,
  }

  --- List of all elements/program widgets
  local dock_elements = { layout = wibox.layout.fixed.horizontal }

  --- This function creates a list with all dock elements/program widgets
  ---@return table|nil string list of widgets
  local function get_dock_elements()
    dock_element_ammount = 0
    dock_elements = { layout = wibox.layout.fixed.horizontal }

    local data = io.open("/home/crylia/.config/awesome/src/config/dock.json", "r")
    if not data then
      return
    end
    local dock_data = json:decode(data:read("a"))
    data:close()
    for _, program in ipairs(dock_data) do
      table.insert(dock_elements, create_dock_element(program, User_config.dock_icon_size))
    end
    dock:setup {
      dock_elements,
      create_incicator_widget(),
      layout = wibox.layout.fixed.vertical
    }
  end

  get_dock_elements()

  --- Function to get an empty list with the same ammount as dock_element
  local function get_fake_elements()
    local fake_elements = { layout = wibox.layout.fixed.horizontal }

    for i = 0, dock_element_ammount, 1 do
      fake_elements[i] = wibox.widget {
        bg = '00000000',
        forced_width = User_config.dock_icon_size + dpi(20),
        forced_height = dpi(10),
        id = "fake",
        widget = wibox.container.background
      }
    end
    return fake_elements
  end

  fakedock:setup {
    get_fake_elements(),
    type = 'dock',
    layout = wibox.layout.fixed.vertical
  }

  ---Check if the dock needs to be hidden, I also put the topbar check here since it shares that logic
  ---@param s screen The screen to check for hide
  local function check_for_dock_hide(s)
    local clients_on_tag = s.selected_tag:clients()

    -- If there is no client on the current tag show the dock
    if #clients_on_tag < 1 then
      dock.visible = true
      return
    end

    -- If there is a maximized client hide the dock and if fullscreened hide the activation area
    for _, client in ipairs(clients_on_tag) do
      if client.maximized or client.fullscreen then
        dock.visible = false
        if client.fullscreen then
          fakedock.visible = false
          capi.awesome.emit_signal("notification_center_activation::toggle", s, false)
        end
      elseif not client.fullscreen then
        fakedock.visible = true
        capi.awesome.emit_signal("notification_center_activation::toggle", s, true)
      end
    end



    if s == capi.mouse.screen then
      local minimized = false
      for _, c in ipairs(clients_on_tag) do
        if c.minimized then
          minimized = true
        else
          minimized = false
          local y = c:geometry().y
          local h = c.height
          if (y + h) >= s.geometry.height - User_config.dock_icon_size - 35 then
            dock.visible = false
            return
          else
            dock.visible = true
          end
        end
      end
      if minimized then
        dock.visible = true
      end
    else
      dock.visible = false
    end
  end

  -- Call the function every second to check if the dock needs to be hidden
  local dock_intelligent_hide = gears.timer {
    timeout = 1,
    autostart = true,
    call_now = true,
    callback = function()
      check_for_dock_hide(screen)
    end
  }

  --- Hover function to show the dock
  fakedock:connect_signal(
    "mouse::enter",
    function()
      if #screen.clients < 1 then
        dock.visible = true
        dock_intelligent_hide:stop()
        return
      end
      for _, c in ipairs(screen.clients) do
        if not c.fullscreen then
          dock.visible = true
          dock_intelligent_hide:stop()
        end
      end
    end
  )

  capi.client.connect_signal(
    "manage",
    function()
      check_for_dock_hide(screen)
      dock:setup {
        dock_elements,
        create_incicator_widget(),
        layout = wibox.layout.fixed.vertical
      }
      fakedock:setup {
        get_fake_elements(),
        type = 'dock',
        layout = wibox.layout.fixed.vertical
      }
    end
  )

  capi.client.connect_signal(
    "property::minimized",
    function()
      check_for_dock_hide(screen)
      dock:setup {
        dock_elements,
        create_incicator_widget(),
        layout = wibox.layout.fixed.vertical
      }
      fakedock:setup {
        get_fake_elements(),
        type = 'dock',
        layout = wibox.layout.fixed.vertical
      }
    end
  )

  capi.client.connect_signal(
    "unmanage",
    function()
      check_for_dock_hide(screen)
      dock:setup {
        dock_elements,
        create_incicator_widget(),
        layout = wibox.layout.fixed.vertical
      }
      fakedock:setup {
        get_fake_elements(),
        type = 'dock',
        layout = wibox.layout.fixed.vertical
      }
    end
  )

  capi.client.connect_signal(
    "focus",
    function()
      check_for_dock_hide(screen)
      dock:setup {
        dock_elements,
        create_incicator_widget(),
        layout = wibox.layout.fixed.vertical
      }
      fakedock:setup {
        get_fake_elements(),
        type = 'dock',
        layout = wibox.layout.fixed.vertical
      }
    end
  )

  capi.awesome.connect_signal(
    "dock::changed",
    function()
      get_dock_elements()
      dock:setup {
        dock_elements,
        create_incicator_widget(),
        layout = wibox.layout.fixed.vertical
      }
      fakedock:setup {
        get_fake_elements(),
        type = 'dock',
        layout = wibox.layout.fixed.vertical
      }
    end
  )

  capi.awesome.connect_signal(
    "dock::check_for_dock_hide",
    function()
      dock_intelligent_hide:again()
    end
  )

  dock:connect_signal(
    "mouse::enter",
    function()
      dock_intelligent_hide:stop()
    end
  )

  dock:connect_signal(
    "mouse::leave",
    function()
      if cm_open then
        return
      end
      check_for_dock_hide(screen)
      dock_intelligent_hide:again()
    end
  )
  dock:setup {
    dock_elements,
    create_incicator_widget(),
    layout = wibox.layout.fixed.vertical
  }
end
