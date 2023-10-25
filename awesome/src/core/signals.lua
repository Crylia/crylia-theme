local setmetatable = setmetatable

-- Awesome Libs
local aplacement = require('awful.placement')
local ascreen = require('awful.screen')
local beautiful = require('beautiful')
local gtimer = require('gears.timer')

local capi = {
  awesome = awesome,
  mouse = mouse,
  screen = screen,
  client = client,
  tag = tag,
}

local instance = nil
if not instance then
  instance = setmetatable({}, {
    __call = function()
      capi.screen.connect_signal('added', function()
        capi.awesome.restart()
      end)

      capi.screen.connect_signal('removed', function()
        capi.awesome.restart()
      end)

      capi.client.connect_signal('manage', function(c)
        if capi.awesome.startup and not c.size_hints.user_porition and not c.size_hints.program_position then
          aplacement.no_offscreen(c)
        end
        if c.transient_for then
          c.floating = true
        end
        if c.fullscreen then
          gtimer.delayed_call(function()
            if c.valid then
              c:geometry(c.screen.geometry)
            end
          end)
        end
      end)

      capi.client.connect_signal('unmanage', function(c)
        if #ascreen.focused().clients > 0 then
          ascreen.focused().clients[1]:emit_signal('request::activate', 'mouse_enter', {
            raise = true,
          })
        end
      end)

      capi.tag.connect_signal('property::selected', function(c)
        if #ascreen.focused().clients > 0 then
          ascreen.focused().clients[1]:emit_signal('request::activate', 'mouse_enter', {
            raise = true,
          })
        end
      end)

      -- Sloppy focus
      if beautiful.user_config.sloppy_focus then
        client.connect_signal('mouse::enter', function(c)
          c:emit_signal(
            'request::activate',
            'mouse_enter', {
            raise = true,
          })
        end)
      end
    end,
  })
end
return instance
