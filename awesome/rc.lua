---@diagnostic disable: lowercase-global
-----------------------------------------------------------------------------------------
--  █████╗ ██╗    ██╗███████╗███████╗ ██████╗ ███╗   ███╗███████╗██╗    ██╗███╗   ███╗ --
-- ██╔══██╗██║    ██║██╔════╝██╔════╝██╔═══██╗████╗ ████║██╔════╝██║    ██║████╗ ████║ --
-- ███████║██║ █╗ ██║█████╗  ███████╗██║   ██║██╔████╔██║█████╗  ██║ █╗ ██║██╔████╔██║ --
-- ██╔══██║██║███╗██║██╔══╝  ╚════██║██║   ██║██║╚██╔╝██║██╔══╝  ██║███╗██║██║╚██╔╝██║ --
-- ██║  ██║╚███╔███╔╝███████╗███████║╚██████╔╝██║ ╚═╝ ██║███████╗╚███╔███╔╝██║ ╚═╝ ██║ --
-- ╚═╝  ╚═╝ ╚══╝╚══╝ ╚══════╝╚══════╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝ ╚══╝╚══╝ ╚═╝     ╚═╝ --
-----------------------------------------------------------------------------------------
-- Initialising, order is important!
awesome = awesome
client = client
mouse = mouse
mousegrabber = mousegrabber
root = root
screen = screen
tag = tag


require("src.theme.user_config")
require("src.theme.theme_config")
require("src.tools.gio_icon_lookup")
require("src.theme.init")
require("src.core.error_handling")
require("src.tools.hex_to_rgba")
require("src.core.signals")
require("src.core.notifications")
require("src.core.rules")
require("src.bindings.global_buttons")
require("src.bindings.bind_to_tags")
require("src.modules.init")
require("src.tools.helpers.init")
require("src.tools.auto_starter")(User_config.autostart)
require("src.tools.dbus.bluetooth_dbus")()
