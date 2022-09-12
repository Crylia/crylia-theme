local awful = require("awful")

--[[ local lgi = require("lgi")
local pulseaudio = require("lua_libpulse_glib")
local ppretty = require("pl.ppretty")

local pa = pulseaudio.new()

local ctx = pa:context("My Test App")

ctx:connect(nil, function(state)
  if state == 4 then
    print("Connection is ready")

    ctx:get_sinks(function(sinks)
      ppretty.dump(sinks)
    end)
  end
end) ]]

awful.spawn.with_line_callback(
  [[bash -c "LC_ALL=C pactl subscribe"]],
  {
    stdout = function(line)
      -- Volume changed
      if line:match("on sink") or line:match("on source") then
        awesome.emit_signal("audio::volume_changed")
        awesome.emit_signal("microphone::volume_changed")
      end
      -- Device added/removed
      if line:match("on server") then
        awesome.emit_signal("audio::device_changed")
        awesome.emit_signal("microphone::device_changed")
      end
    end,
    output_done = function()
      -- Kill the pulseaudio subscribe command to prevent it from spawning multiple instances
      awful.spawn.with_shell("pkill pactl && pkill grep")
    end
  }
)

awesome.connect_signal(
  "exit",
  function()
    awful.spawn.with_shell("pkill pactl && pkill grep")
  end
)

awesome.connect_signal(
  "audio::volume_changed",
  function()
    awful.spawn.easy_async_with_shell(
      "./.config/awesome/src/scripts/vol.sh mute",
      function(stdout)
        if stdout == "" or stdout == nil then
          return
        end
        local muted = false
        if stdout:match("yes") then
          muted = true
        end
        awful.spawn.easy_async_with_shell(
          "./.config/awesome/src/scripts/vol.sh volume",
          function(stdout2)
            if stdout == "" or stdout == nil then
              return
            end
            awesome.emit_signal("audio::get", muted, stdout2:gsub("%%", ""):gsub("\n", "") or 0)
          end
        )
      end
    )
  end
)

awesome.connect_signal(
  "microphone::volume_changed",
  function()
    awful.spawn.easy_async_with_shell(
      "./.config/awesome/src/scripts/mic.sh mute",
      function(stdout)
        local muted = false
        if stdout:match("yes") then
          muted = true
        end
        awful.spawn.easy_async_with_shell(
          "./.config/awesome/src/scripts/mic.sh volume",
          function(stdout2)
            if stdout2 == nil or stdout2 == "awful" then
              return
            end
            awesome.emit_signal("microphone::get", muted, stdout2:gsub("%%", ""):gsub("\n", "") or 0)
          end
        )
      end
    )
  end
)

awesome.emit_signal("audio::volume_changed")
awesome.emit_signal("microphone::volume_changed")
awesome.emit_signal("audio::device_changed")
awesome.emit_signal("microphone::device_changed")
