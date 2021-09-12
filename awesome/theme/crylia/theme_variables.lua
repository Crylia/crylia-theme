------------------------------------------------------------------------------------------
-- This is the main themeing file, here are most colors changed                         --
-- If you want to change individual widget colors you will need to edit them seperately --
------------------------------------------------------------------------------------------

-- Awesome Libs
local colors = require("theme.crylia.colors")
local dpi = require("beautiful.xresources").apply_dpi
local gears = require("gears")

-- Note that most variables wont change anything since almost everything you see is individually themed

Theme.font = "JetBrains Mono, Bold"

Theme.bg_normal = colors.color["Grey900"]
Theme.bg_focus = colors.color["Grey900"]
Theme.bg_urgent = colors.color["RedA200"]
Theme.bg_minimize = colors.color["White"]
Theme.bg_systray = colors.color["White"]

Theme.fg_normal = colors.color["White"]
Theme.fg_focus = colors.color["White"]
Theme.fg_urgent = colors.color["White"]
Theme.fg_minimize = colors.color["White"]

Theme.useless_gap = dpi(5) -- Change this if you dont like window gaps
Theme.border_width = dpi(1) -- Change this if you dont like borders
Theme.border_normal = colors.color["Grey600"]
--Theme.border_focus = colors.color["Red"] -- Doesnt work, no idea why; workaround is in signals.lua
Theme.border_marked = colors.color["Red400"]

Theme.menu_submenu_icon = Theme_path .. "assets.ArchLogo.png"
Theme.menu_height = dpi(30)
Theme.menu_width = dpi(200)
Theme.menu_bg_normal = colors.color["Grey900"]
Theme.menu_bg_focus = colors.color["Grey800"]
Theme.menu_fg_focus = colors.color["White"]
Theme.menu_border_color = colors.color["Grey600"]
Theme.menu_border_width = dpi(1)

Theme.taglist_fg_focus = colors.color["Grey900"]
Theme.taglist_bg_focus = colors.color["White"]

Theme.tooltip_border_color = colors.color["Grey800"]
Theme.tooltip_bg = colors.color["White"] .. "00"
Theme.tooltip_fg = colors.color["White"]
Theme.tooltip_border_width = dpi(1)
Theme.tooltip_shape = function (cr, width, heigth)
    gears.shape.rounded_rect(cr, width, heigth, 10)
end

Theme.notification_bg = colors.color["Grey900"]
Theme.notification_fg = colors.color["White"]
Theme.notification_border_width = dpi(1)
Theme.notification_border_color = colors.color["Grey800"]
Theme.notification_shape = function (cr, width, heigth)
    gears.shape.rounded_rect(cr, width, heigth, 10)
end
Theme.notification_margin = dpi(10)
Theme.notification_max_width = dpi(400)
Theme.notification_max_height = dpi(1000)
Theme.notification_icon_size = dpi(40)