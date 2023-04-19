-- Awesome libs
local gobject = require('gears.object')
local gtable = require('gears.table')
local aspawn = require('awful.spawn')
local beautiful = require('beautiful')

local instance = nil
local kb_helper = {}

function kb_helper:cycle_layout()
  self:get_layout_async(function(layout)
    local index = gtable.hasitem(self.layout_list, layout)
    if index then
      if index == #self.layout_list then
        self:set_layout(self.layout_list[1])
      else
        self:set_layout(self.layout_list[index + 1])
      end
    else
      self:set_layout(self.layout_list[1])
    end
  end)
end

function kb_helper:set_layout(keymap)
  aspawn('setxkbmap ' .. keymap)
  self:emit_signal('KB::layout_changed', keymap)
end

function kb_helper:get_layout_async(callback)
  aspawn.easy_async_with_shell([[ setxkbmap -query | grep layout | awk '{print $2}' ]], function(stdout)
    callback(stdout:gsub('\n', ''))
  end)
end

local function new()
  local self = gobject {}

  gtable.crush(self, kb_helper, true)

  self.layout_list = beautiful.user_config.kblayout

  return self
end

if not instance then
  instance = new()
end
return instance
