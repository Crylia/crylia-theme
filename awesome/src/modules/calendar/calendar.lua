--------------------------------------
-- This is the application launcher --
--------------------------------------

-- Awesome Libs
local awful = require("awful")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")
local ical_parser = require("src.tools.ical_parser")

local capi = {
  awesome = awesome,
  mouse = mouse,
}

local icondir = awful.util.getdir("config") .. "src/assets/icons/calendar/"

--- Month name lookup table
local months_table = {
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December",
  "January",
  "February",
}

--- Table to easily shift back every month by two months
local month_convert = {
  11,
  12,
  1,
  2,
  3,
  4,
  5,
  6,
  7,
  8,
  9,
  10,
}

--- Weekdays name lookup table
local weekdays_table = {
  "Mon",
  "Tue",
  "Wed",
  "Thu",
  "Fri",
  "Sat",
  "Sun",
}

--- Create a date object from the current date
local os_date = os.date("%d%m%Y")
local date = {
  day = math.floor(os_date:sub(1, 2)),
  month = month_convert[math.floor(os_date:sub(3, 4))],
  year = math.floor(os_date:sub(5, 8))
}

---Calculates the weekday of a given date
---@param day number|string? as number, usually from date.da
---@param month number|string? as number, usually from date.month
---@param year number|string? as number, usually from date.year
---@return number|nil weekday as number
local function get_date_weekday(day, month, year)
  if not (day and month and year) then return end

  if (month == 11) or (month == 12) then
    year = year - 1
  end

  -- No idea how the algorithm works, but since it works -> don't touch it!
  local w = ((day + math.floor(2.6 * month - 0.2) - 2 * tonumber(tostring(year):match("([0-9]+)[0-9][0-9]")) +
      tonumber(tostring(year):match("[0-9][0-9]([0-9]+)")) +
      math.floor(tonumber(tostring(year):match("[0-9][0-9]([0-9]+)")) / 4) +
      math.floor(tonumber(tostring(year):match("([0-9]+)[0-9][0-9]")) / 4)) % 7)
  --TODO: Add user variable to choose between Sunday and Monday weekstart
  if w == 0 then w = 7 end
  return w
end

---Returns the length of the month from a lookup table and also check for leap years
---@param month number? as number, usually from date.month, can also be a string
---@param year number? as number, usually from date.year, can also be a string
---@return integer|nil month_length as integer
local function get_last_day_of_month(month, year)
  if not (month and year) then return end

  month = tonumber(month)
  local last_day = {
    31,
    30,
    31,
    30,
    31,
    31,
    30,
    31,
    30,
    31,
    31,
    28,
  }
  --In this calculcation February is the 12th of last year
  if (month == 12) and (math.floor(year % 4) == 0) then
    return 29
  else
    return last_day[month]
  end
end

---Simple function to calculate how many weeks will need to be displayed in a calendar
---@param month number? as number, usually from date.month, can also be a string
---@param year number? as number, usually from date.year, can also be a string
---@return number|nil weeks ammount of weeks between 4-6
local function get_weeks_in_month(month, year)
  if not (month and year) then return end
  return math.ceil((get_last_day_of_month(month, year) + get_date_weekday(1, month, year) - 1) / 7)
end

---Gets the last month and accounts for year changes
---@param d table date object
---@return table|nil date returns a date object
local function get_last_month(d)
  if not (d) then return end
  if d.month == 1 then
    return { month = 12, year = d.year - 1 }
  else
    return { month = d.month - 1, year = d.year }
  end
end

---Simple function to create a widget 7x for each day of the week
---@return table weeks_widget All weekdays names as a widget
local function create_weekdays()
  local weekdays = { layout = wibox.layout.flex.horizontal }
  for i = 1, 7 do
    table.insert(weekdays, wibox.widget {
      {
        text = weekdays_table[i],
        align = "center",
        valign = "center",
        widget = wibox.widget.textbox,
      },
      bg = Theme_config.calendar.weekdays.bg,
      fg = Theme_config.calendar.weekdays.fg,
      widget = wibox.container.background,
    })
  end
  return weekdays
end

