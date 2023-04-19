local aspawn = require('awful.spawn')
local gobject = require('gears.object')
local gtable = require('gears.table')

local backlight = {}

local instance = nil

function backlight.brightness_get_async(callback)
  aspawn.easy_async_with_shell('brightnessctl get', function(stdout)
    callback(tonumber(stdout:gsub('\n', '')))
  end)
end

function backlight:brightness_increase()
  aspawn('brightnessctl set 2+%')
  self:emit_signal('brightness_changed')
end

function backlight:brightness_decrease()
  aspawn('brightnessctl set 2-%')
  self:emit_signal('brightness_changed')
end

local function new()
  local self = gobject {}

  gtable.crush(self, backlight, true)

  -- Init the backlight device and get the max brightness
  aspawn.easy_async_with_shell('brightnessctl max', function(stdout)
    self.max_brightness = tonumber(stdout:gsub('\n', '') or 1)
  end)

  return self
end

if not instance then
  instance = new()
end
return instance
