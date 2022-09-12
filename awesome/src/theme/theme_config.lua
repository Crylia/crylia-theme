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
  bg_low = color["Green200"],
  bg_mid = color["Orange200"],
  bg_high = color["Red200"],
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
  bg_low = color["Green200"],
  bg_mid = color["Orange200"],
  bg_high = color["Red200"],
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
  notify_icon_color = color["Grey100"]
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
  fg = color["Grey100"],
  bg_urgent = color["RedA200"],
  fg_urgent = color["Grey900"],
  bg_focus = color["Grey100"],
  bg_focus_pressed = "#dddddd",
  bg_focus_hover = color["Grey100"],
  fg_focus = color["Grey900"],
}

Theme_config.tasklist = {
  bg = "#3A475C",
  fg = color["Grey100"],
  bg_urgent = color["RedA200"],
  fg_urgent = color["Grey900"],
  bg_focus = color["Grey100"],
  bg_focus_pressed = "#dddddd",
  bg_focus_hover = color["Grey100"],
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

--#region Module Settings
Theme_config.calendar = {
  bg = color["Grey900"],
  fg = color["Grey100"],
  border_color = color["Grey800"],
  border_width = dpi(2),
  shape = function(cr, w, h)
    gears.shape.rounded_rect(cr, w, h, dpi(8))
  end,
  day = {
    today_border_color = color["Blue200"],
    bg = color["Grey900"],
    bg_focus = color["Teal200"],
    bg_unfocus = color["Grey900"],
    fg = color["Grey100"],
    fg_focus = color["Grey900"],
    fg_unfocus = color["Grey600"],
    border_color = color["Grey800"],
    border_width = dpi(2),
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(8))
    end,
  },
  task = {
    bg = color["Purple200"],
    fg = color["Grey900"],
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(4))
    end,
  },
  weekdays = {
    bg = color["Grey900"],
    fg = color["Blue200"]
  },
  add_ical = {
    bg = color["Red200"],
    fg = color["Grey900"],
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(4))
    end,
  },
  add_task = {
    bg = color["LightBlue200"],
    fg = color["Grey900"],
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(4))
    end,
  }
}

Theme_config.notification = {
  border_color = color["Grey800"],
  border_width = dpi(4),
  bg = color["Grey900"],
  spacing = dpi(10),
  shape = function(cr, width, height)
    gears.shape.rounded_rect(cr, width, height, dpi(10))
  end,
  shape_inside = function(cr, width, height)
    gears.shape.rounded_rect(cr, width, height, dpi(4))
  end,
  position = "bottom_right",
  timeout = 3,
  corner_spacing = dpi(20),
  bg_urgent = color["Grey900"],
  fg_urgent_title = color["RedA200"],
  fg_urgent_message = color["Red200"],
  fg_urgent_app_name = color["RedA400"],
  fg_normal_title = color["Pink200"],
  fg_normal_message = "#ffffffaa",
  bg_normal = color["Grey900"],
  spotify_button_icon_color = color["Cyan200"],
  action_bg = color["Grey800"],
  action_fg = color["Green200"],
  icon_color = color["Teal200"],
  fg_appname = color["Teal200"],
  fg_time = color["Teal200"],
  fg_close = color["Teal200"],
  bg_close = color["Grey900"],
  title_border_color = color["Grey800"],
  title_border_width = dpi(2),
}

