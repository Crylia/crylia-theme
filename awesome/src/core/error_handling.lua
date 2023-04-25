local setmetatable = setmetatable
local tostring = tostring

-- Awesome Libs
local gfilesystem = require('gears.filesystem')
local gtimer = require('gears.timer')
local naughty = require('naughty')

local capi = {
  awesome = awesome,
}

local instance = nil
if not instance then
  instance = setmetatable({}, {
    __call = function()
      if capi.awesome.startup_errors then
        naughty.notification {
          preset = naughty.config.presets.critical,
          title = 'ERROR!',
          app_name = 'System Notification',
          message = capi.awesome.startup_errors,
          icon = gfilesystem.get_configuration_dir() .. 'src/assets/CT.svg',
        }
      end

      local in_error = false
      capi.awesome.connect_signal('debug::error', function(err)
        if in_error then return end
        in_error = true

        naughty.notification {
          preset = naughty.config.presets.critical,
          title = 'ERROR',
          app_name = 'System Notification',
          message = tostring(err),
          icon = gfilesystem.get_configuration_dir() .. 'src/assets/CT.svg',
        }

        -- Make sure an error is only put every 3 seconds to prevent spam
        gtimer {
          timeout = 3,
          autostart = true,
          single_shot = true,
          callback = function()
            in_error = false
          end,
        }
      end)
    end,
  })
end
return instance
