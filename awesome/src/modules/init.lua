local tinsert = table.insert
local load = load
local ipairs = ipairs

-- Awesome Libs
local awful = require('awful')
local beautiful = require('beautiful')

local instance = nil
if not instance then
  instance = setmetatable({}, {
    __call = function()
      awful.screen.connect_for_each_screen(function(s)
        local layouts = {}
        for _, str in ipairs(beautiful.user_config.layouts) do
          tinsert(layouts, load('return ' .. str, nil, 't', { awful = awful })())
        end

        awful.layout.append_default_layouts(layouts)
        awful.tag({ '1', '2', '3', '4', '5', '6', '7', '8', '9' }, s, layouts[1])

        require('src.modules.desktop.desktop') { screen = s }
        require('src.modules.crylia_bar')(s)
        --require('src.modules.crylia_wibox.init')(s)
        require('src.modules.notification-center') { screen = s }
        --require('src.modules.window_switcher.init') { screen = s }
        require('src.modules.application_launcher') { screen = s }
      end)
    end,
  })
end
return instance