Theme_config.notification_center = {
  bg = color["Grey900"],
  border_color = color["Grey800"],
  border_width = dpi(4),
  spacing_color = color["Grey800"],

  -- Clear all button
  clear_all_button = {
    bg = color["Blue200"],
    fg = color["Grey900"],
  },

  -- DnD button
  dnd = {
    bg = color["Grey900"],
    fg = color["Pink200"],
    disabled = color["Grey700"],
    enabled = color["Purple200"],
    border_disabled = color["Grey800"],
    border_enabled = color["Purple200"],
  },

  -- Notification_list
  notification_list = {
    timer_fg = color["Teal200"],
    close_color = color["Teal200"],
    close_bg = color["Grey900"],
    icon = color["Teal200"],
    title_fg = color["Teal200"],
    title_border_color = color["Grey800"],
    title_border_width = dpi(2),
    notification_border_color = color["Grey800"],
    notification_bg = color["Grey900"],
    notification_border_width = dpi(4),
    notification_shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, 8)
    end
  },

  -- Profile widget
  profile = {
    username_icon_color = color["Blue200"],
    os_prefix_icon_color = color["Blue200"],
    kernel_icon_color = color["Blue200"],
    uptime_icon_color = color["Blue200"],
    fg = color["Green200"],
    border_color = color["Grey800"],
    border_width = dpi(4),
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(8))
    end
  },

  -- Song info widget
  song_info = {
    shuffle_disabled = color["Grey800"],
    shuffle_enabled = color["Green200"],
    repeat_disabled = color["Grey800"],
    repeat_single = color["Green200"],
    repeat_all = color["Green200"],
    prev_enabled = color["Teal200"],
    next_enabled = color["Teal200"],
    play_enabled = color["Teal200"],
    prev_hover = color["Teal300"],
    next_hover = color["Teal300"],
    play_hover = color["Teal300"],
    title_fg = color["Pink200"],
    artist_fg = color["Teal200"],
    duration_fg = color["Teal200"],
    progress_color = color["Purple200"],
    progress_background_color = color["Grey800"],
    border_color = color["Grey800"],
    border_width = dpi(4),
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(8))
    end
  },
  -- Spacing line widget
  spacing_line = {
    color = color["Grey800"],
  },

  -- Status bar widgets
  status_bar = {
    border_color = color["Grey800"],
    border_width = dpi(4),
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(10))
    end,
    bar_bg_color = color["Grey800"],
    cpu_usage_color = color["Cyan200"],
    cpu_temp_color = color["Blue200"],
    ram_usage_color = color["Red200"],
    gpu_usage_color = color["Green200"],
    gpu_temp_color = color["Green200"],
    volume_color = color["Yellow200"],
    microphone_color = color["Blue200"],
    backlight_color = color["Pink200"],
    battery_color = color["Purple200"],
  },

  -- Time Date widget
  time_date = {

  },

  -- Weather widget
  weather = {
    description_fg = color["LightBlue200"],
    line_color = color["Grey800"],
    speed_icon_color = color["OrangeA200"],
    humidity_icon_color = color["OrangeA200"],
    border_color = color["Grey800"],
    border_width = dpi(4),
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(12))
    end
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

Theme_config.center_bar = {
  bg = color["Grey900"],
}

Theme_config.dock = {
  element_bg = color["Grey900"],
  element_focused_bg = color["Grey800"],
  element_focused_hover_bg = color["Grey800"],
  element_focused_hover_fg = color["Grey100"],
  bg = color["Grey900"],
  indicator_bg = color["Grey600"],
  indicator_focused_bg = color["YellowA200"],
  indicator_urgent_bg = color["RedA200"],
  indicator_maximized_bg = color["GreenA200"],
  indicator_bg_mindicator_minimized_bginimized = color["BlueA200"],
  indicator_fullscreen_bg = color["PurpleA200"],
}

