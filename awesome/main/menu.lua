--------------------------------------------------------------
-- Menu class, this is where you change the rightclick menu --
--------------------------------------------------------------
-- Awesome Libs
local awful = require("awful")

-- Menu Namespace
local M = { }

-- Module Namespace
local _M = { }

local terminal = RC.vars.terminal

M.session = {
    { "Logout", function () awesome.quit() end },
    { "Shutdown", function () awful.spawn.with_shell('shutdown now') end },
    { "Reboot", function () awful.spawn.with_shell('reboot') end },
}

M.applications = {
    { "Brave", "brave-browser" },
    { "VS Code", "code" },
    { "Blender", "blender" },
    { "Steam", "steam" },
    { "Lutris", "lutris" },
}

M.settings = {
    { "General Settings", "gnome-control-center" },
    { "Power Settings", "xfce4-power-manager-settings" },
    { "Display Settings", "arandr" }
}

function _M.get()
    local menu_items = {
        { "Power Menu", M.session },
        { "Applications", M.applications },
        { "Open Terminal", terminal },
        { "Settings", M.settings },
    }

    return menu_items
end

return _M.get