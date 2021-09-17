------------------------------------------------------------------------------------------
-- Layout class, if you want to add or remove layouts from the list do it in this table --
------------------------------------------------------------------------------------------
-- Awesome Libs
local awful = require("awful")

local _M = { }

function _M.get()
    local layouts = {
        awful.layout.suit.tile,
        awful.layout.suit.floating,
    }

    return layouts
end

return _M.get