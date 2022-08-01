--------------------------------
-- This is the taglist widget --
--------------------------------

-- Awesome Libs
local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local dpi = require("beautiful").xresources.apply_dpi

local list_update = function(widget, buttons, _, _, objects)
  widget:reset()

  for _, object in ipairs(objects) do

    local tag_widget = wibox.widget {
      {
        {
          {
            text = "",
            align = "center",
            valign = "center",
            visible = true,
            font = User_config.font.extrabold,
            forced_width = dpi(25),
            id = "label",
            widget = wibox.widget.textbox
          },
          id = "margin",
          left = dpi(5),
          right = dpi(5),
          widget = wibox.container.margin
        },
        id = "container",
        layout = wibox.layout.fixed.horizontal
      },
      fg = Theme_config.taglist.fg,
      shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, dpi(6))
      end,
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

    tag_widget:buttons(create_buttons(buttons, object))

    tag_widget.container.margin.label:set_text(object.index)
    if object.urgent == true then
      tag_widget:set_bg(Theme_config.taglist.bg_urgent)
      tag_widget:set_fg(Theme_config.taglist.fg_urgent)
    elseif object == awful.screen.focused().selected_tag then
      tag_widget:set_bg(Theme_config.taglist.bg_focus)
      tag_widget:set_fg(Theme_config.taglist.fg_focus)
    else
      tag_widget:set_bg(Theme_config.taglist.bg)
    end

    -- Set the icon for each client
    for _, client in ipairs(object:clients()) do
      tag_widget.container.margin:set_right(0)
      local icon = wibox.widget {
        {
          id = "icon_container",
          {
            id = "icon",
            image = Get_icon(client.class, client.name) or client.icon,
            resize = true,
            valign = "center",
            halign = "center",
            widget = wibox.widget.imagebox
          },
          widget = wibox.container.place
        },
        forced_width = dpi(33),
        margins = dpi(6),
        widget = wibox.container.margin
      }

      tag_widget.container:setup({
        icon,
        strategy = "exact",
        layout = wibox.container.constraint,
      })
    end

    --#region Hover_signal
    local old_wibox, old_cursor
    tag_widget:connect_signal(
      "mouse::enter",
      function()
        if object == awful.screen.focused().selected_tag then
          tag_widget.bg = Theme_config.taglist.bg_focus_hover .. 'dd'
        else
          tag_widget.bg = Theme_config.taglist.bg .. 'dd'
        end
        local w = mouse.current_wibox
        if w then
          old_cursor, old_wibox = w.cursor, w
          w.cursor = "hand1"
        end
      end
    )

    tag_widget:connect_signal(
      "button::press",
      function()
        if object == awful.screen.focused().selected_tag then
          tag_widget.bg = Theme_config.taglist.bg_focus_pressed .. 'dd'
        else
          tag_widget.bg = Theme_config.taglist.bg .. 'dd'
        end
      end
    )

    tag_widget:connect_signal(
      "button::release",
      function()
        if object == awful.screen.focused().selected_tag then
          tag_widget.bg = Theme_config.taglist.bg_focus_hover .. 'dd'
        else
          tag_widget.bg = Theme_config.taglist.bg .. 'dd'
        end
      end
    )

    tag_widget:connect_signal(
      "mouse::leave",
      function()
        if object == awful.screen.focused().selected_tag then
          tag_widget.bg = Theme_config.taglist.bg_focus
        else
          tag_widget.bg = Theme_config.taglist.bg
        end
        if old_wibox then
          old_wibox.cursor = old_cursor
          old_wibox = nil
        end
      end
    )
    --#endregion

    widget:add(tag_widget)
    widget:set_spacing(dpi(6))
  end
end

return function(s)
  return awful.widget.taglist(
    s,
    awful.widget.taglist.filter.noempty,
    gears.table.join(
      awful.button(
        {},
        1,
        function(t)
          t:view_only()
        end
      ),
      awful.button(
        { modkey },
        1,
        function(t)
          if client.focus then
            client.focus:move_to_tag(t)
          end
        end
      ),
      awful.button(
        {},
        3,
        function(t)
          if client.focus then
            client.focus:toggle_tag(t)
          end
        end
      ),
      awful.button(
        { modkey },
        3,
        function(t)
          if client.focus then
            client.focus:toggle_tag(t)
          end
        end
      ),
      awful.button(
        {},
        4,
        function(t)
          awful.tag.viewnext(t.screen)
        end
      ),
      awful.button(
        {},
        5,
        function(t)
          awful.tag.viewprev(t.screen)
        end
      )
    ),
    {},
    list_update,
    wibox.layout.fixed.horizontal()
  )
end
