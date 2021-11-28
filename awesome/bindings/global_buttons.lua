-- Awesome Libs
local gears = require("gears")
local awful = require("awful")

return function ()
    local globalbuttons = gears.table.join(
        awful.button({ }, 3, function()
            user_vars.main_menu:toggle()
        end),
        awful.button({ }, 4, awful.tag.viewnext),
        awful.button({ }, 5, awful.tag.viewprev)
    )
    return globalbuttons
end