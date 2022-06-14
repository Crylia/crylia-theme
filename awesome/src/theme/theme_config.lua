-- Awesome Libs
local color = require("src.theme.colors")
local dpi = require("beautiful.xresources").apply_dpi
local gears = require("gears")

Theme_config = {}

--[[
  =======================
  === Widget Settings ===
  =======================

  Every widget can be customized with a custom color.
  You can change the color and other theme related settings here.
  For functional changes visit the user_config.lua

]] --

--#region Widget Settings
Theme_config.audio = {
  bg = color["Yellow200"],
  fg = color["Grey900"],
}

Theme_config.battery = {
  bg = color["Purple200"],
  fg = color["Grey900"],
}

Theme_config.bluetooth = {
  bg = color["Blue200"],
  fg = color["Grey900"],
}

Theme_config.clock = {
  bg = color["Orange200"],
  fg = color["Grey900"],
}

Theme_config.cpu_freq = {
  bg = color["Blue200"],
  fg = color["Grey900"],
}

Theme_config.cpu_temp = {
  fg = color["Grey900"],
}

Theme_config.cpu_usage = {
  bg = color["Blue200"],
  fg = color["Grey900"],
}

Theme_config.date = {
  bg = color["Teal200"],
  fg = color["Grey900"],
}

Theme_config.gpu_usage = {
  bg = color["Green200"],
  fg = color["Grey900"],
}

Theme_config.gpu_temp = {
  fg = color["Grey900"],
}

Theme_config.kblayout = {
  bg = color["Green200"],
  fg = color["Grey900"],
  bg_container = color["Grey900"],
  border_color_container = color["Grey800"],
  item = {
    bg = color["Grey800"],
    fg_long = color["Red200"],
    fg_short = color["Purple200"],
    bg_selected = color["DeepPurple200"],
    fg_selected = color["Grey900"],
  }
}

Theme_config.layout_list = {
  bg = color["LightBlue200"],
  fg = color["Grey900"],
}

Theme_config.network = {
  bg = color["Red200"],
  fg = color["Grey900"],
  notify_icon_color = color["White"]
}

Theme_config.power_button = {
  bg = color["Red200"],
  fg = color["Grey900"],
}

Theme_config.ram_info = {
  bg = color["Red200"],
  fg = color["Grey900"],
}

Theme_config.systray = {
  bg = "#3A475C",
}

Theme_config.taglist = {
  bg = "#3A475C",
  fg = color["White"],
  bg_urgent = color["RedA200"],
  fg_urgent = color["Grey900"],
  bg_focus = color["White"],
  bg_focus_pressed = "#dddddd",
  bg_focus_hover = color["White"],
  fg_focus = color["Grey900"],
}

Theme_config.tasklist = {
  bg = "#3A475C",
  fg = color["White"],
  bg_urgent = color["RedA200"],
  fg_urgent = color["Grey900"],
  bg_focus = color["White"],
  bg_focus_pressed = "#dddddd",
  bg_focus_hover = color["White"],
  fg_focus = color["Grey900"],
}
--#endregion

--[[
  =======================
  === Module Settings ===
  =======================

  Here you can customize the modules.
  For functional changes visit the user_config.lua

]] --

Theme_config.notification_center = {
  bg = color["Grey900"],

  -- Clear all button
  clear_all_button = {
    bg = color["Blue200"],
    fg = color["Grey900"],
  },

  -- DnD button
  dnd = {

  },

  -- Notification_list
  notification_list = {

  },

  -- Profile widget
  profile = {

  },

  -- Song info widget
  song_info = {

  },
  -- Spacing line widget
  spacing_line = {

  },

  -- Status bar widgets
  status_bar = {

  },

  -- Time Date widget
  time_date = {

  },

  -- Weather widget
  weather = {

  },
}

Theme_config.bluetooth_controller = {
  icon_color = color["Purple200"],
  icon_color_dark = color["Grey900"],
  con_button_color = color["Blue200"],
  device_bg = color["Grey900"],
  device_bg_hover = "#313131",
  device_fg_hover = color["LightBlue100"],
  device_fg = color["LightBlue200"],
  device_border_color = color["Grey800"],
  device_border_width = dpi(2),
  con_device_border_color = color["Grey800"],
  con_device_border_width = dpi(2),
  connected_bg = color["Grey800"],
  connected_fg = color["Purple200"],
  connected_icon_color = color["Purple200"],
  discovered_icon_color = color["LightBlue200"],
  discovered_bg = color["Grey800"],
  discovered_fg = color["LightBlue200"],
  container_border_color = color["Grey800"],
  container_border_width = dpi(4),
  container_bg = color["Grey900"],
}

Theme_config.brightness_osd = {
  bg = color["Grey900"],
  fg = color["Blue200"],
  border_color = color["Grey800"],
  border_width = dpi(4),
  bar_bg_active = color["Blue200"],
  bar_bg = color["Grey800"],
  icon_color = color["Blue200"],
}

Theme_config.powermenu = {
  container_bg = "#21212188",
  button_fg = color["Grey900"],
  shutdown_button_bg = color["Blue200"],
  reboot_button_bg = color["Red200"],
  suspend_button_bg = color["Yellow200"],
  lock_button_bg = color["Green200"],
  logout_button_bg = color["Orange200"],
}

Theme_config.titlebar = {
  bg = "#121212AA",
  close_button_bg = color["Red200"],
  close_button_fg = color["Grey900"],
  minimize_button_bg = color["Yellow200"],
  minimize_button_fg = color["Grey900"],
  maximize_button_bg = color["Green200"],
  maximize_button_fg = color["Grey900"],

}

Theme_config.volume_controller = {

}

Theme_config.volume_osd = {
  bg = color["Grey900"],
  fg = color["Purple200"],
  border_color = color["Grey800"],
  border_width = dpi(4),
  bar_bg_active = color["Purple200"],
  bar_bg = color["Grey800"],
  icon_color = color["Purple200"],
}

Theme_config.window_switcher = {
  element_bg = color["Grey800"],
  element_fg = color["CyanA200"],
  border_color = color["Grey800"],
  border_width = dpi(4),
  bg = color["Grey900"],
}
