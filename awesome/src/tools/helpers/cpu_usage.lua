local awful = require("awful")
local watch = awful.widget.watch

local capi = {
  awesome = awesome,
}

local total_prev = 0
local idle_prev = 0

--!Find a better way that doesn't need manual GC since it has a huge performance impact
watch(
  [[ cat "/proc/stat" | grep '^cpu ' ]],
  3,
  function(_, stdout)
    local user, nice, system, idle, iowait, irq, softirq, steal =
    stdout:match("(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s")

    local total = user + nice + system + idle + iowait + irq + softirq + steal

    local diff_idle = idle - idle_prev
    local diff_total = total - total_prev
    local diff_usage = math.floor(((1000 * (diff_total - diff_idle) / diff_total + 5) / 10) + 0.5)

    capi.awesome.emit_signal("update::cpu_usage", diff_usage)

    total_prev = total
    idle_prev = idle

    collectgarbage("collect")
  end
)
