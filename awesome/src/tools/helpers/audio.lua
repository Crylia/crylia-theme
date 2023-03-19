local aspawn = require('awful.spawn')
local gobject = require('gears.object')
local gtable = require('gears.table')

local audio = {}

local instance = nil

function audio.set_sink_volume(volume)
  aspawn('pactl set-sink-volume @DEFAULT_SINK@ ' .. volume .. '%')
end

function audio.set_source_volume(volume)
  aspawn('pactl set-source-volume @DEFAULT_SOURCE@ ' .. volume .. '%')
end

function audio.sink_volume_up()
  aspawn('pactl set-sink-volume @DEFAULT_SINK@ +2%')
end

function audio.source_volume_up()
  aspawn('pactl set-source-volume @DEFAULT_SOURCE@ +2%')
end

function audio.sink_volume_down()
  aspawn('pactl set-sink-volume @DEFAULT_SINK@ -2%')
end

function audio.source_volume_down()
  aspawn('pactl set-source-volume @DEFAULT_SOURCE@ -2%')
end

function audio.sink_toggle_mute()
  aspawn('pactl set-sink-mute @DEFAULT_SINK@ toggle')
end

function audio.source_toggle_mute()
  aspawn('pactl set-source-mute @DEFAULT_SOURCE@ toggle')
end

local function new()

  local self = gobject {}
  gtable.crush(self, audio, true)

  aspawn.with_line_callback([[bash -c "LC_ALL=C pactl subscribe"]], {
    stdout = function(line)
      -- Volume changed
      if line:match('on sink') or line:match('on source') then
        self:emit_signal('sink::volume_changed')
        self:emit_signal('source::volume_changed')
      end
      -- Device added/removed
      if line:match('on server') then
        self:emit_signal('sink::device_changed')
        self:emit_signal('source::device_changed')
      end
    end,
    output_done = function()
      aspawn.with_shell('pkill pactl && pkill grep')
    end,
  })

  self:connect_signal('sink::volume_changed', function()
    aspawn.easy_async_with_shell([[LC_ALL=C pactl get-sink-mute @DEFAULT_SINK@]], function(stdout)
      if stdout == '' or stdout == nil then
        return
      end
      local muted = false
      if stdout:match('yes') then
        muted = true
      end
      aspawn.easy_async_with_shell([[LC_ALL=C pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}']], function(stdout2)
        if stdout == '' or stdout == nil then
          return
        end
        self:emit_signal('sink::get', muted, stdout2:gsub('%%', ''):gsub('\n', '') or 0)
      end)
    end)
  end)

  self:connect_signal('source::volume_changed', function()
    aspawn.easy_async_with_shell([[LC_ALL=C pactl get-source-mute @DEFAULT_SOURCE@]], function(stdout)
      local muted = false
      if stdout:match('yes') then
        muted = true
      end
      aspawn.easy_async_with_shell([[LC_ALL=C pactl get-source-volume @DEFAULT_SOURCE@ | awk '{print $5}']], function(stdout2)
        if stdout2 == nil or stdout2 == 'awful' then
          return
        end
        self:emit_signal('source::get', muted, stdout2:gsub('%%', ''):gsub('\n', '') or 0)
      end)
    end)
  end)

  self:emit_signal('sink::volume_changed')
  self:emit_signal('source::volume_changed')
  self:emit_signal('sink::device_changed')
  self:emit_signal('source::device_changed')

  return self
end

if not instance then
  instance = new()
end
return instance
