---------------------------------
-- This is the window_switcher --
---------------------------------

-- Awesome Libs
local awful = require("awful")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")

return function()

  local elements = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    spacing = dpi(20),
    id = "switcher"
  }

  local selected = 0

  local function create_elements(fn)
    fn = fn or ""

    elements:reset()

    local clients = client.get()
    local clients_sorted = {}

    if client.focus then
      clients_sorted[1] = client.focus
    end

    for _, client in ipairs(clients) do
      if client ~= clients_sorted[1] then
        table.insert(clients_sorted, client)
      end
    end

    selected = selected

    for i, client in ipairs(clients_sorted) do
      local window_element = wibox.widget {
        {
          {
            {
              { -- Icon
                {
                  id = "icon",
                  --!ADD FALLBACK ICON!--
                  image = Get_icon(client.class, client.name) or client.icon,
                  --image = gears.surface(client.content),
                  valign = "center",
                  halign = "center",
                  widget = wibox.widget.imagebox
                },
                width = dpi(100),
                height = dpi(100),
                id = "icon_const",
                strategy = "exact",
                widget = wibox.container.constraint
              },
              {
                {
                  text = client.name,
                  id = "label",
                  widget = wibox.widget.textbox
                },
                id = "place",
                valign = "center",
                halign = "center",
                widget = wibox.container.place
              },
              id = "layout1",
              spacing = dpi(10),
              layout = wibox.layout.fixed.vertical
            },
            id = "box",
            width = dpi(150),
            height = dpi(150),
            strategy = "exact",
            widget = wibox.container.constraint
          },
          id = "margin",
          margins = dpi(20),
          widget = wibox.container.margin
        },
        shape = function(cr, width, height)
          gears.shape.rounded_rect(cr, width, height, dpi(12))
        end,
        border_color = Theme_config.window_switcher.border_color,
        border_width = Theme_config.window_switcher.border_width,
        bg = Theme_config.window_switcher.element_bg,
        fg = Theme_config.window_switcher.element_fg,
        widget = wibox.container.background
      }

      if i == selected then
        window_element.border_color = Theme_config.window_switcher.selected_border_color
        window_element.fg = Theme_config.window_switcher.selected_fg
        window_element.bg = Theme_config.window_switcher.selected_bg
      else
        window_element.border_color = Theme_config.window_switcher.border_color
        window_element.fg = Theme_config.window_switcher.element_fg
        window_element.bg = Theme_config.window_switcher.bg
      end

      elements:add(window_element)
    end

    if fn == "next" then
      if selected >= #clients_sorted then
        selected = 1
      else
        selected = selected + 1
      end

      for i, element in ipairs(elements.children) do
        if i == selected then
          element.border_color = Theme_config.window_switcher.selected_border_color
          element.fg = Theme_config.window_switcher.selected_fg
          element.bg = Theme_config.window_switcher.selected_bg
        else
          element.border_color = Theme_config.window_switcher.border_color
          element.fg = Theme_config.window_switcher.element_fg
          element.bg = Theme_config.window_switcher.bg
        end
      end
    elseif fn == "raise" then
      local c = clients_sorted[selected]
      if not c:isvisible() and c.first_tag then
        c.first_tag:view_only()
      end
      c:emit_signal('request::activate')
      c:raise()

      --reset selected
      selected = 0
    end
    return elements
  end

  elements = create_elements()

  awesome.connect_signal(
    "window_switcher::select_next",
    function()
      elements = create_elements("next")
    end
  )

  awesome.connect_signal(
    "window_switcher::raise",
    function()
      elements = create_elements("raise")
    end
  )

  client.connect_signal(
    "manage",
    function()
      elements = create_elements()
    end
  )

  client.connect_signal(
    "unmanage",
    function()
      elements = create_elements()
    end
  )

  awesome.connect_signal(
    "window_switcher::update",
    function()
      elements = create_elements()
    end
  )

  return elements
end
