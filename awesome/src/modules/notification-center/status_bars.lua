------------------------------------
-- This is the status_bars widget --
------------------------------------

-- Awesome Libs
local awful = require("awful")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")

local rubato = require("src.lib.rubato")

local capi = {
  awesome = awesome,
}

-- Icon directory path
local icondir = awful.util.getdir("config") .. "src/assets/icons/"

--- Signal bars widget for the notification-center
---@diagnostic disable-next-line: undefined-doc-name
---@return wibox.widget
return function()

  ---Creates a layout with bar widgets based on the given table
  ---@param widget_table table
  ---@return table
  local function create_bar_layout(widget_table)
    local bar_layout = { layout = wibox.layout.flex.horizontal, spacing = dpi(10) }

    for _, widget in pairs(widget_table) do
      local w
      if widget == "cpu_usage" then
        w = wibox.widget {
          {
            {
              { --Bar
                color = Theme_config.notification_center.status_bar.cpu_usage_color,
                background_color = Theme_config.notification_center.status_bar.bar_bg_color,
                max_value = 100,
                value = 0,
                forced_height = dpi(8),
                shape = function(cr)
                  gears.shape.rounded_bar(cr, dpi(58), dpi(8))
                end,
                id = "progressbar1",
                widget = wibox.widget.progressbar
              },
              id = "background1",
              halign = "center",
              valign = "center",
              widget = wibox.container.place
            },
            id            = "background2",
            forced_height = dpi(58), --120 Base size - (10+10) margin - (4+4) Border - 24 Icon - 10 spacing = 58
            forced_width  = dpi(24),
            direction     = "east",
            widget        = wibox.container.rotate
          },
          {
            { --Icon
              image = gears.color.recolor_image(icondir .. "cpu/cpu.svg",
                Theme_config.notification_center.status_bar.cpu_usage_color),
              halign = "center",
              valign = "center",
              widget = wibox.widget.imagebox,
              id = "icon1",
            },
            id = "background3",
            height = dpi(24),
            width = dpi(24),
            widget = wibox.container.constraint
          },
          id = "cpu_layout",
          spacing = dpi(10),
          layout = wibox.layout.fixed.vertical
        }

        local bar = w:get_children_by_id("progressbar1")[1]

        local rubato_timer = rubato.timed {
          duration = 1,
          pos = bar.value,
          easing = rubato.linear,
          subscribed = function(v)
            bar.value = v
          end
        }

        local tooltip = awful.tooltip {
          objects = { w },
          mode = "inside",
          preferred_alignments = "middle",
          margins = dpi(10)
        }

        w:connect_signal("mouse::enter", function()
          capi.awesome.emit_signal("notification_center::block_mouse_events")
        end)

        w:connect_signal("mouse::leave", function()
          capi.awesome.emit_signal("notification_center::unblock_mouse_events")
        end)

        capi.awesome.connect_signal(
          "update::cpu_usage",
          function(cpu_usage)
            tooltip.text = "CPU Usage: " .. cpu_usage .. "%"
            rubato_timer.target = cpu_usage
          end
        )
      elseif widget == "cpu_temp" then
        w = wibox.widget {
          {
            {
              { --Bar
                color = Theme_config.notification_center.status_bar.cpu_temp_color,
                background_color = Theme_config.notification_center.status_bar.bar_bg_color,
                max_value = 100,
                value = 0,
                forced_height = dpi(8),
                shape = function(cr)
                  gears.shape.rounded_bar(cr, dpi(58), dpi(8))
                end,
                id = "progressbar1",
                widget = wibox.widget.progressbar
              },
              id = "background1",
              halign = "center",
              valign = "center",
              widget = wibox.container.place
            },
            id            = "background2",
            forced_height = dpi(58), --120 Base size - (10+10) margin - (4+4) Border - 24 Icon - 10 spacing = 58
            forced_width  = dpi(24),
            direction     = "east",
            widget        = wibox.container.rotate
          },
          {
            { --Icon
              id = "icon1",
              image = gears.color.recolor_image(icondir .. "cpu/thermometer.svg",
                Theme_config.notification_center.status_bar.cpu_temp_color),
              halign = "center",
              valign = "center",
              widget = wibox.widget.imagebox
            },
            id = "background3",
            height = dpi(24),
            width = dpi(24),
            widget = wibox.container.constraint
          },
          id = "cpu_temp_layout",
          spacing = dpi(10),
          layout = wibox.layout.fixed.vertical
        }

        local bar = w:get_children_by_id("progressbar1")[1]

        local rubato_timer = rubato.timed {
          duration = 1,
          pos = bar.value,
          easing = rubato.linear,
          subscribed = function(v)
            bar.value = v
          end
        }

        local tooltip = awful.tooltip {
          objects = { w },
          mode = "inside",
          preferred_alignments = "middle",
          margins = dpi(10)
        }
        w:connect_signal("mouse::enter", function()
          capi.awesome.emit_signal("notification_center::block_mouse_events")
        end)

        w:connect_signal("mouse::leave", function()
          capi.awesome.emit_signal("notification_center::unblock_mouse_events")
        end)
        capi.awesome.connect_signal(
          "update::cpu_temp",
          function(cpu_temp)
            local temp_icon
            if cpu_temp < 50 then
              temp_icon = icondir .. "cpu/thermometer-low.svg"
            elseif cpu_temp >= 50 and cpu_temp < 80 then
              temp_icon = icondir .. "cpu/thermometer.svg"
            elseif cpu_temp >= 80 then
              temp_icon = icondir .. "cpu/thermometer-high.svg"
            end
            w:get_children_by_id("icon1")[1].image = gears.color.recolor_image(temp_icon,
              Theme_config.notification_center.status_bar.cpu_temp_color)
            tooltip.text = "CPU Temp: " .. cpu_temp .. "°C"
            rubato_timer.target = cpu_temp
          end
        )
      elseif widget == "ram_usage" then
        w = wibox.widget {
          {
            {
              { --Bar
                color = Theme_config.notification_center.status_bar.ram_usage_color,
                background_color = Theme_config.notification_center.status_bar.bar_bg_color,
                max_value = 100,
                value = 0,
                forced_height = dpi(8),
                shape = function(cr)
                  gears.shape.rounded_bar(cr, dpi(58), dpi(8))
                end,
                id = "progressbar1",
                widget = wibox.widget.progressbar
              },
              id = "background1",
              halign = "center",
              valign = "center",
              widget = wibox.container.place
            },
            id            = "background2",
            forced_height = dpi(58), --120 Base size - (10+10) margin - (4+4) Border - 24 Icon - 10 spacing = 58
            forced_width  = dpi(24),
            direction     = "east",
            widget        = wibox.container.rotate
          },
          {
            { --Icon
              image = gears.color.recolor_image(icondir .. "cpu/ram.svg",
                Theme_config.notification_center.status_bar.ram_usage_color),
              halign = "center",
              valign = "center",
              widget = wibox.widget.imagebox
            },
            height = dpi(24),
            width = dpi(24),
            widget = wibox.container.constraint
          },
          id = "ram_layout",
          spacing = dpi(10),
          layout = wibox.layout.fixed.vertical
        }

        local bar = w:get_children_by_id("progressbar1")[1]

        local rubato_timer = rubato.timed {
          duration = 1,
          pos = bar.value,
          easing = rubato.linear,
          subscribed = function(v)
            bar.value = v
          end
        }

        local tooltip = awful.tooltip {
          objects = { w },
          mode = "inside",
          preferred_alignments = "middle",
          margins = dpi(10)
        }
        w:connect_signal("mouse::enter", function()
          capi.awesome.emit_signal("notification_center::block_mouse_events")
        end)

        w:connect_signal("mouse::leave", function()
          capi.awesome.emit_signal("notification_center::unblock_mouse_events")
        end)
        capi.awesome.connect_signal(
          "update::ram_widget",
          function(MemTotal, _, MemAvailable)
            if not MemTotal or not MemAvailable then
              return
            end
            local ram_usage = math.floor(((MemTotal - MemAvailable) / MemTotal * 100) + 0.5)
            tooltip.text = "RAM Usage: " .. ram_usage .. "%"
            rubato_timer.target = ram_usage
          end
        )
      elseif widget == "gpu_usage" then
        w = wibox.widget {
          {
            {
              { --Bar
                color = Theme_config.notification_center.status_bar.gpu_usage_color,
                background_color = Theme_config.notification_center.status_bar.bar_bg_color,
                max_value = 100,
                value = 0,
                forced_height = dpi(8),
                shape = function(cr)
                  gears.shape.rounded_bar(cr, dpi(58), dpi(8))
                end,
                id = "progressbar1",
                widget = wibox.widget.progressbar
              },
              id = "background1",
              halign = "center",
              valign = "center",
              widget = wibox.container.place
            },
            id            = "background2",
            forced_height = dpi(58), --120 Base size - (10+10) margin - (4+4) Border - 24 Icon - 10 spacing = 58
            forced_width  = dpi(24),
            direction     = "east",
            widget        = wibox.container.rotate
          },
          {
            { --Icon
              image = gears.color.recolor_image(icondir .. "cpu/gpu.svg",
                Theme_config.notification_center.status_bar.gpu_usage_color),
              halign = "center",
              valign = "center",
              widget = wibox.widget.imagebox
            },
            height = dpi(24),
            width = dpi(24),
            widget = wibox.container.constraint
          },
          id = "gpu_layout",
          spacing = dpi(10),
          layout = wibox.layout.fixed.vertical
        }

        local bar = w:get_children_by_id("progressbar1")[1]

        local rubato_timer = rubato.timed {
          duration = 1,
          pos = bar.value,
          easing = rubato.linear,
          subscribed = function(v)
            bar.value = v
          end
        }

        local tooltip = awful.tooltip {
          objects = { w },
          mode = "inside",
          preferred_alignments = "middle",
          margins = dpi(10)
        }
        w:connect_signal("mouse::enter", function()
          capi.awesome.emit_signal("notification_center::block_mouse_events")
        end)

        w:connect_signal("mouse::leave", function()
          capi.awesome.emit_signal("notification_center::unblock_mouse_events")
        end)
        capi.awesome.connect_signal(
          "update::gpu_usage",
          function(gpu_usage)
            tooltip.text = "GPU Usage: " .. gpu_usage .. "%"
            rubato_timer.target = tonumber(gpu_usage)
          end
        )
      elseif widget == "gpu_temp" then
        w = wibox.widget {
          {
            {
              { --Bar
                color = Theme_config.notification_center.status_bar.gpu_temp_color,
                background_color = Theme_config.notification_center.status_bar.bar_bg_color,
                max_value = 100,
                value = 0,
                forced_height = dpi(8),
                shape = function(cr)
                  gears.shape.rounded_bar(cr, dpi(58), dpi(8))
                end,
                id = "progressbar1",
                widget = wibox.widget.progressbar
              },
              id = "background1",
              halign = "center",
              valign = "center",
              widget = wibox.container.place
            },
            id            = "background2",
            forced_height = dpi(58), --120 Base size - (10+10) margin - (4+4) Border - 24 Icon - 10 spacing = 58
            forced_width  = dpi(24),
            direction     = "east",
            widget        = wibox.container.rotate
          },
          {
            { --Icon
              id = "icon1",
              image = gears.color.recolor_image(icondir .. "cpu/thermometer.svg",
                Theme_config.notification_center.status_bar.gpu_temp_color),
              halign = "center",
              valign = "center",
              widget = wibox.widget.imagebox
            },
            id = "background3",
            height = dpi(24),
            width = dpi(24),
            widget = wibox.container.constraint
          },
          id = "gpu_temp_layout",
          spacing = dpi(10),
          layout = wibox.layout.fixed.vertical
        }

        local bar = w:get_children_by_id("progressbar1")[1]

        local rubato_timer = rubato.timed {
          duration = 1,
          pos = bar.value,
          easing = rubato.linear,
          subscribed = function(v)
            bar.value = v
          end
        }

        local tooltip = awful.tooltip {
          objects = { w },
          mode = "inside",
          preferred_alignments = "middle",
          margins = dpi(10)
        }
        w:connect_signal("mouse::enter", function()
          capi.awesome.emit_signal("notification_center::block_mouse_events")
        end)

        w:connect_signal("mouse::leave", function()
          capi.awesome.emit_signal("notification_center::unblock_mouse_events")
        end)
        capi.awesome.connect_signal(
          "update::gpu_temp",
          function(gpu_temp)
            local temp_icon
            local temp_num = tonumber(gpu_temp) or "NaN"

            if temp_num then

              if temp_num < 50 then
                temp_icon = icondir .. "cpu/thermometer-low.svg"
              elseif temp_num >= 50 and temp_num < 80 then
                temp_icon = icondir .. "cpu/thermometer.svg"
              elseif temp_num >= 80 then
                temp_icon = icondir .. "cpu/thermometer-high.svg"
              end
            else
              temp_num = "NaN"
              temp_icon = icondir .. "cpu/thermometer-low.svg"
            end
            w:get_children_by_id("icon1")[1].image = gears.color.recolor_image(temp_icon,
              Theme_config.notification_center.status_bar.gpu_temp_color)
            tooltip.text = "GPU Temp: " .. temp_num .. "°C"
            rubato_timer.target = temp_num
          end
        )
      elseif widget == "volume" then
        w = wibox.widget {
          {
            {
              { --Bar
                color = Theme_config.notification_center.status_bar.volume_color,
                background_color = Theme_config.notification_center.status_bar.bar_bg_color,
                max_value = 100,
                value = 0,
                forced_height = dpi(8),
                shape = function(cr)
                  gears.shape.rounded_bar(cr, dpi(58), dpi(8))
                end,
                id = "progressbar1",
                widget = wibox.widget.progressbar
              },
              id = "background1",
              halign = "center",
              valign = "center",
              widget = wibox.container.place
            },
            id            = "background2",
            forced_height = dpi(58), --120 Base size - (10+10) margin - (4+4) Border - 24 Icon - 10 spacing = 58
            forced_width  = dpi(24),
            direction     = "east",
            widget        = wibox.container.rotate
          },
          {
            { --Icon
              id = "icon1",
              image = gears.color.recolor_image(icondir .. "audio/volume-high.svg",
                Theme_config.notification_center.status_bar.volume_color),
              halign = "center",
              valign = "center",
              widget = wibox.widget.imagebox
            },
            id = "background3",
            height = dpi(24),
            width = dpi(24),
            widget = wibox.container.constraint
          },
          id = "volume_layout",
          spacing = dpi(10),
          layout = wibox.layout.fixed.vertical
        }

        local bar = w:get_children_by_id("progressbar1")[1]

        local rubato_timer = rubato.timed {
          duration = 1,
          pos = bar.value,
          easing = rubato.linear,
          subscribed = function(v)
            bar.value = v
          end
        }

        local tooltip = awful.tooltip {
          objects = { w },
          mode = "inside",
          preferred_alignments = "middle",
          margins = dpi(10)
        }
        w:connect_signal("mouse::enter", function()
          capi.awesome.emit_signal("notification_center::block_mouse_events")
        end)

        w:connect_signal("mouse::leave", function()
          capi.awesome.emit_signal("notification_center::unblock_mouse_events")
        end)
        capi.awesome.connect_signal(
          "audio::get",
          function(muted, volume)
            local icon = icondir .. "audio/volume"
            volume = tonumber(volume)
            if not volume then
              return
            end
            if muted then
              icon = icon .. "-mute"
            else
              if volume < 1 then
                icon = icon .. "-mute"
              elseif volume >= 1 and volume < 34 then
                icon = icon .. "-low"
              elseif volume >= 34 and volume < 67 then
                icon = icon .. "-medium"
              elseif volume >= 67 then
                icon = icon .. "-high"
              end
            end
            w:get_children_by_id("icon1")[1].image = gears.color.recolor_image(icon .. ".svg",
              Theme_config.notification_center.status_bar.volume_color)
            tooltip.text = "Volume: " .. volume .. "%"
            rubato_timer.target = volume
          end
        )
      elseif widget == "microphone" then
        w = wibox.widget {
          {
            {
              { --Bar
                color = Theme_config.notification_center.status_bar.microphone_color,
                background_color = Theme_config.notification_center.status_bar.bar_bg_color,
                max_value = 100,
                value = 0,
                forced_height = dpi(8),
                shape = function(cr)
                  gears.shape.rounded_bar(cr, dpi(58), dpi(8))
                end,
                id = "progressbar1",
                widget = wibox.widget.progressbar
              },
              id = "background1",
              halign = "center",
              valign = "center",
              widget = wibox.container.place
            },
            id            = "background2",
            forced_height = dpi(58), --120 Base size - (10+10) margin - (4+4) Border - 24 Icon - 10 spacing = 58
            forced_width  = dpi(24),
            direction     = "east",
            widget        = wibox.container.rotate
          },
          {
            { --Icon
              id = "icon1",
              image = gears.color.recolor_image(icondir .. "audio/microphone.svg",
                Theme_config.notification_center.status_bar.microphone_color),
              halign = "center",
              valign = "center",
              widget = wibox.widget.imagebox
            },
            id = "background3",
            height = dpi(24),
            width = dpi(24),
            widget = wibox.container.constraint
          },
          id = "microphone_layout",
          spacing = dpi(10),
          layout = wibox.layout.fixed.vertical
        }

        local bar = w:get_children_by_id("progressbar1")[1]

        local rubato_timer = rubato.timed {
          duration = 1,
          pos = bar.value,
          easing = rubato.linear,
          subscribed = function(v)
            bar.value = v
          end
        }

        local tooltip = awful.tooltip {
          objects = { w },
          mode = "inside",
          preferred_alignments = "middle",
          margins = dpi(10)
        }
        w:connect_signal("mouse::enter", function()
          capi.awesome.emit_signal("notification_center::block_mouse_events")
        end)

        w:connect_signal("mouse::leave", function()
          capi.awesome.emit_signal("notification_center::unblock_mouse_events")
        end)
        capi.awesome.connect_signal(
          "microphone::get",
          function(muted, volume)
            if not volume then
              return
            end
            local icon = icondir .. "audio/microphone"
            volume = tonumber(volume)
            if not volume then
              return
            end
            if muted or (volume < 1) then
              icon = icon .. "-off"
            end
            w:get_children_by_id("icon1")[1].image = gears.color.recolor_image(icon .. ".svg",
              Theme_config.notification_center.status_bar.microphone_color)
            tooltip.text = "Microphone: " .. volume .. "%"
            rubato_timer.target = volume
          end
        )
      elseif widget == "backlight" then
        w = wibox.widget {
          {
            {
              { --Bar
                color = Theme_config.notification_center.status_bar.backlight_color,
                background_color = Theme_config.notification_center.status_bar.bar_bg_color,
                max_value = 100,
                value = 0,
                forced_height = dpi(8),
                shape = function(cr)
                  gears.shape.rounded_bar(cr, dpi(58), dpi(8))
                end,
                id = "progressbar1",
                widget = wibox.widget.progressbar
              },
              id = "background1",
              halign = "center",
              valign = "center",
              widget = wibox.container.place
            },
            id            = "background2",
            forced_height = dpi(58), --120 Base size - (10+10) margin - (4+4) Border - 24 Icon - 10 spacing = 58
            forced_width  = dpi(24),
            direction     = "east",
            widget        = wibox.container.rotate
          },
          {
            { --Icon
              id = "icon1",
              image = gears.color.recolor_image(icondir .. "brightness/brightness-high.svg",
                Theme_config.notification_center.status_bar.backlight_color),
              halign = "center",
              valign = "center",
              widget = wibox.widget.imagebox
            },
            id = "background3",
            height = dpi(24),
            width = dpi(24),
            widget = wibox.container.constraint
          },
          id = "brightness_layout",
          spacing = dpi(10),
          layout = wibox.layout.fixed.vertical
        }

        local bar = w:get_children_by_id("progressbar1")[1]

        local rubato_timer = rubato.timed {
          duration = 1,
          pos = bar.value,
          easing = rubato.linear,
          subscribed = function(v)
            bar.value = v
          end
        }

        local tooltip = awful.tooltip {
          objects = { w },
          mode = "inside",
          preferred_alignments = "middle",
          margins = dpi(10)
        }
        w:connect_signal("mouse::enter", function()
          capi.awesome.emit_signal("notification_center::block_mouse_events")
        end)

        w:connect_signal("mouse::leave", function()
          capi.awesome.emit_signal("notification_center::unblock_mouse_events")
        end)
        capi.awesome.connect_signal(
          "brightness::get",
          function(brightness)
            local icon = icondir .. "brightness"
            if brightness >= 0 and brightness < 34 then
              icon = icon .. "-low"
            elseif brightness >= 34 and brightness < 67 then
              icon = icon .. "-medium"
            elseif brightness >= 67 then
              icon = icon .. "-high"
            end
            w:get_children_by_id("icon1")[1]:set_image(gears.color.recolor_image(icon .. ".svg",
              Theme_config.notification_center.status_bar.backlight_color))
            tooltip.text = "Backlight: " .. brightness .. "%"
            rubato_timer.target = brightness
          end
        )
      elseif widget == "battery" then
        w = wibox.widget {
          {
            {
              { --Bar
                color = Theme_config.notification_center.status_bar.battery_color,
                background_color = Theme_config.notification_center.status_bar.bar_bg_color,
                max_value = 100,
                value = 0,
                forced_height = dpi(8),
                shape = function(cr)
                  gears.shape.rounded_bar(cr, dpi(58), dpi(8))
                end,
                id = "progressbar1",
                widget = wibox.widget.progressbar
              },
              id = "background1",
              halign = "center",
              valign = "center",
              widget = wibox.container.place
            },
            id            = "background2",
            forced_height = dpi(58), --120 Base size - (10+10) margin - (4+4) Border - 24 Icon - 10 spacing = 58
            forced_width  = dpi(24),
            direction     = "east",
            widget        = wibox.container.rotate
          },
          {
            { --Icon
              id = "icon1",
              image = gears.color.recolor_image(icondir .. "battery/battery.svg",
                Theme_config.notification_center.status_bar.battery_color),
              halign = "center",
              valign = "center",
              widget = wibox.widget.imagebox
            },
            id = "background3",
            height = dpi(24),
            width = dpi(24),
            widget = wibox.container.constraint
          },
          id = "battery_layout",
          spacing = dpi(10),
          layout = wibox.layout.fixed.vertical
        }

        local bar = w:get_children_by_id("progressbar1")[1]

        local rubato_timer = rubato.timed {
          duration = 1,
          pos = bar.value,
          easing = rubato.linear,
          subscribed = function(v)
            bar.value = v
          end
        }

        local tooltip = awful.tooltip {
          objects = { w },
          mode = "inside",
          preferred_alignments = "middle",
          margins = dpi(10)
        }
        w:connect_signal("mouse::enter", function()
          capi.awesome.emit_signal("notification_center::block_mouse_events")
        end)

        w:connect_signal("mouse::leave", function()
          capi.awesome.emit_signal("notification_center::unblock_mouse_events")
        end)
        capi.awesome.connect_signal(
          "update::battery_widget",
          function(battery, battery_icon)
            w:get_children_by_id("icon1")[1].image = gears.color.recolor_image(battery_icon,
              Theme_config.notification_center.status_bar.battery_color)
            tooltip.text = "Battery: " .. battery .. "%"
            rubato_timer.target = battery
          end
        )
      end
      table.insert(bar_layout, w)
    end

    return bar_layout
  end

  local signal_bars = wibox.widget {
    {
      {
        {
          {
            create_bar_layout(User_config.status_bar_widgets),
            width = dpi(480),
            strategy = "exact",
            widget = wibox.container.constraint
          },
          halign = "center",
          valign = "center",
          widget = wibox.container.place
        },
        magins = dpi(10),
        layout = wibox.container.margin
      },
      forced_height = dpi(120),
      forced_width = dpi(500),
      border_color = Theme_config.notification_center.status_bar.border_color,
      border_width = Theme_config.notification_center.status_bar.border_width,
      shape = Theme_config.notification_center.status_bar.shape,
      widget = wibox.container.background
    },
    top = dpi(10),
    left = dpi(20),
    right = dpi(20),
    bottom = dpi(10),
    widget = wibox.container.margin
  }

  return signal_bars

end
