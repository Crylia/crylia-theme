local base = require("wibox.widget.base")
local wibox = require("wibox")
local gtable = require("gears.table")
local dpi = require("beautiful").xresources.apply_dpi
local gshape = require("gears.shape")
local gfilesystem = require("gears.filesystem")
local gcolor = require("gears.color")
local abutton = require("awful.button")

local icondir = gfilesystem.get_configuration_dir() .. "src/assets/icons/desktop/"

local capi = {
  mouse = mouse
}

local element = { mt = {} }

function element:layout(_, width, height)
  if self._private.widget then
    return { base.place_widget_at(self._private.widget, 0, 0, width, height) }
  end
end

function element:fit(context, width, height)
  local w, h = 0, 0
  if self._private.widget then
    w, h = base.fit_widget(self, context, self._private.widget, width, height)
  end
  return w, h
end

function element:get_widget()
  return self._private.widget
end

function element:on_hover()
  self:connect_signal("mouse::enter", function()
    self.bg = "#0ffff033"
    self.border_color = "#0ffff099"
  end)

  --[[ self:connect_signal("mouse::leave", function()
    self.bg = gcolor.transparent
    self.border_color = gcolor.transparent
  end) ]]

  self:connect_signal("button::press", function()
    self.bg = "#0ffff088"
    self.border_color = "#0ffff0dd"
  end)

  self:connect_signal("button::release", function()
    self.bg = "#0ffff033"
    self.border_color = "#0ffff099"
  end)
end

function element.new(args)
  args = args or {}

  local w = base.make_widget_from_value(wibox.widget {
    {
      {
        {
          {
            image = args.icon,
            resize = true,
            clip_shape = gshape.rounded_rect,
            valign = "center",
            halign = "center",
            id = "icon_role",
            widget = wibox.widget.imagebox
          },
          strategy = "exact",
          height = args.icon_size,
          width = args.icon_size,
          widget = wibox.container.constraint
        },
        {
          text = args.label,
          id = "text_role",
          valign = "center",
          halign = "center",
          widget = wibox.widget.textbox
        },
        spacing = dpi(10),
        layout = wibox.layout.fixed.vertical
      },
      widget = wibox.container.place,
      valign = "center",
      halign = "center"
    },
    fg = "#ffffff",
    bg = gcolor.transparent,
    border_color = gcolor.transparent,
    border_width = dpi(2),
    shape = gshape.rounded_rect,
    forced_width = args.width,
    forced_height = args.height,
    width = args.width,
    height = args.height,
    exec = args.exec,
    icon_size = args.icon_size,
    icon = args.icon,
    widget = wibox.container.background
  })

  gtable.crush(w, element, true)

  w:on_hover()

  return w
end

function element.mt:__call(...)
  return element.new(...)
end

return setmetatable(element, element.mt)
