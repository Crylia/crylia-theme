------------------------------------------------------------------------------------------
-- Layout class, if you want to add or remove layouts from the list do it in this table --
------------------------------------------------------------------------------------------
-- Awesome Libs
local awful = require("awful")

return function()
    local layouts = {
        awful.layout.suit.tile,
        awful.layout.suit.floating,
        awful.layout.suit.fair,
    }

    return layouts
end
