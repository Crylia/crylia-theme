--------------------------------------------------------------------------------------------------------------
-- This is the statusbar, every widget, module and so on is combined to all the stuff you see on the screen --
--------------------------------------------------------------------------------------------------------------
-- Awesome Libs
local awful = require("awful")

awful.screen.connect_for_each_screen(function(s)
  -- Create 9 tags
  awful.layout.append_default_layouts(User_config.layouts)
  awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, User_config.layouts[1])

  require("src.modules.desktop.desktop") { screen = s }
  require("src.modules.powermenu.powermenu")(s)
  require("src.modules.audio.volume_osd") { screen = s }
  --require("src.modules.audio.volume_controller") { screen = s }
  require("src.modules.brightness.brightness_osd") { screen = s }
  require("src.modules.crylia_bar.init")(s)
  --require("src.modules.crylia_wibox.init")(s)
  require("src.modules.notification-center.init")(s)
  require("src.modules.window_switcher.init")(s)
  require("src.modules.application_launcher.init") { screen = s }
  --require("src.modules.network_controller.init") { screen = s }
end)

do
  require("src.lib.nice") { titlebar_font = User_config.font.bold,
    titlebar_items = { left = { "icon" }, right = { "minimize", "maximize", "close" } } }
end
