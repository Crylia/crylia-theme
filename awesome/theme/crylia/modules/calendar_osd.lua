local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")
local dpi = require("beautiful").xresources.apply_dpi
local color = require("theme.crylia.colors")

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
    shape = function (cr, width, height)
        gears.shape.rounded_rect(cr, width, height, 5)
    end
}
styles.focus = {
    fg_color = color.color["Grey900"],
    bg_color = color.color["TealA200"],
    shape = function (cr, width, height)
        gears.shape.rounded_rect(cr, width, height, 5)
    end
}
styles.header  = {
    fg_color = color.color["Teal200"],
    markup = function(t) return '<b>' .. t .. '</b>' end,
    shape = function (cr, width, height)
        gears.shape.rounded_rect(cr, width, height, 5)
    end
}
styles.weekday = {
    padding = 8,
    fg_color = color.color["Teal200"],
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
    local default_bg = (weekday==0 or weekday==6) and color.color["Grey900"] or color.color["Grey800"]
    local ret = wibox.widget {
        {
            widget,
            margins = 10,
            widget  = wibox.container.margin
        },
        shape = props.shape,
        shape_border_color = color.color["Grey800"],
        shape_border_width = 1,
        fg = props.fg_color or '#999999',
        bg = props.bg_color or default_bg,
        widget = wibox.container.background
    }
    return ret
end
local cal = wibox.widget {
    date     = os.date('*t'),
    fn_embed = decorate_cell,
    widget   = wibox.widget.calendar.month
}

return cal