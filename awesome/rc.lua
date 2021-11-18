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
RC = {}
RC.vars = require("Main.UserVariables")

-- Error Handling
require("Main.ErrorHandling")

-- Default Theme and Custom Wallpaper
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
beautiful.wallpaper = RC.vars.wallpaper
modkey = RC.vars.modkey

require("Main.Theme")

-- Load Local User Libs
local Main = {
    Layouts = require("Main.Layouts"),
    Tags = require("Main.Tags"),
    Menu = require("Main.Menu"),
    Rules = require("Main.Rules")
}

-- Load all Shortcuts from Local User Libs
local Bindings = {
    GlobalButtons = require("Bindings.GlobalButtons"),
    ClientButtons = require("Bindings.ClientButtons"),
    GlobalKeys = require("Bindings.GlobalKeys"),
    BindToTags = require("Bindings.BindToTags"),
    ClientKeys = require("Bindings.ClientKeys")
}

RC.Layouts = Main.Layouts()

awful.layout.layouts = Main.Layouts()

RC.Tags = Main.Tags()

RC.MainMenu = awful.menu({
    items = Main.Menu()
})

-- A Variable needed in Statusbar (helper)
RC.Launcher = awful.widget.launcher({
    Image = beautiful.awesome_icon,
    Menu = RC.MainMenu
})

-- Menubar configuration
menubar.utils.terminal = RC.vars.terminal

-- Set root
root.buttons(Bindings.GlobalButtons())
root.keys(Bindings.BindToTags(Bindings.GlobalKeys()))

-- Default statusbar, comment if you want use a third party tool like polybar
require("CryliaBar.init")

-- Rules to apply to new clients
awful.rules.rules = Main.Rules(
    Bindings.ClientKeys(),
    Bindings.ClientButtons()
)

-- Signals
require("Main.Signals")

-- Autostart programs
--awful.spawn.with_shell("~/.screenlayout/single_screen.sh")
awful.spawn.with_shell("picom --experimental-backends")
awful.spawn.with_shell("xfce4-power-manager")
