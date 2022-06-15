------------------------------------
-- This is the status_bars widget --
------------------------------------

-- Awesome Libs
local awful = require("awful")
local color = require("src.theme.colors")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")

local rubato = require("src.lib.rubato")

-- Icon directory path
local icondir = awful.util.getdir("config") .. "src/assets/icons/"

--- Signal bars widget for the notification-center
---@diagnostic disable-next-line: undefined-doc-name
---@return wibox.widget
return function()

  ---Creates a layout with bar widgets based on the given table
  ---@param widget_table string{}
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
                color = color["Blue200"],
                background_color = color["Grey800"],
                max_value = 100,
                value = 0,
                forced_height = dpi(8),
                shape = function(cr, width, heigth)
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
              image = gears.color.recolor_image(icondir .. "cpu/cpu.svg", color["Cyan200"]),
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

        awesome.connect_signal(
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
                color = color["Blue200"],
                background_color = color["Grey800"],
                max_value = 100,
                value = 0,
                forced_height = dpi(8),
                shape = function(cr, width, heigth)
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
              image = gears.color.recolor_image(icondir .. "cpu/thermometer.svg", color["Cyan200"]),
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

        awesome.connect_signal(
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
            w:get_children_by_id("icon1")[1].image = gears.color.recolor_image(temp_icon, color["Blue200"])
            tooltip.text = "CPU Temp: " .. cpu_temp .. "°C"
            rubato_timer.target = cpu_temp
          end
        )
      elseif widget == "ram_usage" then
        w = wibox.widget {
          {
            {
              { --Bar
                color = color["Red200"],
                background_color = color["Grey800"],
                max_value = 100,
                value = 0,
                forced_height = dpi(8),
                shape = function(cr, width, heigth)
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
              image = gears.color.recolor_image(icondir .. "cpu/ram.svg", color["Red200"]),
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

        awesome.connect_signal(
          "update::ram_widget",
          function(MemTotal, MemFree, MemAvailable)
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
                color = color["Green200"],
                background_color = color["Grey800"],
                max_value = 100,
                value = 0,
                forced_height = dpi(8),
                shape = function(cr, width, heigth)
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
              image = gears.color.recolor_image(icondir .. "cpu/gpu.svg", color["Green200"]),
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

        awesome.connect_signal(
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
                color = color["Green200"],
                background_color = color["Grey800"],
                max_value = 100,
                value = 0,
                forced_height = dpi(8),
                shape = function(cr, width, heigth)
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
              image = gears.color.recolor_image(icondir .. "cpu/thermometer.svg", color["Green200"]),
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

        awesome.connect_signal(
          "update::gpu_temp",
          function(gpu_temp)
            local temp_icon
            local temp_num = tonumber(gpu_temp)

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
            w:get_children_by_id("icon1")[1].image = gears.color.recolor_image(temp_icon, color["Green200"])
            tooltip.text = "GPU Temp: " .. temp_num .. "°C"
            rubato_timer.target = temp_num
          end
        )
      elseif widget == "volume" then
        w = wibox.widget {
          {
            {
              { --Bar
                color = color["Yellow200"],
                background_color = color["Grey800"],
                max_value = 100,
                value = 0,
                forced_height = dpi(8),
                shape = function(cr, width, heigth)
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
              image = gears.color.recolor_image(icondir .. "audio/volume-high.svg", color["Yellow200"]),
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

        awesome.connect_signal(
          "update::volume_widget",
          function(volume, volume_icon)
            --w:get_children_by_id("progressbar1")[1].value = volume
            w:get_children_by_id("icon1")[1].image = gears.color.recolor_image(volume_icon, color["Yellow200"])
            tooltip.text = "Volume: " .. volume .. "%"
            rubato_timer.target = volume
          end
        )
      elseif widget == "microphone" then
        w = wibox.widget {
          {
            {
              { --Bar
                color = color["Purple200"],
                background_color = color["Grey800"],
                max_value = 100,
                value = 0,
                forced_height = dpi(8),
                shape = function(cr, width, heigth)
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
              image = gears.color.recolor_image(icondir .. "audio/microphone.svg", color["Purple200"]),
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

        awesome.connect_signal(
          "update::microphone_widget",
          function(microphone, microphone_icon)
            --w:get_children_by_id("progressbar1")[1].value = microphone
            w:get_children_by_id("icon1")[1].image = gears.color.recolor_image(microphone_icon, color["Purple200"])
            tooltip.text = "Microphone: " .. microphone .. "%"
            rubato_timer.target = microphone
          end
        )
      elseif widget == "backlight" then
        w = wibox.widget {
          {
            {
              { --Bar
                color = color["Pink200"],
                background_color = color["Grey800"],
                max_value = 100,
                value = 0,
                forced_height = dpi(8),
                shape = function(cr, width, heigth)
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
              image = gears.color.recolor_image(icondir .. "brightness/brightness-high.svg", color["Pink200"]),
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

        awesome.connect_signal(
          "update::backlight",
          function(backlight, backlight_icon)
            --w:get_children_by_id("progressbar1")[1].value = backlight
            w:get_children_by_id("icon1")[1].image = gears.color.recolor_image(backlight_icon, color["Pink200"])
            tooltip.text = "Backlight: " .. backlight .. "%"
            rubato_timer.target = backlight
          end
        )
      elseif widget == "battery" then
        w = wibox.widget {
          {
            {
              { --Bar
                color = color["Purple200"],
                background_color = color["Grey800"],
                max_value = 100,
                value = 0,
                forced_height = dpi(8),
                shape = function(cr, width, heigth)
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
              image = gears.color.recolor_image(icondir .. "battery/battery.svg", color["Purple200"]),
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

        awesome.connect_signal(
          "update::battery_widget",
          function(battery, battery_icon)
            --w:get_children_by_id("progressbar1")[1].value = battery
            w:get_children_by_id("icon1")[1].image = gears.color.recolor_image(battery_icon, color["Purple200"])
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
      border_color = color["Grey800"],
      border_width = dpi(4),
      shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, dpi(10))
      end,
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
