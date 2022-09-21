---------------------------------
-- This is the window_switcher --
---------------------------------

-- Awesome Libs
local awful = require("awful")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")

local color = require("src.lib.color")
local rubato = require("src.lib.rubato")

local capi = {
  awesome = awesome,
  client = client,
}

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

    local clients = capi.client.get()
    local clients_sorted = {}

    if capi.client.focus then
      clients_sorted[1] = capi.client.focus
    end

    for _, client in ipairs(clients) do
      if client ~= clients_sorted[1] then
        table.insert(clients_sorted, client)
      end
    end

    selected = selected

    for _, client in ipairs(clients_sorted) do
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
        bg = Theme_config.window_switcher.bg,
        fg = Theme_config.window_switcher.element_fg,
        widget = wibox.container.background
      }

      elements:add(window_element)
    end

    if fn == "next" then
      if selected >= #clients_sorted then
        selected = 1
      else
        selected = selected + 1
      end

      for i, element in ipairs(elements.children) do

        -- Background rubato init
        local r_timed_bg = rubato.timed { duration = 0.5 }
        local g_timed_bg = rubato.timed { duration = 0.5 }
        local b_timed_bg = rubato.timed { duration = 0.5 }

        -- starting color
        r_timed_bg.pos, g_timed_bg.pos, b_timed_bg.pos = color.utils.hex_to_rgba(Theme_config.window_switcher.bg)


        -- Foreground rubato init
        local r_timed_fg = rubato.timed { duration = 0.5 }
        local g_timed_fg = rubato.timed { duration = 0.5 }
        local b_timed_fg = rubato.timed { duration = 0.5 }

        -- starting color
        r_timed_fg.pos, g_timed_fg.pos, b_timed_fg.pos = color.utils.hex_to_rgba(Theme_config.window_switcher.element_fg)

        -- Border rubato init
        local r_timed_border = rubato.timed { duration = 0.5 }
        local g_timed_border = rubato.timed { duration = 0.5 }
        local b_timed_border = rubato.timed { duration = 0.5 }

        -- starting color
        r_timed_border.pos, g_timed_border.pos, b_timed_border.pos = color.utils.hex_to_rgba(Theme_config.window_switcher
          .border_color)

        local function set_bg(newbg)
          r_timed_bg.target, g_timed_bg.target, b_timed_bg.target = color.utils.hex_to_rgba(newbg)
        end

        local function set_fg(newfg)
          r_timed_fg.target, g_timed_fg.target, b_timed_fg.target = color.utils.hex_to_rgba(newfg)
        end

        local function set_border(newborder)
          r_timed_border.target, g_timed_border.target, b_timed_border.target = color.utils.hex_to_rgba(newborder)
        end

        local function update_bg()
          element:set_bg("#" .. color.utils.rgba_to_hex { r_timed_bg.pos, g_timed_bg.pos, b_timed_bg.pos })
        end

        local function update_fg()
          element:set_fg("#" .. color.utils.rgba_to_hex { r_timed_fg.pos, g_timed_fg.pos, b_timed_fg.pos })
        end

        local function update_border()
          element.border_color = "#" ..
              color.utils.rgba_to_hex { r_timed_border.pos, g_timed_border.pos, b_timed_border.pos }
        end

        -- Subscribe to the function bg and fg
        r_timed_bg:subscribe(update_bg)
        g_timed_bg:subscribe(update_bg)
        b_timed_bg:subscribe(update_bg)
        r_timed_fg:subscribe(update_fg)
        g_timed_fg:subscribe(update_fg)
        b_timed_fg:subscribe(update_fg)
        r_timed_border:subscribe(update_border)
        g_timed_border:subscribe(update_border)
        b_timed_border:subscribe(update_border)

        if i == selected then
          r_timed_bg.pos, g_timed_bg.pos, b_timed_bg.pos = color.utils.hex_to_rgba(Theme_config.window_switcher.bg)
          r_timed_fg.pos, g_timed_fg.pos, b_timed_fg.pos = color.utils.hex_to_rgba(Theme_config.window_switcher.element_fg)
          r_timed_border.pos, g_timed_border.pos, b_timed_border.pos = color.utils.hex_to_rgba(Theme_config.window_switcher
            .border_color)
          set_border(Theme_config.window_switcher.selected_border_color)
          set_fg(Theme_config.window_switcher.selected_fg)
          set_bg(Theme_config.window_switcher.selected_bg)
        elseif i == selected - 1 or (selected == 1 and i == #clients_sorted) then
          r_timed_bg.pos, g_timed_bg.pos, b_timed_bg.pos = color.utils.hex_to_rgba(Theme_config.window_switcher.selected_bg)
          r_timed_fg.pos, g_timed_fg.pos, b_timed_fg.pos = color.utils.hex_to_rgba(Theme_config.window_switcher.selected_fg)
          r_timed_border.pos, g_timed_border.pos, b_timed_border.pos = color.utils.hex_to_rgba(Theme_config.window_switcher
            .selected_border_color)
          set_border(Theme_config.window_switcher.border_color)
          set_fg(Theme_config.window_switcher.element_fg)
          set_bg(Theme_config.window_switcher.bg)
        else
          r_timed_bg.pos, g_timed_bg.pos, b_timed_bg.pos = color.utils.hex_to_rgba(Theme_config.window_switcher.bg)
          r_timed_fg.pos, g_timed_fg.pos, b_timed_fg.pos = color.utils.hex_to_rgba(Theme_config.window_switcher.element_fg)
          r_timed_border.pos, g_timed_border.pos, b_timed_border.pos = color.utils.hex_to_rgba(Theme_config.window_switcher
            .border_color)
          set_border(Theme_config.window_switcher.border_color)
          set_fg(Theme_config.window_switcher.element_fg)
          set_bg(Theme_config.window_switcher.bg)
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

  capi.awesome.connect_signal(
    "window_switcher::select_next",
    function()
      elements = create_elements("next")
    end
  )

  capi.awesome.connect_signal(
    "window_switcher::raise",
    function()
      elements = create_elements("raise")
    end
  )

  capi.client.connect_signal(
    "manage",
    function()
      elements = create_elements()
    end
  )

  capi.client.connect_signal(
    "unmanage",
    function()
      elements = create_elements()
    end
  )

  capi.awesome.connect_signal(
    "window_switcher::update",
    function()
      elements = create_elements()
    end
  )

  return elements
end
