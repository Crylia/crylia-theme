----------------------------------------------------------------
-- This class is to output an error if you fuck up the config --
----------------------------------------------------------------
-- Awesome Libs
local naughty = require('naughty')
local gfilesystem = require('gears.filesystem')

local capi = {
  awesome = awesome,
}

if capi.awesome.startup_errors then
  naughty.notify { preset = naughty.config.presets.critical,
    title = 'Oops, there were errors during startup!',
    text = capi.awesome.startup_errors,
    gfilesystem.get_configuration_dir() .. 'src/assets/CT.svg',
  }
end

do
  local in_error = false
  capi.awesome.connect_signal(
    'debug::error',
    function(err)
      if in_error then
        return
      end
      in_error = true

      naughty.notification {
        preset = naughty.config.presets.critical,
        title = 'ERROR',
        app_name = 'System Notification',
        message = tostring(err),
        icon = gfilesystem.get_configuration_dir() .. 'src/assets/CT.svg',
      }
      in_error = false
    end
  )
end
