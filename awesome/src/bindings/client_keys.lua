-- Awesome Libs
local aclient = require('awful.client')
local akey = require('awful.key')
local ascreen = require('awful.screen')
local beautiful = require('beautiful')

local gtable = require('gears.table')

local modkey = beautiful.user_config['modkey']

return gtable.join(
--#region Basic interactions
  akey({ modkey }, '#24', function(c)
    c:kill()
  end, { description = 'Close client', group = 'Client' }),

  akey({ modkey }, '#41', function(c)
    c.fullscreen = not c.fullscreen
    c:raise()
  end, { description = 'Toggle fullscreen', group = 'Client' }),

  akey({ modkey }, '#42',
    aclient.floating.toggle,
    { description = 'Toggle floating', group = 'Client' }),

  akey({ modkey }, '#57', function(c)
    c.minimized = true
  end, { description = 'Minimize', group = 'Client' }),

  akey({ modkey }, '#58', function(c)
    c.maximized = not c.maximized
    c:raise()
  end, { description = 'Toggle maximize', group = 'Client' }),
  --#endregion

  --#region Client focus movement
  akey({ modkey }, '#44', function(c)
    aclient.focus.global_bydirection('up', c)
  end, { description = 'Move client a screen up', group = 'Client' }),

  akey({ modkey }, '#111', function(c)
    aclient.focus.global_bydirection('up', c)
  end, { description = 'Move client a screen up', group = 'Client' }),

  akey({ modkey }, '#43', function(c)
    aclient.focus.global_bydirection('left', c)
  end, { description = 'Move client a screen left', group = 'Client' }),

  akey({ modkey }, '#113', function(c)
    aclient.focus.global_bydirection('left', c)
  end, { description = 'Move client a screen left', group = 'Client' }),

  akey({ modkey }, '#46', function(c)
    aclient.focus.global_bydirection('right', c)
  end, { description = 'Move client a screen right', group = 'Client' }),

  akey({ modkey }, '#114', function(c)
    aclient.focus.global_bydirection('right', c)
  end, { description = 'Move client a screen right', group = 'Client' }),

  akey({ modkey }, '#45', function(c)
    aclient.focus.global_bydirection('down', c)
  end, { description = 'Move client a screen down', group = 'Client' }),

  akey({ modkey }, '#116', function(c)
    aclient.focus.global_bydirection('down', c)
  end, { description = 'Move client a screen down', group = 'Client' }),
  --#endregion

  --#region Screen movement
  akey({ modkey, 'Shift' }, '#44', function(c)
    local s = ascreen.focus_bydirection('Up', c.screen)
    c:move_to_screen(s)
    if not c:isvisible() and c.first_tag then
      c.first_tag:view_only()
    end
    c:emit_signal('request::activate')
    c:raise()
  end, { description = 'Move client a screen up', group = 'Client' }),

  akey({ modkey, 'Shift' }, '#111', function(c)
    local s = ascreen.focus_bydirection('Up', c.screen)
    c:move_to_screen(s)
    if not c:isvisible() and c.first_tag then
      c.first_tag:view_only()
    end
    c:emit_signal('request::activate')
    c:raise()
    c:activate {
      --switch_to_tag = true,
      raise   = true,
      context = 'somet_reason',
    }
  end, { description = 'Move client a screen up', group = 'Client' }),

  akey({ modkey, 'Shift' }, '#43', function(c)
    c:move_to_screen(ascreen.focus_bydirection('left', c.screen))
    c.first_tag:view_only()
    client.focus = c
    c:raise()
    c:activate {
      --switch_to_tag = true,
      raise   = true,
      context = 'somet_reason',
    }
  end, { description = 'Move client a screen left', group = 'Client' }),

  akey({ modkey, 'Shift' }, '#113', function(c)
    local s = ascreen.focus_bydirection('left', c.screen)
    c:move_to_screen(s)
    if not c:isvisible() and c.first_tag then
      c.first_tag:view_only()
    end
    c:emit_signal('request::activate')
    c:raise()
  end, { description = 'Move client a screen left', group = 'Client' }),

  akey({ modkey, 'Shift' }, '#46', function(c)
    local s = ascreen.focus_bydirection('Right', c.screen)
    c:move_to_screen(s)
    if not c:isvisible() and c.first_tag then
      c.first_tag:view_only()
    end
    c:emit_signal('request::activate')
    c:raise()
  end, { description = 'Move client a screen right', group = 'Client' }),

  akey({ modkey, 'Shift' }, '#114', function(c)
    local s = ascreen.focus_bydirection('Right', c.screen)
    c:move_to_screen(s)
    if not c:isvisible() and c.first_tag then
      c.first_tag:view_only()
    end
    c:emit_signal('request::activate')
    c:raise()
  end, { description = 'Move client a screen right', group = 'Client' }),

  akey({ modkey, 'Shift' }, '#45', function(c)
    local s = ascreen.focus_bydirection('Down', c.screen)
    c:move_to_screen(s)
    if not c:isvisible() and c.first_tag then
      c.first_tag:view_only()
    end
    c:emit_signal('request::activate')
    c:raise()
  end, { description = 'Move client a screen down', group = 'Client' }),

  akey({ modkey, 'Shift' }, '#116', function(c)
    local s = ascreen.focus_bydirection('Down', c.screen)
    c:move_to_screen(s)
    if not c:isvisible() and c.first_tag then
      c.first_tag:view_only()
    end
    c:emit_signal('request::activate')
    c:raise()
  end, { description = 'Move client a screen down', group = 'Client' })
--#endregion
)
