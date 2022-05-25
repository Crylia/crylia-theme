--------------------------------
-- This is the battery widget --
--------------------------------
-- Awesome Libs
local awful = require("awful")
local color = require("src.theme.colors")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local naughty = require("naughty")
local watch = awful.widget.watch
local wibox = require("wibox")
require("src.core.signals")

-- Icon directory path
local icondir = awful.util.getdir("config") .. "src/assets/icons/battery/"

-- Returns the battery widget
return function()
  local battery_widget = wibox.widget {
    {
      {
        {
          {
            {
              id = "icon",
              image = gears.color.recolor_image(icondir .. "battery-unknown.svg", "#212121"),
              widget = wibox.widget.imagebox,
              resize = false
            },
            id = "icon_layout",
            widget = wibox.container.place
          },
          id = "icon_margin",
          top = dpi(2),
          widget = wibox.container.margin
        },
        spacing = dpi(10),
        {
          visible = false,
          align = 'center',
          valign = 'center',
          id = "label",
          widget = wibox.widget.textbox
        },
        id = "battery_layout",
        layout = wibox.layout.fixed.horizontal
      },
      id = "container",
      left = dpi(8),
      right = dpi(8),
      widget = wibox.container.margin
    },
    bg = color["Purple200"],
    fg = color["Grey900"],
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, 5)
    end,
    widget = wibox.container.background
  }

  local battery_tooltip = awful.tooltip {
    objects = { battery_widget },
    text = "",
    mode = "inside",
    preferred_alignments = "middle",
    margins = dpi(10)
  }

  local get_battery_info = function()
    awful.spawn.easy_async_with_shell(
      [[ upower -i $(upower -e | grep BAT) | grep "time to " ]],
      function(stdout)
        if stdout == nil or stdout == '' then
          battery_tooltip:set_text('No Battery Found')
          return
        end
        local rem_time = ""
        if stdout:match("hour") then
          rem_time = "Hours"
        else
          rem_time = "Minutes"
        end
        local bat_time = stdout:match("%d+,%d") or stdout:match("%d+.%d") or ""
        if stdout:match("empty") then
          battery_tooltip:set_text("Remaining battery time: " .. bat_time .. " " .. rem_time)
        elseif stdout:match("time to full") then
          battery_tooltip:set_text("Battery fully charged in: " .. bat_time .. " " .. rem_time)
        end
      end
    )
  end
  get_battery_info()

  local last_battery_check = os.time()
  local notify_critical_battery = true

  local battery_warning = function()
    naughty.notification {
      icon = gears.color.recolor_image(icondir .. "battery-alert.svg", color["White"]),
      app_name = "System notification",
      title = "Battery is low",
      message = "Battery is almost empty",
      urgency = "critical"
    }
  end

  local update_battery = function(status)
    awful.spawn.easy_async_with_shell(
      [[sh -c "upower -i $(upower -e | grep BAT) | grep percentage | awk '{print \$2}' |tr -d '\n%'"]],
      function(stdout)
        local battery_percentage = tonumber(stdout)

        if not battery_percentage then
          return
        end

        battery_widget.container.battery_layout.spacing = dpi(5)
        battery_widget.container.battery_layout.label.visible = true
        battery_widget.container.battery_layout.label:set_text(battery_percentage .. '%')

        local icon = 'battery'

        if status == 'fully-charged' or status == 'charging' and battery_percentage == 100 then
          icon = icon .. '-' .. 'charging'
          battery_widget.container.battery_layout.icon_margin.icon_layout.icon:set_image(gears.surface.load_uncached(
            gears.color.recolor_image(icondir .. icon .. '.svg', "#212121")))
          return
        end

        if battery_percentage > 0 and battery_percentage < 10 and status == 'discharging' then
          icon = icon .. '-' .. 'alert'
          if (os.difftime(os.time(), last_battery_check) > 300 or notify_critical_battery) then
            last_battery_check = os.time()
            notify_critical_battery = false
            battery_warning()
          end
          battery_widget.container.battery_layout.icon_margin.icon_layout.icon:set_image(gears.surface.load_uncached(
            gears.color.recolor_image(icondir .. icon .. '.svg', "#212121")))
          return
        end

        if battery_percentage > 0 and battery_percentage < 10 then
          icon = icon .. '-' .. status .. '-' .. 'outline'
        elseif battery_percentage >= 10 and battery_percentage < 20 then
          icon = icon .. '-' .. status .. '-' .. '10'
        elseif battery_percentage >= 20 and battery_percentage < 30 then
          icon = icon .. '-' .. status .. '-' .. '20'
        elseif battery_percentage >= 30 and battery_percentage < 40 then
          icon = icon .. '-' .. status .. '-' .. '30'
        elseif battery_percentage >= 40 and battery_percentage < 50 then
          icon = icon .. '-' .. status .. '-' .. '40'
        elseif battery_percentage >= 50 and battery_percentage < 60 then
          icon = icon .. '-' .. status .. '-' .. '50'
        elseif battery_percentage >= 60 and battery_percentage < 70 then
          icon = icon .. '-' .. status .. '-' .. '60'
        elseif battery_percentage >= 70 and battery_percentage < 80 then
          icon = icon .. '-' .. status .. '-' .. '70'
        elseif battery_percentage >= 80 and battery_percentage < 90 then
          icon = icon .. '-' .. status .. '-' .. '80'
        elseif battery_percentage >= 90 and battery_percentage < 100 then
          icon = icon .. '-' .. status .. '-' .. '90'
        end

        battery_widget.container.battery_layout.icon_margin.icon_layout.icon:set_image(gears.surface.load_uncached(
          gears.color.recolor_image(icondir .. icon .. '.svg', "#212121")))

      end
    )
  end

  Hover_signal(battery_widget, color["Purple200"], color["Grey900"])

  battery_widget:connect_signal(
    'button::press',
    function()
      awful.spawn("xfce4-power-manager-settings")
    end
  )

  battery_widget:connect_signal(
    "mouse::enter",
    function()
      get_battery_info()
    end
  )

  watch(
    [[sh -c "upower -i $(upower -e | grep BAT) | grep state | awk '{print \$2}' | tr -d '\n'"]],
    5,
    function(widget, stdout)
      local status = stdout:gsub('%\n', '')
      if status == nil or status == '' then
        battery_widget.container.battery_layout.spacing = dpi(0)
        battery_widget.container.battery_layout.label.visible = false
        battery_tooltip:set_text('No battery found')
        battery_widget.container.battery_layout.icon_margin.icon_layout.icon:set_image(gears.surface.load_uncached(
          gears.color.recolor_image(icondir .. 'battery-off' .. '.svg', "#212121")))
      end
      update_battery(status)
    end
  )

  return battery_widget
end
