-- Awesome Libs
local awful = require("awful")
local beautiful = require("beautiful")

client.connect_signal(
    "manage",
    function (c)
        if awesome.startup and not c.size_hints.user_porition and not c.size_hints.program_position then
            awful.placement.no_offscreen(c)
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