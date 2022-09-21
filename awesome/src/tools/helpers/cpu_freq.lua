local awful = require("awful")
local watch = awful.widget.watch

local capi = {
  awesome = awesome,
}

watch(
  [[ bash -c "cat /proc/cpuinfo | grep "MHz" | awk '{print int($4)}'" ]],
  3,
  function(_, stdout)
    local cpu_freq = {}

    for value in stdout:gmatch("%d+") do
      table.insert(cpu_freq, value)
    end

    local average = 0

    if User_config.clock_mode == "average" then
      for i = 1, #cpu_freq do
        average = average + cpu_freq[i]
      end
      average = math.floor(average / #cpu_freq)
      capi.awesome.emit_signal("update::cpu_freq_average", average)
    elseif User_config.clock_mode then
      capi.awesome.emit_signal("update::cpu_freq_core", cpu_freq[User_config.clock_mode])
    end
  end
)
