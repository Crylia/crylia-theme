-------------------------------------------
-- Uservariables are stored in this file --
-------------------------------------------
local home = os.getenv("HOME")

-- If you want different default programs, wallpaper path or modkey; edit this file.
local _M = {
    -- This is your default Terminal
    terminal = "alacritty",
    -- This is the modkey 'mod4' = Super/Mod/WindowsKey, 'mod3' = alt...
    modkey = "Mod4",
    -- place your wallpaper at this path with this name, you could also try to change the path
    wallpaper = home .. "/.config/awesome/theme/crylia/assets/wallpaper.jpg",
    -- Naming scheme for the powermenu, userhost = "user@hostname", fullname = "Firstname Surname", something else ...
    namestyle = "userhost"
}

return _M