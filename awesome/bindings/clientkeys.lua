-- Awesome Libs
local awful = require("awful")
local gears = require("gears")

local _M = {}
local modkey = RC.vars.modkey

function _M.get()
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
            { description = "Close window", group = "Client" }
        ),
        awful.key(
            { modkey, "Control" },
            "Space",
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
            {description = "(un)maximize", group = "client"}
        ),
        awful.key(
            { modkey, "Control" },
            "m",
            function (c)
                c.maximized_vertical = not c.maximized_vertical
                c:raise()
            end,
            { description = "Unmaximize", group = "client"}
        )
    )
    return clientkeys
end

return _M.get