---------------------------------
-- This is the window_switcher --
---------------------------------

-- Awesome Libs
local awful = require("awful")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")

local naughty = require("naughty")
-- Icon directory path
local icondir = awful.util.getdir("config") .. "src/assets/icons/window_switcher/"

return function(s)

  -- Variable to check if client is selected

  local list_update = function(widget, buttons, label, _, objects)
    widget:reset()

    local function sort_objects()
      local objects_sorted = {}
      objects_sorted[1] = objects[1]
      local index = 2
      for _, object in ipairs(objects) do
        if object ~= nil or object ~= 0 then
          if object == client.focus then
            objects_sorted[1] = object
          else
            objects_sorted[index] = object
            index = index + 1
          end
        end
      end
      index = 2
      if objects_sorted[1].pid == objects_sorted[2].pid then
        table.remove(objects_sorted, 2)
      end
      return objects_sorted
    end

    local objects_sorted = sort_objects()

    local selected = objects_sorted[1].pid

    for _, object in ipairs(objects_sorted) do
      local window_element = wibox.widget {
        {
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
                {
                  text = "Application",
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
      local text, _ = label(object, window_element:get_children_by_id("label")[1])

      local i = 1
      local sel = nil

      local select_next = function()
        if #objects_sorted >= i then
          selected = objects_sorted[i].pid
          sel = selected

          if object.valid then
            if selected == object.pid then
              window_element.border_color = Theme_config.window_switcher.selected_border_color
              window_element.fg = Theme_config.window_switcher.selected_fg
              window_element.bg = Theme_config.window_switcher.selected_bg
            else
              window_element.border_color = Theme_config.window_switcher.border_color
              window_element.fg = Theme_config.window_switcher.element_fg
              window_element.bg = Theme_config.window_switcher.bg
            end
          end
        end
        if #objects_sorted > i then
          i = i + 1
        else
          i = 1
        end
      end

      awesome.connect_signal(
        "window_switcher::select_next",
        select_next
      )

      object:connect_signal(
        "unmanage",
        function(c)
          i = 1
          objects_sorted[1] = objects_sorted[#objects_sorted]
          objects_sorted[#objects_sorted] = nil
          if objects_sorted[1] then
            selected = objects_sorted[1].pid
          end
          -- remove object from table
          for _, object in ipairs(objects) do
            if object.pid == c.pid then
              table.remove(objects, _)
              break
            end
          end
          for _, object in ipairs(objects_sorted) do
            if object.pid == c.pid then
              table.remove(objects_sorted, _)
              break
            end
          end
        end
      )

      awesome.connect_signal(
        "window_switcher::raise",
        function()
          if objects_sorted[i] then
            if object.valid then
              if sel == object.pid then
                object:jump_to()
              end

              -- Reset window switcher
              i = 1
              selected = objects_sorted[i].pid
              sel = selected
              if selected == object.pid then
                window_element.border_color = Theme_config.window_switcher.selected_border_color
                window_element.fg = Theme_config.window_switcher.selected_fg
                window_element.bg = Theme_config.window_switcher.bg
              else
                window_element.border_color = Theme_config.window_switcher.border_color
                window_element.fg = Theme_config.window_switcher.element_fg
                window_element.bg = Theme_config.window_switcher.selected_bg
              end
            end
          end
        end
      )

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
        window_element:get_children_by_id("label")[1].text = object.name
      end
      if selected == object.pid then
        window_element.border_color = Theme_config.window_switcher.selected_border_color
        window_element.fg = Theme_config.window_switcher.selected_fg
        window_element.bg = Theme_config.window_switcher.selected_bg
      end

      window_element:get_children_by_id("icon")[1]:set_image(xdg_icon_lookup:find_icon(object.class, 64))

      widget:add(window_element)
      widget:set_spacing(dpi(20))
    end
    return widget
  end

  local window_switcher = awful.widget.tasklist(
    s,
    awful.widget.tasklist.source.all_clients,
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

  local window_switcher_margin = wibox.widget {
    window_switcher,
    margins = dpi(20),
    widget = wibox.container.margin
  }

  local window_switcher_container = awful.popup {
    widget = wibox.container.background,
    ontop = true,
    visible = false,
    stretch = false,
    screen = s,
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(12))
    end,
    placement = awful.placement.centered,
    bg = Theme_config.window_switcher.bg,
    border_color = Theme_config.window_switcher.border_color,
    border_width = Theme_config.window_switcher.border_width
  }

  awesome.connect_signal(
    "toggle_window_switcher",
    function()
      window_switcher_container.visible = not window_switcher_container.visible
    end
  )

  window_switcher_container:setup {
    window_switcher_margin,
    layout = wibox.layout.fixed.vertical
  }
end
