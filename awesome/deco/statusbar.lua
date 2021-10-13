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
            bg = "#00000000",
            border_width = dpi(1),
            border_color = "#454545",
            shape = function (cr, height, width)
                gears.shape.rounded_rect(cr, dpi(500), dpi(300))
            end,
            placement = function (c)
                awful.placement.top_left(c, {margins = dpi(10)})
            end,
        }

        -- OSD Container
        s.osd_container = awful.popup{
            widget = {
                margins = dpi(10),
                widget = wibox.container.margin
            },
            ontop = true,
            bg = "#00000000",
            border_width = dpi(1),
            border_color = "#454545",
            shape = function (cr, width, height)
                gears.shape.rounded_rect(cr, width, height, 10)
            end,
            placement = function (c)
                awful.placement.bottom_right(c, {margins = dpi(10)})
            end,
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
        s.calendar_osd = require("theme.crylia.modules.calendar_osd")
        --s.addtag = require("theme.crylia.widgets.addtag")()
        s.layoutlist = require("theme.crylia.widgets.layout_list")()
        s.powerbutton = require("theme.crylia.widgets.power")()


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
                },{
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

        s.osd_container:setup{
            {
                s.volume_osd,
                layout = wibox.layout.fixed.horizontal
            },
            spacing = dpi(10),
            {
                s.brightness_osd,
                layout = wibox.layout.fixed.horizontal

            },
            layout = wibox.layout.align.vertical
        }
        s.calendar_osd_container:setup{
            s.calendar_osd,
            visible = false,
            layout = wibox.layout.align.horizontal
        }

        -- Signals
        awesome.connect_signal(
            "hide_centerbar",
            function (hide)
                s.top_center.visible = hide
            end
        )
    end
)