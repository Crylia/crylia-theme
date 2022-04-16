-------------------------------------------------------------
-- This is a button widget to add a new tag to the taglist --
-------------------------------------------------------------

-- !!! THIS WIDGET IS OBSCOLETE !!!

-- Awesome Libs
local awful = require("awful")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")

-- User Libs
local color = require("theme.crylia.colors")

-- Icon directory path
local icondir = awful.util.getdir("config") .. "theme/crylia/assets/icons/addtag/"

-- Returns the add tag button widget
return function()

    -- This is the widget that gets dispayed
    local add_tag_button = wibox.widget {
        {
            {
                image = gears.color.recolor_image(icondir .. "plus.svg", color.color["White"]),
                widget = wibox.widget.imagebox,
                resize = false
            },
            margins = dpi(4),
            widget = wibox.container.margin
        },
        bg = color.color["Grey900"],
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 5)
        end,
        widget = wibox.container.background
    }

    -- Keybindings and Mouse click bindings
    add_tag_button:buttons(
        gears.table.join(
        -- Add a new tag
            awful.button(
                {},
                1,
                nil,
                function()
                    awful.tag.add()
                end
            )
        )
    )

    -- Signals
    local old_wibox, old_cursor, old_bg
    add_tag_button:connect_signal(
        "mouse::enter",
        function()
            old_bg = add_tag_button.bg
            add_tag_button.bg = "#ffffff" .. "12"
            local w = mouse.current_wibox
            if w then
                old_cursor, old_wibox = w.cursor, w
                w.cursor = "hand1"
            end
        end
    )
    add_tag_button:connect_signal(
        "button::press",
        function()
            add_tag_button.bg = "#ffffff" .. "24"
        end
    )
    add_tag_button:connect_signal(
        "button::release",
        function()
            add_tag_button.bg = "#ffffff" .. "12"
        end
    )
    add_tag_button:connect_signal(
        "mouse::leave",
        function()
            add_tag_button.bg = old_bg
            if old_wibox then
                old_wibox.cursor = old_cursor
                old_wibox = nil
            end
        end
    )

    return add_tag_button
end
