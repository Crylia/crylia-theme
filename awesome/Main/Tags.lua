-----------------------------------------------------------------------------------------------------
-- Here are the ammount of tags generated, edit the awful.tag args if you want a different ammount --
-----------------------------------------------------------------------------------------------------

-- Awesome Libs
local awful = require("awful")

return function()
    local tags = {}
    awful.screen.connect_for_each_screen(
        function (s)
            tags[s] = awful.tag(
                {
                    "1", "2", "3", "4", "5", "6", "7", "8", "9"
                },
                s,
                RC.Layouts[1]
            )
        end
    )

    return tags
end