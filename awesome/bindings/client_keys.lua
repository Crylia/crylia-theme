-- Awesome Libs
local awful = require("awful")
local gears = require("gears")

local modkey = user_vars.vars.modkey

return function ()
    local clientkeys = gears.table.join(
        awful.key(
            { modkey },
            "f",
            function(c)
                c.fullscreen = not c.fullscreen
                c:raise()
            end,
            { description = "Toggle fullscreen", group = "Client" }
        ),
        awful.key(
            { modkey },
            "q",
            function(c)
                c:kill()
            end,
            { description = "Close focused client", group = "Client" }
        ),
        awful.key(
            { modkey },
            "g",
            awful.client.floating.toggle,
            { description = "Toggle floating window", group = "Client" }
        ),
        awful.key(
            { modkey},
            "m",
            function (c)
                c.maximized = not c.maximized
                c:raise()
            end ,
            {description = "(un)maximize", group = "Client"}
        )
    )
    return clientkeys
end