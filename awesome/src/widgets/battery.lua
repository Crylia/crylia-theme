---@diagnostic disable: undefined-field
--------------------------------
-- This is the battery widget --
--------------------------------

-- Awesome Libs
local awful = require("awful")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local lgi = require("lgi")
local naughty = require("naughty")
local upower_glib = lgi.require("UPowerGlib")
local wibox = require("wibox")

require("src.core.signals")

-- Icon directory path
local icondir = awful.util.getdir("config") .. "src/assets/icons/battery/"

---Returns the battery widget
---@return wibox.widget
return function(battery_kind)

  -- Battery wibox.widget
  local battery_widget = wibox.widget {
    {
      {
        {
          {
            {
              id = "icon",
              image = gears.color.recolor_image(icondir .. "battery-unknown.svg", Theme_config.battery.fg),
              widget = wibox.widget.imagebox,
              valign = "center",
              halign = "center",
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
    bg = Theme_config.battery.bg,
    fg = Theme_config.battery.fg,
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(6))
    end,
    widget = wibox.container.background
  }

  -- Color change on mouse over
  Hover_signal(battery_widget, Theme_config.battery.bg, Theme_config.battery.fg)

  -- Open an energy manager on click
  battery_widget:connect_signal(
    'button::press',
    function()
      awful.spawn(User_config.energy_manager)
    end
  )

  ---Gets every enery device path
  ---@return table string battery device paths
  local function get_device_path()
    local paths = upower_glib.Client():get_devices()
    local path_table = {}
    for _, path in ipairs(paths) do
      table.insert(path_table, path:get_object_path())
    end
    return path_table
  end

  ---Takes a path and returns the glib object
  ---@param path string battery device path
  ---@return UPowerGlib.Device battery battery device object
  local function get_device_from_path(path)
    local devices = upower_glib.Client():get_devices()

    for _, device in ipairs(devices) do
      if device:get_object_path() == path then
        return device
      end
    end
    return nil
  end

  local tooltip = awful.tooltip {
    objects = { battery_widget },
    mode = "inside",
    preferred_alignments = "middle",
    margins = dpi(10)
  }

  ---Sets the battery information for the widget
  ---@param device UPowerGlib.Device battery
  local function set_battery(device)
    local battery_percentage = math.floor(device.percentage + 0.5)
    local battery_status = upower_glib.DeviceState[device.state]:lower()
    local battery_temp = device.temperature

    local battery_time = 1

    if device.time_to_empty ~= 0 then
      battery_time = device.time_to_empty
    else
      battery_time = device.time_to_full
    end

    local battery_string = math.floor(battery_time / 3600) .. "h, " .. math.floor((battery_time / 60) % 60) .. "m"

    if battery_temp == 0.0 then
      battery_temp = "NaN"
    else
      battery_temp = math.floor(battery_temp + 0.5) .. "°C"
    end

    if not battery_percentage then
      return
    end

    battery_widget:get_children_by_id("battery_layout")[1].spacing = dpi(5)
    battery_widget:get_children_by_id("label")[1].visible = true
    battery_widget:get_children_by_id("label")[1].text = battery_percentage .. '%'

    tooltip.markup = "<span foreground='#64ffda'>Battery Status:</span> <span foreground='#90caf9'>"
        .. battery_status .. "</span>\n<span foreground='#64ffda'>Remaining time:</span> <span foreground='#90caf9'>"
        .. battery_string .. "</span>\n<span foreground='#64ffda'>Temperature:</span> <span foreground='#90caf9'>"
        .. battery_temp .. "</span>"

    local icon = 'battery'

    if battery_status == 'fully-charged' or battery_status == 'charging' and battery_percentage == 100 then
      icon = icon .. '-' .. 'charging.svg'
      naughty.notification {
        title = "Battery notification",
        message = "Battery is fully charged",
        icon = icondir .. icon,
        timeout = 5
      }
      battery_widget:get_children_by_id("icon")[1].image = gears.surface.load_uncached(gears.color.recolor_image(icondir
        .. icon, Theme_config.battery.fg))
      return
    elseif battery_percentage > 0 and battery_percentage < 10 and battery_status == 'discharging' then
      icon = icon .. '-' .. 'alert.svg'
      naughty.notification {
        title = "Battery warning",
        message = "Battery is running low!\n" .. battery_percentage .. "% left",
        urgency = "critical",
        icon = icondir .. icon,
        timeout = 60
      }
      battery_widget:get_children_by_id("icon")[1].image = gears.surface.load_uncached(gears.color.recolor_image(icondir
        .. icon, Theme_config.battery.fg))
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

    battery_widget:get_children_by_id("icon")[1].image = gears.surface.load_uncached(gears.color.recolor_image(icondir ..
      icon .. '.svg', Theme_config.battery.fg))
    awesome.emit_signal("update::battery_widget", battery_percentage, icondir .. icon .. ".svg")

  end

  ---This function attaches a device path to the dbus interface
  ---It will only display on a widget if the user specified a device kind
  ---This device will then be filtered out and sent information to the widget itself
  ---The rest will only report in the background to other widgets e.g. Bluetooth devices
  ---Will report to the bluetooth widget.
  ---@param path string device path /org/freedesktop/...
  local function attach_to_device(path)
    local device_path = User_config.battery_path or path or ""

    battery_widget.device = get_device_from_path(device_path) or upower_glib.Client():get_display_device()

    battery_widget.device.on_notify = function(device)
      battery_widget:emit_signal("upower::update", device)
    end

    -- Check which device kind the user wants to display
    -- If there are multiple then the first is used
    if upower_glib.DeviceKind[battery_widget.device.kind] == battery_kind then
      set_battery(battery_widget.device)
    end

    -- The delayed call will fire every time awesome finishes its main event loop
    gears.timer.delayed_call(battery_widget.emit_signal, battery_widget, "upower::update", battery_widget.device)
  end

  for _, device in ipairs(get_device_path()) do
    attach_to_device(device)
  end

  battery_widget:connect_signal(
    "upower::update",
    function(_, device)
      if upower_glib.DeviceKind[battery_widget.device.kind] == battery_kind then
        set_battery(device)
      end
    end
  )

  return battery_widget
end
