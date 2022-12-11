local aspawn = require("awful.spawn")

local capi = {
  awesome = awesome,
}

aspawn.with_line_callback([[bash -c "LC_ALL=C pactl subscribe"]], {
  stdout = function(line)
    -- Volume changed
    if line:match("on sink") or line:match("on source") then
      capi.awesome.emit_signal("audio::volume_changed")
      capi.awesome.emit_signal("microphone::volume_changed")
    end
    -- Device added/removed
    if line:match("on server") then
      capi.awesome.emit_signal("audio::device_changed")
      capi.awesome.emit_signal("microphone::device_changed")
    end
  end,
  output_done = function()
    aspawn.with_shell("pkill pactl && pkill grep")
  end
})

capi.awesome.connect_signal("audio::volume_changed", function()
  aspawn.easy_async_with_shell("./.config/awesome/src/scripts/vol.sh mute", function(stdout)
    if stdout == "" or stdout == nil then
      return
    end
    local muted = false
    if stdout:match("yes") then
      muted = true
    end
    aspawn.easy_async_with_shell("./.config/awesome/src/scripts/vol.sh volume", function(stdout2)
      if stdout == "" or stdout == nil then
        return
      end
      capi.awesome.emit_signal("audio::get", muted, stdout2:gsub("%%", ""):gsub("\n", "") or 0)
    end)
  end)
end)

capi.awesome.connect_signal("microphone::volume_changed", function()
  aspawn.easy_async_with_shell("./.config/awesome/src/scripts/mic.sh mute", function(stdout)
    local muted = false
    if stdout:match("yes") then
      muted = true
    end
    aspawn.easy_async_with_shell("./.config/awesome/src/scripts/mic.sh volume", function(stdout2)
      if stdout2 == nil or stdout2 == "awful" then
        return
      end
      capi.awesome.emit_signal("microphone::get", muted, stdout2:gsub("%%", ""):gsub("\n", "") or 0)
    end)
  end)
end)

capi.awesome.emit_signal("audio::volume_changed")
capi.awesome.emit_signal("microphone::volume_changed")
capi.awesome.emit_signal("audio::device_changed")
capi.awesome.emit_signal("microphone::device_changed")