Theme_config.left_bar = {
  bg = color["Grey900"],
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

Theme_config.right_bar = {
  bg = color["Grey900"],
}

Theme_config.titlebar = {
  bg = "#121212AA",
  close_button = {
    border_color = "#00000000",
    bg = "#00000000",
    fg = color["Grey100"],
    hover_border = color["Red800"],
    hover_bg = color["Red800"] .. "bb",
    hover_fg = color["Red800"],
  },
  minimize_button = {
    border_color = "#00000000",
    fg = color["Grey100"],
    bg = "#00000000",
    hover_border = color["Orange800"],
    hover_fg = color["Orange800"],
    hover_bg = color["Orange800"] .. "bb",
  },
  maximize_button = {
    border_color = "#00000000",
    fg = color["Grey100"],
    bg = "#00000000",
    hover_border = color["Green800"],
    hover_fg = color["Green800"],
    hover_bg = color["Green800"] .. "bb",
  },
}

Theme_config.volume_controller = {
  bg = color["Grey900"],
  border_color = color["Grey800"],
  border_width = dpi(4),
  shape = function(cr, width, height)
    gears.shape.rounded_rect(cr, width, height, dpi(12))
  end,
  device_bg = color["Grey900"],
  device_border_color = color["Grey800"],
  device_border_width = dpi(2),
  device_shape = function(cr, width, height)
    gears.shape.rounded_rect(cr, width, height, dpi(4))
  end,
  device_headphones_fg = color["Purple200"],
  device_microphone_fg = color["Blue200"],
  device_headphones_selected_bg = color["Purple200"],
  device_headphones_selected_fg = color["Grey900"],
  device_microphone_selected_bg = color["Blue200"],
  device_microphone_selected_fg = color["Grey900"],
  device_headphones_selected_border_color = color["Purple200"],
  device_microphone_selected_border_color = color["Blue200"],
  device_headphones_selected_icon_color = color["Purple200"],
  device_microphone_selected_icon_color = color["Blue200"],
  device_icon_color = color["Grey900"],
  list_border_color = color["Grey800"],
  list_border_width = dpi(2),
  list_shape = function(cr, width, height)
    gears.shape.partially_rounded_rect(cr, width, height, false, false, true, true, dpi(4))
  end,
  list_bg = color["Grey800"],
  list_headphones_fg = color["Purple200"],
  list_microphone_fg = color["Blue200"],
  selector_shape = function(cr, width, height)
    gears.shape.rounded_rect(cr, width, height, dpi(4))
  end,
  volume_fg = color["Purple200"],
  microphone_fg = color["Blue200"],
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
  element_fg = color["Green200"],
  border_color = color["Grey800"],
  border_width = dpi(4),
  bg = color["Grey900"],
  selected_fg = color["CyanA200"],
  selected_border_color = color["Purple200"],
  selected_bg = "#313131"
}

Theme_config.application_launcher = {
  bg = color["Grey900"],
  border_color = color["Grey800"],
  border_width = dpi(4),
  application = {
    border_color = color["Grey800"],
    border_color_active = color["Purple200"],
    border_width = dpi(2),
    bg = "#313131",
    fg = color["Grey100"],
    hover_bg = color["Grey700"],
  },
  searchbar = {
    bg = color["Grey900"],
    fg = color["Grey100"],
    fg_hint = color["Grey700"],
    fg_cursor = color["Grey900"],
    bg_cursor = color["Grey100"],
    border_color = color["Grey800"],
    border_width = dpi(2),
    icon_color = color["Grey900"],
    icon_background = color["LightBlue200"],
    hover_bg = color["Grey800"],
    hover_fg = color["Purple200"],
    hover_border = color["Grey700"],
    border_active = color["LightBlue200"],
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(4))
    end,
  }
}

Theme_config.context_menu = {
  bg = color["Grey900"],
  border_color = color["Grey800"],
  border_width = dpi(4),
  shape = function(cr, width, height)
    gears.shape.rounded_rect(cr, width, height, dpi(8))
  end,
  fg = color["Grey100"],
  entry = {
    bg = color["Grey900"],
    fg = color["Grey100"],
    border_color = color["Grey800"],
    border_width = dpi(2),
    hover_fg = color["Teal200"],
    hover_border = color["Teal200"],
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(4))
    end,
    icon_color = color["Grey100"],
    icon_color_hover = color["Teal200"]
  }
}
--#endregion

--[[
  ========================
  === General Settings ===
  ========================

  Here are some general settings for borders, tooltips etc

]] --

--#region General Settings

Theme_config.window = {
  border_width = dpi(2),
  border_normal = color["Grey800"],
  border_marked = color["Red200"],
  useless_gap = dpi(5)
}

Theme_config.tooltip = {
  bg = color["Grey900"],
  fg = color["CyanA200"],
  border_color = color["Grey800"],
  border_width = dpi(4),
  gaps = dpi(15),
  shape = function(cr, width, heigth)
    gears.shape.rounded_rect(cr, width, heigth, dpi(4))
  end
}

Theme_config.hotkeys = {
  bg = color["Grey900"],
  fg = color["Grey100"],
  border_color = color["Grey800"],
  border_width = dpi(4),
  shape = function(cr, width, heigth)
    gears.shape.rounded_rect(cr, width, heigth, dpi(12))
  end,
  modifiers_fg = color["Cyan200"],
  description_font = User_config.font.bold,
  font = User_config.font.bold,
  group_margin = dpi(20),
  label_bg = color["Cyan200"],
  label_fg = color["Grey900"],
}

--#endregion
