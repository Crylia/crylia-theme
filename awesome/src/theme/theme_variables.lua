------------------------------------------------------------------------------------------
-- This is the main themeing file, here are most colors changed                         --
-- If you want to change individual widget colors you will need to edit them seperately --
------------------------------------------------------------------------------------------

-- Awesome Libs
local color = require("src.theme.colors")
local dpi = require("beautiful.xresources").apply_dpi
local gears = require("gears")
local awful = require("awful")

-- Icon directory path
local icondir = awful.util.getdir("config") .. "src/assets/icons/titlebar/"

Theme.font = user_vars.font.bold

Theme.bg_normal = color["Grey900"]
Theme.bg_focus = color["Grey900"]
Theme.bg_urgent = color["RedA200"]
Theme.bg_minimize = color["White"]
Theme.bg_systray = color["White"]

Theme.fg_normal = color["White"]
Theme.fg_focus = color["White"]
Theme.fg_urgent = color["White"]
Theme.fg_minimize = color["White"]

Theme.useless_gap = dpi(5) -- Change this to 0 if you dont like window gaps
Theme.border_width = dpi(0) -- Change this to 0 if you dont like borders
Theme.border_normal = color["Grey800"]
--Theme.border_focus = color["Red"] -- Doesnt work, no idea why; workaround is in signals.lua
Theme.border_marked = color["Red400"]

--Theme.menu_submenu_icon = Theme_path .. "assets.ArchLogo.png"
Theme.menu_height = dpi(40)
Theme.menu_width = dpi(200)
Theme.menu_bg_normal = color["Grey900"]
Theme.menu_bg_focus = color["Grey800"]
Theme.menu_fg_focus = color["White"]
Theme.menu_border_color = color["Grey800"]
Theme.menu_border_width = dpi(0)
Theme.menu_shape = function(cr, width, heigth)
    gears.shape.rounded_rect(cr, width, heigth, 5)
end

Theme.taglist_fg_focus = color["Grey900"]
Theme.taglist_bg_focus = color["White"]

Theme.tooltip_border_color = color["Grey900"]
Theme.tooltip_bg = color["Grey800"]
Theme.tooltip_fg = color["White"]
Theme.tooltip_border_width = dpi(0)
Theme.tooltip_shape = function(cr, width, heigth)
    gears.shape.rounded_rect(cr, width, heigth, 5)
end

Theme.notification_bg = color["Grey900"]
Theme.notification_fg = color["White"]
Theme.notification_border_width = dpi(0)
Theme.notification_border_color = color["Grey900"]
Theme.notification_shape = function(cr, width, heigth)
    gears.shape.rounded_rect(cr, width, heigth, 10)
end
Theme.notification_margin = dpi(10)
Theme.notification_max_width = dpi(400)
Theme.notification_max_height = dpi(1000)
Theme.notification_icon_size = dpi(40)

Theme.titlebar_close_button_normal = icondir .. "close.svg"
Theme.titlebar_maximized_button_normal = icondir .. "maximize.svg"
Theme.titlebar_minimize_button_normal = icondir .. "minimize.svg"
Theme.titlebar_maximized_button_active = icondir .. "maximize.svg"
Theme.titlebar_maximized_button_inactive = icondir .. "maximize.svg"

Theme.bg_systray = color["BlueGrey800"]
Theme.systray_icon_spacing = dpi(10)

Theme.hotkeys_bg = color["Grey900"]
Theme.hotkeys_fg = color["White"]
Theme.hotkeys_border_width = 0
Theme.hotkeys_shape = function(cr, width, height)
    gears.shape.rounded_rect(cr, width, height, 10)
end
Theme.hotkeys_description_font = user_vars.font.bold

-- Icon directory path
local layout_path = Theme_path .. "../assets/layout/"

-- Here are the icons for the layouts defined, if you want to add more layouts go to main/layouts.lua
Theme.layout_floating = gears.color.recolor_image(layout_path .. "floating.svg", color["Grey900"])
Theme.layout_tile = gears.color.recolor_image(layout_path .. "tile.svg", color["Grey900"])
--Theme.layout_dwindle = gears.color.recolor_image(layout_path .. "dwindle.svg", color["Grey900"])
--Theme.layout_fairh = gears.color.recolor_image(layout_path .. "fairh.svg", color["Grey900"])
--Theme.layout_fullscreen = gears.color.recolor_image(layout_path .. "fullscreen.svg", color["Grey900"])
--Theme.layout_max = gears.color.recolor_image(layout_path .. "max.svg", color["Grey900"])
