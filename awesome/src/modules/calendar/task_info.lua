-- Awesome Libs
local awful = require("awful")
local dpi = require("beautiful").xresources.apply_dpi
local gcolor = require("gears.color")
local gtable = require("gears.table")
local gshape = require("gears.shape")
local gobject = require("gears.object")
local wibox = require("wibox")

local capi = {
  mouse = mouse,
}

local icondir = awful.util.getdir("config") .. "src/assets/icons/calendar/"

local task_info = { mt = {} }
task_info._private = {}

function task_info.new(args)
  args = args or {}
  if not args.task then return end
  args.screen = args.screen or awful.screen.focused()
  local ret = gobject {}
  gtable.crush(ret, task_info, true)

  local task_info_widget = wibox.widget {
    {
      { -- Task detail
        { -- Calendar color
          widget = wibox.container.background,
          shape = function(cr, _, height)
            gshape.rounded_rect(cr, dpi(10), height, dpi(8))
          end,
        },
        {
          { -- Summary
            widget = wibox.widget.textbox,
            text = ret.summary,
            valign = "center",
            align = "left",
            id = "summary",
          },
          { -- Date long
            widget = wibox.widget.textbox,
            text = ret.date_long,
            valign = "center",
            align = "right",
            id = "date_long",
          },
          { -- From - To
            widget = wibox.widget.textbox,
            text = ret.from_to,
            valign = "center",
            align = "left",
            id = "from_to",
          },
          { -- Repeat information
            widget = wibox.widget.textbox,
            text = ret.repeat_info,
            valign = "center",
            align = "right",
            id = "repeat_info",
          },
          layout = wibox.layout.fixed.vertical,
        },
        layout = wibox.layout.fixed.horizontal
      },
      { -- Location
        {
          widget = wibox.widget.imagebox,
          image = gcolor.recolor_image(icondir .. "location.svg", Theme_config.calendar.task_info.location_icon_color),
          resize = false,
          valign = "center",
          halign = "center",
        },
        {
          widget = wibox.widget.textbox,
          text = ret.location,
          valign = "center",
          align = "left",
          id = "location",
        },
        id = "location_container",
        layout = wibox.layout.fixed.horizontal
      },
      { -- Alarm
        {
          widget = wibox.widget.imagebox,
          image = gcolor.recolor_image(icondir .. "alarm.svg", Theme_config.calendar.task_info.alarm_icon_color),
          resize = false,
          valign = "center",
          halign = "center",
        },
        {
          widget = wibox.widget.textbox,
          text = ret.alarm,
          valign = "center",
          align = "left",
          id = "alarm",
        },
        id = "alarm_container",
        layout = wibox.layout.fixed.horizontal
      },
      id = "task_detail",
      layout = wibox.layout.fixed.vertical
    },
    bg = Theme_config.calendar.task_info.bg,
    fg = Theme_config.calendar.task_info.fg,
    shape = Theme_config.calendar.task_info.shape,
    widget = wibox.container.background,
  }

  ret.widget = awful.popup {
    widget = task_info_widget,
    ontop = true,
    visible = true,
    bg = "#00000000",
    x = capi.mouse.coords().x,
    y = capi.mouse.coords().y,
    screen = args.screen
  }

end

function task_info.mt:__call(...)
  task_info.new(...)
end

return setmetatable(task_info, task_info.mt)
