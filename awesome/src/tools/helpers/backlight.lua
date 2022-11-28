local aspawn = require("awful.spawn")
local capi = {
  awesome = awesome,
}

local backlight = {}

backlight.device = ""

backlight.max_brightness = 1

-- Init the backlight device and get the max brightness
aspawn.easy_async_with_shell("ls /sys/class/backlight/", function(stdout)
  backlight.device = stdout:gsub("%s+", "")
  aspawn.easy_async_with_shell("cat /sys/class/backlight/" .. backlight.device .. "/max_brightness", function(stdout)
    backlight.max_brightness = tonumber(stdout:gsub("\n", "") or 0)
  end)
end)


function backlight.brightness_get()
  aspawn.easy_async_with_shell("cat /sys/class/backlight/" .. backlight.device .. "/brightness", function(stdout)
    capi.awesome.emit_signal("brightness::get", tonumber(stdout))
  end)
end

function backlight.brightness_get_percent()
  aspawn.easy_async_with_shell("cat /sys/class/backlight/" .. backlight.device .. "/brightness", function(stdout)
    capi.awesome.emit_signal("brightness::get_percent",
      math.floor((tonumber(stdout) / backlight.max_brightness * 100) + 0.5))
  end)
end

function backlight.brightness_set(value)
  if value < 0 or value > (backlight.max_brightness or 24000) then return end
  aspawn.with_shell("echo " .. math.floor(value) .. " > /sys/class/backlight/" .. backlight.device .. "/brightness")
end

function backlight.brightness_increase()
  aspawn.easy_async_with_shell("cat /sys/class/backlight/" .. backlight.device .. "/brightness", function(stdout)
    local new_value = tonumber(stdout:gsub("\n", "") or 0) +
        (backlight.max_brightness / 100 * User_config.brightness_step)
    backlight.brightness_set(new_value)
    capi.awesome.emit_signal("brightness::changed", new_value)
  end)
end

function backlight.brightness_decrease()
  aspawn.easy_async_with_shell("cat /sys/class/backlight/" .. backlight.device .. "/brightness", function(stdout)
    local new_value = tonumber(stdout:gsub("\n", "") or 0) -
        (backlight.max_brightness / 100 * User_config.brightness_step)
    backlight.brightness_set(new_value)
    capi.awesome.emit_signal("brightness::changed", new_value)
  end)
end

return backlight
