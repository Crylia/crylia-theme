--------------------------------
-- This is the taglist widget --
--------------------------------

-- Awesome Libs
local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local dpi = require("beautiful").xresources.apply_dpi

local color = require("src.lib.color")
local rubato = require("src.lib.rubato")

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

    --#region Rubato and Color animation

    -- Background rubato init
    local r_timed_bg = rubato.timed { duration = 0.5 }
    local g_timed_bg = rubato.timed { duration = 0.5 }
    local b_timed_bg = rubato.timed { duration = 0.5 }

    -- starting color
    r_timed_bg.pos, g_timed_bg.pos, b_timed_bg.pos = color.utils.hex_to_rgba(Theme_config.taglist.bg)


    -- Foreground rubato init
    local r_timed_fg = rubato.timed { duration = 0.5 }
    local g_timed_fg = rubato.timed { duration = 0.5 }
    local b_timed_fg = rubato.timed { duration = 0.5 }

    -- starting color
    r_timed_fg.pos, g_timed_fg.pos, b_timed_fg.pos = color.utils.hex_to_rgba(Theme_config.taglist.fg)

    -- Subscribable function to have rubato set the bg/fg color
    local function update_bg()
      tag_widget:set_bg("#" ..
        color.utils.rgba_to_hex { math.max(0, r_timed_bg.pos), math.max(0, g_timed_bg.pos), math.max(0, b_timed_bg.pos) })
    end

    local function update_fg()
      tag_widget:set_fg("#" ..
        color.utils.rgba_to_hex { math.max(0, r_timed_fg.pos), math.max(0, g_timed_fg.pos), math.max(0, b_timed_fg.pos) })
    end

    -- Subscribe to the function bg and fg
    r_timed_bg:subscribe(update_bg)
    g_timed_bg:subscribe(update_bg)
    b_timed_bg:subscribe(update_bg)
    r_timed_fg:subscribe(update_fg)
    g_timed_fg:subscribe(update_fg)
    b_timed_fg:subscribe(update_fg)

    -- Both functions to set a color, if called they take a new color
    local function set_bg(newbg)
      r_timed_bg.target, g_timed_bg.target, b_timed_bg.target = color.utils.hex_to_rgba(newbg)
    end

    local function set_fg(newfg)
      r_timed_fg.target, g_timed_fg.target, b_timed_fg.target = color.utils.hex_to_rgba(newfg)
    end

    tag_widget.container.margin.label:set_text(object.index)
    -- Use the wraper function to call the set_bg and set_fg based on the client state
    if object.urgent == true then
      set_bg(Theme_config.taglist.bg_urgent)
      set_fg(Theme_config.taglist.fg_urgent)
    elseif object == awful.screen.focused().selected_tag then
      set_bg(Theme_config.taglist.bg_focus)
      set_fg(Theme_config.taglist.fg_focus)
    else
      set_fg(Theme_config.taglist.fg)
      set_bg(Theme_config.taglist.bg)
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
