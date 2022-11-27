---------------------------------
-- This is the gpu Info widget --
---------------------------------

-- Awesome Libs
local awful = require("awful")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")

local color = require("src.lib.color")
local rubato = require("src.lib.rubato")

require("src.tools.helpers.gpu_temp")
require("src.tools.helpers.gpu_usage")

local capi = {
  awesome = awesome,
}

local icon_dir = gears.filesystem.get_configuration_dir() .. "src/assets/icons/cpu/"

return function(widget)

  local gpu_usage_widget = wibox.widget {
    {
      {
        {
          {
            {
              id = "icon",
              widget = wibox.widget.imagebox,
              valign = "center",
              halign = "center",
              image = gears.color.recolor_image(icon_dir .. "gpu.svg", Theme_config.gpu_usage.fg),
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
        id = "gpu_layout",
        layout = wibox.layout.fixed.horizontal
      },
      id = "container",
      left = dpi(8),
      right = dpi(8),
      widget = wibox.container.margin
    },
    bg = Theme_config.gpu_usage.bg,
    fg = Theme_config.gpu_usage.fg,
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(6))
    end,
    widget = wibox.container.background
  }

  local gpu_temp_widget = wibox.widget {
    {
      {
        {
          {
            {
              id = "icon",
              widget = wibox.widget.imagebox,
              valign = "center",
              halign = "center",
              image = gears.color.recolor_image(icon_dir .. "gpu.svg", Theme_config.gpu_temp.fg),
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
        id = "gpu_layout",
        layout = wibox.layout.fixed.horizontal
      },
      id = "container",
      left = dpi(8),
      right = dpi(8),
      widget = wibox.container.margin
    },
    bg = Theme_config.gpu_temp.bg_low,
    fg = Theme_config.gpu_temp.fg,
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(6))
    end,
    widget = wibox.container.background
  }

  Hover_signal(gpu_temp_widget)
  Hover_signal(gpu_usage_widget)

  -- GPU Utilization
  capi.awesome.connect_signal(
    "update::gpu_usage",
    function(stdout)
      gpu_usage_widget.container.gpu_layout.label.text = stdout:gsub("\n", "") .. "%"
    end
  )

  local r_timed_gpu_bg = rubato.timed { duration = 2.5 }
  local g_timed_gpu_bg = rubato.timed { duration = 2.5 }
  local b_timed_gpu_bg = rubato.timed { duration = 2.5 }

  r_timed_gpu_bg.pos, g_timed_gpu_bg.pos, b_timed_gpu_bg.pos = color.utils.hex_to_rgba(Theme_config.cpu_temp.bg_low)

  -- Subscribable function to have rubato set the bg/fg color
  local function update_bg()
    gpu_temp_widget:set_bg("#" ..
      color.utils.rgba_to_hex { math.max(0, r_timed_gpu_bg.pos), math.max(0, g_timed_gpu_bg.pos),
        math.max(0, b_timed_gpu_bg.pos) })
  end

  r_timed_gpu_bg:subscribe(update_bg)
  g_timed_gpu_bg:subscribe(update_bg)
  b_timed_gpu_bg:subscribe(update_bg)

  -- Both functions to set a color, if called they take a new color
  local function set_bg(newbg)
    r_timed_gpu_bg.target, g_timed_gpu_bg.target, b_timed_gpu_bg.target = color.utils.hex_to_rgba(newbg)
  end

  -- GPU Temperature
  capi.awesome.connect_signal(
    "update::gpu_temp",
    function(stdout)

      local temp_icon
      local temp_color
      local temp_num = tonumber(stdout) or "N/A"

      if temp_num then

        if temp_num < 50 then
          temp_color = Theme_config.gpu_temp.bg_low
          temp_icon = icon_dir .. "thermometer-low.svg"
        elseif temp_num >= 50 and temp_num < 80 then
          temp_color = Theme_config.gpu_temp.bg_mid
          temp_icon = icon_dir .. "thermometer.svg"
        elseif temp_num >= 80 then
          temp_color = Theme_config.gpu_temp.bg_high
          temp_icon = icon_dir .. "thermometer-high.svg"
        end
      else
        temp_num = "N/A"
        temp_color = Theme_config.gpu_temp.bg_low
        temp_icon = icon_dir .. "thermometer-low.svg"
      end
      gpu_temp_widget.container.gpu_layout.icon_margin.icon_layout.icon:set_image(temp_icon)
      set_bg(temp_color)
      gpu_temp_widget.container.gpu_layout.label.text = tostring(temp_num) .. "°C"
    end
  )

  if widget == "usage" then
    return gpu_usage_widget
  elseif widget == "temp" then
    return gpu_temp_widget
  end
end
