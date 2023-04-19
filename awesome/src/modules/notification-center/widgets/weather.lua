--------------------------------
-- This is the weather widget --
--------------------------------

-- Awesome Libs
local beautiful = require('beautiful')
local dpi = require('beautiful').xresources.apply_dpi
local wibox = require('wibox')
local gfilesystem = require('gears.filesystem')
local gtimer = require('gears.timer')
local aspawn = require('awful.spawn')
local gcolor = require('gears.color')

local json_lua = require('src.lib.json-lua.json-lua')

-- Icon directory path
local icondir = gfilesystem.get_configuration_dir() .. 'src/assets/icons/weather/'

local instance = nil

local icon_table = {
  ['01d'] = 'weather-sunny',
  ['01n'] = 'weather-clear-night',
  ['02d'] = 'weather-partly-cloudy',
  ['02n'] = 'weather-night-partly-cloudy',
  ['03d'] = 'weather-cloudy',
  ['03n'] = 'weather-clouds-night',
  ['04d'] = 'weather-cloudy',
  ['04n'] = 'weather-cloudy',
  ['09d'] = 'weather-rainy',
  ['09n'] = 'weather-rainy',
  ['10d'] = 'weather-partly-rainy',
  ['10n'] = 'weather-partly-rainy',
  ['11d'] = 'weather-pouring',
  ['11n'] = 'weather-pouring',
  ['13d'] = 'weather-snowy',
  ['13n'] = 'weather-snowy',
  ['50d'] = 'weather-fog',
  ['50n'] = 'weather-fog',
}

if not instance then
  instance = setmetatable({}, { __call = function()

    local w = wibox.widget {
      {
        {
          {
            {
              {
                {
                  { -- Icon
                    valign = 'center',
                    halign = 'center',
                    widget = wibox.widget.imagebox,
                    id = 'icon',
                  },
                  widget = wibox.container.constraint,
                  width = dpi(64),
                  height = dpi(64),
                  strategy = 'exact',
                },
                { -- Temperature
                  text = 'NaN°C',
                  valign = 'center',
                  halign = 'center',
                  widget = wibox.widget.textbox,
                  font = 'JetBrains Mono Bold 24',
                  id = 'temp',
                },
                { -- City, Country
                  text   = 'City, Country',
                  valign = 'center',
                  halign = 'center',
                  widget = wibox.widget.textbox,
                  id     = 'city_country',
                },
                {
                  { -- Description
                    text = 'NaN',
                    valign = 'center',
                    halign = 'center',
                    widget = wibox.widget.textbox,
                    id = 'description',
                  },
                  fg = beautiful.colorscheme.bg_blue,
                  widget = wibox.container.background,
                },
                { -- line
                  {
                    bg = beautiful.colorscheme.bg1,
                    widget = wibox.container.background,
                  },
                  widget = wibox.container.constraint,
                  height = dpi(2),
                  width = dpi(10),
                  strategy = 'exact',
                },
                {
                  { -- Speed
                    {
                      image = gcolor.recolor_image(icondir .. 'weather-windy.svg',
                        beautiful.colorscheme.bg_red),
                      valign = 'center',
                      halign = 'center',
                      widget = wibox.widget.imagebox,
                    },
                    widget = wibox.container.constraint,
                    width = dpi(24),
                    height = dpi(24),
                    strategy = 'exact',
                  },
                  {
                    text = 'NaN m/s',
                    valign = 'center',
                    halign = 'center',
                    widget = wibox.widget.textbox,
                    id = 'speed',
                  },
                  spacing = dpi(10),
                  layout = wibox.layout.fixed.horizontal,
                },
                {
                  { -- Humidity
                    {
                      {
                        widget = wibox.widget.imagebox,
                        valign = 'center',
                        halign = 'center',
                        image = gcolor.recolor_image(icondir .. 'humidity.svg',
                          beautiful.colorscheme.bg_red),
                      },
                      widget = wibox.container.constraint,
                      width = dpi(24),
                      height = dpi(24),
                      strategy = 'exact',
                    },
                    {
                      text = 'NaN%',
                      valign = 'center',
                      halign = 'center',
                      widget = wibox.widget.textbox,
                      id = 'humidity',
                    },
                    spacing = dpi(10),
                    layout = wibox.layout.fixed.horizontal,
                  },
                  widget = wibox.container.place,
                },
                spacing = dpi(10),
                layout = wibox.layout.fixed.vertical,
              },
              margins = dpi(20),
              widget = wibox.container.margin,
            },
            widget = wibox.container.place,
          },
          border_color = beautiful.colorscheme.border_color,
          border_width = dpi(2),
          shape = beautiful.shape[12],
          widget = wibox.container.background,
        },
        top = dpi(20),
        left = dpi(20),
        right = dpi(10),
        bottom = dpi(10),
        widget = wibox.container.margin,
      },
      widget = wibox.container.constraint,
      width = dpi(250),
      strategy = 'exact',
    }

    gtimer {
      timeout = 900,
      autostart = true,
      call_now = true,
      callback = function()
        aspawn.easy_async_with_shell("curl -sf 'http://api.openweathermap.org/data/2.5/weather?id=" ..
          beautiful.user_config.weather_secrets.city_id .. '&units=' .. beautiful.user_config.weather_secrets.unit .. '&appid=' .. beautiful.user_config.weather_secrets.key .. "'",
          function(stdout)
            if not stdout:match('error') then
              local weather_metadata = json_lua:decode(stdout)
              if weather_metadata then
                w:get_children_by_id('icon')[1].image = icondir .. icon_table[weather_metadata.weather[1].icon] .. '.svg'
                w:get_children_by_id('temp')[1].text = math.floor(weather_metadata.main.temp + 0.5) .. '°C'
                w:get_children_by_id('city_country')[1].text = weather_metadata.name .. ', ' .. weather_metadata.sys.country
                w:get_children_by_id('description')[1].text = weather_metadata.weather[1].description:sub(1, 1):upper() ..
                    weather_metadata.weather[1].description:sub(2)
                w:get_children_by_id('speed')[1].text = weather_metadata.wind.speed .. ' m/s'
                w:get_children_by_id('humidity')[1].text = weather_metadata.main.humidity .. '%'
              end
            end
          end
        )
      end,
    }

    return w

  end, })
end

return instance
