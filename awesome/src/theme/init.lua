local setmetatable = setmetatable
local print = print
local type = type

--------------------------------------------------
--  ██████╗██████╗ ██╗   ██╗██╗     ██╗ █████╗  --
-- ██╔════╝██╔══██╗╚██╗ ██╔╝██║     ██║██╔══██╗ --
-- ██║     ██████╔╝ ╚████╔╝ ██║     ██║███████║ --
-- ██║     ██╔══██╗  ╚██╔╝  ██║     ██║██╔══██║ --
-- ╚██████╗██║  ██║   ██║   ███████╗██║██║  ██║ --
--  ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝╚═╝  ╚═╝ --
--------------------------------------------------

local awful = require('awful')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi
local gshape = require('gears.shape')
local gwallpaper = require('gears.wallpaper')
local gfilesystem = require('gears.filesystem')
local config = require('src.tools.config')

local capi = {
  awesome = awesome,
  screen = screen,
}

local instance = nil
if not instance then
  instance = setmetatable({}, {
    __call = function()
      local function get_userconfig()
        local data = config.read_json(gfilesystem.get_xdg_config_home() .. 'crylia_theme/crylia_theme.json')
        if not data then
          print('Warning: No crylia_theme.json found, using default config')

          data = config.read_json('/etc/crylia_theme/crylia_theme.json')
        end

        assert(type(data) == 'table', 'Invalid config file (not a table)!')

        return data
      end

      local function get_colorscheme()
        local data = config.read_json(gfilesystem.get_xdg_config_home() .. 'crylia_theme/one_dark.json')
        if not data then
          print('Warning: No theme.json found, using default config')

          data = config.read_json('/etc/crylia_theme/theme.json')
        end

        assert(type(data) == 'table', 'Invalid config file (not a table)!')

        return data
      end

      local theme = {}

      awesome.set_preferred_icon_size(128)

      theme.user_config = get_userconfig()
      theme.colorscheme = get_colorscheme()

      theme.shape = {}
      for i = 2, 30, 2 do
        theme.shape[i] = function(w, h, cr)
          gshape.rounded_rect(w, h, cr, dpi(i))
        end
      end

      -- Default font, change it in user_config, not here.
      theme.font = theme.user_config.font .. ' bold ' .. 16

      --#region Client variables
      theme.useless_gap = dpi(5)
      theme.border_width = dpi(2)
      theme.border_normal = theme.colorscheme.bg_1
      theme.border_marked = theme.colorscheme.bg_red
      --#endregion

      --#region Tooltip variables
      theme.tooltip_border_color = theme.colorscheme.border_color
      theme.tooltip_bg = theme.colorscheme.bg
      theme.tooltip_fg = theme.colorscheme.bg_teal
      theme.tooltip_border_width = dpi(2)
      theme.tooltip_gaps = dpi(15)
      --#endregion

      --#region Hotkeys variables
      theme.hotkeys_bg = theme.colorscheme.bg
      theme.hotkeys_fg = theme.colorscheme.fg
      theme.hotkeys_border_width = dpi(2)
      theme.hotkeys_border_color = theme.colorscheme.border_color
      theme.hotkeys_modifiers_fg = theme.colorscheme.bg_teal
      theme.hotkeys_description_font = theme.user_config.font
      theme.hotkeys_font = theme.user_config.font
      theme.hotkeys_group_margin = dpi(20)
      theme.hotkeys_label_bg = theme.colorscheme.bg_teal
      theme.hotkeys_label_fg = theme.colorscheme.bg
      --#endregion

      --#region Layout icons
      local layout_path       = gfilesystem.get_configuration_dir() .. 'src/assets/layout/'
      theme.layout_cornerne   = layout_path .. 'cornerne.png'
      theme.layout_cornernw   = layout_path .. 'cornernw.png'
      theme.layout_cornerse   = layout_path .. 'cornerse.png'
      theme.layout_cornersw   = layout_path .. 'cornersw.png'
      theme.layout_dwindle    = layout_path .. 'dwindle.png'
      theme.layout_fairh      = layout_path .. 'fairh.png'
      theme.layout_fairv      = layout_path .. 'fairv.png'
      theme.layout_floating   = layout_path .. 'floating.png'
      theme.layout_fullscreen = layout_path .. 'fullscreen.png'
      theme.layout_magnifier  = layout_path .. 'magnifier.png'
      theme.layout_max        = layout_path .. 'max.png'
      theme.layout_spiral     = layout_path .. 'spiral.png'
      theme.layout_tile       = layout_path .. 'tile.png'
      theme.layout_tilebottom = layout_path .. 'tilebottom.png'
      theme.layout_tileleft   = layout_path .. 'tileleft.png'
      theme.layout_tiletop    = layout_path .. 'tiletop.png'
      --#endregion

      theme.notification_spacing = dpi(20)
      theme.bg_systray = theme.colorscheme.bg1
      theme.systray_icon_spacing = dpi(10)

      -- Wallpaper
      beautiful.wallpaper = theme.user_config['wallpaper']
      capi.screen.connect_signal('request::wallpaper', function(s)
        if beautiful.wallpaper then
          if type(beautiful.wallpaper) == 'string' then
            gwallpaper.maximized(beautiful.wallpaper, s)
          else
            beautiful.wallpaper(s)
          end
        end
      end)

      beautiful.init(theme)

      -- Load titlebar
      require('src.core.titlebar')()
    end,
  })
end
return instance
