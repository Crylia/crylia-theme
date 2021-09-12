-------------------------------------------
-- Uservariables are stored in this file --
-------------------------------------------
local home = os.getenv("HOME")

-- If you want different default programs, wallpaper path or modkey; edit this file.
local _M = {
    terminal = "alacritty",
    modkey = "Mod4",
    wallpaper = home .. "/.config/awesome/theme/crylia/assets/wallpaper.jpg"
}

return _M