--------------------------------------------------------------------------------------------------------------
-- This is the statusbar, every widget, module and so on is combined to all the stuff you see on the screen --
--------------------------------------------------------------------------------------------------------------
-- Awesome Libs
local awful = require("awful")
local color = require("src.theme.colors")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")

local desktop_parser = require("src.tools.desktop_parser")

return function(screen, programs)

  local function create_dock_element(program, size)
    if not program then
      return
    end

    local dock_element = wibox.widget {
      {
        {
          {
            {
              resize = true,
              widget = wibox.widget.imagebox,
              valign = "center",
              halign = "center",
              id = "icon",
            },
            id = "icon_container",
            strategy = "exact",
            width = size,
            height = size,
            widget = wibox.container.constraint
          },
          margins = dpi(5),
          widget = wibox.container.margin,
          id = "margin"
        },
        shape = function(cr, width, height)
          gears.shape.rounded_rect(cr, width, height, dpi(10))
        end,
        bg = color["Grey900"],
        widget = wibox.container.background,
        id = "background"
      },
      top = dpi(5),
      left = dpi(5),
      right = dpi(5),
      widget = wibox.container.margin
    }

    dock_element.background.margin.icon_container.icon.image = xdg_icon_lookup:find_icon(program["Icon"], 64)

    for _, c in ipairs(client.get()) do
      if string.lower(c.class):match(program["Icon"]) and c == client.focus then
        dock_element.background.bg = color["Grey800"]
      end
    end

    Hover_signal(dock_element.background, color["Grey800"], color["White"])

    dock_element:connect_signal(
      "button::press",
      function(_, _, _, button)
        if button == 1 then
          awful.spawn(program["Exec"])
        end
      end
    )

    awful.tooltip {
      objects = { dock_element },
      text = program["Name"],
      mode = "outside",
      preferred_alignments = "middle",
      margins = dpi(10)
    }

    return dock_element
  end

  local dock = awful.popup {
    widget = wibox.container.background,
    ontop = true,
    bg = color["Grey900"],
    visible = true,
    screen = screen,
    type = "dock",
    height = dpi(User_config.dock_icon_size + 10),
    placement = function(c) awful.placement.bottom(c, { margins = dpi(10) }) end,
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(16))
    end
  }

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

  local function get_dock_elements(pr)
    local dock_elements = { layout = wibox.layout.fixed.horizontal }

    for i, p in ipairs(pr) do
      dock_elements[i] = create_dock_element(desktop_parser(p), User_config.dock_icon_size)
    end

    return dock_elements
  end

  local dock_elements = get_dock_elements(programs)

  local function get_fake_elements(amount)
    local fake_elements = { layout = wibox.layout.fixed.horizontal }

    for i = 0, amount, 1 do
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

  local function create_incicator_widget(prog)
    local container = { layout = wibox.layout.flex.horizontal }
    local clients = client.get()
    for index, pr in ipairs(prog) do
      local indicators = { layout = wibox.layout.flex.horizontal, spacing = dpi(5) }
      local col = color["Grey600"]
      for i, c in ipairs(clients) do
        local icon = desktop_parser(pr)
        if icon then
          local icon_name = icon["Icon"] or ""
          if icon_name:match(string.lower(c.class or c.name or nil)) then
            if c == client.focus then
              col = color["YellowA200"]
            elseif c.urgent then
              col = color["RedA200"]
            elseif c.maximized then
              col = color["GreenA200"]
            elseif c.minimized then
              col = color["BlueA200"]
            elseif c.fullscreen then
              col = color["PinkA200"]
            else
              col = color["Grey600"]
            end
            indicators[i] = wibox.widget {
              widget = wibox.container.background,
              shape = gears.shape.rounded_rect,
              forced_height = dpi(3),
              bg = col,
              forced_width = dpi(5),
            }
          end
        end
      end
      container[index] = wibox.widget {
        indicators,
        forced_height = dpi(5),
        forced_width = dpi(50),
        left = dpi(5),
        right = dpi(5),
        widget = wibox.container.margin,
      }
    end

    return wibox.widget {
      container,
      bottom = dpi(5),
      widget = wibox.container.margin,
    }
  end

  fakedock:setup {
    get_fake_elements(#programs),
    type = 'dock',
    layout = wibox.layout.fixed.vertical
  }

  local function check_for_dock_hide(s)
    local clients_on_tag = s.selected_tag:clients()
    for _, client in ipairs(clients_on_tag) do
      if client.fullscreen then
        dock.visible = false
        fakedock.visible = false
      else
        fakedock.visible = true
      end
    end
    if #clients_on_tag < 1 then
      dock.visible = true
      return
    end
    if s == mouse.screen then
      local minimized = false
      for _, c in ipairs(clients_on_tag) do
        if c.maximized or c.fullscreen then
          dock.visible = false
          return
        end
        if c.minimized then
          minimized = true
        else
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

  local dock_intelligent_hide = gears.timer {
    timeout = 1,
    autostart = true,
    call_now = true,
    callback = function()
      check_for_dock_hide(screen)
    end
  }

  fakedock:connect_signal(
    "mouse::enter",
    function()
      for _, c in ipairs(screen.clients) do
        if not c.fullscreen then
          dock_intelligent_hide:stop()
          dock.visible = true
        end
      end
      if #screen.clients < 1 then
        dock.visible = true
        dock_intelligent_hide:stop()
      end
    end
  )

  client.connect_signal(
    "manage",
    function()
      check_for_dock_hide(screen)
      dock:setup {
        dock_elements,
        create_incicator_widget(programs),
        layout = wibox.layout.fixed.vertical
      }
    end
  )

  client.connect_signal(
    "property::minimized",
    function()
      check_for_dock_hide(screen)
      dock:setup {
        dock_elements,
        create_incicator_widget(programs),
        layout = wibox.layout.fixed.vertical
      }
    end
  )

  client.connect_signal(
    "unmanage",
    function()
      check_for_dock_hide(screen)
      dock:setup {
        dock_elements,
        create_incicator_widget(programs),
        layout = wibox.layout.fixed.vertical
      }
    end
  )

  client.connect_signal(
    "focus",
    function()
      check_for_dock_hide(screen)
      dock:setup {
        dock_elements,
        create_incicator_widget(programs),
        layout = wibox.layout.fixed.vertical
      }
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
      dock_intelligent_hide:again()
      dock.visible = false
    end
  )
  dock:setup {
    dock_elements,
    create_incicator_widget(programs),
    layout = wibox.layout.fixed.vertical
  }
end
