local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")
local dpi = require("beautiful").xresources.apply_dpi
local watch = awful.widget.watch
local color = require("theme.crylia.colors")

local icondir = awful.util.getdir("config") .. "theme/crylia/assets/icons/date/"

local calendar_osd = function ()

    local calendar_osd_time = wibox.widget{
        {
            widget = wibox.widget.textbox,
            text = os.date("%H-%M-%S"),
            id = "clock",
            font = "digital-7 italic",
            forced_height = dpi(50)
        },
        layout = wibox.layout.align.horizontal
    }


--[[     local create_calendar = function (widget, date)
        local d = {year = date.year, month = (date.month or 1), day = (date.day or 1)}
        local weekday = tonumber(os.date("%w", os.time(d)))
        local default_bg = (weekday == 0 or weekday == 6) and color.color["Grey900"]
        local container = wibox.widget {
            {
                widget,
                margins = dpi(2),
                widget = wibox.container.margin
            },
            shape = function (cr, height, width)
                gears.shape.rounded_rect(cr, height, widget)
            end,
            shape_border_width = dpi(1),
            shape_border_color = color.color["Grey800"],
            fg = color.color["White"],
            bg = color.color["Grey900"],
            widget = wibox.container.background
        }
    end ]]

    local calendar =  wibox.widget{
        font = "digital-7 italic",
        date = os.date("*t"),
        spacing = dpi(15),
        --fn_embed = create_calendar,
        widget = wibox.widget.calendar.month()
    }

    local current_month = calendar:get_date().month

    local update_active_month = function (i)
        local date = calendar:get_date()
        date.month = date.month + i,
        calendar:set_date(nil),
        calendar:set_date(date)
    end

    calendar:buttons(
        gears.table.join(
            awful.button(
                { },
                4,
                function ()
                    update_active_month(-1)
                end
            ),
            awful.button(
                { },
                5,
                function ()
                    update_active_month(1)
                end
            )
        )
    )

    local calendar_widget = wibox.widget{
        {
            calendar_osd_time,
            calendar,
            layout = wibox.layout.fixed.vertical
        },
        bg = color.color["White"] .. "00",
        shape = function (cr, height, width)
            gears.shape.rounded_rect(cr, dpi(500), dpi(300))
        end,
        widget = wibox.container.background
    }

    return calendar_widget
end

return calendar_osd