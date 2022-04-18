-----------------------------------------------------------------------------------------
--  █████╗ ██╗    ██╗███████╗███████╗ ██████╗ ███╗   ███╗███████╗██╗    ██╗███╗   ███╗ --
-- ██╔══██╗██║    ██║██╔════╝██╔════╝██╔═══██╗████╗ ████║██╔════╝██║    ██║████╗ ████║ --
-- ███████║██║ █╗ ██║█████╗  ███████╗██║   ██║██╔████╔██║█████╗  ██║ █╗ ██║██╔████╔██║ --
-- ██╔══██║██║███╗██║██╔══╝  ╚════██║██║   ██║██║╚██╔╝██║██╔══╝  ██║███╗██║██║╚██╔╝██║ --
-- ██║  ██║╚███╔███╔╝███████╗███████║╚██████╔╝██║ ╚═╝ ██║███████╗╚███╔███╔╝██║ ╚═╝ ██║ --
-- ╚═╝  ╚═╝ ╚══╝╚══╝ ╚══════╝╚══════╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝ ╚══╝╚══╝ ╚═╝     ╚═╝ --
-----------------------------------------------------------------------------------------

local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")

user_vars = {}
user_vars.vars = require("main.user_variables")

require("main.error_handling")

beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
require("main.theme")

local main = {
    layouts = require("main.layouts"),
    tags = require("main.tags"),
    menu = require("main.menu"),
    rules = require("main.rules")
}

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

root.buttons(bindings.global_buttons())
root.keys(bindings.bind_to_tags(bindings.global_keys()))

require("crylia_bar.init")

awful.rules.rules = main.rules(
    bindings.client_keys(),
    bindings.client_buttons()
)

require("main.signals")

require("theme.crylia.tools.auto_starter")
--Autostarter(user_vars.vars.autostart)
