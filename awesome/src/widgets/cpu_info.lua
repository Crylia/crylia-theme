---------------------------------
-- This is the CPU Info widget --
---------------------------------

-- Awesome Libs
local awful = require("awful")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")

local color = require("src.lib.color")
local rubato = require("src.lib.rubato")

local icon_dir = awful.util.getdir("config") .. "src/assets/icons/cpu/"

--TODO: Add tooltip with more CPU and per core information
return function(widget, _)

  local cpu_usage_widget = wibox.widget {
    {
      {
        {
          {
            {
              id = "icon",
              widget = wibox.widget.imagebox,
              valign = "center",
              halign = "center",
              image = gears.color.recolor_image(icon_dir .. "cpu.svg", Theme_config.cpu_usage.fg),
              resize = false
            },
            id = "icon_layout",
            widget = wibox.container.place
          },
          top = dpi(2),
          widget = wibox.container.margin,
          id = "icon_margin"
        },
        spacing = dpi(10),
        {
          id = "label",
          align = "center",
          valign = "center",
          widget = wibox.widget.textbox
        },
        id = "cpu_layout",
        layout = wibox.layout.fixed.horizontal
      },
      id = "container",
      left = dpi(8),
      right = dpi(8),
      widget = wibox.container.margin
    },
    bg = Theme_config.cpu_usage.bg,
    fg = Theme_config.cpu_usage.fg,
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(6))
    end,
    widget = wibox.container.background
  }

  local cpu_temp = wibox.widget {
    {
      {
        {
          {
            {
              id = "icon",
              image = gears.color.recolor_image(icon_dir .. "thermometer.svg", Theme_config.cpu_temp.fg),
              widget = wibox.widget.imagebox,
              valign = "center",
              halign = "center",
              resize = false
            },
            id = "icon_layout",
            widget = wibox.container.place
          },
          top = dpi(2),
          widget = wibox.container.margin,
          id = "icon_margin"
        },
        spacing = dpi(10),
        {
          id = "label",
          align = "center",
          valign = "center",
          widget = wibox.widget.textbox
        },
        id = "cpu_layout",
        layout = wibox.layout.fixed.horizontal
      },
      id = "container",
      left = dpi(8),
      right = dpi(8),
      widget = wibox.container.margin
    },
    bg = Theme_config.cpu_temp.bg_low,
    fg = Theme_config.cpu_temp.fg,
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(6))
    end,
    widget = wibox.container.background
  }

  local cpu_clock = wibox.widget {
    {
      {
        {
          {
            {
              id = "icon",
              widget = wibox.widget.imagebox,
              valign = "center",
              halign = "center",
              image = gears.color.recolor_image(icon_dir .. "cpu.svg", Theme_config.cpu_freq.fg),
              resize = false
            },
            id = "icon_layout",
            widget = wibox.container.place
          },
          top = dpi(2),
          widget = wibox.container.margin,
          id = "icon_margin"
        },
        spacing = dpi(10),
        {
          id = "label",
          align = "center",
          valign = "center",
          widget = wibox.widget.textbox
        },
        id = "cpu_layout",
        layout = wibox.layout.fixed.horizontal
      },
      id = "container",
      left = dpi(8),
      right = dpi(8),
      widget = wibox.container.margin
    },
    bg = Theme_config.cpu_freq.bg,
    fg = Theme_config.cpu_freq.fg,
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(6))
    end,
    widget = wibox.container.background
  }

  awesome.connect_signal(
    "update::cpu_usage",
    function(usage)
      cpu_usage_widget.container.cpu_layout.label.text = usage .. "%"
    end
  )

  local r_timed_cpu_bg = rubato.timed { duration = 2.5 }
  local g_timed_cpu_bg = rubato.timed { duration = 2.5 }
  local b_timed_cpu_bg = rubato.timed { duration = 2.5 }

  r_timed_cpu_bg.pos, g_timed_cpu_bg.pos, b_timed_cpu_bg.pos = color.utils.hex_to_rgba(Theme_config.cpu_temp.bg_low)

  -- Subscribable function to have rubato set the bg/fg color
  local function update_bg()
    cpu_temp:set_bg("#" .. color.utils.rgba_to_hex { r_timed_cpu_bg.pos, g_timed_cpu_bg.pos, b_timed_cpu_bg.pos })
  end

  r_timed_cpu_bg:subscribe(update_bg)
  g_timed_cpu_bg:subscribe(update_bg)
  b_timed_cpu_bg:subscribe(update_bg)

  -- Both functions to set a color, if called they take a new color
  local function set_bg(newbg)
    r_timed_cpu_bg.target, g_timed_cpu_bg.target, b_timed_cpu_bg.target = color.utils.hex_to_rgba(newbg)
  end

  awesome.connect_signal(
    "update::cpu_temp",
    function(temp)
      local temp_icon
      local temp_color

      if temp < 50 then
        temp_color = Theme_config.cpu_temp.bg_low
        temp_icon = icon_dir .. "thermometer-low.svg"
      elseif temp >= 50 and temp < 80 then
        temp_color = Theme_config.cpu_temp.bg_mid
        temp_icon = icon_dir .. "thermometer.svg"
      elseif temp >= 80 then
        temp_color = Theme_config.cpu_temp.bg_high
        temp_icon = icon_dir .. "thermometer-high.svg"
      end
      cpu_temp.container.cpu_layout.icon_margin.icon_layout.icon:set_image(temp_icon)
      set_bg(temp_color)
      cpu_temp.container.cpu_layout.label.text = math.floor(temp) .. "°C"
      awesome.emit_signal("update::cpu_temp_widget", temp, temp_icon)
    end
  )

  awesome.connect_signal(
    "update::cpu_freq_average",
    function(average)
      cpu_clock.container.cpu_layout.label.text = average .. "Mhz"
    end
  )

  awesome.connect_signal(
    "update::cpu_freq_core",
    function(freq)
      cpu_clock.container.cpu_layout.label.text = freq .. "Mhz"
    end
  )

  Hover_signal(cpu_temp)
  Hover_signal(cpu_usage_widget)
  Hover_signal(cpu_clock)

  if widget == "usage" then
    return cpu_usage_widget
  elseif widget == "temp" then
    return cpu_temp
  elseif widget == "freq" then
    return cpu_clock
  end

end
