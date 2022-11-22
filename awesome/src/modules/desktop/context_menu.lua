local base = require("wibox.widget.base")
local awful = require("awful")
local gtable = require("gears.table")
local gfilesystem = require("gears.filesystem")
local gcolor = require("gears.color")
local wibox = require("wibox")
local dpi = require("beautiful").xresources.apply_dpi
local gobject = require("gears.object")


local cm = require("src.modules.context_menu.init")

local capi = {
  awesome = awesome
}

local icondir = gfilesystem.get_configuration_dir() .. "src/assets/icons/desktop/"

local context_menu = { mt = {} }
context_menu._private = {}

function context_menu:toggle()
  self._private.popup.x = mouse.coords().x - 10
  self._private.popup.y = mouse.coords().y - 10
  self._private.popup.visible = not self._private.popup.visible
end

function context_menu.new(args)
  args = args or {}

  local ret = gobject {}
  gtable.crush(ret, context_menu, true)



  capi.awesome.connect_signal("context_menu:show", function()
    ret:toggle()
    mousegrabber.run(function()
      if mouse.current_wibox ~= ret._private.popup then
        ret:toggle()
        return false
      end
      return true
    end, nil)
  end)

  return w
end

function context_menu.mt:__call(...)
  return context_menu.new(...)
end

return setmetatable(context_menu, context_menu.mt)
