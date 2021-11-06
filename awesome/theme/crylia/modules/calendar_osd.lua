---------------------------------------
-- This is the calendar_osd module --
---------------------------------------

-- Awesome Libs

local wibox = require("wibox")
local gears = require("gears")
local dpi = require("beautiful").xresources.apply_dpi
local color = require("theme.crylia.colors")

return function ()
    local styles = {}

    styles.month = {
        padding = 15,
        bg_color = color.color["Grey900"],
        border_width = 1,
        shape = function (cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 5)
        end
    }
    styles.normal  = {
        fg_color = color.color["Grey900"],
        font = "JetBrainsMonoExtraBold NF",
        shape = function (cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 5)
        end
    }
    styles.focus = {
        fg_color = color.color["Grey900"],
        bg_color = color.color["Purple200"],
        shape = function (cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 5)
        end
    }
    styles.header  = {
        fg_color = color.color["Grey900"],
        bg_color = color.color["Teal200"],
        markup = function(t) return '<b>' .. t .. '</b>' end,
        shape = function (cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 5)
        end
    }
    styles.weekday = {
        padding = 8,
        fg_color = color.color["Grey900"],
        bg_color = color.color["Teal200"],
        markup = function(t) return '<b>' .. t .. '</b>' end,
        shape = function (cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 5)
        end
    }
    local function decorate_cell(widget, flag, date)
        if flag=='monthheader' and not styles.monthheader then
            flag = 'header'
        end
        local props = styles[flag] or {}
        if props.markup and widget.get_text and widget.set_markup then
            widget:set_markup(props.markup(widget:get_text()))
        end
        -- Change bg color for weekends
        local d = {year=date.year, month=(date.month or 1), day=(date.day or 1)}
        local weekday = tonumber(os.date('%w', os.time(d)))
        local default_bg = (weekday == 0 or weekday == 6) and color.color["Red200"] or color.color["White"]
        local ret = wibox.widget {
            {
                widget,
                left = dpi(8),
                right = dpi(8),
                top = dpi(4),
                bottom = dpi(4),
                widget  = wibox.container.margin
            },
            shape = function (cr, width, height)
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
        font = "JetBrainsMonoExtraBold NF",
        spacing = dpi(10)
    }

    local calendar_osd_widget = wibox.widget{
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

    local set_clock = function ()
        calendar_osd_widget.digital_clock:set_text(os.date("%H:%M"))
    end

    local calendar_clock_update = gears.timer {
        timeout = 5,
        autostart = true,
        call_now = true,
        callback = function ()
            set_clock()
        end
    }

    return calendar_osd_widget
end