--------------------------------------------------------------------------------------------------------------
-- This is the statusbar, every widget, module and so on is combined to all the stuff you see on the screen --
--------------------------------------------------------------------------------------------------------------

return function(s)

  -- Every Widget
  --[[
  If you are going to use a widget on a single screen only, put it inside the s.index == X where X is the screen number.
  This will lead to better performance and prevent widgets to be loaded but not used
  --]]
  s.audio = require("src.widgets.audio")(s)
  s.date = require("src.widgets.date")()
  s.clock = require("src.widgets.clock")()
  s.layoutlist = require("src.widgets.layout_list")()
  s.powerbutton = require("src.widgets.power")()
  s.kblayout = require("src.widgets.kblayout")(s)
  s.taglist = require("src.widgets.taglist")(s)
  s.tasklist = require("src.widgets.tasklist")(s)
  -- s.battery = require("src.widgets.battery")()
  -- s.bluetooth = require("src.widgets.bluetooth")()
  -- s.cpu_freq = require("src.widgets.cpu_info")("freq", "average")
  -- s.systray = require("src.widgets.systray")(s)
  -- s.cpu_usage = require("src.widgets.cpu_info")("usage")
  -- s.cpu_temp = require("src.widgets.cpu_info")("temp")
  -- s.gpu_usage = require("src.widgets.gpu_info")("usage")
  -- s.gpu_temp = require("src.widgets.gpu_info")("temp")
  -- s.network = require("src.widgets.network")()
  -- s.ram_info = require("src.widgets.ram_info")()

  if s.index == 1 then
    s.systray = require("src.widgets.systray")(s)
    s.cpu_usage = require("src.widgets.cpu_info")("usage")
    s.cpu_temp = require("src.widgets.cpu_info")("temp")
    s.gpu_usage = require("src.widgets.gpu_info")("usage")
    s.gpu_temp = require("src.widgets.gpu_info")("temp")

    require("src.modules.crylia_bar.left_bar")(s, { s.layoutlist, s.systray, s.taglist })
    require("src.modules.crylia_bar.center_bar")(s, { s.tasklist })
    require("src.modules.crylia_bar.right_bar")(s, { s.gpu_usage, s.gpu_temp, s.cpu_usage, s.cpu_temp, s.audio, s.kblayout, s.date, s.clock, s.powerbutton })
    require("src.modules.crylia_bar.dock")(s, user_vars.dock_programs)
  end

  if s.index == 2 then
    s.network = require("src.widgets.network")()
    s.ram_info = require("src.widgets.ram_info")()

    require("src.modules.crylia_bar.left_bar")(s, { s.layoutlist, s.taglist })
    require("src.modules.crylia_bar.center_bar")(s, { s.tasklist })
    require("src.modules.crylia_bar.right_bar")(s, { s.ram_info, s.audio, s.kblayout, s.network, s.date, s.clock, s.powerbutton })
  end
end
