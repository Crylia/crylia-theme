-------------------------------------------
-- Uservariables are stored in this file --
-------------------------------------------
local awful = require("awful")
local dpi = require("beautiful").xresources.apply_dpi
local home = os.getenv("HOME")

-- If you want different default programs, wallpaper path or modkey; edit this file.
User_config = {

  --[[
    Autostart programms, shell commands etc.
    Wrap shell commands into `bash -c ''`
    Example:
      Firefox: "firefox"
      Custom Script: "bash -c 'myscript'"
      Flatpak application: flatpak run com.example.App
  ]] --
  autostart = {
    "picom --experimental-backends",
    "xfce4-power-manager",
    "light-locker --lock-on-suspend --lock-on-lid &",
    "/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1",
    "setxkbmap -option caps:swapescape",
    "/home/crylia/.screenlayout/single.sh"
  },

  --[[
    The battery that should be displayed in the battery widget.
    This can allow you to for example display your phone's battery
    You can choose from one of these values (default is internal battery):
      "UNKNOWN"
      "LINE_POWER"
      "TABLET"
      "COMPUTER"
      "GAMING_INPUT"
      "LAST"
      "BATTERY"
      "UPS"
      "MONITOR"
      "MOUSE"
      "KEYBOARD"
      "PDA"
      "PHONE"
      "MEDIA_PLAYER"
      More information at: https://lazka.github.io/pgi-docs/UPowerGlib-1.0/enums.html#UPowerGlib.DeviceKind.KEYBOARD
  ]] --
  battery_kind = "LINE_POWER",

  --[[
    If your battery is not found you can specify its path here.
    If you don't specify a path, then UPower will use the first it can find.
    Example:
      battery_path = "/org/freedesktop/UPower/devices/battery_BAT0"
  ]] --
  battery_path = nil,

  --[[
      DnD or 'Do not Disturb' will prevent notifications from poping up.
      This is just a default value, you can toggle it in the notification-center, but it won't be saved.
  ]] --
  dnd = false,

  --[[
      Dock program size in dpi.
      Example:
        dock_size = dpi(48)
  ]] --
  dock_icon_size = dpi(64),

  --[[
    This is the program that will be started when clicking on the battery widget
    If you don't want any just leave it as nil
  ]] --
  energy_manager = "xfce4-power-manager-settings",

  --[[
    Your filemanager. Will be opened with <super> + <e>
  ]] --
  file_manager = "nautilus",

  --[[
    The font that will be used on all widgets/modules etc.
    First is the regular font, second is the bold font and third the extra bold font.
    Specify is used when I needed a custom font size/weight.
    Example:
      font = {
        regular = "JetBrainsMono Nerd Font, 14",
        bold = "JetBrainsMono Nerd Font, bold 14",
        extrabold = "JetBrainsMono Nerd Font, ExtraBold 14",
        specify = "JetBrainsMono Nerd Font"
      }
  ]]
  font = {
    regular = "JetBrainsMono Nerd Font, " .. dpi(16),
    bold = "JetBrainsMono Nerd Font, bold " .. dpi(16),
    extrabold = "JetBrainsMono Nerd Font, ExtraBold " .. dpi(16),
    specify = "JetBrainsMono Nerd Font"
  },

  --[[
    The icon theme name must be exactly as the folder is called
    The folder can be in any $XDG_DATA_DIRS/icons/[icon_theme_name]
  ]] --
  icon_theme = "Papirus-Dark",

  -- List every Keyboard layout you use here comma seperated. (run localectl list-keymaps to list all averiable keymaps)
  --[[
    Keyboard layouts for the keyboard widget.
    Specify every layout you want to use or leave it as is.
    Example:
      kblayout = { "de", "ru", "us" }
  ]] --
  kblayout = { "de", "ru" },

  --[[
    This is a list of every layout you can use.
    Remove every that you don't want to use.
  ]] --
  layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.floating,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.corner.nw,
    awful.layout.suit.corner.ne,
    awful.layout.suit.corner.sw,
    awful.layout.suit.corner.se,
    awful.layout.suit.magnifier,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.spiral.dwindle,
  },

  --[[
    The modkey is <Super>(<Meta> or <Windows Key>) default
    Run xmodmap -pm to see a list of all possible keys.
    Example:
      "mod1" <-- Is Alt_L
      "mod2" <-- is Numlock
      "mod3" <-- Nothing on my system
      "mod4" <-- for the super/windows key
      "mod5" <-- for the shift key
  ]] --
  modkey = "Mod4",

  --[[
    This is the naming sheme used for the powermenu and maybe some other places in the future.
    Example:
      "userhost" <-- Will display "username@hostname"
      "fullname" <-- Will display "Firstname Surname"
      "?" <-- Will display "?"
  ]] --
  namestyle = "userhost",

  --[[
    This is used to identify your network adapters.
    Use this command `ip a` to get your lan or wlan name.
    Example:
      wlan = "wlo1",
      ethernet = "eno1"
  ]] --
  network = {
    wlan = "wlo1",
    ethernet = "eno1"
  },

  --[[
    This is the program that will be executed when hitting the print key.
  ]] --
  screenshot_program = "flameshot gui",

  --[[
    These are the status bar widgets which are to be found in the notification-center.
    You can add or remove them to your linking, here is a full list:
      "cpu_usage"
      "cpu_temp"
      "ram_usage"
      "microphone"
      "volume"
      "gpu_temp"
      "gpu_usage"
      "battery"
      "backlight"
  ]] --
  status_bar_widgets = {
    "cpu_usage",
    "cpu_temp",
    "ram_usage",
    "microphone",
    "volume",
    "gpu_temp",
    "gpu_usage",
    "battery",
    "backlight"
  },

  --[[
    This is the default terminal, Alacritty is the default.
  ]] --
  terminal = "alacritty",

  --[[
    Add every client that should get no titlebar.
    Use xprop WM_ClASS to get the class of the window.
    !Always use the right(second) string!
    Example:
      titlebar_exception = {
        "firefox",
        "discord",
        "Spotify"
      }
  ]] --
  titlebar_exception = {
  },

  --[[
      The titlebar position can be "left" (default) or "top"
      Example:
        titlebar_position = "top"
  ]] --
  titlebar_position = "top",

  --[[
      This is the path to your wallpaper.
      home is $HOME, you can also use an absolute path.
  ]] --
  wallpaper = home .. "/.config/awesome/src/assets/fuji.jpg",

  --[[
    This is the weather widget.
    You can use the openweather api to get your city ID. https://home.openweathermap.org/api_keys
    Example:
      weather_api_key = "your_api_key",
      weather_city_id = "your_city_id",
      unit = "metric" or "imperial"
  ]]
  weather_secrets = {
    key = "",
    city_id = "",
    unit = "metric"
  },

  --[[
    You can configure your bar's here, if you leave it empty the bar will not be shown.
    If you have multiple monitors you can add [N] where N is  to the table below to get a per screen configuration.
    Here is a full list of every widget you can use:
    Widgets:
      "Audio"           <-- Displays the volume and can show the Audio Menu
      "Battery"         <-- Displays the battery percentage
      "Bluetooth"       <-- Displays the bluetooth status and can open the Bluetooth Menu
      "Clock"           <-- Displays a clock
      "Cpu Frequency"   <-- Shows the CPU Frequency in MHz
      "Cpu Temperature" <-- Shows the CPU Temperature in Celsius
      "Cpu Usage"       <-- Shows the CPU Usage in %
      "Date"            <-- Displays the current date
      "Gpu Temperature" <-- Shows the GPU Temperature in Celsius
      "Gpu Usage"       <-- Shows the GPU Usage in %
      "Keyboard Layout" <-- Shows the current keyboard layout and can open the Keyboard Menu
      "Tiling Layout"   <-- Shows the current tiling layout
      "Network"         <-- Shows the current network connection and strength and can open the Network Menu
      "Power Button"    <-- Opens the Session menu
      "Ram Usage"       <-- Shows the RAM Usage in x/y GB
      "Systray"         <-- Shows the systray
      "Taglist"         <-- Shows all tags per screen and their open programs
      "Tasklist"        <-- Shows all programs per tag
    !The order goes from left to right!
  ]]
  widgets = {
    [1] = {
      left_bar = {
        "Tiling Layout",
        "Systray",
        "Taglist"
      },
      center_bar = {
        "Tasklist"
      },
      right_bar = {
        "Battery",
        "Network",
        "Bluetooth",
        "Audio",
        "Keyboard Layout",
        "Date",
        "Clock",
        "Power Button"
      }
    },
    [2] = {
      left_bar = {
        "Tiling Layout",
        "Taglist"
      },
      center_bar = {
        "Tasklist"
      },
      right_bar = {
        "Ram Usage",
        "Audio",
        "Keyboard Layout",
        "Network",
        "Date",
        "Clock",
        "Power Button"
      }
    }
  }
}
