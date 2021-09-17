---------------------------------------
-- This function sets your wallpaper --
---------------------------------------
-- Awesome Libs
local gears = require("gears")
local beautiful = require("beautiful")

function Set_wallpaper(s)
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

screen.connect_signal("property::geometry", Set_wallpaper)