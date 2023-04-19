local ipairs = ipairs
local mfloor = math.floor
local setmetatable = setmetatable

-- Awesome Libs
local aspawn = require('awful.spawn')
local atooltip = require('awful.tooltip')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi
local gcolor = require('gears.color')
local gfilesystem = require('gears.filesystem')
local gsurface = require('gears.surface')
local gtimer = require('gears.timer')
local lgi = require('lgi')
local nnotification = require('naughty.notification')
local upower_glib = lgi.require('UPowerGlib')
local wibox = require('wibox')

-- Local libs
local hover = require('src.tools.hover')

local capi = {
  awesome = awesome,
}

-- Icon directory path
local icondir = gfilesystem.get_configuration_dir() .. 'src/assets/icons/battery/'

local instance = nil
if not instance then
  instance = setmetatable({}, {
    __call = function(_, battery_kind)
      local battery_widget = wibox.widget {
        {
          {
            {
              {
                {
                  id = 'icon',
                  image = gcolor.recolor_image(icondir .. 'battery-unknown.svg', beautiful.colorscheme.fg_dark),
                  widget = wibox.widget.imagebox,
                  valign = 'center',
                  halign = 'center',
                  resize = false,
                },
                id = 'icon_layout',
                widget = wibox.container.place,
              },
              id = 'icon_margin',
              top = dpi(2),
              widget = wibox.container.margin,
            },
            spacing = dpi(10),
            {
              visible = false,
              align = 'center',
              valign = 'center',
              id = 'label',
              widget = wibox.widget.textbox,
            },
            id = 'battery_layout',
            layout = wibox.layout.fixed.horizontal,
          },
          id = 'container',
          left = dpi(8),
          right = dpi(8),
          widget = wibox.container.margin,
        },
        bg = beautiful.colorscheme.bg_purple,
        fg = beautiful.colorscheme.fg_dark,
        shape = beautiful.shape[6],
        widget = wibox.container.background,
      }

      hover.bg_hover { widget = battery_widget }

      battery_widget:connect_signal('button::press', function()
        aspawn(beautiful.user_config.energy_manager)
      end)

      local function get_device_path()
        local paths = upower_glib.Client():get_devices()
        local path_table = {}
        for _, path in ipairs(paths) do
          table.insert(path_table, path:get_object_path())
        end
        return path_table
      end

      local function get_device_from_path(path)
        local devices = upower_glib.Client():get_devices()

        for _, device in ipairs(devices) do
          if device:get_object_path() == path then
            return device
          end
        end
        return nil
      end

      local tooltip = atooltip {
        objects = { battery_widget },
        mode = 'inside',
        preferred_alignments = 'middle',
        margins = dpi(10),
      }

      ---Sets the battery information for the widget
      ---@param device UPowerGlib.Device battery
      local function set_battery(device)
        local battery_percentage = mfloor(device.percentage + 0.5)
        local battery_status = upower_glib.DeviceState[device.state]:lower()
        local battery_temp = device.temperature

        local battery_time = 1

        if device.time_to_empty ~= 0 then
          battery_time = device.time_to_empty
        else
          battery_time = device.time_to_full
        end

        local battery_string = mfloor(battery_time / 3600) .. 'h, ' .. mfloor((battery_time / 60) % 60) .. 'm'

        if battery_temp == 0.0 then
          battery_temp = 'NaN'
        else
          battery_temp = mfloor(battery_temp + 0.5) .. '°C'
        end

        if not battery_percentage then
          return
        end

        battery_widget:get_children_by_id('battery_layout')[1].spacing = dpi(5)
        battery_widget:get_children_by_id('label')[1].visible = true
        battery_widget:get_children_by_id('label')[1].text = battery_percentage .. '%'

        tooltip.markup = "<span foreground='" .. beautiful.colorscheme.bg_teal .. "'>Battery Status:</span> <span foreground='" .. beautiful.colorscheme.fg .. "'>"
            .. battery_status .. "</span>\n<span foreground='" .. beautiful.colorscheme.bg_teal .. "'>Remaining time:</span> <span foreground='" .. beautiful.colorscheme.fg .. "'>"
            .. battery_string .. "</span>\n<span foreground='" .. beautiful.colorscheme.bg_teal .. "'>Temperature:</span> <span foreground='" .. beautiful.colorscheme.fg .. "'>"
            .. battery_temp .. '</span>'

        local icon = 'battery'

        if battery_status == 'fully-charged' or battery_status == 'charging' and battery_percentage == 100 then
          icon = icon .. '-' .. 'charging.svg'
          nnotification {
            title = 'Battery notification',
            message = 'Battery is fully charged',
            icon = icondir .. icon,
            timeout = 5,
          }
          battery_widget:get_children_by_id('icon')[1].image = gsurface.load_uncached(gcolor.recolor_image(icondir
            .. icon, beautiful.colorscheme.fg_dark))
          return
        elseif battery_percentage > 0 and battery_percentage < 10 and battery_status == 'discharging' then
          icon = icon .. '-' .. 'alert.svg'
          nnotification {
            title = 'Battery warning',
            message = 'Battery is running low!\n' .. battery_percentage .. '% left',
            urgency = 'critical',
            icon = icondir .. icon,
            timeout = 60,
          }
          battery_widget:get_children_by_id('icon')[1].image = gsurface.load_uncached(gcolor.recolor_image(icondir
            .. icon, beautiful.colorscheme.fg_dark))
          return
        end

        if battery_percentage > 0 and battery_percentage < 10 then
          icon = icon .. '-' .. battery_status .. '-' .. 'outline'
        elseif battery_percentage >= 10 and battery_percentage < 20 then
          icon = icon .. '-' .. battery_status .. '-' .. '10'
        elseif battery_percentage >= 20 and battery_percentage < 30 then
          icon = icon .. '-' .. battery_status .. '-' .. '20'
        elseif battery_percentage >= 30 and battery_percentage < 40 then
          icon = icon .. '-' .. battery_status .. '-' .. '30'
        elseif battery_percentage >= 40 and battery_percentage < 50 then
          icon = icon .. '-' .. battery_status .. '-' .. '40'
        elseif battery_percentage >= 50 and battery_percentage < 60 then
          icon = icon .. '-' .. battery_status .. '-' .. '50'
        elseif battery_percentage >= 60 and battery_percentage < 70 then
          icon = icon .. '-' .. battery_status .. '-' .. '60'
        elseif battery_percentage >= 70 and battery_percentage < 80 then
          icon = icon .. '-' .. battery_status .. '-' .. '70'
        elseif battery_percentage >= 80 and battery_percentage < 90 then
          icon = icon .. '-' .. battery_status .. '-' .. '80'
        elseif battery_percentage >= 90 and battery_percentage < 100 then
          icon = icon .. '-' .. battery_status .. '-' .. '90'
        end

        battery_widget:get_children_by_id('icon')[1].image = gsurface.load_uncached(gcolor.recolor_image(icondir ..
          icon .. '.svg', beautiful.colorscheme.fg_dark))
        capi.awesome.emit_signal('update::battery_widget', battery_percentage, icondir .. icon .. '.svg')
      end

      local function attach_to_device(path)
        local device_path = beautiful.user_config.battery_path or path or ''

        battery_widget.device = get_device_from_path(device_path) or upower_glib.Client():get_display_device()

        battery_widget.device.on_notify = function(device)
          battery_widget:emit_signal('upower::update', device)
        end

        if upower_glib.DeviceKind[battery_widget.device.kind] == battery_kind then
          set_battery(battery_widget.device)
        end

        gtimer.delayed_call(battery_widget.emit_signal, battery_widget, 'upower::update', battery_widget.device)
      end

      for _, device in ipairs(get_device_path()) do
        attach_to_device(device)
      end

      battery_widget:connect_signal('upower::update', function(_, device)
        if upower_glib.DeviceKind[battery_widget.device.kind] == battery_kind then
          set_battery(device)
        end
      end)

      return battery_widget
    end,
  })
end
return instance
