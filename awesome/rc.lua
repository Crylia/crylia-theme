-----------------------------------------------------------------------------------------
--  █████╗ ██╗    ██╗███████╗███████╗ ██████╗ ███╗   ███╗███████╗██╗    ██╗███╗   ███╗ --
-- ██╔══██╗██║    ██║██╔════╝██╔════╝██╔═══██╗████╗ ████║██╔════╝██║    ██║████╗ ████║ --
-- ███████║██║ █╗ ██║█████╗  ███████╗██║   ██║██╔████╔██║█████╗  ██║ █╗ ██║██╔████╔██║ --
-- ██╔══██║██║███╗██║██╔══╝  ╚════██║██║   ██║██║╚██╔╝██║██╔══╝  ██║███╗██║██║╚██╔╝██║ --
-- ██║  ██║╚███╔███╔╝███████╗███████║╚██████╔╝██║ ╚═╝ ██║███████╗╚███╔███╔╝██║ ╚═╝ ██║ --
-- ╚═╝  ╚═╝ ╚══╝╚══╝ ╚══════╝╚══════╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝ ╚══╝╚══╝ ╚═╝     ╚═╝ --
-----------------------------------------------------------------------------------------
if os.getenv "LOCAL_LUA_DEBUGGER_VSCODE" == "1" then
    require("lldebugger").start()
end

-- Default Awesome Libs
local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local menubar = require("menubar")

-- Global Namespace
user_vars = {}
user_vars.vars = require("main.user_variables")

-- Error Handling
require("main.error_handling")

-- Default Theme and Custom Wallpaper
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
beautiful.wallpaper = user_vars.vars.wallpaper
modkey = user_vars.vars.modkey

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
    global_buttons = require("bindings.global_buttons"),
    client_buttons = require("bindings.client_buttons"),
    global_keys = require("bindings.global_keys"),
    bind_to_tags = require("bindings.bind_to_tags"),
    client_keys = require("bindings.client_keys")
}

user_vars.Layouts = main.layouts()

awful.layout.layouts = main.layouts()

user_vars.tags = main.tags()

user_vars.main_menu = awful.menu({
    items = main.menu()
})

-- A Variable needed in Statusbar (helper)
user_vars.launcher = awful.widget.launcher({
    image = beautiful.awesome_icon,
    menu = user_vars.main_menu
})

-- Menubar configuration
menubar.utils.terminal = user_vars.vars.terminal

-- Set root
root.buttons(bindings.global_buttons())
root.keys(bindings.bind_to_tags(bindings.global_keys()))

-- Default statusbar, comment if you want use a third party tool like polybar
require("crylia_bar.init")

-- Rules to apply to new clients
awful.rules.rules = main.rules(
    bindings.client_keys(),
    bindings.client_buttons()
)

-- Signals
require("main.signals")

-- Autostart programs
--awful.spawn.with_shell("~/.screenlayout/single_screen.sh")
awful.spawn.with_shell("picom --experimental-backends")
awful.spawn.with_shell("xfce4-power-manager")
awful.spawn.with_shell("light-locker --lock-on-suspend --lock-on-lid &")
