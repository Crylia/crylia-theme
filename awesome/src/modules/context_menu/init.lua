---------------------------------------
-- This is the brightness_osd module --
---------------------------------------
-- Awesome Libs
local awful = require('awful')
local apopup = require('awful.popup')
local abutton = awful.button
local beautiful = require('beautiful')
local dpi = require('beautiful').xresources.apply_dpi
local gtable = require('gears.table')
local base = require('wibox.widget.base')
local wibox = require('wibox')
local gfilesystem = require('gears.filesystem')
local gcolor = require('gears.color')
local gtimer = require('gears.timer')

local hover = require('src.tools.hover')

local capi = {
  awesome = awesome,
  mouse = mouse,
}

local icondir = gfilesystem.get_configuration_dir() .. 'src/assets/icons/context_menu/'

local context_menu = {
  mt = {},
}

function context_menu:layout(_, width, height)
  if self._private.widget then
    return {
      base.place_widget_at(self._private.widget, 0, 0, width, height),
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
    spacing = spacing,
  }

  if not wtemplate then
    return
  end

  for key, entry in pairs(entries) do
    local menu_entry = base.make_widget_from_value {
      {
        {
          {
            {
              {
                widget = wibox.widget.imagebox,
                resize = true,
                valign = 'center',
                halign = 'center',
                id = 'icon_role',
              },
              widget = wibox.container.constraint,
              stragety = 'exact',
              width = dpi(24),
              height = dpi(24),
              id = 'const',
            },
            {
              widget = wibox.widget.textbox,
              valign = 'center',
              halign = 'left',
              id = 'text_role',
            },
            spacing = dpi(10),
            layout = wibox.layout.fixed.horizontal,
          },
          nil,
          {
            {
              widget = wibox.widget.imagebox,
              resize = true,
              valign = 'center',
              halign = 'center',
              id = 'arrow_role',
            },
            widget = wibox.container.constraint,
            stragety = 'exact',
            width = dpi(24),
            height = dpi(24),
            id = 'const',
          },
          layout = wibox.layout.align.horizontal,
        },
        margins = dpi(5),
        widget = wibox.container.margin,
      },
      bg = beautiful.colorscheme.bg,
      fg = beautiful.colorscheme.fg,
      widget = wibox.container.background,
    }

    assert(type(menu_entry) == 'table', 'Entry must be a table')

    hover.bg_hover { widget = menu_entry }

    menu_entry:get_children_by_id('icon_role')[1].image = entry.icon
    menu_entry:get_children_by_id('text_role')[1].text = entry.name
    if entry.submenu then
      menu_entry:get_children_by_id('arrow_role')[1].image =
      gcolor.recolor_image(icondir .. 'entry.svg', beautiful.colorscheme.bg_red)
    end
    gtable.crush(menu_entry, entry, true)

    menu_entry:buttons(gtable.join {
      abutton {
        modifiers = {},
        button = 1,
        on_release = function()
          if not entry.submenu then
            entry.callback()
          end
          capi.awesome.emit_signal('submenu::close')
          capi.awesome.emit_signal('cm::hide')
        end,
      },
    })

    if entry.submenu then
      menu_entry.popup = apopup {
        widget = self:make_entries(wtemplate, entry.submenu, spacing),
        bg = beautiful.colorscheme.bg,
        ontop = true,
        fg = beautiful.colorscheme.bg_red,
        border_width = dpi(2),
        border_color = beautiful.colorscheme.border_color,
        visible = false,
      }

      local hide_timer = gtimer {
        timeout = 0.1,
        autostart = false,
        single_shot = true,
        callback = function()
          menu_entry.popup.visible = false
        end,
      }

      menu_entry:connect_signal('mouse::enter', function()
        -- place widget right of parent
        menu_entry.popup:move_next_to(capi.mouse.current_widget_geometry)
        hide_timer:stop()
        menu_entry.popup.visible = true
      end)
      menu_entry.popup:connect_signal('mouse::leave', function()
        hide_timer:again()
      end)
      menu_entry.popup:connect_signal('mouse::enter', function()
        hide_timer:stop()
      end)
      menu_entry:connect_signal('mouse::leave', function()
        hide_timer:again()
      end)
      capi.awesome.connect_signal('submenu::close', function()
        menu_entry.popup.visible = false
      end)
    end
    menu_entries[key] = menu_entry
  end
  return menu_entries
end

function context_menu:toggle()
  self.x = capi.mouse.coords().x - dpi(5)
  self.y = capi.mouse.coords().y - dpi(5)
  if self.y + self.height > capi.mouse.screen.geometry.height then
    self.y = self.y - self.height + dpi(10)
  end
  self.visible = not self.visible
end

-- This is terribly done but I don't know how to do it better since
-- the awful.popup.widget needs to know itself which I don't think is possible
function context_menu.new(args)
  args = args or {}

  local ret = {}

  gtable.crush(ret, context_menu, true)

  local entries = ret:make_entries(args.widget_template, args.entries, args.spacing)

  ret = apopup {
    widget = entries,
    bg = beautiful.colorscheme.bg,
    fg = beautiful.colorscheme.bg_red,
    ontop = true,
    border_width = dpi(2),
    border_color = beautiful.colorscheme.border_color,
    visible = false,
    x = capi.mouse.coords().x + 10,
    y = capi.mouse.coords().y - 10,
  }

  -- I literally have no clue how to do it better, it doesn't really matter anyways
  capi.awesome.connect_signal('cm::hide', function()
    ret.visible = false
  end)

  gtable.crush(ret, context_menu, true)

  return ret
end

function context_menu.mt:__call(...)
  return context_menu.new(...)
end

return setmetatable(context_menu, context_menu.mt)
