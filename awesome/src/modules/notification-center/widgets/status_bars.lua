------------------------------------
-- This is the status_bars widget --
------------------------------------

-- Awesome Libs
local awful = require('awful')
local beautiful = require('beautiful')
local dpi = require('beautiful').xresources.apply_dpi
local gears = require('gears')
local wibox = require('wibox')
local base = require('wibox.widget.base')
local gfilesystem = require('gears.filesystem')

local rubato = require('src.lib.rubato')

-- Own Libs
local audio = require('src.tools.helpers.audio')
local backlight_helper = require('src.tools.helpers.backlight')
--local battery = require('src.tools.helpers.battery')
local cpu_usage = require('src.tools.helpers.cpu_usage')
local cpu_temp = require('src.tools.helpers.cpu_temp')
local ram = require('src.tools.helpers.ram')
local gpu_usage = require('src.tools.helpers.gpu_usage')
local gpu_temp = require('src.tools.helpers.gpu_temp')

-- Icon directory path
local icondir = gfilesystem.get_configuration_dir() .. 'src/assets/icons/'

local capi = {
  awesome = awesome,
}

return setmetatable({}, {
  __call = function()
    ---Creates a layout with bar widgets based on the given table
    ---@param widget_table table
    ---@return table
    local function create_bar_layout(widget_table)
      local bar_layout = { layout = wibox.layout.flex.horizontal, spacing = dpi(10) }

      for _, widget in pairs(widget_table) do
        local w = base.make_widget_from_value {
          {
            {
              {
                {  --Bar
                  color = beautiful.colorscheme.bg_teal,
                  background_color = beautiful.colorscheme.bg1,
                  max_value = 100,
                  value = 0,
                  forced_height = dpi(8),
                  shape = function(cr)
                    gears.shape.rounded_bar(cr, dpi(58), dpi(8))
                  end,
                  id = 'progress_role',
                  widget = wibox.widget.progressbar,
                },
                halign = 'center',
                valign = 'center',
                widget = wibox.container.place,
              },
              direction = 'east',
              widget    = wibox.container.rotate,
            },
            widget   = wibox.container.constraint,
            height   = dpi(58),  --120 Base size - (10+10) margin - (4+4) Border - 24 Icon - 10 spacing = 58
            width    = dpi(24),
            strategy = 'exact',
          },
          {
            {  --Icon
              id = 'image_role',
              halign = 'center',
              valign = 'center',
              widget = wibox.widget.imagebox,
            },
            height = dpi(24),
            width = dpi(24),
            widget = wibox.container.constraint,
          },
          spacing = dpi(10),
          layout = wibox.layout.fixed.vertical,
        }

        assert(type(w) == 'table', 'Widget creation failed')

        local bar = w:get_children_by_id('progress_role')[1]

        local rubato_timer = rubato.timed {
          duration = 1,
          pos = bar.value,
          easing = rubato.linear,
          subscribed = function(v)
            bar.value = v
          end,
        }

        local tooltip = awful.tooltip {
          objects = { w },
          mode = 'inside',
          preferred_alignments = 'middle',
          margins = dpi(10),
        }

        if widget == 'cpu_usage' then
          cpu_usage:connect_signal('update::cpu_usage', function(_, v)
            if not v then return nil end
            tooltip.text = 'CPU Usage: ' .. v .. '%'
            rubato_timer.target = v
            w:get_children_by_id('image_role')[1].image = gears.color.recolor_image(icondir .. 'cpu/cpu.svg',
              beautiful.colorscheme.bg_teal)
          end)
        elseif widget == 'cpu_temp' then
          cpu_temp:connect_signal('update::cpu_temp', function(_, v)
            if not v then return nil end
            local temp_icon
            if v < 50 then
              temp_icon = icondir .. 'cpu/thermometer-low.svg'
            elseif v >= 50 and v < 80 then
              temp_icon = icondir .. 'cpu/thermometer.svg'
            elseif v >= 80 then
              temp_icon = icondir .. 'cpu/thermometer-high.svg'
            end
            w:get_children_by_id('image_role')[1].image = gears.color.recolor_image(temp_icon,
              beautiful.colorscheme.bg_blue)
            tooltip.text = 'CPU Temp: ' .. v .. '°C'
            rubato_timer.target = v
          end)
        elseif widget == 'ram_usage' then
          ram:connect_signal('update::ram_widget', function(_, MemTotal, _, MemAvailable)
            if not MemTotal and MemAvailable then return nil end
            if not MemTotal or not MemAvailable then return end
            local ram_usage = math.floor(((MemTotal - MemAvailable) / MemTotal * 100) + 0.5)
            tooltip.text = 'RAM Usage: ' .. ram_usage .. '%'
            rubato_timer.target = ram_usage
            w:get_children_by_id('image_role')[1].image = gears.color.recolor_image(icondir .. 'cpu/ram.svg',
              beautiful.colorscheme.bg_red)
          end)
        elseif widget == 'gpu_usage' then
          gpu_usage:connect_signal('update::gpu_usage', function(_, v)
            if not v then return nil end
            tooltip.text = 'GPU Usage: ' .. v .. '%'
            rubato_timer.target = v
            w:get_children_by_id('image_role')[1].image = gears.color.recolor_image(icondir .. 'cpu/gpu.svg',
              beautiful.colorscheme.bg_green)
          end)
        elseif widget == 'gpu_temp' then
          gpu_temp:connect_signal('update::gpu_temp', function(_, v)
            if not v then return nil end
            local temp_icon, temp_num

            if v then
              temp_num = tonumber(v)
              if temp_num < 50 then
                temp_icon = icondir .. 'cpu/thermometer-low.svg'
              elseif temp_num >= 50 and temp_num < 80 then
                temp_icon = icondir .. 'cpu/thermometer.svg'
              elseif temp_num >= 80 then
                temp_icon = icondir .. 'cpu/thermometer-high.svg'
              end
            else
              temp_num = 'NaN'
              temp_icon = icondir .. 'cpu/thermometer-low.svg'
            end
            w:get_children_by_id('image_role')[1].image = gears.color.recolor_image(temp_icon,
              beautiful.colorscheme.bg_green)
            tooltip.text = 'GPU Temp: ' .. temp_num .. '°C'
            rubato_timer.target = temp_num
          end)
        elseif widget == 'volume' then
          audio:connect_signal('sink::get', function(_, muted, volume)
            if not volume and muted then return nil end
            local icon = icondir .. 'audio/volume'
            volume = tonumber(volume)
            if not volume then
              return
            end
            if muted then
              icon = icon .. '-mute'
            else
              if volume < 1 then
                icon = icon .. '-mute'
              elseif volume >= 1 and volume < 34 then
                icon = icon .. '-low'
              elseif volume >= 34 and volume < 67 then
                icon = icon .. '-medium'
              elseif volume >= 67 then
                icon = icon .. '-high'
              end
            end
            w:get_children_by_id('image_role')[1].image = gears.color.recolor_image(icon .. '.svg',
              beautiful.colorscheme.bg_yellow)
            tooltip.text = 'Volume: ' .. volume .. '%'
            rubato_timer.target = volume
          end)
        elseif widget == 'microphone' then
          audio:connect_signal('source::get', function(_, muted, volume)
            if not volume and muted then return nil end
            if not volume then
              return
            end
            local icon = icondir .. 'audio/microphone'
            volume = tonumber(volume)
            if not volume then
              return
            end
            if muted or (volume < 1) then
              icon = icon .. '-off'
            end
            w:get_children_by_id('image_role')[1].image = gears.color.recolor_image(icon .. '.svg',
              beautiful.colorscheme.bg_blue)
            tooltip.text = 'Microphone: ' .. volume .. '%'
            rubato_timer.target = volume
          end)
        elseif widget == 'backlight' then
          backlight_helper:connect_signal('brightness_changed', function()
            backlight_helper.brightness_get_async(function(brightness)
              if not brightness then return end
              brightness = math.floor((tonumber(brightness) / (backlight_helper.brightness_max or 24000) * 100) + 0.5)

              local icon = icondir .. 'brightness/brightness'
              if brightness >= 0 and brightness < 34 then
                icon = icon .. '-low.svg'
              elseif brightness >= 34 and brightness < 67 then
                icon = icon .. '-medium.svg'
              elseif brightness >= 67 then
                icon = icon .. '-high.svg'
              end

              w:get_children_by_id('image_role')[1]:set_image(gears.color.recolor_image(icon,
                beautiful.colorscheme.bg_purple))
              tooltip.text = 'Backlight: ' .. brightness .. '%'
              rubato_timer.target = brightness
            end)
          end)
          backlight_helper.brightness_get_async(function(brightness)
            if not brightness then return end
            brightness = math.floor((tonumber(brightness) / (backlight_helper.brightness_max or 24000) * 100) + 0.5)

            local icon = icondir .. 'brightness/brightness'
            if brightness >= 0 and brightness < 34 then
              icon = icon .. '-low.svg'
            elseif brightness >= 34 and brightness < 67 then
              icon = icon .. '-medium.svg'
            elseif brightness >= 67 then
              icon = icon .. '-high.svg'
            end

            w:get_children_by_id('image_role')[1]:set_image(gears.color.recolor_image(icon,
              beautiful.colorscheme.bg_purple))
            tooltip.text = 'Backlight: ' .. brightness .. '%'
            rubato_timer.target = brightness
          end)
        elseif widget == 'battery' then
          capi.awesome.connect_signal('update::battery_widget', function(battery, battery_icon)
            w:get_children_by_id('image_role')[1].image = gears.color.recolor_image(battery_icon,
              beautiful.colorscheme.bg_purple)
            tooltip.text = 'Battery: ' .. battery .. '%'
            rubato_timer.target = battery
          end)
        end

        table.insert(bar_layout, w)
      end

      return bar_layout
    end

    return wibox.widget {
      {
        {
          {
            {
              {
                create_bar_layout(beautiful.user_config.status_bar_widgets),
                width = dpi(480),
                strategy = 'exact',
                widget = wibox.container.constraint,
              },
              widget = wibox.container.place,
            },
            magins = dpi(10),
            layout = wibox.container.margin,
          },
          border_color = beautiful.colorscheme.border_color,
          border_width = dpi(2),
          shape = beautiful.shape[12],
          widget = wibox.container.background,
        },
        widget = wibox.container.constraint,
        height = dpi(120),
        width = dpi(500),
        strategy = 'exact',
      },
      top = dpi(10),
      left = dpi(20),
      right = dpi(20),
      bottom = dpi(10),
      widget = wibox.container.margin,
    }
  end,
})
