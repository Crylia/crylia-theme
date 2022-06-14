-----------------------------------
-- This is the volume_old module --
-----------------------------------

-- Awesome Libs
local awful = require("awful")
local color = require("src.theme.colors")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")

-- Icon directory path
local icondir = awful.util.getdir("config") .. "src/assets/icons/audio/"

-- Returns the volume_osd
return function(s)

  local volume_osd_widget = wibox.widget {
    {
      {
        { -- Volume Icon
          image = gears.color.recolor_image(icondir .. "volume-high.svg", Theme_config.volume_osd.icon_color),
          valign = "center",
          halign = "center",
          resize = false,
          id = "icon",
          widget = wibox.widget.imagebox
        },
        { -- Volume Bar
          {
            {
              id = "progressbar1",
              color = Theme_config.volume_osd.bar_bg_active,
              background_color = Theme_config.volume_osd.bar_bg,
              max_value = 100,
              value = 50,
              forced_height = dpi(6),
              shape = function(cr, width, heigth)
                gears.shape.rounded_bar(cr, width, heigth, dpi(6))
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
    border_color = Theme_config.volume_osd.border_color,
    border_width = Theme_config.volume_osd.border_width,
    fg = Theme_config.volume_osd.fg,
    bg = Theme_config.volume_osd.bg,
    widget = wibox.container.background
  }

  local update_slider = function()
    awful.spawn.easy_async_with_shell(
      "./.config/awesome/src/scripts/vol.sh mute",
      function(stdout)
        if stdout:match("yes") then
          volume_osd_widget:get_children_by_id("icon")[1]
              :set_image(gears.color.recolor_image(
                icondir .. "volume-mute" .. ".svg", Theme_config.volume_osd.icon_color))
          volume_osd_widget:get_children_by_id("progressbar1")[1].value = tonumber(0)
        else
          awful.spawn.easy_async_with_shell(
            "./.config/awesome/src/scripts/vol.sh volume",
            function(stdout2)
              local volume_level = stdout2:gsub("%%", ""):gsub("\n", "")
              volume_osd_widget:get_children_by_id("progressbar1")[1].value = tonumber(volume_level)
              local icon = icondir .. "volume"
              if volume_level < 1 then
                icon = icon .. "-mute"
              elseif volume_level >= 1 and volume_level < 34 then
                icon = icon .. "-low"
              elseif volume_level >= 34 and volume_level < 67 then
                icon = icon .. "-medium"
              elseif volume_level >= 67 then
                icon = icon .. "-high"
              end
              volume_osd_widget:get_children_by_id("icon")[1]:set_image(gears.color.recolor_image(icon .. ".svg",
                Theme_config.volume_osd.icon_color))
            end
          )
        end
      end
    )
  end

  update_slider()

  local volume_container = awful.popup {
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

  local hide_volume_osd = gears.timer {
    timeout = 2,
    autostart = true,
    callback = function()
      volume_container.visible = false
    end
  }

  volume_container:setup {
    volume_osd_widget,
    layout = wibox.layout.fixed.horizontal
  }

  awesome.connect_signal(
    "widget::volume_osd:rerun",
    function()
      volume_container.visible = true
      if hide_volume_osd.started then
        hide_volume_osd:again()
        update_slider()
      else
        hide_volume_osd:start()
        update_slider()
      end
    end
  )
end
