-----------------------------------------------------------------------------------------
--  █████╗ ██╗    ██╗███████╗███████╗ ██████╗ ███╗   ███╗███████╗██╗    ██╗███╗   ███╗ --
-- ██╔══██╗██║    ██║██╔════╝██╔════╝██╔═══██╗████╗ ████║██╔════╝██║    ██║████╗ ████║ --
-- ███████║██║ █╗ ██║█████╗  ███████╗██║   ██║██╔████╔██║█████╗  ██║ █╗ ██║██╔████╔██║ --
-- ██╔══██║██║███╗██║██╔══╝  ╚════██║██║   ██║██║╚██╔╝██║██╔══╝  ██║███╗██║██║╚██╔╝██║ --
-- ██║  ██║╚███╔███╔╝███████╗███████║╚██████╔╝██║ ╚═╝ ██║███████╗╚███╔███╔╝██║ ╚═╝ ██║ --
-- ╚═╝  ╚═╝ ╚══╝╚══╝ ╚══════╝╚══════╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝ ╚══╝╚══╝ ╚═╝     ╚═╝ --
-----------------------------------------------------------------------------------------
-- Default Awesome Libs
local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local menubar = require("menubar")

-- Global Namespace
RC = {}
RC.vars = require("main.user_variables")

-- Error Handling
require("main.error_handling")

-- Default Theme and Custom Wallpaper
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
beautiful.wallpaper = RC.vars.wallpaper
modkey = RC.vars.modkey

require("main.theme")

-- Load Local User Libs
local main = {
    layouts = require("main.layouts"),
    tags = require("main.tags"),
    menu = require("main.menu"),
    rules = require("main.rules")
}

-- Load all Shortcuts from Local User Libs
local bindings = {
    globalbuttons = require("bindings.globalbuttons"),
    clientbuttons = require("bindings.clientbuttons"),
    globalkeys = require("bindings.globalkeys"),
    bindtotags = require("bindings.bindtotags"),
    clientkeys = require("bindings.clientkeys")
}

-- Sets the local layout to Aweful.layout.inc
RC.layouts = main.layouts()
awful.layout.layouts = main.layouts()

-- Tag table which holds all screen tags
RC.tags = main.tags()

-- Creates a launcher widget and a main menu
RC.mainmenu = awful.menu({
    items = main.menu()
})

-- A Variable needed in Statusbar (helper)
RC.launcher = awful.widget.launcher({
    image = beautiful.awesome_icon,
    menu = RC.mainmenu
})

-- Menubar configuration
menubar.utils.terminal = RC.vars.terminal

-- Sets the user Keybindings
RC.globalkeys = bindings.globalkeys()
RC.globalkeys = bindings.bindtotags(RC.globalkeys)

-- Set root
root.buttons(bindings.globalbuttons())
root.keys(RC.globalkeys)

-- Keymap
mykeyboardlayout = awful.widget.keyboardlayout()

-- Default statusbar, uncomment if you dont use a third party tool like polybar
require("deco.statusbar")

-- Rules to apply to new clients
awful.rules.rules = main.rules(
    bindings.clientkeys(),
    bindings.clientbuttons()
)

-- Signals
require("main.signals")

-- Titlebar
require("theme.crylia.modules.titlebar")

-- Autostart programs
--awful.spawn.with_shell("~/.screenlayout/single_screen.sh")
awful.spawn.with_shell("picom --experimental-backends")
awful.spawn.with_shell("xfce4-power-manager")
awful.spawn.with_shell("~/.screenlayout/single_screen.sh")
