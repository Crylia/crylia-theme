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
            function (c)
                c.fullscreen = not c.fullscreen
                c:raise()
            end,
            { description = "Toggle fullscreen", group = "Client" }
        ),
        awful.key(
            { modkey },
            "q",
            function (c)
                c:kill()
            end,
            { description = "Close window", group = "Client" }
        ),
        awful.key(
            { modkey, "Shift" },
            "Space",
            awful.client.floating.toggle,
            { description = "Toggle floating window", group = "Client" }
        ),
        awful.key(
            { modkey, "Control" },
            "r",
            function (c)
                awesome.restart()
            end,
            { description = "Restart awesome", group = "Client" }
        )
    )
    return clientkeys
end

return _M.get