local aspawn = require('awful.spawn')
local gobject = require('gears.object')
local gtable = require('gears.table')
local gtimer = require('gears.timer')

local backlight = {}

local instance = nil

function backlight.brightness_get_async(callback)
  aspawn.easy_async_with_shell('brightnessctl get', function(stdout)
    callback(stdout:gsub('\n', ''))
  end)
end

function backlight:brightness_increase()
  if not self.allow_cmd then return end
  self.allow_cmd = false
  aspawn.easy_async_with_shell('brightnessctl set 2+%', function()
    self.allow_cmd = true
  end)
  self:emit_signal('brightness_changed')
end

function backlight:brightness_decrease()
  if not self.allow_cmd then return end
  self.allow_cmd = false
  aspawn.easy_async_with_shell('brightnessctl set 2-%', function()
    self.allow_cmd = true
  end)
  self:emit_signal('brightness_changed')
end

local function new()
  local self = gobject {}

  gtable.crush(self, backlight, true)

  -- Init the backlight device and get the max brightness
  aspawn.easy_async_with_shell('brightnessctl max', function(stdout)
    self.max_brightness = tonumber(stdout:gsub('\n', '') or 1)
  end)

  --  Function locker to avoid spawning more commands than can be processed at a time
  self.allow_cmd = true

  self:emit_signal('brightness_changed')

  return self
end

if not instance then
  instance = new()
end
return instance
