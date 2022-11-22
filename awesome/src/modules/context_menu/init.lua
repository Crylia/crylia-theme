---------------------------------------
-- This is the brightness_osd module --
---------------------------------------
-- Awesome Libs
local awful = require("awful")
local abutton = awful.button
local dpi = require("beautiful").xresources.apply_dpi
local gtable = require("gears.table")
local base = require("wibox.widget.base")
local wibox = require("wibox")
local gfilesystem = require("gears.filesystem")
local gobject = require("gears.object")
local gcolor = require("gears.color")
local gtimer = require("gears.timer")

local capi = {
  awesome = awesome,
  mouse = mouse
}

local icondir = gfilesystem.get_configuration_dir() .. "src/assets/icons/context_menu/"

local context_menu = {
  mt = {}
}

function context_menu:layout(_, width, height)
  if self._private.widget then
    return {
      base.place_widget_at(self._private.widget, 0, 0, width, height)
    }
  end
end

function context_menu:fit(context, width, height)
  local w, h = 0, 0
  if self._private.widget then
    w, h = base.fit_widget(self, context, self._private.widget, width, height)
  end
  return w, h
end

context_menu.set_widget = base.set_widget_common

function context_menu:make_entries(wtemplate, entries, spacing)
  local menu_entries = {
    layout = wibox.layout.fixed.vertical,
    spacing = spacing
  }

  if not wtemplate then
    return
  end

  for _, entry in ipairs(entries) do
    -- TODO: Figure out how to make a new widget from etemplate
    local menu_entry = wibox.widget {
      {
        {
          {
            {
              {
                widget = wibox.widget.imagebox,
                resize = true,
                valign = "center",
                halign = "center",
                id = "icon_role"
              },
              widget = wibox.container.constraint,
              stragety = "exact",
              width = dpi(24),
              height = dpi(24),
              id = "const"
            },
            {
              widget = wibox.widget.textbox,
              valign = "center",
              halign = "left",
              id = "text_role"
            },
            spacing = dpi(10),
            layout = wibox.layout.fixed.horizontal
          },
          nil,
          {
            {
              widget = wibox.widget.imagebox,
              resize = true,
              valign = "center",
              halign = "center",
              id = "arrow_role"
            },
            widget = wibox.container.constraint,
            stragety = "exact",
            width = dpi(24),
            height = dpi(24),
            id = "const"
          },
          layout = wibox.layout.align.horizontal
        },
        margins = dpi(5),
        widget = wibox.container.margin
      },
      bg = Theme_config.desktop.context_menu.entry_bg,
      fg = Theme_config.desktop.context_menu.entry_fg,
      widget = wibox.container.background
    }

    Hover_signal(menu_entry)

    menu_entry:get_children_by_id("icon_role")[1].image = entry.icon
    menu_entry:get_children_by_id("text_role")[1].text = entry.name
    if entry.submenu then
      menu_entry:get_children_by_id("arrow_role")[1].image =
      gcolor.recolor_image(icondir .. "entry.svg", Theme_config.desktop.context_menu.entry_fg)
    end
    gtable.crush(menu_entry, entry, true)

    menu_entry:buttons(gtable.join {
      abutton({
        modifiers = {},
        button = 1,
        on_release = function()
          if not entry.submenu then
            entry.callback()
          end
          self.visible = false
        end
      })
    })

    if entry.submenu then
      menu_entry.popup = awful.popup {
        widget = self:make_entries(wtemplate, entry.submenu, spacing),
        bg = Theme_config.desktop.context_menu.bg,
        ontop = true,
        fg = Theme_config.desktop.context_menu.fg,
        border_width = Theme_config.desktop.context_menu.border_width,
        border_color = Theme_config.desktop.context_menu.border_color,
        shape = Theme_config.desktop.context_menu.shape,
        visible = false
      }

      local hide_timer = gtimer {
        timeout = 0.1,
        autostart = false,
        single_shot = true,
        callback = function()
          menu_entry.popup.visible = false
        end
      }

      menu_entry:connect_signal("mouse::enter", function()
        -- place widget right of parent
        menu_entry.popup:move_next_to(capi.mouse.current_widget_geometry)
        hide_timer:stop()
        menu_entry.popup.visible = true
      end)
      menu_entry.popup:connect_signal("mouse::leave", function()
        hide_timer:again()
      end)
      menu_entry.popup:connect_signal("mouse::enter", function()
        hide_timer:stop()
      end)
      menu_entry:connect_signal("mouse::leave", function()
        hide_timer:again()
      end)
      capi.awesome.connect_signal("submenu::close", function()
        menu_entry.popup.visible = false
      end)
    end

    table.insert(menu_entries, menu_entry)
  end

  return menu_entries
end

function context_menu:toggle()
  self.x = capi.mouse.coords().x
  self.y = capi.mouse.coords().y
  self.visible = not self.visible
end

function context_menu.new(args)
  args = args or {}

  local ret = {}

  gtable.crush(ret, context_menu, true)

  ret = awful.popup {
    widget = ret:make_entries(args.widget_template, args.entries, args.spacing),
    bg = Theme_config.desktop.context_menu.bg,
    fg = Theme_config.desktop.context_menu.fg,
    ontop = true,
    border_width = Theme_config.desktop.context_menu.border_width,
    border_color = Theme_config.desktop.context_menu.border_color,
    shape = Theme_config.desktop.context_menu.shape,
    visible = false,
    x = capi.mouse.coords().x + 10,
    y = capi.mouse.coords().y - 10
  }

  gtable.crush(ret, context_menu, true)

  return ret
end

function context_menu.mt:__call(...)
  return context_menu.new(...)
end

return setmetatable(context_menu, context_menu.mt)
