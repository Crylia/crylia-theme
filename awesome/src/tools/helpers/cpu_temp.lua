local aspawn = require('awful.spawn')
local awatch = require('awful.widget.watch')
local gobject = require('gears.object')

local instance = nil

local function new()
  local self = gobject {}

  awatch([[ bash -c "sensors | grep 'Package id 0:' | awk '{print $4}'" ]], 2, function(_, stdout)
    local temp = tonumber(stdout:match('%d+'))
    if not temp or temp == '' then
      aspawn.easy_async_with_shell('paste <(cat /sys/class/thermal/thermal_zone*/type) <(cat /sys/class/thermal/thermal_zone*/temp)', function(stdout2)
        if (not stdout2) or stdout:match('\n') then return end
        temp = math.floor((tonumber(stdout2:match('x86_pkg_temp(.%d+)')) / 1000) + 0.5)
        self:emit_signal('update::cpu_temp', temp)
      end)
    else
      self:emit_signal('update::cpu_temp', temp)
    end
  end)

  return self
end

if not instance then
  instance = new()
end
return instance
