local awful = require("awful")
local watch = awful.widget.watch

watch(
  [[ bash -c "nvidia-smi -q -d UTILIZATION | grep Gpu | awk '{print $3}'"]],
  3,
  function(_, stdout)
    stdout = stdout:match("%d+")
    awesome.emit_signal("update::gpu_usage", stdout)
  end
)
