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
    local MenuItems = {
        { "Power Menu", session },
        { "Applications", applications },
        { "Open Terminal", RC.vars.terminal },
        { "Settings", settings },
    }
    return MenuItems
end