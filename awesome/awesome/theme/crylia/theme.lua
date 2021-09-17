--------------------------------------------------
--  ██████╗██████╗ ██╗   ██╗██╗     ██╗ █████╗  --
-- ██╔════╝██╔══██╗╚██╗ ██╔╝██║     ██║██╔══██╗ --
-- ██║     ██████╔╝ ╚████╔╝ ██║     ██║███████║ --
-- ██║     ██╔══██╗  ╚██╔╝  ██║     ██║██╔══██║ --
-- ╚██████╗██║  ██║   ██║   ███████╗██║██║  ██║ --
--  ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝╚═╝  ╚═╝ --
--------------------------------------------------
local awful = require("awful")

Theme_path = awful.util.getdir("config") .. "/theme/crylia/"
Theme = { }

dofile(Theme_path .. "theme_variables.lua")
dofile(Theme_path .. "layouts.lua")

Theme.wallpaper = Theme_path .. "assets/wallpaper.png"
Theme.awesome_icon = Theme_path .. "assets/icons/icon.png"
Theme.awesome_subicon = Theme_path .. "assets/icons/icon.png"

return Theme