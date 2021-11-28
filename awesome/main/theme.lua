local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local home = os.getenv("HOME")

beautiful.init(home .. "/.config/awesome/theme/crylia/theme.lua")

if(user_vars.vars.wallpaper) then
    local wallpaper = user_vars.vars.wallpaper
    if awful.util.file_readable(wallpaper) then
        Theme.wallpaper = wallpaper
    end
end

if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end