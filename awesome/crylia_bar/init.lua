--------------------------------------------------------------------------------------------------------------
-- This is the statusbar, every widget, module and so on is combined to all the stuff you see on the screen --
--------------------------------------------------------------------------------------------------------------
-- Awesome Libs
local awful = require("awful")

awful.screen.connect_for_each_screen(
    function (s)
        -- Modules
        require("theme.crylia.modules.powermenu")(s)
        require("theme.crylia.modules.calendar_osd")(s)
        require("theme.crylia.modules.volume_osd")(s)
        require("theme.crylia.modules.brightness_osd")(s)
        require("theme.crylia.modules.titlebar")

        -- Widgets
        s.battery =     require("theme.crylia.widgets.battery")()
        s.network =     require("theme.crylia.widgets.network")()
        s.audio =       require("theme.crylia.widgets.audio")()
        s.date =        require("theme.crylia.widgets.date")()
        s.clock =       require("theme.crylia.widgets.clock")()
        s.bluetooth =   require("theme.crylia.widgets.bluetooth")()
        s.layoutlist =  require("theme.crylia.widgets.layout_list")()
        s.powerbutton = require("theme.crylia.widgets.power")()
        s.kblayout =    require("theme.crylia.widgets.kblayout")()
        s.taglist =     require("theme.crylia.widgets.taglist")(s)
        s.tasklist =    require("theme.crylia.widgets.tasklist")(s)
        s.systray =     require("theme.crylia.widgets.systray")(s)

        -- Bars
        require("crylia_bar.left_bar")(s, {s.layoutlist, s.systray, s.taglist})
        require("crylia_bar.center_bar")(s, s.tasklist)
        require("crylia_bar.right_bar")(s, {s.battery, s.network, s.bluetooth, s.audio, s.kblayout, s.date, s.clock,s.powerbutton})
    end
)
