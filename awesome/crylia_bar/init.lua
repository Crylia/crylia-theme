--------------------------------------------------------------------------------------------------------------
-- This is the statusbar, every widget, module and so on is combined to all the stuff you see on the screen --
--------------------------------------------------------------------------------------------------------------
-- Awesome Libs
local awful = require("awful")

awful.screen.connect_for_each_screen(
-- For each screen this function is called once
-- If you want to change the modules per screen use the indices
-- e.g. 1 would be the primary screen and 2 the secondary screen.
    function(s)
        -- Create 9 tags
        awful.layout.layouts = user_vars.layouts
        awful.tag(
            { "1", "2", "3", "4", "5", "6", "7", "8", "9" },
            s,
            user_vars.layouts[1]
        )

        require("src.modules.powermenu")(s)
        -- TODO: rewrite calendar osd, maybe write an own inplementation
        -- require("src.modules.calendar_osd")(s)
        require("src.modules.volume_osd")(s)
        require("src.modules.brightness_osd")(s)
        require("src.modules.titlebar")

        -- Widgets
        s.battery = require("src.widgets.battery")()
        s.network = require("src.widgets.network")()
        s.audio = require("src.widgets.audio")()
        s.date = require("src.widgets.date")()
        s.clock = require("src.widgets.clock")()
        s.bluetooth = require("src.widgets.bluetooth")()
        s.layoutlist = require("src.widgets.layout_list")()
        s.powerbutton = require("src.widgets.power")()
        s.kblayout = require("src.widgets.kblayout")(s)
        s.taglist = require("src.widgets.taglist")(s)
        s.tasklist = require("src.widgets.tasklist")(s)
        s.systray = require("src.widgets.systray")(s)

        -- Add more of these if statements if you want to change
        -- the modules/widgets per screen.
        -- uncomment this example and dont forget to remove/comment the other code below
        --[[ if s.index == 1 then
            require("crylia_bar.left_bar")(s, {s.layoutlist, s.systray, s.taglist})
            require("crylia_bar.center_bar")(s, s.tasklist)
            require("crylia_bar.right_bar")(s, {s.date, s.clock,s.powerbutton})
            require("crylia_bar.dock")(s, user_vars.dock_programs)
        end ]]

        --[[ if s.index == 2 then
            require("crylia_bar.left_bar")(s, {s.layoutlist, s.systray, s.taglist})
            require("crylia_bar.center_bar")(s, s.tasklist)
            require("crylia_bar.right_bar")(s, {s.battery, s.network, s.bluetooth, s.audio, s.kblayout, s.date, s.clock,s.powerbutton})
        end ]]
        -- Bars

        require("crylia_bar.left_bar")(s, { s.layoutlist, s.systray, s.taglist })
        require("crylia_bar.center_bar")(s, s.tasklist)
        require("crylia_bar.right_bar")(s, { s.battery, s.network, s.bluetooth, s.audio, s.kblayout, s.date, s.clock, s.powerbutton })
        require("crylia_bar.dock")(s, user_vars.dock_programs)
    end
)
