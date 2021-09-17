-- This function does currently nothing
-- Awesome Libs
local gears = require("gears")
local awful = require("awful")

local _M = { }

function _M.get()
    local taglist_buttons = gears.table.join(
        awful.button(
            { },
            1,
            function (t)
                t:view_only()
            end
        ),
        awful.button(
            { modkey },
            1,
            function (t)
                if client.focus then
                    client.focus:move_to_tag(t)
                end
            end
        ),
        awful.button(
            { },
            3,
            function (t)
                if client.focus then
                    client.focus:toggle_tag(t)
                end
            end
        ),
        awful.button(
            { modkey },
            3,
            function (t)
                if client.focus then
                    client.focus:toggle_tag(t)
                end
            end
        ),
        awful.button(
            { },
            4,
            function (t)
                awful.tag.viewnext(t.screen)
            end
        ),
        awful.button(
            { },
            5,
            function (t)
                if client.focus then
                    awful.tag.viewprev(t.screen)
                end
            end
        )
    )
    return taglist_buttons
end

return _M.get