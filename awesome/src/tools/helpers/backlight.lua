local awful = require("awful")

BACKLIGHT_MAX_BRIGHTNESS = 0
BACKLIGHT_SEPS = 0
awful.spawn.easy_async_with_shell(
  "pkexec xfpm-power-backlight-helper --get-max-brightness",
  function(stdout)
    BACKLIGHT_MAX_BRIGHTNESS = tonumber(stdout)
    BACKLIGHT_SEPS = BACKLIGHT_MAX_BRIGHTNESS / 100
    BACKLIGHT_SEPS = math.floor(BACKLIGHT_SEPS)
  end
)

awesome.connect_signal(
  "brightness::update",
  function()
    awful.spawn.easy_async_with_shell(
      "pkexec xfpm-power-backlight-helper --get-brightness",
      function(value)
        awesome.emit_signal("brightness::get", math.floor((tonumber(value) - 1) / (BACKLIGHT_MAX_BRIGHTNESS - 1) * 100))
        awesome.emit_signal("brightness::rerun")
      end
    )
  end
)
