-- Awesome Libs
local abutton = require('awful.button')
local gtable = require('gears.table')
local amouse = require('awful.mouse')
local beautiful = require('beautiful')


local modkey = beautiful.user_config['modkey']

return gtable.join {
  abutton({}, 1, function(c)
    c:emit_signal('request::activate', 'mouse_click', { raise = true })
  end),
  abutton({ modkey }, 1, function(c)
    c:emit_signal('request::activate', 'mouse_click', { raise = true })
    amouse.client.move(c)
  end),
  abutton({ modkey }, 3, function(c)
    c:emit_signal('request::activate', 'mouse_click', { raise = true })
    amouse.client.resize(c)
  end),
}
