--------------------------------
-- This is the taglist widget --
--------------------------------

-- Awesome Libs
local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local dpi = require("beautiful").xresources.apply_dpi

local capi = {
  client = client,
}

local modkey = User_config.modkey

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
      bg = Theme_config.taglist.bg,
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
    -- Use the wraper function to call the set_bg and set_fg based on the client state
    if object == awful.screen.focused().selected_tag then
      tag_widget:set_bg(Theme_config.taglist.bg_focus)
      tag_widget:set_fg(Theme_config.taglist.fg_focus)
    elseif object.urgent == true then
      tag_widget:set_bg(Theme_config.taglist.bg_urgent)
      tag_widget:set_fg(Theme_config.taglist.fg_urgent)
    else
      tag_widget:set_bg(Theme_config.taglist.bg)
      tag_widget:set_fg(Theme_config.taglist.fg)
    end
    --#endregion

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

      --[[ awful.spawn.easy_async_with_shell(
        "ps -o cmd " .. client.pid .. " | tail -n 1",
        function(stdout)
          local cmd = stdout:gsub("\n", "")
          local app_info = Gio.AppInfo.create_from_commandline(cmd, client.name, {})
          local exec = Gio.AppInfo.get_executable(app_info)
          icon:get_children_by_id("icon")[1].image = Get_icon(exec)
        end
      ) ]]
    end

    Hover_signal(tag_widget)

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
          if capi.client.focus then
            capi.client.focus:move_to_tag(t)
          end
        end
      ),
      awful.button(
        {},
        3,
        function(t)
          if capi.client.focus then
            capi.client.focus:toggle_tag(t)
          end
        end
      ),
      awful.button(
        { modkey },
        3,
        function(t)
          if capi.client.focus then
            capi.client.focus:toggle_tag(t)
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
