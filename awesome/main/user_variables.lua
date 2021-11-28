-------------------------------------------
-- Uservariables are stored in this file --
-------------------------------------------
local home = os.getenv("HOME")

-- If you want different default programs, wallpaper path or modkey; edit this file.
local _M = {

    -- This is your default Terminal
    terminal = "alacritty -o font.size=8",

    -- This is the modkey 'mod4' = Super/Mod/WindowsKey, 'mod3' = alt...
    modkey = "Mod4",

    -- place your wallpaper at this path with this name, you could also try to change the path
    wallpaper = home .. "/.config/awesome/theme/crylia/assets/wallpaper.jpg",

    -- Naming scheme for the powermenu, userhost = "user@hostname", fullname = "Firstname Surname", something else ...
    namestyle = "userhost",

    -- List every Keyboard layout you use here comma seperated. (run localectl list-keymaps to list all averiable keymaps)
    kblayout = {"de", "ru", "us"},

    -- Set to false if you dont have a controller
    bluetooth = true,

    -- Your filemanager that opens with super+e
    file_manager = "thunar",

    -- Screenshot program to make a screenshot when print is hit
    screenshot_program = "flameshot gui"
}

return _M