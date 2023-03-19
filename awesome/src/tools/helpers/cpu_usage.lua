local aspawn = require('awful.spawn')
local gobject = require('gears.object')
local gtimer = require('gears.timer')

local instance = nil

--!Find a better way that doesn't need manual GC since it has a huge performance impact
local function new()

  local self = gobject {}

  local total_prev = 0
  local idle_prev = 0

  gtimer {
    timeout = 2,
    autostart = true,
    call_now = true,
    callback = function()
      aspawn.easy_async_with_shell([[ cat "/proc/stat" | grep '^cpu ' ]], function(stdout)
        local user, nice, system, idle, iowait, irq, softirq, steal =
        stdout:match('(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s')

        local total = user + nice + system + idle + iowait + irq + softirq + steal

        local diff_total = total - total_prev
        local diff_usage = math.floor(((1000 * (diff_total - (idle - idle_prev)) / diff_total + 5) / 10) + 0.5)

        self:emit_signal('update::cpu_usage', diff_usage)

        total_prev = total
        idle_prev = idle
      end)
    end
  }

  return self
end

if not instance then
  instance = new()
end
return instance
