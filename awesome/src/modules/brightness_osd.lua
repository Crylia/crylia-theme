---------------------------------------
-- This is the brightness_osd module --
---------------------------------------

-- Awesome Libs
local awful = require("awful")
local color = require("src.theme.colors")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")

-- Icon directory path
local icondir = awful.util.getdir("config") .. "src/assets/icons/brightness/"

BACKLIGHT_MAX_BRIGHTNESS = 0
BACKLIGHT_SEPS = 0
awful.spawn.easy_async_with_shell(
  "pkexec xfpm-power-backlight-helper --get-max-brightness",
  function(stdout)
    BACKLIGHT_MAX_BRIGHTNESS = tonumber(stdout)
    BACKLIGHT_SEPS = BACKLIGHT_MAX_BRIGHTNESS / 100
    BACKLIGHT_SEPS = math.floor(BACKLIGHT_SEPS)
  end
)

return function(s)

  local brightness_osd_widget = wibox.widget {
    {
      {
        { -- Brightness Icon
          image = gears.color.recolor_image(icondir .. "brightness-high.svg", Theme_config.brightness_osd.icon_color),
          valign = "center",
          halign = "center",
          resize = false,
          id = "icon",
          widget = wibox.widget.imagebox
        },
        { -- Brightness Bar
          {
            {
              id = "progressbar1",
              color = Theme_config.brightness_osd.bar_bg_active,
              background_color = Theme_config.brightness_osd.bar_bg,
              max_value = 100,
              value = 0,
              forced_height = dpi(6),
              shape = function(cr, width, height)
                gears.shape.rounded_bar(cr, width, height, dpi(6))
              end,
              widget = wibox.widget.progressbar
            },
            id = "progressbar_container2",
            halign = "center",
            valign = "center",
            widget = wibox.container.place
          },
          id = "progressbar_container",
          width = dpi(240),
          heigth = dpi(20),
          stragety = "max",
          widget = wibox.container.constraint
        },
        id = "layout1",
        spacing = dpi(10),
        layout = wibox.layout.fixed.horizontal
      },
      id = "margin",
      margins = dpi(10),
      widget = wibox.container.margin
    },
    forced_width = dpi(300),
    forced_height = dpi(80),
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(12))
    end,
    border_color = Theme_config.brightness_osd.border_color,
    border_width = Theme_config.brightness_osd.border_width,
    fg = Theme_config.brightness_osd.fg,
    bg = Theme_config.brightness_osd.bg,
    widget = wibox.container.background
  }

  local update_slider = function()
    awful.spawn.easy_async_with_shell(
      [[ pkexec xfpm-power-backlight-helper --get-brightness ]],
      function(stdout)
        local brightness_value = math.floor((tonumber(stdout) - 1) / (BACKLIGHT_MAX_BRIGHTNESS - 1) * 100)
        brightness_osd_widget:get_children_by_id("progressbar1")[1].value = brightness_value

        awesome.emit_signal("update::backlight", brightness_value)

        local icon = icondir .. "brightness"
        if brightness_value >= 0 and brightness_value < 34 then
          icon = icon .. "-low"
        elseif brightness_value >= 34 and brightness_value < 67 then
          icon = icon .. "-medium"
        elseif brightness_value >= 67 then
          icon = icon .. "-high"
        end
        brightness_osd_widget:get_children_by_id("icon")[1]:set_image(gears.color.recolor_image(icon .. ".svg",
          Theme_config.brightness_osd.icon_color))
      end
    )
  end

  update_slider()

  local brightness_container = awful.popup {
    widget = {},
    ontop = true,
    stretch = false,
    visible = false,
    screen = s,
    placement = function(c) awful.placement.bottom_left(c, { margins = dpi(20) }) end,
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(14))
    end
  }

  local hide_brightness_osd = gears.timer {
    timeout = 2,
    autostart = true,
    callback = function()
      brightness_container.visible = false
    end
  }

  brightness_container:setup {
    brightness_osd_widget,
    layout = wibox.layout.fixed.horizontal
  }

  awesome.connect_signal(
    "widget::brightness_osd:rerun",
    function()
      brightness_container.visible = true
      if hide_brightness_osd.started then
        hide_brightness_osd:again()
        update_slider()
      else
        hide_brightness_osd:start()
        update_slider()
      end
    end
  )
end
