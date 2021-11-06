--------------------------------------------------------------------------------------------------------------
-- This is the statusbar, every widget, module and so on is combined to all the stuff you see on the screen --
--------------------------------------------------------------------------------------------------------------
-- Awesome Libs
local awful = require("awful")
local beautiful = require("beautiful")
local colors = require ("theme.crylia.colors")
local dpi = beautiful.xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")

local tasklist = require("theme.crylia.widgets.tasklist")
local taglist = require("theme.crylia.widgets.taglist")

awful.screen.connect_for_each_screen(
    function (s)

        -- Bar for the layoutbox, taglist and newtag button
        s.top_left = awful.popup {
            widget = wibox.container.background,
            ontop = false,
            bg = colors.color["Grey900"],
            stretch = false,
            visible = true,
            placement = function (c)
                awful.placement.top_left(c, {margins = dpi(10)})
            end,
            shape = function (cr, width, height)
                gears.shape.rounded_rect(cr, width, height, 5)
            end
        }

        -- Bar for the tasklist
        s.top_center = awful.popup{
            widget = {
                margins = dpi(10),
                widget = wibox.container.margin
            },
            ontop = false,
            bg = colors.color["Grey900"],
            visible = true,
            stretch = false,
            maximum_width = 600,
            placement = function (c)
                awful.placement.top(c, {margins = dpi(10)})
            end,
            shape = function (cr, width, height)
                gears.shape.rounded_rect(cr, width, height, 5)
            end,
            layout = wibox.layout.flex.horizontal
        }

        -- Bar for all the widgets
        s.top_right = awful.popup {
            widget = {
                margins = dpi(10),
                widget = wibox.container.margin
            },
            ontop = false,
            bg = "#212121",
            visible = true,
            placement = function (c)
                awful.placement.top_right(c, {margins = dpi(10)})
            end,
            shape = function (cr, width, height)
                gears.shape.rounded_rect(cr, width, height, 5)
            end
        }

        -- Calendar OSD container
        s.calendar_osd_container = awful.popup{
            widget = {},
            ontop = true,
            shape = function (cr, width, height)
                gears.shape.rounded_rect(cr, width, height, 10)
            end,
            border_width = dpi(0),
            border_color = colors.color["Grey800"],
            placement = function (c)
                awful.placement.top_right(c, {
                    margins = {
                        right = dpi(100),
                        top = dpi(60)
                    }
                })
            end,
            visible = false
        }

        local hide_osd = gears.timer{
            timeout = 0.25,
            autostart = true,
            callback = function ()
                s.calendar_osd_container.visible = false
            end
        }

        -- OSD Container
        s.volume_container = awful.popup{
            widget = {
                margins = dpi(10),
                widget = wibox.container.margin
            },
            ontop = true,
            bg = "#00000000",
            border_width = dpi(0),
            border_color = "#454545",
            shape = function (cr, width, height)
                gears.shape.rounded_rect(cr, width, height, 10)
            end,
            placement = function (c)
                awful.placement.bottom_right(c, {margins = dpi(10)})
            end,
            visible = false,
        }

        local hide_volume_osd = gears.timer{
            timeout = 1,
            autostart = true,
            callback = function ()
                s.volume_container.visible = false
            end
        }

        s.brightness_container = awful.popup{
            widget = {
                margins = dpi(10),
                widget = wibox.container.margin
            },
            ontop = true,
            bg = "#00000000",
            border_width = dpi(0),
            border_color = "#454545",
            shape = function (cr, width, height)
                gears.shape.rounded_rect(cr, width, height, 10)
            end,
            placement = function (c)
                awful.placement.bottom_right(c, {margins = dpi(10)})
            end,
            visible = false
        }

        local hide_brightness_osd = gears.timer{
            timeout = 1,
            autostart = true,
            callback = function ()
                s.brightness_container.visible = false
            end
        }

        s.powermenu_container = wibox{
            screen = s,
            type = "splash",
            visible = false,
            ontop = true,
            bg = "#21212188",
            height = s.geometry.height,
            width = s.geometry.width,
            x = s.geometry.x,
            y = s.geometry.y
        }

        -- All the modules and widgets
        s.volume_osd = require("theme.crylia.modules.volume_osd")()
        s.brightness_osd = require("theme.crylia.modules.brightness_osd")()
        s.battery = require("theme.crylia.widgets.battery")()
        s.network = require("theme.crylia.widgets.network")()
        s.audio = require("theme.crylia.widgets.audio")()
        s.date = require("theme.crylia.widgets.date")()
        s.clock = require("theme.crylia.widgets.clock")()
        s.bluetooth = require("theme.crylia.widgets.bluetooth")()
        s.calendar_osd = require("theme.crylia.modules.calendar_osd")()
        s.layoutlist = require("theme.crylia.widgets.layout_list")()
        s.powerbutton = require("theme.crylia.widgets.power")()
        s.kblayout = require("theme.crylia.widgets.kblayout")()
        s.powermenu = require("theme.crylia.modules.powermenu")()

        s.top_left:setup {
            nil,
            nil,
            {
                {
                    s.layoutlist,
                    margins = dpi(6),
                    widget = wibox.container.margin
                },
                {
                    taglist(s),
                    margins = dpi(6),
                    widget = wibox.container.margin
                },
                forced_height = 45,
                layout = wibox.layout.fixed.horizontal
            },
            layout = wibox.layout.align.horizontal
        }

        -- This is the space from top down till the window starts
        s.top_left:struts{
            top = 55
        }

        s.top_center:setup{
            {
                tasklist(s),
                margins = dpi(6),
                widget = wibox.container.margin
            },
            forced_height = 45,
            layout = wibox.layout.align.horizontal
        }

        s.top_right:setup {
            nil,
            nil,
            {
                {
                    s.battery,
                    left = dpi(6),
                    right = dpi(3),
                    top = dpi(6),
                    bottom = dpi(6),
                    widget = wibox.container.margin
                },
                {
                    s.network,
                    left = dpi(3),
                    right = dpi(3),
                    top = dpi(6),
                    bottom = dpi(6),
                    widget = wibox.container.margin
                },
                {
                    s.bluetooth,
                    left = dpi(3),
                    right = dpi(3),
                    top = dpi(6),
                    bottom = dpi(6),
                    widget = wibox.container.margin
                },
                {
                    s.audio,
                    left = dpi(3),
                    right = dpi(3),
                    top = dpi(6),
                    bottom = dpi(6),
                    widget = wibox.container.margin
                },
                {
                    s.kblayout,
                    left = dpi(3),
                    right = dpi(3),
                    top = dpi(6),
                    bottom = dpi(6),
                    widget = wibox.container.margin
                },
                {
                    s.date,
                    left = dpi(3),
                    right = dpi(3),
                    top = dpi(6),
                    bottom = dpi(6),
                    widget = wibox.container.margin
                },
                {
                    s.clock,
                    left = dpi(3),
                    right = dpi(3),
                    top = dpi(6),
                    bottom = dpi(6),
                    widget = wibox.container.margin
                },
                {
                    s.powerbutton,
                    left = dpi(3),
                    right = dpi(6),
                    top = dpi(6),
                    bottom = dpi(6),
                    widget = wibox.container.margin
                },
                forced_height = 45,
                layout = wibox.layout.fixed.horizontal
            },
            layout = wibox.layout.align.horizontal
        }

        s.volume_container:setup{
            s.volume_osd,
            layout = wibox.layout.fixed.horizontal
        }

        s.brightness_container:setup{
            s.brightness_osd,
            layout = wibox.layout.fixed.horizontal
        }

        s.calendar_osd_container:setup{
            s.calendar_osd,
            layout = wibox.layout.align.horizontal
        }

        s.powermenu_container:setup{
            s.powermenu,
            layout = wibox.layout.flex.horizontal
        }

        s.powermenu_container:buttons(
            gears.table.join(
                awful.button(
                    {},
                    3,
                    function ()
                        awesome.emit_signal("module::powermenu:hide")
                    end
                )
            )
        )

        -- Signals
        awesome.connect_signal(
            "module::powermenu:show",
            function()
                for s in screen do
                    s.powermenu_container.visible = false
                end
                awful.screen.focused().powermenu_container.visible = true
            end
        )
    
        awesome.connect_signal(
            "module::powermenu:hide",
            function()
                for s in screen do
                    s.powermenu_container.visible = false
                end
            end
        )

        awesome.connect_signal(
            "hide_centerbar",
            function (hide)
                s.top_center.visible = hide
            end
        )

        awesome.connect_signal(
            "widget::brightness_osd:rerun",
            function ()
                if hide_brightness_osd.started then
                    hide_brightness_osd:again()
                else
                    hide_brightness_osd:start()
                end
            end
        )

        awesome.connect_signal(
            "module::brightness_osd:show",
            function ()
                s.brightness_container.visible = true
            end
        )

        s.brightness_container:connect_signal(
            "mouse::enter",
            function ()
                s.brightness_container.visible = true
                hide_brightness_osd:stop()
            end
        )

        s.brightness_container:connect_signal(
            "mouse::leave",
            function ()
                s.brightness_container.visible = true
                hide_brightness_osd:again()
            end
        )

        awesome.connect_signal(
            "module::volume_osd:show",
            function ()
                s.volume_container.visible = true
            end
        )

        s.volume_container:connect_signal(
            "mouse::enter",
            function ()
                s.volume_container.visible = true
                hide_volume_osd:stop()
            end
        )

        s.volume_container:connect_signal(
            "mouse::leave",
            function ()
                s.volume_container.visible = true
                hide_volume_osd:again()
            end
        )

        awesome.connect_signal(
            "widget::volume_osd:rerun",
            function ()
                if hide_volume_osd.started then
                    hide_volume_osd:again()
                else
                    hide_volume_osd:start()
                end
            end
        )

        s.calendar_osd_container:connect_signal(
            "mouse::enter",
            function ()
                s.calendar_osd_container.visible = true
                hide_osd:stop()
            end
        )

        s.calendar_osd_container:connect_signal(
            "mouse::leave",
            function ()
                s.calendar_osd_container.visible = false
                hide_osd:stop()
            end
        )

        awesome.connect_signal(
            "widget::calendar_osd:stop",
            function ()
                s.calendar_osd_container.visible = true
                hide_osd:stop()
            end
        )

        awesome.connect_signal(
            "widget::calendar_osd:rerun",
            function ()
                if hide_osd.started then
                    hide_osd:again()
                else
                    hide_osd:start()
                end
            end
        )
    end
)