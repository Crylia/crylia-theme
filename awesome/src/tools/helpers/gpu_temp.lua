local awful = require("awful")
local watch = awful.widget.watch

local capi = {
  awesome = awesome,
}

watch(
  [[ bash -c "nvidia-smi -q -d TEMPERATURE | grep 'GPU Current Temp' | awk '{print $5}'"]],
  3,
  function(_, stdout)
    capi.awesome.emit_signal("update::gpu_temp", stdout:match("%d+"):gsub("\n", ""))
  end
)