---Create tasks from ical object
---@return table|nil tasks All tasks as a table
local function create_tasks()
  if not ical_parser or not ical_parser.VCALENDAR then return end
  local tasks = {}
  --TODO: Initialize the timezone from ical.VCALENDAR.VTIMEZONE and make sure the time is correct

  -- Sort every VEVENT in ical by date into the tasks table.
  for _, calendar in ipairs(ical_parser.VCALENDAR) do
    for _, event in ipairs(calendar.VEVENT) do
      local start_time = event.DTSTART.DTSTART
      start_time.month = month_convert[start_time.month]
      local end_time
      if event.DTEND then
        end_time = event.DTEND.DTEND
        end_time.month = month_convert[end_time.month]
      end

      if event.RRULE then
        if event.RRULE.FREQ == "DAILY" then
        elseif event.RRULE.FREQ == "WEEKLY" then
          -- An event will always start on the day it first occurs.
          local event_start = start_time
          local event_end = event.RRULE.UNTIL

          local year_counter = event_start.year
          local month_counter = event_start.month
          if month_counter == 11 then
            year_counter = year_counter - 1
          elseif month_counter == 12 then
            year_counter = year_counter - 1
          end
          local day_counter = event_start.day
          local task = {}
          while (year_counter <= event_end.year) or (month_counter <= event_end.month) or (day_counter <= event_end.day) do
            -- First event will always be right since we start on its starting day
            task = {
              date_start = {
                year = year_counter,
                month = month_counter,
                day = day_counter,
                hour = event_start.hour or 0,
                minute = event_start.minute or 0,
                second = event_start.second or 0
              },
              date_end = {
                year = year_counter,
                month = month_counter,
                day = day_counter,
                hour = end_time.hour or 0,
                minute = end_time.minute or 0,
                second = end_time.second or 0
              },
              summary = event.SUMMARY,
              location = event.LOCATION,
            }

            if event.VALARM then
              task.alarm = {
                time = event.VALARM.TRIGGER.TRIGGER
              }
              local alarm_time = task.alarm.time:match("([-]?%d+)")
              local alarm_unit = task.alarm.time:match("(%a)")
              if alarm_unit == "W" then
                alarm_time = alarm_time * 604800
              elseif alarm_unit == "D" then
                alarm_time = alarm_time * 86400
              elseif alarm_unit == "H" then
                alarm_time = alarm_time * 3600
              elseif alarm_unit == "M" then
                alarm_time = alarm_time * 60
              end

              --[[ gears.timer {
              autostart = true,
              callback = function()
                if alarm_time then
                  require("naughty").notification {
                    app_name = "Task Alarm",
                    title = task.summary,
                    message = task.description,
                    urgency = "normal",
                    timeout = 5,
                    icon = icondir .. "/alarm.png",
                  }
                  gears.timer:stop()
                end
              end
            } ]]
            end

            table.insert(tasks, task)

            day_counter = day_counter + 7
            local month_length = get_last_day_of_month(month_counter, year_counter)
            if day_counter > month_length then
              day_counter = day_counter - month_length
              month_counter = month_counter + 1
            end
            if month_counter == 11 then
              year_counter = year_counter + 1
            end
            if month_counter > 13 then
              month_counter = 1
            end
          end
        elseif event.RRULE.FREQ == "MONTHLY" then
        elseif event.RRULE.FREQ == "YEARLY" then
          if not end_time then
            end_time = {
              year = start_time.year + 1000,
            }
          end

          local task = {}
          for i = start_time.year, end_time.year, 1 do
            task = {
              date_start = {
                year = i,
                month = start_time.month,
                day = start_time.day,
                hour = start_time.hour or 0,
                minute = start_time.minute or 0,
                second = start_time.second or 0
              },
              date_end = {
                year = i,
                month = start_time.month,
                day = start_time.day,
                hour = end_time.hour or 0,
                minute = end_time.minute or 0,
                second = end_time.second or 0
              },
              summary = event.SUMMARY,
              location = event.LOCATION,
              description = event.DESCRIPTION,
              url = event.URL,
            }

            if event.VALARM then
              task.alarm = {
                time = event.VALARM.TRIGGER.TRIGGER
              }
              local alarm_time = task.alarm.time:match("([-]?%d+)")
              local alarm_unit = task.alarm.time:match("(%a)")
              if alarm_unit == "W" then
                alarm_time = alarm_time * 604800
              elseif alarm_unit == "D" then
                alarm_time = alarm_time * 86400
              elseif alarm_unit == "H" then
                alarm_time = alarm_time * 3600
              elseif alarm_unit == "M" then
                alarm_time = alarm_time * 60
              end

              --[[ gears.timer {
              timeout = os.time(task.date_start) - os.time() + alarm_time,
              autostart = true,
              callback = function()
                require("naughty").notification {
                  app_name = "Task Alarm",
                  title = task.summary,
                  message = task.description,
                  urgency = "normal",
                  timeout = 5,
                  icon = icondir .. "/alarm.png",
                }
              end
            } ]]
            end

            table.insert(tasks, task)
          end
        end
      else
        local task = {
          date_start = {
            year = start_time.year,
            month = start_time.month,
            day = start_time.day,
            hour = start_time.hour or 0,
            minute = start_time.minute or 0,
            second = start_time.second or 0
          },
          date_end = {
            year = start_time.year,
            month = start_time.month,
            day = start_time.day,
            hour = start_time.hour or 0,
            minute = start_time.minute or 0,
            second = start_time.second or 0
          },
          summary = event.SUMMARY,
          location = event.LOCATION,
          description = event.DESCRIPTION,
          url = event.URL,
        }

        if event.VALARM then
          task.alarm = {
            time = event.VALARM.TRIGGER.TRIGGER
          }
          local alarm_time = task.alarm.time:match("([-]?%d+)")
          local alarm_unit = task.alarm.time:match("(%a)")
          if alarm_unit == "W" then
            alarm_time = alarm_time * 604800
          elseif alarm_unit == "D" then
            alarm_time = alarm_time * 86400
          elseif alarm_unit == "H" then
            alarm_time = alarm_time * 3600
          elseif alarm_unit == "M" then
            alarm_time = alarm_time * 60
          end

          --[[ gears.timer {
          timeout = os.time(task.date_start) - os.time() + alarm_time,
          autostart = true,
          callback = function()
            require("naughty").notification {
              app_name = "Task Alarm",
              title = task.summary,
              message = task.description,
              urgency = "normal",
              timeout = 5,
              icon = icondir .. "/alarm.png",
            }
          end
        } ]]
        end
        table.insert(tasks, task)
      end
    end
  end

  return tasks
