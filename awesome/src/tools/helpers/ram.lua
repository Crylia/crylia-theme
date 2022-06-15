local awful = require("awful")
local watch = awful.widget.watch

watch(
  [[ bash -c "cat /proc/meminfo| grep Mem | awk '{print $2}'" ]],
  3,
  function(_, stdout)
    local MemTotal, MemFree, MemAvailable = stdout:match("(%d+)\n(%d+)\n(%d+)\n")
    awesome.emit_signal("update::ram_widget", MemTotal, MemFree, MemAvailable)
  end
)
