local awful = require("awful")
local watch = awful.widget.watch

local capi = {
  awesome = awesome,
}

watch(
  [[ bash -c "sensors | grep 'Package id 0:' | awk '{print $4}'" ]],
  3,
  function(_, stdout)
    local temp = tonumber(stdout:match("%d+"))
    if not temp or temp == "" then
      awful.spawn.easy_async_with_shell(
        "paste <(cat /sys/class/thermal/thermal_zone*/type) <(cat /sys/class/thermal/thermal_zone*/temp)",
        function(stdout2)
          if (not stdout2) or stdout:match("\n") then return end
          temp = math.floor((tonumber(stdout2:match("x86_pkg_temp(.%d+)")) / 1000) + 0.5)
          capi.awesome.emit_signal(
            "update::cpu_temp",
            temp
          )
        end
      )
    else
      capi.awesome.emit_signal(
        "update::cpu_temp",
        temp
      )
    end
  end
)