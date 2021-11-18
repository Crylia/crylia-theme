-- Awesome Libs
local gears = require("gears")
local awful = require("awful")

return function ()
    local globalbuttons = gears.table.join(
        awful.button({ }, 3, function()
            RC.MainMenu:toggle()
        end),
        awful.button({ }, 4, awful.tag.viewnext),
        awful.button({ }, 5, awful.tag.viewprev)
    )
    return globalbuttons
end