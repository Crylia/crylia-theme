---------------------------------
-- This is the CPU Info widget --
---------------------------------

-- Awesome Libs
local awful = require("awful")
local color = require("src.theme.colors")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local watch = awful.widget.watch
local wibox = require("wibox")
require("src.core.signals")

local icon_dir = awful.util.getdir("config") .. "src/assets/icons/cpu/"

--TODO: Add tooltip with more CPU and per core information
return function(widget, clock_mode)

  local cpu_usage_widget = wibox.widget {
    {
      {
        {
          {
            {
              id = "icon",
              widget = wibox.widget.imagebox,
              image = gears.color.recolor_image(icon_dir .. "cpu.svg", color["Grey900"]),
              resize = false
            },
            id = "icon_layout",
            widget = wibox.container.place
          },
          top = dpi(2),
          widget = wibox.container.margin,
          id = "icon_margin"
        },
        spacing = dpi(10),
        {
          id = "label",
          align = "center",
          valign = "center",
          widget = wibox.widget.textbox
        },
        id = "cpu_layout",
        layout = wibox.layout.fixed.horizontal
      },
      id = "container",
      left = dpi(8),
      right = dpi(8),
      widget = wibox.container.margin
    },
    bg = color["Blue200"],
    fg = color["Grey900"],
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, 5)
    end,
    widget = wibox.container.background
  }

  local cpu_temp = wibox.widget {
    {
      {
        {
          {
            {
              id = "icon",
              widget = wibox.widget.imagebox,
              resize = false
            },
            id = "icon_layout",
            widget = wibox.container.place
          },
          top = dpi(2),
          widget = wibox.container.margin,
          id = "icon_margin"
        },
        spacing = dpi(10),
        {
          id = "label",
          align = "center",
          valign = "center",
          widget = wibox.widget.textbox
        },
        id = "cpu_layout",
        layout = wibox.layout.fixed.horizontal
      },
      id = "container",
      left = dpi(8),
      right = dpi(8),
      widget = wibox.container.margin
    },
    bg = color["Green200"],
    fg = color["Grey900"],
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, 5)
    end,
    widget = wibox.container.background
  }

  local cpu_clock = wibox.widget {
    {
      {
        {
          {
            {
              id = "icon",
              widget = wibox.widget.imagebox,
              image = icon_dir .. "cpu.svg",
              resize = false
            },
            id = "icon_layout",
            widget = wibox.container.place
          },
          top = dpi(2),
          widget = wibox.container.margin,
          id = "icon_margin"
        },
        spacing = dpi(10),
        {
          id = "label",
          align = "center",
          valign = "center",
          widget = wibox.widget.textbox
        },
        id = "cpu_layout",
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

  local total_prev = 0
  local idle_prev = 0

  watch(
    [[ cat "/proc/stat" | grep '^cpu ' ]],
    3,
    function(_, stdout)
      local user, nice, system, idle, iowait, irq, softirq, steal, guest, guest_nice =
      stdout:match("(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s")

      local total = user + nice + system + idle + iowait + irq + softirq + steal

      local diff_idle = idle - idle_prev
      local diff_total = total - total_prev
      local diff_usage = (1000 * (diff_total - diff_idle) / diff_total + 5) / 10

      cpu_usage_widget.container.cpu_layout.label.text = tostring(math.floor(diff_usage)) .. "%"

      total_prev = total
      idle_prev = idle
      collectgarbage("collect")
    end
  )

  watch(
    [[ bash -c "sensors | grep 'Package id 0:' | awk '{print $4}'" ]],
    3,
    function(_, stdout)

      local temp_icon
      local temp_color

      local temp_num = tonumber(stdout:match("%d+"))
      if temp_num < 50 then
        temp_color = color["Green200"]
        temp_icon = icon_dir .. "thermometer-low.svg"
      elseif temp_num >= 50 and temp_num < 80 then
        temp_color = color["Orange200"]
        temp_icon = icon_dir .. "thermometer.svg"
      elseif temp_num >= 80 then
        temp_color = color["Red200"]
        temp_icon = icon_dir .. "thermometer-high.svg"
      end
      Hover_signal(cpu_temp, temp_color, color["Grey900"])
      cpu_temp.container.cpu_layout.icon_margin.icon_layout.icon:set_image(temp_icon)
      cpu_temp:set_bg(temp_color)
      cpu_temp.container.cpu_layout.label.text = math.floor(temp_num) .. "°C"
    end
  )

  watch(
    [[ bash -c "cat /proc/cpuinfo | grep "MHz" | awk '{print int($4)}'" ]],
    3,
    function(_, stdout)
      local cpu_freq = {}

      for value in stdout:gmatch("%d+") do
        table.insert(cpu_freq, value)
      end

      local average = 0

      if clock_mode == "average" then
        for i = 1, #cpu_freq do
          average = average + cpu_freq[i]
        end
        average = math.floor(average / #cpu_freq)
        cpu_clock.container.cpu_layout.label.text = tonumber(average) .. "Mhz"
      elseif clock_mode then
        cpu_clock.container.cpu_layout.label.text = tonumber(cpu_freq[clock_mode]) .. "Mhz"
      end
    end
  )

  Hover_signal(cpu_usage_widget, color["Blue200"], color["Grey900"])
  Hover_signal(cpu_clock, color["Purple200"], color["Grey900"])

  if widget == "usage" then
    return cpu_usage_widget
  elseif widget == "temp" then
    return cpu_temp
  elseif widget == "freq" then
    return cpu_clock
  end

end
