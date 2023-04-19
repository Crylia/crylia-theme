local base = require('wibox.widget.base')
local gtable = require('gears.table')
local gcolor = require('gears.color')
local beautiful = require('beautiful')
local dpi = require('beautiful').xresources.apply_dpi
local wibox = require('wibox')
local gshape = require('gears.shape')
local rubato = require('src.lib.rubato')
local abutton = require('awful.button')

local toggle_widget = { mt = {} }

function toggle_widget:layout(_, width, height)
  if self._private.widget then
    return { base.place_widget_at(self._private.widget, 0, 0, width, height) }
  end
end

function toggle_widget:fit(context, width, height)
  local w, h = 0, 0
  if self._private.widget then
    w, h = base.fit_widget(self, context, self._private.widget, width, height)
  end
  return w, h
end

toggle_widget.set_widget = base.set_widget_common

function toggle_widget:get_widget()
  return self._private.widget
end

function toggle_widget:set_enabled()
  self.active = true
  self.toggle_button.border_color = self.color
  self.newcolor = self.color
  self.rubato_timed.target = 39
end

function toggle_widget:set_disabled()
  self.active = not self.active
  self.toggle_button.border_color = beautiful.colorscheme.bg1
  self.newcolor = beautiful.colorscheme.bg1
  self.rubato_timed.target = 5
end

function toggle_widget:toggle_animation(pos, color)
  if pos > 39 then return end
  return function(_, _, cr, width, height)
    cr:set_source(gcolor(beautiful.colorscheme.bg))
    cr:paint()
    cr:set_source(gcolor(color))
    cr:move_to(pos, 0)
    local x = pos
    local y = 5
    local newwidth = dpi(width / 2 - 6)
    local newheight = height - 10

    local radius = height / 6.0
    local degrees = math.pi / 180.0

    cr:new_sub_path()
    cr:arc(x + newwidth - radius, y + radius, radius, -90 * degrees, 0 * degrees)
    cr:arc(x + newwidth - radius, y + newheight - radius, radius, 0 * degrees, 90 * degrees)
    cr:arc(x + radius, y + newheight - radius, radius, 90 * degrees, 180 * degrees)
    cr:arc(x + radius, y + radius, radius, 180 * degrees, 270 * degrees)
    cr:close_path()
    cr:fill()
  end
end

function toggle_widget.new(args)
  args = args or {}

  local ret = base.make_widget(nil, nil, {
    enable_properties = true,
  })

  gtable.crush(ret, toggle_widget, true)

  ret.newcolor = beautiful.colorscheme.bg1
  ret.color = args.color

  ret.toggle_button = wibox.widget {
    {
      widget = wibox.widget {
        fit = function(_, width, height)
          return width, height
        end,
        draw = ret:toggle_animation(0, ret.newcolor),
      },
      id = 'background',
    },
    active = false,
    widget = wibox.container.background,
    bg = beautiful.colorscheme.bg,
    border_color = beautiful.colorscheme.border_color,
    border_width = dpi(2),
    forced_height = args.size,
    forced_width = args.size * 2,
    shape = beautiful.shape[10],
  }

  ret.rubato_timed = rubato.timed {
    duration = 0.2,
    pos = 5,
    subscribed = function(pos)
      ret.toggle_button:get_children_by_id('background')[1].draw = ret:toggle_animation(pos, ret.newcolor)
      ret.toggle_button:emit_signal('widget::redraw_needed')
    end,
  }

  ret:set_widget(wibox.widget {
    {
      {
        args.text and {
          text = args.text,
          valign = 'center',
          align = 'center',
          widget = wibox.widget.textbox,
          id = 'clearall',
        } or nil,
        ret.toggle_button,
        spacing = args.text and dpi(10) or dpi(0),
        layout = wibox.layout.fixed.horizontal,
        id = 'layout12',
      },
      id = 'background4',
      fg = args.fg,
      shape = beautiful.shape[12],
      widget = wibox.container.background,
    },
    id = 'place',
    widget = wibox.container.place,
    valign = 'bottom',
    halign = 'right',
  })

  ret.toggle_button:buttons(
    gtable.join(
      abutton({}, 1, function()
        if ret.active then
          ret:set_disabled()
        else
          ret:set_enabled()
        end
        ret:emit_signal('dnd::toggle', ret.active)
      end
      )
    )
  )

  return ret
end

function toggle_widget.mt:__call(...)
  return toggle_widget.new(...)
end

return setmetatable(toggle_widget, toggle_widget.mt)
