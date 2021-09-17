-- Awesome Libs
local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")
client.connect_signal(
    "manage",
    function (c)
        if awesome.startup and not c.size_hints.user_porition and not c.size_hints.program_position then
            awful.placement.no_offscreen(c)
        end
        local screen = mouse.screen
        local s = awful.client.focus.history.get(screen, 0)
        if not (c == nil) then
            client.focus = c
            c:raise()
        end
    end
)

client.connect_signal(
    "unmanage",
    function ()
        local screen = mouse.screen
        local c = awful.client.focus.history.get(screen, 0)
        if not (c == nil) then
            client.focus = c
            c:raise()
        end
    end
)

-- Workaround for focused border color, why in the love of god doesnt it work with
-- beautiful.border_focus
client.connect_signal("focus", function (c)
    c.border_color = "#bdbdbd"
end)

client.connect_signal("unfocus", function (c)
    c.border_color = beautiful.border_normal
end)