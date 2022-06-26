--------------------------------
-- This is the weather widget --
--------------------------------

-- Awesome Libs
local awful = require("awful")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")
local naughty = require("naughty")

local json_lua = require("src.lib.json-lua.json-lua")

-- Icon directory path
local icondir = awful.util.getdir("config") .. "src/assets/icons/weather/"

return function()

  local api_secrets = {
    key = User_config.weather_secrets.key,
    city_id = User_config.weather_secrets.city_id,
    unit = User_config.weather_secrets.unit
  }

  local weather_widget = wibox.widget {
    {
      {
        {
          {
            {
              { -- Icon
                valign = "center",
                align = "center",
                resize = true,
                forced_width = dpi(64),
                forced_height = dpi(64),
                widget = wibox.widget.imagebox,
                id = "icon"
              },
              id = "place2",
              valing = "center",
              halign = "center",
              widget = wibox.container.place
            },
            { -- Temperature
              text = "0°C",
              valign = "center",
              align = "center",
              widget = wibox.widget.textbox,
              font = "JetBrains Mono Bold 24",
              id = "temp"
            },
            { -- City, Country
              text   = "City, Country",
              valign = "center",
              align  = "center",
              widget = wibox.widget.textbox,
              id     = "city_country",
            },
            {
              { -- Description
                text = "Description",
                valign = "center",
                align = "center",
                widget = wibox.widget.textbox,
                id = "description"
              },
              fg = Theme_config.notification_center.weather.description_fg,
              widget = wibox.container.background
            },
            { -- line
              forced_height = dpi(4),
              forced_width = dpi(10),
              bg = Theme_config.notification_center.weather.line_bg,
              widget = wibox.container.background,
              id = "line"
            },
            {
              { -- Speed
                {
                  image = gears.color.recolor_image(icondir .. "weather-windy.svg",
                    Theme_config.notification_center.weather.speed_icon_color),
                  resize = true,
                  forced_width = dpi(24),
                  forced_height = dpi(24),
                  valign = "center",
                  halign = "center",
                  widget = wibox.widget.imagebox
                },
                {
                  text = "",
                  valign = "center",
                  align = "center",
                  widget = wibox.widget.textbox,
                  id = "speed"
                },
                spacing = dpi(10),
                id = "layout3",
                layout = wibox.layout.fixed.horizontal
              },
              id = "place4",
              halign = "center",
              valign = "center",
              widget = wibox.container.place
            },
            {
              { -- Humidity
                {
                  forced_width = dpi(24),
                  forced_height = dpi(24),
                  widget = wibox.widget.imagebox,
                  valign = "center",
                  halign = "center",
                  image = gears.color.recolor_image(icondir .. "humidity.svg",
                    Theme_config.notification_center.weather.humidity_icon_color),
                  id = "humidity_icon"
                },
                {
                  text = "",
                  valign = "center",
                  align = "center",
                  widget = wibox.widget.textbox,
                  id = "humidity"
                },
                spacing = dpi(10),
                id = "layoutHum",
                layout = wibox.layout.fixed.horizontal
              },
              halign = "center",
              valign = "center",
              widget = wibox.container.place
            },
            id = "lyt",
            spacing = dpi(10),
            layout = wibox.layout.fixed.vertical
          },
          margins = dpi(20),
          widget = wibox.container.margin,
        },
        id = "center",
        halign = "center",
        valign = "center",
        widget = wibox.container.place
      },
      id = "background",
      border_color = Theme_config.notification_center.weather.border_color,
      border_width = Theme_config.notification_center.weather.border_width,
      shape = Theme_config.notification_center.weather.shape,
      widget = wibox.container.background
    },
    id = "margin",
    top = dpi(20),
    left = dpi(20),
    right = dpi(10),
    bottom = dpi(10),
    forced_width = dpi(250),
    widget = wibox.container.margin
  }

  local function fetch_weather_data()
    awful.spawn.easy_async_with_shell(
      "curl -sf 'http://api.openweathermap.org/data/2.5/weather?id=" ..
      api_secrets.city_id .. "&units=" .. api_secrets.unit .. "&appid=" .. api_secrets.key .. "'",
      function(stdout)
        if not stdout:match('error') then
          local weather_metadata = json_lua:decode(stdout)
          if weather_metadata then
            local temp = weather_metadata.main.temp
            local humidity = weather_metadata.main.humidity
            local city = weather_metadata.name
            local country = weather_metadata.sys.country
            local weather_icon = weather_metadata.weather[1].icon
            local description = weather_metadata.weather[1].description
            local speed = weather_metadata.wind.speed

            local icon_table = {
              ["01d"] = "weather-sunny",
              ["01n"] = "weather-clear-night",
              ["02d"] = "weather-partly-cloudy",
              ["02n"] = "weather-night-partly-cloudy",
              ["03d"] = "weather-cloudy",
              ["03n"] = "weather-clouds-night",
              ["04d"] = "weather-cloudy",
              ["04n"] = "weather-cloudy",
              ["09d"] = "weather-rainy",
              ["09n"] = "weather-rainy",
              ["10d"] = "weather-partly-rainy",
              ["10n"] = "weather-partly-rainy",
              ["11d"] = "weather-pouring",
              ["11n"] = "weather-pouring",
              ["13d"] = "weather-snowy",
              ["13n"] = "weather-snowy",
              ["50d"] = "weather-fog",
              ["50n"] = "weather-fog"
            }

            weather_widget:get_children_by_id("icon")[1].image = icondir .. icon_table[weather_icon] .. ".svg"
            weather_widget:get_children_by_id("temp")[1].text = math.floor(temp + 0.5) .. "°C"
            weather_widget:get_children_by_id("city_country")[1].text = city .. ", " .. country
            weather_widget:get_children_by_id("description")[1].text = description:sub(1, 1):upper() ..
                description:sub(2)
            weather_widget:get_children_by_id("line")[1].bg = Theme_config.notification_center.weather.line_color
            weather_widget:get_children_by_id("speed")[1].text = speed .. " m/s"
            weather_widget:get_children_by_id("humidity")[1].text = humidity .. "%"

          end
        end
      end
    )
  end

  fetch_weather_data()

  gears.timer {
    timeout = 900,
    autostart = true,
    callback = function()
      fetch_weather_data()
    end
  }

  return weather_widget

end
