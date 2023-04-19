-- Awesome Libs
local akey = require('awful.key')
local ascreen = require('awful.screen')
local atag = require('awful.tag')
local beautiful = require('beautiful')
local gtable = require('gears.table')

-- Local libs
local globalkeys = require('src.bindings.global_keys')

local modkey = beautiful.user_config['modkey']

local capi = {
  client = client,
  root = root,
}

for i = 1, 9 do
  globalkeys = gtable.join(globalkeys,
    akey({ modkey }, '#' .. i + 9, function()
      local screen = ascreen.focused()
      local tag = screen.tags[i]
      if tag then
        tag:view_only()
      end
      capi.client.emit_signal('tag::switched')
    end, { description = 'Switch to tag ' .. i, group = 'Tag' }),

    akey({ modkey, 'Control' }, '#' .. i + 9,
      function()
        local screen = ascreen.focused()
        local tag = screen.tags[i]
        if tag then
          atag.viewtoggle(tag)
        end
      end, { description = 'View tag ' .. i, group = 'Tag' }),

    akey({ modkey, 'Shift' }, '#' .. i + 9, function()
      local screen = ascreen.focused()
      if capi.client.focus then
        local tag = screen.tags[i]
        if tag then
          capi.client.focus:move_to_tag(tag)
        end
      end
    end, { description = 'Move focused client to tag ' .. i, group = 'Tag' })
  )
end
capi.root.keys(globalkeys)
