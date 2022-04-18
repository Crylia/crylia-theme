---------------------------------------
-- This is the calendar_osd module --
---------------------------------------

-- Awesome Libs

local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local dpi = require("beautiful").xresources.apply_dpi
local color = require("src.theme.colors")

return function(s)
    local styles = {}

    styles.month   = {
        padding = 15,
        bg_color = color["Grey900"],
        border_width = 1,
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 5)
        end
    }
    styles.normal  = {
        fg_color = color["Grey900"],
        font = user_vars.font.extrabold,
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 5)
        end
    }
    styles.focus   = {
        fg_color = color["Grey900"],
        bg_color = color["Purple200"],
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 5)
        end
    }
    styles.header  = {
        fg_color = color["Grey900"],
        bg_color = color["Teal200"],
        markup = function(t) return '<b>' .. t .. '</b>' end,
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 5)
        end
    }
    styles.weekday = {
        padding = 8,
        fg_color = color["Grey900"],
        bg_color = color["Teal200"],
        markup = function(t) return '<b>' .. t .. '</b>' end,
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 5)
        end
    }
    local function decorate_cell(widget, flag, date)
        if flag == 'monthheader' and not styles.monthheader then
            flag = 'header'
        end
        local props = styles[flag] or {}
        if props.markup and widget.get_text and widget.set_markup then
            widget:set_markup(props.markup(widget:get_text()))
        end
        -- Change bg color for weekends
        local d = { year = date.year, month = (date.month or 1), day = (date.day or 1) }
        local weekday = tonumber(os.date('%w', os.time(d)))
        local default_bg = (weekday == 0 or weekday == 6) and color["Red200"] or color["White"]
        local ret = wibox.widget {
            {
                widget,
                left   = dpi(8),
                right  = dpi(8),
                top    = dpi(4),
                bottom = dpi(4),
                widget = wibox.container.margin
            },
            shape = function(cr, width, height)
                gears.shape.rounded_rect(cr, width, height, 5)
            end,
            fg = props.fg_color or '#999999',
            bg = props.bg_color or default_bg,
            widget = wibox.container.background
        }
        return ret
    end

    local calendar = wibox.widget {
        date = os.date('*t'),
        fn_embed = decorate_cell,
        widget = wibox.widget.calendar.month,
        font = user_vars.font.extrabold,
        spacing = dpi(10)
    }

    local calendar_osd_widget = wibox.widget {
        {
            widget = wibox.widget.textbox,
            fg = "#ffffff",
            align = "center",
            valign = "center",
            font = "DS-Digital, Bold Italic 50",
            id = "digital_clock"
        },
        {
            widget = calendar
        },
        visible = true,
        layout = wibox.layout.fixed.vertical
    }

    local set_clock = function()
        calendar_osd_widget.digital_clock:set_text(os.date("%H:%M"))
    end

    local calendar_clock_update = gears.timer {
        timeout = 5,
        autostart = true,
        call_now = true,
        callback = function()
            set_clock()
        end
    }

    local calendar_osd_container = awful.popup {
        screen = s,
        widget = wibox.container.background,
        ontop = true,
        bg = color["Grey900"],
        stretch = false,
        visible = false,
        placement = function(c) awful.placement.top_right(c, { margins = { right = dpi(100), top = dpi(60) } }) end,
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 5)
        end
    }

    local hide_osd = gears.timer {
        timeout = 0.25,
        autostart = true,
        callback = function()
            calendar_osd_container.visible = false
        end
    }

    calendar_osd_container:setup {
        calendar_osd_widget,
        layout = wibox.layout.align.horizontal
    }

    calendar_osd_container:connect_signal(
        "mouse::enter",
        function()
            calendar_osd_container.visible = true
            hide_osd:stop()
        end
    )

    calendar_osd_container:connect_signal(
        "mouse::leave",
        function()
            calendar_osd_container.visible = false
            hide_osd:stop()
        end
    )

    awesome.connect_signal(
        "widget::calendar_osd:stop",
        function()
            calendar_osd_container.visible = true
            hide_osd:stop()
        end
    )

    awesome.connect_signal(
        "widget::calendar_osd:rerun",
        function()
            if hide_osd.started then
                hide_osd:again()
            else
                hide_osd:start()
            end
        end
    )
end