end

local tasks = create_tasks()

local selected_day = {
  year = date.year,
  month = date.month,
  day = date.day,
  col = 1,
  row = 1,
}

return function(s)
  -- The calendar grid
  local calendar_matrix = wibox.widget { layout = wibox.layout.grid, spacing = dpi(2) }

  local weeks = wibox.widget { layout = wibox.layout.fixed.vertical }

  ---Main function to create the calendar widget
  ---Probably needs some refractor at some point since it's a bit messy
  ---@return wibox.widget calendar_widget
  local function create_calendar()

    calendar_matrix:reset()

    --- Months table holds every month with their starting week day, length(30/31 or 28/29), the last week day and the name
    local months = {}
    for m_num, month in ipairs(months_table) do
      months[m_num] = {
        name = month,
        first_day = get_date_weekday("01", m_num, date.year),
        length = get_last_day_of_month(m_num, date.year),
        last_day = get_date_weekday(get_last_day_of_month(m_num, date.year), m_num, date.year),
        weeks = get_weeks_in_month(m_num, date.year)
      }
    end

    local function get_tasks_for_day(day, month, year)
      if not tasks or #tasks == 0 then return end
      local tasks_layout = {
        layout = require("src.lib.overflow_widget.overflow").vertical,
        scrollbar_width = 0,
        step = dpi(50),
        spacing = dpi(2)
      }
      for _, task in ipairs(tasks) do
        if (task.date_start.year == year) and (task.date_start.month == month) and (task.date_start.day == day) then
          table.insert(tasks_layout, wibox.widget {
            {
              {
                text = task.summary,
                align = "left",
                halign = "center",
                font = "JetBrainsMono Nerd Font, bold 10",
                widget = wibox.widget.textbox
              },
              margins = dpi(2),
              widget = wibox.container.margin
            },
            fg = Theme_config.calendar.task.fg,
            bg = Theme_config.calendar.task.bg,
            shape = Theme_config.calendar.task.shape,
            forced_height = dpi(20),
            widget = wibox.container.background
          })
        end
      end
      return tasks_layout
    end

    if months[date.month].first_day ~= 1 then
      -- Fill previous month days, i doubles as the day
      local column = 1
      local last_month = get_last_month(date)
      local prev_month = date.month
      local prev_year = date.year
      if date.month == 1 then
        prev_month = 12
        last_month = months[12].length
      else
        last_month = months[date.month - 1].length
      end
      if date.month == 11 then
        prev_year = date.year - 1
      end
      prev_month = prev_month - 1
      for i = last_month - months[date.month].first_day + 2, last_month, 1 do
        local border = Theme_config.calendar.day.border_color
        local bg = Theme_config.calendar.day.bg_unfocus
        local fg = Theme_config.calendar.day.fg_unfocus
        if column == selected_day.col and 1 == selected_day.row then
          border = Theme_config.calendar.day.today_border_color
          bg = Theme_config.calendar.day.today_bg_focus
          fg = Theme_config.calendar.day.today_fg_focus
        end
        local y = tonumber(os.date("%Y"))
        local m = month_convert[tonumber(os.date("%m"))]
        if m == 1 then
          m = 12
        end
        if (i == date.day) and (m == prev_month) and (date.year == y) then
          bg = Theme_config.calendar.day.bg_focus
          fg = Theme_config.calendar.day.fg_focus
        end
        local day = wibox.widget {
          {
            {
              {
                {
                  {
                    {
                      { -- Day
                        widget = wibox.widget.textbox,
                        align = "center",
                        valign = "center",
                        text = math.floor(i),
                        id = "day_text",
                      },
                      widget = wibox.container.margin,
                      margins = dpi(2),
                    },
                    id = "day_bg",
                    widget = wibox.container.background,
                    bg = bg,
                    shape = Theme_config.calendar.day.shape,
                    fg = fg,
                  },
                  widget = wibox.container.place,
                  valign = "center",
                  halign = "center",
                },
                {
                  get_tasks_for_day(math.floor(i), prev_month, prev_year),
                  widget = wibox.container.margin,
                  margins = dpi(4)
                },
                id = "tasks",
                spacing = dpi(4),
                layout = wibox.layout.fixed.vertical
              },
              widget = wibox.container.margin,
              top = dpi(4)
            },
            id = "background",
            widget = wibox.container.background,
            bg = Theme_config.calendar.day.bg_unfocus,
            fg = Theme_config.calendar.day.fg_unfocus,
            border_color = border,
            border_width = Theme_config.calendar.day.border_width,
            shape = function(cr, width, height)
              gears.shape.rounded_rect(cr, width, height, dpi(8))
            end
          },
          widget = wibox.container.constraint,
          width = dpi(100),
          height = dpi(120),
          strategy = "exact"
        }

        -- update selected_day if the day is clicked
        day:buttons(
          gears.table.join(
            awful.button({}, 1, function()
              selected_day.col = column
              selected_day.row = 1
              day:emit_signal("day::update_selected")
            end)
          )
        )

        day:connect_signal("day::update_selected", function()
          if column == selected_day.col and 1 == selected_day.row then
            capi.awesome.emit_signal("day::reset_border")
            day.background.border_color = Theme_config.calendar.day.today_border_color
          end
        end)

        capi.awesome.connect_signal("day::reset_border", function()
          day.background.border_color = Theme_config.calendar.day.border_color
        end)

        calendar_matrix:add_widget_at(day, 1, column)
        column = column + 1
      end
    end

    --Actual month days
    local row = 1
    local col = months[date.month].first_day
    for i = 1, months[date.month].length, 1 do

      local border = Theme_config.calendar.day.border_color
      local fg = Theme_config.calendar.day.fg
      local bg = Theme_config.calendar.day.bg
      if col == selected_day.col and row == selected_day.row then
        border = Theme_config.calendar.day.today_border_color
      end

      local m = month_convert[tonumber(os.date("%m"))]
      local y = tonumber(os.date("%Y"))
      if (i == date.day) and (date.month == m) and (date.year == y) then
        bg = Theme_config.calendar.day.bg_focus
        fg = Theme_config.calendar.day.fg_focus
      end

      local day = wibox.widget {
        {
          {
            {
              {
                {
                  {
                    { -- Day
                      widget = wibox.widget.textbox,
                      align = "center",
                      valign = "center",
                      text = math.floor(i),
                      id = "day_text",
                    },
                    widget = wibox.container.margin,
                    margins = dpi(2),
                  },
                  id = "day_bg",
                  widget = wibox.container.background,
                  bg = bg,
                  shape = Theme_config.calendar.day.shape,
                  fg = fg,
                },
                widget = wibox.container.place,
                valign = "center",
                halign = "center",
              },
              {
                get_tasks_for_day(math.floor(i), date.month, date.year),
                widget = wibox.container.margin,
                margins = dpi(4)
              },
              id = "tasks",
              spacing = dpi(4),
              layout = wibox.layout.fixed.vertical
            },
            widget = wibox.container.margin,
            top = dpi(4)
          },
          id = "background",
          widget = wibox.container.background,
          bg = Theme_config.calendar.day.bg,
          fg = Theme_config.calendar.day.fg,
          border_color = border,
          border_width = Theme_config.calendar.day.border_width,
          shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, dpi(8))
          end
        },
        widget = wibox.container.constraint,
        width = dpi(100),
        height = dpi(120),
        strategy = "exact"
      }

      -- update selected_day if the day is clicked
      day:buttons(
        gears.table.join(
          awful.button({}, 1, function()
            selected_day.col = col
            selected_day.row = row
            day:emit_signal("day::update_selected")
          end)
        )
      )

      day:connect_signal("day::update_selected", function()
        if col == selected_day.col and row == selected_day.row then
          capi.awesome.emit_signal("day::reset_border")
          day.background.border_color = Theme_config.calendar.day.today_border_color
        end
      end)

      capi.awesome.connect_signal("day::reset_border", function()
        day.background.border_color = Theme_config.calendar.day.border_color
      end)

      calendar_matrix:add_widget_at(day, row, col)
      col = col + 1
      if col == 8 then
        col = 1
        row = row + 1
      end
    end

    --next month
    local next_month = date.month
    if date.month == 12 then
      next_month = 1
    else
      next_month = next_month + 1
    end

    if months[date.month].last_day ~= 7 then
      for i = 1, 7 - months[date.month].last_day, 1 do
        local border = Theme_config.calendar.day.border_color
        local fg = Theme_config.calendar.day.fg_unfocus
        local bg = Theme_config.calendar.day.bg_unfocus
        if i == selected_day.col and months[date.month].weeks == selected_day.row then
          border = Theme_config.calendar.day.today_border_color
        end
        local m = month_convert[tonumber(os.date("%m")) + 1]
        if m == 13 then
          m = 1
        end
        local y = tonumber(os.date("%Y"))
        if (i == date.day) and (next_month == m) and (date.year == y) then
          bg = Theme_config.calendar.day.bg_focus
          fg = Theme_config.calendar.day.fg_focus
        end
        local day = wibox.widget {
          {
            {
              {
                {
                  {
                    {
                      { -- Day
                        widget = wibox.widget.textbox,
                        align = "center",
                        valign = "center",
                        text = math.floor(i),
                        id = "day_text",
                      },
                      widget = wibox.container.margin,
                      margins = dpi(2),
                    },
                    id = "day_bg",
                    widget = wibox.container.background,
                    bg = bg,
                    shape = Theme_config.calendar.day.shape,
                    fg = fg,
                  },
                  widget = wibox.container.place,
                  valign = "center",
                  halign = "center",
                },
                {
                  get_tasks_for_day(math.floor(i), next_month, date.year),
                  widget = wibox.container.margin,
                  margins = dpi(4)
                },
                id = "tasks",
                spacing = dpi(4),
                layout = wibox.layout.fixed.vertical
              },
              widget = wibox.container.margin,
              top = dpi(4)
            },
            id = "background",
            widget = wibox.container.background,
            bg = Theme_config.calendar.day.bg_unfocus,
            fg = Theme_config.calendar.day.fg_unfocus,
            border_color = border,
            border_width = Theme_config.calendar.day.border_width,
            shape = function(cr, width, height)
              gears.shape.rounded_rect(cr, width, height, dpi(8))
            end
          },
          widget = wibox.container.constraint,
          width = dpi(100),
          height = dpi(120),
          strategy = "exact"
        }

        -- update selected_day if the day is clicked
        day:buttons(
          gears.table.join(
            awful.button({}, 1, function()
              selected_day.col = i
              selected_day.row = months[date.month].weeks
              day:emit_signal("day::update_selected")
            end)
          )
        )

        day:connect_signal("day::update_selected", function()
          if i == selected_day.col and months[date.month].weeks == selected_day.row then
            capi.awesome.emit_signal("day::reset_border")
            day.background.border_color = Theme_config.calendar.day.today_border_color
          end
        end)

        capi.awesome.connect_signal("day::reset_border", function()
          day.background.border_color = Theme_config.calendar.day.border_color
        end)
        calendar_matrix:add_widget_at(day, months[date.month].weeks, months[date.month].last_day + i)
      end
    end

    return calendar_matrix
  end

  local function create_calendar_week_num()
    weeks:reset()
    local actual_fucking_date = date.month + 2
    if date.month == 11 then
      actual_fucking_date = 1
    elseif date.month == 12 then
      actual_fucking_date = 2
    end
    local start_week = actual_fucking_date * 4 - 3
    local weeknum = actual_fucking_date * 4 - 3
    if get_date_weekday("01", date.month, date.year) ~= 1 then
      weeknum = weeknum - 1
    end
    if actual_fucking_date == 1 then
      weeknum = 52
    end
    for i = start_week, start_week + get_weeks_in_month(date.month, date.year) - 1, 1 do
      weeks:add(wibox.widget {
        {
          {
            text = weeknum,
            id = "num",
            align = "center",
            valign = "top",
            widget = wibox.widget.textbox,
          },
          id = "background",
          fg = Theme_config.calendar.day.fg_unfocus,
          widget = wibox.container.background,
        },
        strategy = "exact",
        height = dpi(120),
        width = dpi(40),
        widget = wibox.container.constraint
      })
      if weeknum == 52 then
        weeknum = 1
      else
        weeknum = weeknum + 1
      end
    end
    return weeks
  end

  --- Calendar widget
  local calendar = wibox.widget {
    {
      {
        {
          {
            {
              {
                {
                  widget = wibox.widget.imagebox,
                  resize = false,
                  image = gears.color.recolor_image(icondir .. "add_ical.svg", Theme_config.calendar.add_ical.fg_focus),
                  halign = "center",
                  valign = "center"
                },
                id = "add_ical",
                shape = Theme_config.calendar.add_ical.shape,
                bg = Theme_config.calendar.add_ical.bg,
                widget = wibox.container.background
              },
              widget = wibox.container.margin,
              margins = dpi(4)
            },
            {
              {
                {
                  widget = wibox.widget.imagebox,
                  resize = false,
                  image = gears.color.recolor_image(icondir .. "add_task.svg", Theme_config.calendar.add_task.fg),
                  halign = "center",
                  valign = "center"
                },
                id = "add_task",
                shape = Theme_config.calendar.add_task.shape,
                bg = Theme_config.calendar.add_task.bg,
                widget = wibox.container.background
              },
              widget = wibox.container.margin,
              margins = dpi(4)
            },
            layout = wibox.layout.fixed.vertical
          },
          widget = wibox.container.constraint,
          strategy = "exact",
          height = dpi(75)
        },
        create_calendar_week_num(),
        id = "weekdaysnum",
        layout = wibox.layout.fixed.vertical
      },
      {
        {
          { --Header
            { -- Month switcher
              { -- Prev arrow
                widget = wibox.widget.imagebox,
                resize = true,
                image = icondir .. "chevron-left.svg",
                valign = "center",
                halign = "center",
                id = "prev_month",
              },
              {
                { -- Month
                  widget = wibox.widget.textbox,
                  text = months_table[date.month],
                  id = "month",
                  valign = "center",
                  align = "center"
                },
                widget = wibox.container.constraint,
                strategy = "exact",
                width = dpi(150)
              },
              { -- Next arrow
                widget = wibox.widget.imagebox,
                resize = true,
                image = icondir .. "chevron-right.svg",
                valign = "center",
                halign = "center",
                id = "next_month",
              },
              layout = wibox.layout.fixed.horizontal
            },
            nil,
            { -- Year switcher
              { -- Prev arrow
                widget = wibox.widget.imagebox,
                resize = true,
                image = icondir .. "chevron-left.svg",
                valign = "center",
                halign = "center",
                id = "prev_year"
              },
              {
                { -- Month
                  widget = wibox.widget.textbox,
                  text = date.year,
                  id = "year",
                  valign = "center",
                  align = "center"
                },
                widget = wibox.container.constraint,
                strategy = "exact",
                width = dpi(150)
              },
              { -- Next arrow
                widget = wibox.widget.imagebox,
                resize = true,
                image = icondir .. "chevron-right.svg",
                valign = "center",
                halign = "center",
                id = "next_year"
              },
              layout = wibox.layout.fixed.horizontal
            },
            layout = wibox.layout.align.horizontal
          },
          widget = wibox.container.constraint,
          height = dpi(40),
          strategy = "exact"
        },
        { -- Weekdays
          create_weekdays(),
          widget = wibox.container.background
        },
        create_calendar(),
        id = "calendar",
        spacing = dpi(5),
        layout = wibox.layout.fixed.vertical
      },
      id = "lay1",
      layout = wibox.layout.fixed.horizontal,
    },
    widget = wibox.container.background,
    bg = Theme_config.calendar.bg,
    border_color = Theme_config.calendar.border_color,
    border_width = Theme_config.calendar.border_width,
    border_strategy = "inner",
    fg = Theme_config.calendar.fg,
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(4))
    end
  }

  local add_ical = calendar:get_children_by_id("add_ical")[1]
  local add_task = calendar:get_children_by_id("add_task")[1]

  add_ical:buttons(
    gears.table.join(
      awful.button({}, 1, function()
        awful.spawn.easy_async_with_shell(
          "zenity --file-selection --title='Select an iCalendar file' --file-filter='iCalendar File | *.ics'",
          function(path_to_file)
            path_to_file = string.gsub(path_to_file, "\n", "")
            if not path_to_file then return end
            ical_parser.new(path_to_file)
            tasks = create_tasks()
            calendar:get_children_by_id("weekdaysnum")[1].children[2] = create_calendar_week_num()
            calendar:get_children_by_id("calendar")[1].children[3] = create_calendar()
          end
        )
      end)
    )
  )

  Hover_signal(add_ical)
  Hover_signal(add_task)

  --- Popup that contains the calendar
  local cal_popup = awful.popup {
    widget = calendar,
    screen = s,
    ontop = true,
    bg = "#00000000",
    visible = false
  }

  --- Calendar switch month back
  calendar:get_children_by_id("prev_month")[1]:buttons(
    gears.table.join(
      awful.button({}, 1, function()
        date.month = date.month - 1
        if date.month == 0 then
          date.month = 12
        end
        if date.month == 10 then
          date.year = date.year - 1
        end
        calendar:get_children_by_id("month")[1].text = months_table[date.month]
        calendar:get_children_by_id("year")[1].text = date.year
        calendar:get_children_by_id("weekdaysnum")[1].children[2] = create_calendar_week_num()
        calendar:get_children_by_id("calendar")[1].children[3] = create_calendar()
      end)
    )
  )

  --- Calendar switch month forward
  calendar:get_children_by_id("next_month")[1]:buttons(
    gears.table.join(
      awful.button({}, 1, function()
        date.month = date.month + 1
        if date.month == 13 then
          date.month = 1
        end
        if date.month == 11 then
          date.year = date.year + 1
        end
        calendar:get_children_by_id("month")[1].text = months_table[date.month]
        calendar:get_children_by_id("year")[1].text = date.year
        calendar:get_children_by_id("weekdaysnum")[1].children[2] = create_calendar_week_num()
        calendar:get_children_by_id("calendar")[1].children[3] = create_calendar()
      end)
    )
  )

  --- Calendar switch year back
  calendar:get_children_by_id("prev_year")[1]:buttons(
    gears.table.join(
      awful.button({}, 1, function()
        date.year = date.year - 1
        calendar:get_children_by_id("year")[1].text = date.year
        calendar:get_children_by_id("weekdaysnum")[1].children[2] = create_calendar_week_num()
        calendar:get_children_by_id("calendar")[1].children[3] = create_calendar()
      end)
    )
  )

  --- Calendar switch year forward
  calendar:get_children_by_id("next_year")[1]:buttons(
    gears.table.join(
      awful.button({}, 1, function()
        date.year = date.year + 1
        calendar:get_children_by_id("year")[1].text = date.year
        calendar:get_children_by_id("weekdaysnum")[1].children[2] = create_calendar_week_num()
        calendar:get_children_by_id("calendar")[1].children[3] = create_calendar()
      end)
    )
  )

  --- Toggle calendar visibility
  capi.awesome.connect_signal("calendar::toggle", function(widget)
    if s == capi.mouse.screen then
      cal_popup.x = 3765
      cal_popup.y = 60
      cal_popup.visible = not cal_popup.visible
    end
  end)

end
