local setmetatable = setmetatable
local base = require("wibox.widget.base")
local gtable = require("gears.table")
local wibox = require("wibox")

local module = { mt = {} }

function module:layout(_, width, height)
  if self._private.widget then
    return { base.place_widget_at(self._private.widget, 0, 0, width, height) }
  end
end

function module:fit(context, width, height)
  local w, h = 0, 0
  if self._private.widget then
    w, h = base.fit_widget(self, context, self._private.widget, width, height)
  end
  return w, h
end

module.set_widget = base.set_widget_common

function module:set_widget_template(widget_template)
  self._private.widget_template = widget_template
  self:set_widget(widget_template)
end

function module:get_widget()
  return self._private.widget
end

function module:get_children()
  return { self._private.widget }
end

function module:set_children(children)
  self:set_widget(children[1])
end

function module:reset()
  self._private.widget_template = nil
  self:set_widget(nil)
end

local function new(args)
  local self = base.make_widget(nil, nil, { enable_properties = true })

  gtable.crush(self, module, true)

  self:set_widget(wibox.widget.textbox("Hello World!"))

  return self
end

function module.mt:__call(...)
  return new(...)
end

return setmetatable(module, module.mt)
