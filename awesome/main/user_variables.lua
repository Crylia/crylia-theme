-------------------------------------------
-- Uservariables are stored in this file --
-------------------------------------------
local dpi = require("beautiful").xresources.apply_dpi
local home = os.getenv("HOME")

local function get_screen()
    local screen = {}
    for i, s in ipairs(screen) do
        screen[i] = {screen.x, screen.y}
    end
    return screen
end

-- If you want different default programs, wallpaper path or modkey; edit this file.
local _M = {

    -- This is your default Terminal
    terminal = "alacritty -o font.size=8",

    -- This is the modkey 'mod4' = Super/Mod/WindowsKey, 'mod3' = alt...
    modkey = "Mod4",

    -- place your wallpaper at this path with this name, you could also try to change the path
    wallpaper = home .. "/.config/awesome/theme/crylia/assets/space.jpg",

    -- Naming scheme for the powermenu, userhost = "user@hostname", fullname = "Firstname Surname", something else ...
    namestyle = "userhost",

    -- List every Keyboard layout you use here comma seperated. (run localectl list-keymaps to list all averiable keymaps)
    kblayout = {"de", "ru"},

    -- Set to false if you dont have a controller
    bluetooth = true,

    -- Your filemanager that opens with super+e
    file_manager = "thunar",

    -- Screenshot program to make a screenshot when print is hit
    screenshot_program = "flameshot gui",

    -- If you use the dock here is how you control its size
    dock_icon_size = dpi(50),

    -- Add your programs exactly like in this example.
    -- First entry has to be how you would start the program in the terminal (just try it if you dont know yahoo it)
    -- Second can be what ever the fuck you want it to be (will be the displayed name if you hover over it)
    -- For steam games please use this format {"394360", "Name", true} true will tell the func that it's a steam game
    dock_programs = {
        {"firefox", "Firefox"},
        {"discord", "Discord"},
        {"spotify", "Spotify"},
        {"code", "Visual Studio Code"},
        {"arduino", "Arduino IDE"},
        {"zoom", "Zoom"},
        {"thunderbird", "Thunderbird"},
        {"mattermost-desktop", "Mattermost"},
        {"blender", "Blender"}
    },

    screens_size = get_screen()
}

return _M
