-- Awesome Libs
local awful = require('awful')
local beautiful = require('beautiful')
local dpi = require('beautiful').xresources.apply_dpi
local gcolor = require('gears.color')
local gtable = require('gears.table')
local gshape = require('gears.shape')
local gobject = require('gears.object')
local gfilesystem = require('gears').filesystem
local wibox = require('wibox')

local hover = require('src.tools.hover')

local icondir = gfilesystem.get_configuration_dir() .. 'src/assets/icons/calendar/'

local task_info = { mt = {} }
task_info._private = {}

function task_info.new(args)
  args = args or {}
  if not args.task then return end
  local ret = gobject {}
  gtable.crush(ret, task_info, true)

  args.color = args.color or beautiful.colorscheme.fg

  local date_long_written = os.date('%A, %d. %B %Y', os.time(args.date_start))

  local from_to = os.date('%H:%M', os.time(args.date_start)) .. ' - ' .. os.date('%H:%M', os.time(args.date_end))

  local task_info_widget = wibox.widget {
    {
      {
        {
          { -- Task detail
            { -- Calendar color
              widget = wibox.container.background,
              bg = args.color,
              forced_width = dpi(10),
              shape = function(cr, _, height)
                gshape.rounded_rect(cr, dpi(10), height, dpi(8))
              end,
            },
            {
              { -- Summary
                widget = wibox.widget.textbox,
                text = args.summary:sub(1, -2) or 'NO SUMMARY',
                valign = 'center',
                halign = 'left',
                id = 'summary',
              },
              { -- Date long
                widget = wibox.widget.textbox,
                text = date_long_written or '01.12.1970',
                valign = 'center',
                halign = 'right',
                id = 'date_long',
              },
              { -- From - To
                widget = wibox.widget.textbox,
                text = from_to or '',
                valign = 'center',
                halign = 'left',
                id = 'from_to',
              },
              { -- Repeat information
                widget = wibox.widget.textbox,
                text = args.freq or '0',
                valign = 'center',
                halign = 'left',
                id = 'repeat_info',
              }, -- Year
              {
                widget = wibox.widget.textbox,
                text = args.date_start.year or '1970',
                valign = 'center',
                halign = 'left',
                id = 'year',
              },
              spacing = dpi(10),
              layout = wibox.layout.fixed.vertical,
            },
            spacing = dpi(20),
            layout = wibox.layout.fixed.horizontal,
          },
          widget = wibox.container.margin,
          left = dpi(9),
        },
        { -- Location
          {
            widget = wibox.widget.imagebox,
            image = gcolor.recolor_image(icondir .. 'location.svg', args.color),
            resize = false,
            valign = 'center',
            halign = 'center',
          },
          {
            widget = wibox.widget.textbox,
            text = args.location:sub(1, -2) or 'F303',
            valign = 'center',
            halign = 'left',
            id = 'location',
          },
          spacing = dpi(10),
          id = 'location_container',
          layout = wibox.layout.fixed.horizontal,
        },
        { -- Alarm
          {
            widget = wibox.widget.imagebox,
            image = gcolor.recolor_image(icondir .. 'alarm.svg', args.color),
            resize = false,
            valign = 'center',
            halign = 'center',
          },
          {
            widget = wibox.widget.textbox,
            text = args.alarm or 'NO ALARM',
            valign = 'center',
            halign = 'left',
            id = 'alarm',
          },
          spacing = dpi(10),
          id = 'alarm_container',
          layout = wibox.layout.fixed.horizontal,
        },
        id = 'task_detail',
        spacing = dpi(15),
        layout = wibox.layout.fixed.vertical,
      },
      widget = wibox.container.margin,
      left = dpi(6),
      right = dpi(15),
      top = dpi(15),
      bottom = dpi(15),
    },
    bg = beautiful.colorscheme.bg,
    fg = beautiful.colorscheme.fg,
    shape = beautiful.shape[12],
    widget = wibox.container.background,
  }

  hover.bg_hover { widget = task_info_widget }

  ret.widget = task_info_widget

  return ret.widget
end

function task_info.mt:__call(...)
  return task_info.new(...)
end

return setmetatable(task_info, task_info.mt)
