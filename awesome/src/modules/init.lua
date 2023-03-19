--------------------------------------------------------------------------------------------------------------
-- This is the statusbar, every widget, module and so on is combined to all the stuff you see on the screen --
--------------------------------------------------------------------------------------------------------------
-- Awesome Libs
local awful = require('awful')

awful.screen.connect_for_each_screen(function(s)
  -- Create 9 tags
  awful.layout.append_default_layouts(User_config.layouts)
  awful.tag({ '1', '2', '3', '4', '5', '6', '7', '8', '9' }, s, User_config.layouts[1])

  require('src.modules.desktop.desktop') { screen = s }
  require('src.modules.crylia_bar.init')(s)
  --require('src.modules.crylia_wibox.init')(s)
  require('src.modules.notification-center.init') { screen = s }
  --require('src.modules.window_switcher.init')(s)
  require('src.modules.application_launcher.init') { screen = s }
end)

local ip = require('src.modules.inputbox.new') {
  text = 'inputboxtest',
  cursor_pos = 4,
  highlight = {
    start_pos = 1,
    end_pos = 4,
  },
  text_hint = 'Input Some Text',
}

awful.popup {
  widget = ip.widget,
  bg = '#212121',
  visible = true,
  screen = 1,
  placement = awful.placement.centered,
}

--[[ require('src.modules.inputbox.init') {
  text = 'inputboxtest',
  cursor_pos = 4,
  highlight = {
    start_pos = 5,
    end_pos = 8,
  },
}
 ]]
