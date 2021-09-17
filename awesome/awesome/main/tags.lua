-----------------------------------------------------------------------------------------------------
-- Here are the ammount of tags generated, edit the awful.tag args if you want a different ammount --
-----------------------------------------------------------------------------------------------------

-- Awesome Libs
local awful = require("awful")

local _M = { }

function _M.get()
    local tags = {}
    awful.screen.connect_for_each_screen(
        function (s)
            tags[s] = awful.tag(
                {
                    "1", "2", "3", "4"
                },
                s,
                RC.layouts[1]
            )
        end
    )

    return tags
end

return _M.get