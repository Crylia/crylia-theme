---------------------------------
-- This is the window_switcher --
---------------------------------

-- Awesome Libs
local awful = require("awful")
local color = require("src.theme.colors")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")

-- Icon directory path
local icondir = awful.util.getdir("config") .. "src/assets/icons/window_switcher/"

return function(s)

  local list_update = function(widget, buttons, label, _, objects)
    widget:reset()
    for _, object in ipairs(objects) do
      local window_element = wibox.widget {
        {
          {
            { -- Icon
              {
                id = "icon",
                image = object.icon,
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
              text = "Application",
              id = "label",
              valign = "center",
              align = "center",
              widget = wibox.widget.textbox
            },
            id = "layout1",
            spacing = dpi(10),
            layout = wibox.layout.fixed.vertical
          },
          id = "margin",
          margins = dpi(20),
          widget = wibox.container.margin
        },
        shape = function(cr, width, height)
          gears.shape.rounded_rect(cr, width, height, dpi(12))
        end,
        bg = Theme_config.window_switcher.element_bg,
        fg = Theme_config.window_switcher.element_fg,
        widget = wibox.container.background
      }

      local function create_buttons(buttons_t, object_t)
        if buttons_t then
          local btns = {}
          for _, b in ipairs(buttons_t) do
            local btn = awful.button {
              modifiers = b.modifiers,
              button = b.button,
              on_press = function()
                b:emit_signal('press', object_t)
              end,
              on_release = function()
                b:emit_signal('release', object_t)
              end
            }
            btns[#btns + 1] = btn
          end
          return btns
        end
      end

      window_element:buttons(create_buttons(buttons, object))

      local text, _ = label(object, window_element.margin.layout1.label)

      if object == client.focus then
        if text == nil or text == "" then
          window_element:get_children_by_id("label")[1].text = "Application"
        else
          local text_full = text:match(">(.-)<")
          if text_full then
            if object.class == nil then
              text = object.name
            else
              text = object.class:sub(1, 20)
            end
          end
          window_element:get_children_by_id("label")[1].text = text
        end
      else

      end

      window_element:get_children_by_id("icon")[1]:set_image(xdg_icon_lookup:find_icon(object.class, 64))

      widget:add(window_element)
      widget:set_spacing(dpi(6))
    end
    return widget
  end

  local window_switcher = awful.widget.tasklist(
    s,
    awful.widget.tasklist.filter.allscreen,
    awful.util.table.join(
      awful.button(
        {},
        1,
        function(c)
          if c == client.focus then
            c.minimized = true
          else
            c.minimized = false
            if not c:isvisible() and c.first_tag then
              c.first_tag:view_only()
            end
            c:emit_signal('request::activate')
            c:raise()
          end
        end
      )
    ),
    {},
    list_update,
    wibox.layout.fixed.horizontal()
  )

  local window_switcher_container = awful.popup {
    ontop = true,
    visible = false,
    screen = s,
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(12))
    end,
    widget = { window_switcher },
    placement = awful.placement.centered,
    bg = Theme_config.window_switcher.bg,
    border_color = Theme_config.window_switcher.border_color,
    border_width = Theme_config.window_switcher.border_width
  }

  window_switcher_container:setup {
    layout = wibox.layout.fixed.vertical
  }
end
