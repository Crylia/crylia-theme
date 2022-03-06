--------------------------------------------------------------
-- Menu class, this is where you change the rightclick menu --
--------------------------------------------------------------
-- Awesome Libs
local awful = require("awful")

-- Module Namespace
local _M = { }

local session = {
    { "Logout", function () awesome.quit() end },
    { "Shutdown", function () awful.spawn.with_shell('shutdown now') end },
    { "Reboot", function () awful.spawn.with_shell('reboot') end },
}

local applications = {
    { "Firefox", "firefox" },
    { "VS Code", "code" },
    { "Blender", "blender" },
    { "Steam", "steam" },
    { "Lutris", "lutris" },
}

local settings = {
    { "General Settings", "gnome-control-center" },
    { "Power Settings", "xfce4-power-manager-settings" },
    { "Display Settings", "arandr" }
}

return function()
    local menu_items = {
        { "Power Menu", session },
        { "Applications", applications },
        { "Open Terminal", user_vars.vars.terminal },
        { "Settings", settings },
    }
    return menu_items
end
