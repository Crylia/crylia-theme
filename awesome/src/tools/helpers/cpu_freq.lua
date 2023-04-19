local gobject = require('gears.object')
local watch = require('awful.widget.watch')
local beautiful = require('beautiful')

local instance = nil

local function new()
  local self = gobject {}

  watch("bash -c \"cat /proc/cpuinfo | grep 'MHz' | awk '{print int($4)}'\"", 2, function(_, stdout)
    local cpu_freq = {}

    for value in stdout:gmatch('%d+') do
      table.insert(cpu_freq, value)
    end

    local average = 0
    if beautiful.user_config.clock_mode == 'average' then
      for i = 1, #cpu_freq do
        average = average + cpu_freq[i]
      end
      average = math.floor((average / #cpu_freq) + 0.5)
      self:emit_signal('update::cpu_freq_average', average)
    elseif beautiful.user_config.clock_mode then
      self:emit_signal('update::cpu_freq_core', cpu_freq[beautiful.user_config.clock_mode])
    end
  end)

  return self
end

if not instance then
  instance = new()
end
return instance
