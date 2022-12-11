--------------------------------------------------
--  ██████╗██████╗ ██╗   ██╗██╗     ██╗ █████╗  --
-- ██╔════╝██╔══██╗╚██╗ ██╔╝██║     ██║██╔══██╗ --
-- ██║     ██████╔╝ ╚████╔╝ ██║     ██║███████║ --
-- ██║     ██╔══██╗  ╚██╔╝  ██║     ██║██╔══██║ --
-- ╚██████╗██║  ██║   ██║   ███████╗██║██║  ██║ --
--  ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝╚═╝  ╚═╝ --
--------------------------------------------------
local beautiful = require("beautiful")
local gears = require("gears")

local capi = {
  screen = screen,
}

Theme_path = gears.filesystem.get_configuration_dir() .. "/src/theme/"
Theme = {}

-- Default font, change it in user_config, not here.
Theme.font = User_config.font.bold

--#region Client variables
Theme.useless_gap = Theme_config.window.useless_gap
Theme.border_width = Theme_config.window.border_width
Theme.border_normal = Theme_config.window.border_normal
Theme.border_marked = Theme_config.window.border_marked
--#endregion

--#region Tooltip variables
Theme.tooltip_border_color = Theme_config.tooltip.border_color
Theme.tooltip_bg = Theme_config.tooltip.bg
Theme.tooltip_fg = Theme_config.tooltip.fg
Theme.tooltip_border_width = Theme_config.tooltip.border_width
Theme.tooltip_gaps = Theme_config.tooltip.gaps
Theme.tooltip_shape = Theme_config.tooltip.shape
--#endregion

--#region Hotkeys variables
Theme.hotkeys_bg = Theme_config.hotkeys.bg
Theme.hotkeys_fg = Theme_config.hotkeys.fg
Theme.hotkeys_border_width = Theme_config.hotkeys.border_width
Theme.hotkeys_border_color = Theme_config.hotkeys.border_color
Theme.hotkeys_shape = Theme_config.hotkeys.shape
Theme.hotkeys_modifiers_fg = Theme_config.hotkeys.modifiers_fg
Theme.hotkeys_description_font = Theme_config.hotkeys.description_font
Theme.hotkeys_font = Theme_config.hotkeys.font
Theme.hotkeys_group_margin = Theme_config.hotkeys.group_margin
Theme.hotkeys_label_bg = Theme_config.hotkeys.label_bg
Theme.hotkeys_label_fg = Theme_config.hotkeys.label_fg
--#endregion

-- Wallpaper
beautiful.wallpaper = User_config.wallpaper
capi.screen.connect_signal(
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
