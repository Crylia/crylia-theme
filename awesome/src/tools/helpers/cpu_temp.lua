local awful = require("awful")
local watch = awful.widget.watch

watch(
  [[ bash -c "sensors | grep 'Package id 0:' | awk '{print $4}'" ]],
  3,
  function(_, stdout)
    local temp = tonumber(stdout:match("%d+"))
    awesome.emit_signal(
      "update::cpu_temp",
      temp
    )
  end
)
