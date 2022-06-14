--------------------------------------------------
--  ██████╗██████╗ ██╗   ██╗██╗     ██╗ █████╗  --
-- ██╔════╝██╔══██╗╚██╗ ██╔╝██║     ██║██╔══██╗ --
-- ██║     ██████╔╝ ╚████╔╝ ██║     ██║███████║ --
-- ██║     ██╔══██╗  ╚██╔╝  ██║     ██║██╔══██║ --
-- ╚██████╗██║  ██║   ██║   ███████╗██║██║  ██║ --
--  ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝╚═╝  ╚═╝ --
--------------------------------------------------
local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local color = require("src.theme.colors")
local dpi = require("beautiful.xresources").apply_dpi

Theme_path = awful.util.getdir("config") .. "/src/theme/"
Theme = {}

--dofile(Theme_path .. "theme_config.lua")

-- Default font, change it in user_config, not here.
Theme.font = User_config.font.bold

--#region Client variables
Theme.useless_gap = dpi(5)
Theme.border_width = dpi(0)
Theme.border_normal = color["Grey800"]
Theme.border_marked = color["Red200"]
--#endregion

--#region Tooltip variables
Theme.tooltip_border_color = color["Grey800"]
Theme.tooltip_bg = color["Grey900"]
Theme.tooltip_fg = color["CyanA200"]
Theme.tooltip_border_width = dpi(4)
Theme.tooltip_gaps = dpi(15)
Theme.tooltip_shape = function(cr, width, heigth)
  gears.shape.rounded_rect(cr, width, heigth, dpi(4))
end
--#endregion

--#region Hotkeys variables
Theme.hotkeys_bg = color["Grey900"]
Theme.hotkeys_fg = color["White"]
Theme.hotkeys_border_width = dpi(4)
Theme.hotkeys_border_color = color["Grey800"]
Theme.hotkeys_shape = function(cr, width, height)
  gears.shape.rounded_rect(cr, width, height, dpi(12))
end
Theme.hotkeys_modifiers_fg = color["Cyan200"]
Theme.hotkeys_description_font = User_config.font.bold
Theme.hotkeys_font = User_config.font.bold
Theme.hotkeys_group_margin = dpi(20)
Theme.hotkeys_label_bg = color["Cyan200"]
Theme.hotkeys_label_fg = color["Grey900"]
--#endregion

Theme.awesome_icon = Theme_path .. "../assets/icons/ArchLogo.png"
Theme.awesome_subicon = Theme_path .. "../assets/icons/ArchLogo.png"

-- Wallpaper
beautiful.wallpaper = User_config.wallpaper
screen.connect_signal(
  'request::wallpaper',
  function(s)
    if beautiful.wallpaper then
      if type(beautiful.wallpaper) == 'string' then
        gears.wallpaper.maximized(beautiful.wallpaper, s)
      else
        beautiful.wallpaper(s)
      end
    end
  end
)

beautiful.init(Theme)
