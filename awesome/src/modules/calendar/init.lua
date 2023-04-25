-- Awesome Libs
local awful = require('awful')
local apopup = require('awful.popup')
local beautiful = require('beautiful')
local dpi = require('beautiful').xresources.apply_dpi
local gtable = require('gears.table')
local gcolor = require('gears.color')
local gfilesystem = require('gears').filesystem
local wibox = require('wibox')
local base = require('wibox.widget.base')

local capi = {
  mouse = mouse,
}

local ical_parser = require('src.tools.ical_parser')()
local task_info = require('src.modules.calendar.task_info')
local hover = require('src.tools.hover')

local icondir = gfilesystem.get_configuration_dir() .. 'src/assets/icons/calendar/'

local calendar = { mt = {} }
calendar.tasks = {}
calendar.calendars = {}

calendar._private = {}

-- Month lookup table
calendar._private.months = {
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
}

-- Weeks shortname lookup table
calendar._private.weeks = {
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
  'Sun',
}

--- A date table to keep track of the needed date
calendar.date = {
  day = tonumber(os.date('%d')) or 1,
  month = tonumber(os.date('%m')) or 1,
  year = tonumber(os.date('%Y')) or 1970,
}

--#region base widget functions
function calendar:layout(_, width, height)
  if self._private.widget then
    return { base.place_widget_at(self._private.widget, 0, 0, width, height) }
  end
end

function calendar:fit(context, width, height)
  local w, h = 0, 0 ---@type number|nil, number|nil
  if self._private.widget then
    w, h = base.fit_widget(self, context, self._private.widget, width, height)
  end
  return w, h
end

calendar.set_widget = base.set_widget_common

function calendar:get_widget()
  return self._private.widget
end

--#endregion

---Checks how many days a month has and returns the ammount. Also takes leap years into account.
---@param month number|nil
---@param year number|nil
---@return integer last_day The last day of the month
function calendar:get_last_day_in_month(month, year)
  month = month or self.date.month
  year = year or self.date.year

  local last_day = {
    [1] = 31,
    [2] = 28,
    [3] = 31,
    [4] = 30,
    [5] = 31,
    [6] = 30,
    [7] = 31,
    [8] = 31,
    [9] = 30,
    [10] = 31,
    [11] = 30,
    [12] = 31,
  }

  if (month == 2) and (math.floor(year % 4) == 0) then
    return 29
  else
    return last_day[month]
  end
end

---Takes a date and returns the weekday of that month.
---@param day number|nil
---@param month number|nil
---@param year number|nil
---@return number
function calendar:weekday_for_day(day, month, year)
  day = day or self.date.day
  month = month or self.date.month
  year = year or self.date.year

  --[[
    The algorithm uses the march as the first month of the year and february + january
    as the 11th and 12th month of last year. This is also the reason we substract the month by 2
  ]]
  month = month - 2
  if month == 0 then
    month = 12
    year = year - 1
  elseif month == -1 then
    month = 11
    year = year - 1
  end

  -- Forgot what the algorithm was called
  local w = ((day + math.floor(2.6 * month - 0.2) - 2 * tonumber(tostring(year):match('([0-9]+)[0-9][0-9]')) +
      tonumber(tostring(year):match('[0-9][0-9]([0-9]+)')) +
      math.floor(tonumber(tostring(year):match('[0-9][0-9]([0-9]+)')) / 4) +
      math.floor(tonumber(tostring(year):match('([0-9]+)[0-9][0-9]')) / 4)) % 7)

  -- If the week should start on monday, sunday is default. Since the function returns 0 - 6, we have to add 1 for lua's tables
  if w == 0 then w = 7 end

  return w
end

---Calculated how many weeks are in month.
---@param month number|nil
---@param year number|nil
---@return integer
function calendar:weeks_in_month(month, year)
  month = month or self.date.month
  year = year or self.date.year

  return math.ceil((calendar:get_last_day_in_month(month, year) + calendar:weekday_for_day(1) - 1) / 7)
end

function calendar:check_event_uid(uid)
  for _, cal in ipairs(calendar.tasks) do
    for _, task in ipairs(cal) do
      if task.uid == uid then
        return true
      end
    end
  end
  return false
end

function calendar:get_tasks()
  if not ical_parser or not ical_parser.VCALENDAR then return end
  local tasks = {}

  local function task_factory(start_date, end_date, sum, loc, des, uid, freq)
    table.insert(tasks, {
      date_start = {
        year = start_date.y,
        month = start_date.m,
        day = start_date.d,
        hour = start_date.hour or 0,
        min = start_date.min or 0,
        sec = start_date.sec or 0,
      },
      date_end = {
        year = end_date.y,
        month = end_date.m,
        day = end_date.d,
        hour = end_date.hour or 0,
        min = end_date.min or 0,
        sec = end_date.sec or 0,
      },
      summary = sum,
      location = loc,
      description = des,
      uid = uid,
      freq = freq,
    })
  end

  for _, cal in ipairs(ical_parser.VCALENDAR) do
    for _, event in ipairs(cal.VEVENT) do
      if not self:check_event_uid(event.UID) then
        local start_time
        if event.DTSTART then
          start_time = event.DTSTART.DTSTART
        end
        local end_time
        if event.DTEND then
          end_time = event.DTEND.DTEND
        end

        -- If there is no end time then we just set it to the start time
        if not event.DTEND.DTEND then
          end_time = {
            year = start_time.year + 1000,
            month = start_time.month,
            day = start_time.day,
            hour = start_time.hour,
            min = start_time.min,
            sec = start_time.sec,
          }
        end
        -- Get repeat cases
        if event.RRULE then
          if event.RRULE.FREQ == 'DAILY' then
            local year_counter, month_counter, day_counter = start_time.year, start_time.month,
                start_time.day
            while (year_counter < event.RRULE.UNTIL.year) or (month_counter < event.RRULE.UNTIL.month) or
                (day_counter <= event.RRULE.UNTIL.day) do
              task_factory({
                y = year_counter,
                m = month_counter,
                d = day_counter,
                hour = start_time.hour,
                min = start_time.min,
                sec = start_time.sec,
              }, {
                y = year_counter,
                m = month_counter,
                d = day_counter,
                hour = end_time.hour,
                min = end_time.min,
                sec = end_time.sec,
              }, event.SUMMARY, event.LOCATION, event.DESCRIPTION, event.UID, event.RRULE.FREQ)

              day_counter = day_counter + 1
              if day_counter > calendar:get_last_day_in_month(month_counter, year_counter) then
                day_counter = 1
                month_counter = month_counter + 1
                if month_counter > 12 then
                  month_counter = 1
                  year_counter = year_counter + 1
                end
              end
            end
          elseif event.RRULE.FREQ == 'WEEKLY' then
            local year_counter, month_counter, day_counter = start_time.year, start_time.month,
                start_time.day
            while (year_counter < event.RRULE.UNTIL.year) or (month_counter < event.RRULE.UNTIL.month) or
                (day_counter <= event.RRULE.UNTIL.day) do
              task_factory({ y = year_counter, m = month_counter, d = day_counter, hour = start_time.hour,
                min = start_time.min, sec = start_time.sec, }, { y = year_counter, m = month_counter,
                d = day_counter, hour = end_time.hour, min = end_time.min, sec = end_time.sec, },
                event.SUMMARY, event.LOCATION, event.DESCRIPTION, event.UID, event.RRULE.FREQ)
              day_counter = day_counter + 7
              local month_length = calendar:get_last_day_in_month(month_counter, year_counter)
              if day_counter > month_length then
                day_counter = day_counter - month_length
                month_counter = month_counter + 1
                if month_counter > 12 then
                  month_counter = 1
                  year_counter = year_counter + 1
                end
              end
            end
          elseif event.RRULE.FREQ == 'MONTHLY' then
            local year_counter, month_counter, day_counter = start_time.year, start_time.month,
                start_time.day
            while (year_counter < event.RRULE.UNTIL.year) or (month_counter < event.RRULE.UNTIL.month) or
                (day_counter <= event.RRULE.UNTIL.day) do
              task_factory({ y = year_counter, m = month_counter, d = day_counter, hour = start_time.hour,
                min = start_time.min, sec = start_time.sec, }, { y = year_counter, m = month_counter,
                d = day_counter, hour = end_time.hour, min = end_time.min, sec = end_time.sec, },
                event.SUMMARY, event.LOCATION, event.DESCRIPTION, event.UID, event.RRULE.FREQ)
              month_counter = month_counter + 1
              if month_counter > 12 then
                month_counter = 1
                year_counter = year_counter + 1
              end
            end
          elseif event.RRULE.FREQ == 'YEARLY' then
            end_time = event.RRULE.UNTIL
            if not event.RRULE.UNTIL then
              end_time = {
                year = start_time.year + 1000,
                month = start_time.month,
                day = start_time.day,
              }
            end
            for i = start_time.year, end_time.year, 1 do
              task_factory({ y = i, m = start_time.month, d = start_time.day, hour = start_time.hour,
                min = start_time.min, sec = start_time.sec, }, { y = i, m = end_time.month, d = end_time.day,
                hour = end_time.hour, min = end_time.min, sec = end_time.sec, }, event.SUMMARY,
                event.LOCATION, event.DESCRIPTION, event.UID, event.RRULE.FREQ)
            end
          end
          -- If RRULE is empty we just add a single day event
        else
          task_factory({ y = start_time.year, m = start_time.month, d = start_time.day, hour = start_time.hour,
            min = start_time.min, sec = start_time.sec, }, { y = end_time.year, m = end_time.month,
            d = end_time.day, hour = end_time.hour, min = end_time.min, sec = end_time.sec, },
            event.SUMMARY, event.LOCATION, event.DESCRIPTION, event.UID, event.RRULE.FREQ)
        end
        if event.VALARM then
          -- send a notification X minutes before an event starts

        end
      end
    end
    --table.insert(calendars, tasks)
    table.insert(self.tasks, tasks)
    table.insert(self.calendars, {
      tasks = self.tasks,
      color = cal.color,
    })
  end
end

---!Fix later, I have no idea how to calculate it and the internet has no clue either
calendar._private.calendar_weeks_widget = wibox.widget { layout = wibox.layout.fixed.vertical }
---Creates the widget that displays the calendar week
function calendar:create_calendar_weeks_widget()
  self._private.calendar_weeks_widget:reset()
  -- Loop over every month until the current month and calculate for each month if there is a prior week number or next week number
  local start_week = 1

  local end_week = start_week + calendar:weeks_in_month() - 1

  -- Loop from the first calendar week in this month to the last (4-6 in min-max)
  for i = start_week, end_week, 1 do
    self._private.calendar_weeks_widget:add(wibox.widget {
      {
        {
          text = i,
          id = 'num',
          align = 'center',
          valign = 'top',
          widget = wibox.widget.textbox,
        },
        id = 'background',
        fg = beautiful.colorscheme.bg2,
        widget = wibox.container.background,
      },
      strategy = 'exact',
      height = dpi(120),
      width = dpi(40),
      widget = wibox.container.constraint,
    })
  end
end

calendar._private.weekdays = wibox.widget { layout = wibox.layout.flex.horizontal }
---Creates a little widget that holds a short weekday name e.g. Mon...
function calendar:create_weekdays_widget()
  self._private.weekdays:reset()
  for i = 1, 7, 1 do
    self._private.weekdays:add(wibox.widget {
      {
        text = self._private.weeks[i],
        align = 'center',
        valign = 'center',
        widget = wibox.widget.textbox,
      },
      bg = beautiful.colorscheme.bg,
      fg = beautiful.colorscheme.bg_blue,
      widget = wibox.container.background,
    })
  end
end

calendar._private.calendar_matrix = wibox.widget { layout = wibox.layout.grid, spacing = dpi(2), forced_num_cols = 7 }
---Creates the calendar matrix widget
function calendar:create_calendar_widget()
  self._private.calendar_matrix:reset()
  local months_t = {}

  for i, month in ipairs(self._private.months) do
    months_t[i] = {
      name = month,
      first_day = self:weekday_for_day(1, i, self.date.year),
      last_day = self:weekday_for_day(calendar:get_last_day_in_month(i, self.date.year), i, self.date.year),
      day_count = self:get_last_day_in_month(i, self.date.year),
      weeks = self:weeks_in_month(i, self.date.year),
    }
  end

  ---Creates a layout with all tasks that match for a given date
  ---@param day number
  ---@param month number
  ---@param year number
  ---@return wibox.widget|nil layout Tasks in a vertical fixed layout or nil if there is no task
  local function get_tasks_for_day(day, month, year)
    if not self.tasks or #self.tasks == 0 then return end
    local tasks_layout = {
      layout = require('src.lib.overflow_widget.overflow').vertical,
      scrollbar_width = 0,
      step = dpi(50),
      spacing = dpi(2),
    }

    local function task_factory(task, bg)
      return wibox.widget {
        {
          {
            text = task.summary,
            align = 'left',
            halign = 'center',
            font = 'JetBrainsMono Nerd Font, bold 10',
            widget = wibox.widget.textbox,
          },
          margins = dpi(2),
          widget = wibox.container.margin,
        },
        fg = beautiful.colorscheme.bg,
        bg = bg,
        shape = beautiful.shape[4],
        forced_height = dpi(20),
        widget = wibox.container.background,
      }
    end

    for _, cal in ipairs(self.calendars) do
      for _, tasks in ipairs(cal.tasks) do
        for _, task in ipairs(tasks) do
          if (task.date_start.year == year) and (task.date_start.month == month) and (task.date_start.day == day) then
            -- Check if task if before the current date
            local tw
            if task.date_start.year < self.date.year or
                (task.date_start.year == self.date.year and task.date_start.month < self.date.month) or
                (
                task.date_start.year == self.date.year and task.date_start.month == self.date.month and
                    task.date_start.day < self.date.day) then
              tw = task_factory(task, cal.color .. '55')
            else
              tw = task_factory(task, cal.color)
            end

            local ti = task_info {
              summary = task.summary,
              description = task.description,
              location = task.location,
              url = task.url,
              uid = task.uid,
              date_start = task.date_start,
              start_time = task.start_time,
              date_end = task.date_end,
              end_time = task.end_time,
              freq = task.freq,
              task = task,
              color = cal.color,
            }

            local task_popup = apopup {
              widget = ti,
              ontop = true,
              visible = false,
              bg = gcolor.transparent,
              x = capi.mouse.coords().x,
              y = capi.mouse.coords().y,
              screen = capi.mouse.screen,
            }

            tw:buttons(
              gtable.join(
                awful.button({}, 1, function()
                  task_popup.x = capi.mouse.coords().x
                  task_popup.y = capi.mouse.coords().y
                  task_popup.visible = not task_popup.visible
                  collectgarbage('collect')
                end)
              )
            )

            tw:connect_signal('mouse::leave', function()
              task_popup.visible = false
              collectgarbage('collect')
            end)

            hover.bg_hover { widget = tw }

            table.insert(tasks_layout, tw)
          end
        end
      end
    end

    return tasks_layout
  end

  -- Create the last months days that are still present in this month
  if months_t[self.date.month].first_day ~= 1 then
    local column = 1
    local last_month = self.date.month - 1
    local year = self.date.year
    if last_month == 0 then
      year = year - 1
      last_month = 12
    end

    local last_month_length = self:get_last_day_in_month(last_month, year)

    for i = last_month_length - months_t[self.date.month].first_day + 2, last_month_length, 1 do
      local border = beautiful.colorscheme.border_color
      local bg = beautiful.colorscheme.bg
      local fg = beautiful.colorscheme.bg2

      local y = tonumber(os.date('%Y'))
      local m = tonumber(os.date('%m'))

      if (i == self.date.day) and (m == last_month) and (y == year) then
        bg = beautiful.colorscheme.bg_teal
        fg = beautiful.colorscheme.bg
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
                      align = 'center',
                      valign = 'center',
                      text = math.floor(i),
                      id = 'day_text',
                    },
                    widget = wibox.container.margin,
                    margins = dpi(2),
                  },
                  id = 'day_bg',
                  widget = wibox.container.background,
                  bg = bg,
                  shape = beautiful.shape[4],
                  fg = fg,
                },
                widget = wibox.container.place,
                valign = 'center',
                halign = 'center',
              },
              {
                get_tasks_for_day(math.floor(i), last_month, year),
                widget = wibox.container.margin,
                margins = dpi(4),
                id = 'day_tasks',
              },
              id = 'tasks',
              spacing = dpi(4),
              layout = wibox.layout.fixed.vertical,
            },
            id = 'day_bg',
            widget = wibox.container.margin,
            top = dpi(4),
          },
          id = 'background',
          widget = wibox.container.background,
          bg = beautiful.colorscheme.bg,
          fg = beautiful.colorscheme.bg2,
          border_color = border,
          border_width = dpi(2),
          shape = beautiful.shape[4],
        },
        id = 'day',
        widget = wibox.container.constraint,
        width = dpi(100),
        height = dpi(120),
        strategy = 'exact',
      }

      self._private.calendar_matrix:add_widget_at(day, 1, column)
      column = column + 1
    end

  end

  -- Create the days in this month
  local row = 1
  local col = months_t[self.date.month].first_day
  for i = 1, months_t[self.date.month].day_count, 1 do
    local border = beautiful.colorscheme.border_color
    local bg = beautiful.colorscheme.bg
    local fg = beautiful.colorscheme.fg

    local m = tonumber(os.date('%m'))
    local y = tonumber(os.date('%Y'))
    if (i == self.date.day) and (m == self.date.month) and (y == self.date.year) then
      bg = beautiful.colorscheme.bg_teal
      fg = beautiful.colorscheme.bg
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
                    align = 'center',
                    valign = 'center',
                    text = math.floor(i),
                    id = 'day_text',
                  },
                  widget = wibox.container.margin,
                  margins = dpi(2),
                },
                id = 'day_bg',
                widget = wibox.container.background,
                bg = bg,
                shape = beautiful.shape[4],
                fg = fg,
              },
              widget = wibox.container.place,
              valign = 'center',
              halign = 'center',
            },
            {
              get_tasks_for_day(math.floor(i), self.date.month, self.date.year),
              widget = wibox.container.margin,
              margins = dpi(4),
            },
            id = 'tasks',
            spacing = dpi(4),
            layout = wibox.layout.fixed.vertical,
          },
          widget = wibox.container.margin,
          top = dpi(4),
        },
        id = 'background',
        widget = wibox.container.background,
        bg = beautiful.colorscheme.bg,
        fg = beautiful.colorscheme.fg,
        border_color = border,
        border_width = dpi(2),
        shape = beautiful.shape[4],
      },
      widget = wibox.container.constraint,
      width = dpi(100),
      height = dpi(120),
      strategy = 'exact',
    }

    self._private.calendar_matrix:add_widget_at(day, row, col)
    col = col + 1
    if col > 7 then
      row = row + 1
      col = 1
    end
  end

  -- Create the next months days that are still present in this month
  if months_t[self.date.month].last_day ~= 7 then
    local next_month = self.date.month + 1
    local year = self.date.year
    if next_month == 13 then
      year = year + 1
      next_month = 1
    end

    for i = 1, 7 - months_t[self.date.month].last_day, 1 do
      local border = beautiful.colorscheme.border_color
      local bg = beautiful.colorscheme.bg
      local fg = beautiful.colorscheme.bg2

      local m = tonumber(os.date('%m'))
      local y = tonumber(os.date('%Y'))
      if (i == self.date.day) and (m == next_month) and (y == year) then
        bg = beautiful.colorscheme.bg_teal
        fg = beautiful.colorscheme.bg
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
                      align = 'center',
                      valign = 'center',
                      text = math.floor(i),
                      id = 'day_text',
                    },
                    widget = wibox.container.margin,
                    margins = dpi(2),
                  },
                  id = 'day_bg',
                  widget = wibox.container.background,
                  bg = bg,
                  shape = beautiful.shape[4],
                  fg = fg,
                },
                widget = wibox.container.place,
                valign = 'center',
                halign = 'center',
              },
              {
                get_tasks_for_day(math.floor(i), next_month, year),
                widget = wibox.container.margin,
                margins = dpi(4),
              },
              id = 'tasks',
              spacing = dpi(4),
              layout = wibox.layout.fixed.vertical,
            },
            widget = wibox.container.margin,
            top = dpi(4),
          },
          id = 'background',
          widget = wibox.container.background,
          bg = beautiful.colorscheme.bg,
          fg = beautiful.colorscheme.bg2,
          border_color = border,
          border_width = dpi(2),
          shape = beautiful.shape[4],
        },
        widget = wibox.container.constraint,
        width = dpi(100),
        height = dpi(120),
        strategy = 'exact',
      }
      self._private.calendar_matrix:add_widget_at(day, months_t[self.date.month].weeks,
        months_t[self.date.month].last_day + i)
    end
  end
end

function calendar.new(args)
  args = args or {}

  local ret = base.make_widget(nil, nil, { enable_properties = true })
  gtable.crush(ret, calendar, true)

  ret:set_widget(wibox.widget {
    {
      {
        {
          {
            { -- Add new iCal button
              {
                {
                  widget = wibox.widget.imagebox,
                  resize = false,
                  image = gcolor.recolor_image(icondir .. 'add_ical.svg', beautiful.colorscheme.bg),
                  halign = 'center',
                  valign = 'center',
                },
                id = 'add_ical',
                shape = beautiful.shape[4],
                bg = beautiful.colorscheme.bg_red,
                widget = wibox.container.background,
              },
              widget = wibox.container.margin,
              margins = dpi(4),
            },
            { -- New task button
              {
                {
                  widget = wibox.widget.imagebox,
                  resize = false,
                  image = gcolor.recolor_image(icondir .. 'add_task.svg', beautiful.colorscheme.bg),
                  halign = 'center',
                  valign = 'center',
                },
                id = 'add_task',
                shape = beautiful.shape[4],
                bg = beautiful.colorscheme.bg_blue,
                widget = wibox.container.background,
              },
              widget = wibox.container.margin,
              margins = dpi(4),
            },
            layout = wibox.layout.fixed.vertical,
          },
          widget = wibox.container.constraint,
          strategy = 'exact',
          height = dpi(75),
        },
        ret._private.calendar_weeks_widget,
        id = 'weekdaysnum',
        layout = wibox.layout.fixed.vertical,
      },
      {
        {
          { --Header
            { -- Month year switcher
              { -- Prev arrow
                widget = wibox.widget.imagebox,
                resize = true,
                image = icondir .. 'chevron-left.svg',
                valign = 'center',
                halign = 'center',
                id = 'prev_month',
              },
              {
                { -- Month
                  widget = wibox.widget.textbox,
                  text = ret._private.months[ret.date.month],
                  id = 'month',
                  valign = 'center',
                  align = 'center',
                },
                widget = wibox.container.constraint,
                strategy = 'exact',
                width = dpi(150),
              },
              { -- Next year arrow
                widget = wibox.widget.imagebox,
                resize = true,
                image = icondir .. 'chevron-right.svg',
                valign = 'center',
                halign = 'center',
                id = 'next_month',
              },
              layout = wibox.layout.fixed.horizontal,
            },
            nil,
            { -- Year year switcher
              { -- Prev arrow
                widget = wibox.widget.imagebox,
                resize = true,
                image = icondir .. 'chevron-left.svg',
                valign = 'center',
                halign = 'center',
                id = 'prev_year',
              },
              {
                { -- Year
                  widget = wibox.widget.textbox,
                  text = calendar.date.year,
                  id = 'year',
                  valign = 'center',
                  align = 'center',
                },
                widget = wibox.container.constraint,
                strategy = 'exact',
                width = dpi(150),
              },
              { -- Next year arrow
                widget = wibox.widget.imagebox,
                resize = true,
                image = icondir .. 'chevron-right.svg',
                valign = 'center',
                halign = 'center',
                id = 'next_year',
              },
              layout = wibox.layout.fixed.horizontal,
            },
            layout = wibox.layout.align.horizontal,
          },
          widget = wibox.container.constraint,
          height = dpi(40),
          strategy = 'exact',
        },
        { -- Weekdays
          ret._private.weekdays,
          widget = wibox.container.background,
        },
        ret._private.calendar_matrix,
        id = 'calendar',
        spacing = dpi(5),
        layout = wibox.layout.fixed.vertical,
      },
      id = 'lay1',
      layout = wibox.layout.fixed.horizontal,
    },
    widget = wibox.container.background,
    bg = beautiful.colorscheme.bg,
    border_color = beautiful.colorscheme.border_color,
    border_width = dpi(2),
    border_strategy = 'inner',
    fg = beautiful.colorscheme.fg,
    shape = beautiful.shape[12],
  })

  ret:get_tasks()

  -- Init calendar
  ret:create_calendar_widget()
  ret:create_weekdays_widget()
  ret:create_calendar_weeks_widget()

  ret:get_widget():get_children_by_id('add_ical')[1]:buttons(gtable.join(
    awful.button({}, 1, function()
      awful.spawn.easy_async_with_shell(
        "zenity --file-selection --title='Select an ICalendar file' --file-filter='iCalendar File | *.ics'",
        function(path_to_file)
          path_to_file = string.gsub(path_to_file, '\n', '')
          if (not path_to_file) or (path_to_file == '') then return end
          ical_parser:add_calendar(path_to_file)
          ret:get_tasks()
          ret:create_calendar_widget()
        end
      )
    end)
  ))

  ret:get_widget():get_children_by_id('add_task')[1]:buttons(gtable.join(
    awful.button({}, 1, function()
      awful.spawn.easy_async_with_shell(
        "zenity --info --text='Soon TM'",
        function()

        end
      )
    end)
  ))

  ret:get_widget():get_children_by_id('prev_month')[1]:buttons(gtable.join(
    awful.button({}, 1, function()
      ret.date.month = ret.date.month - 1
      if ret.date.month == 0 then
        ret.date.month = 12
        ret.date.year = ret.date.year - 1
      end
      ret:get_widget():get_children_by_id('month')[1].text = ret._private.months[ret.date.month]
      ret:get_widget():get_children_by_id('year')[1].text = ret.date.year
      ret:create_calendar_weeks_widget()
      ret:create_calendar_widget()
    end)
  ))

  ret:get_widget():get_children_by_id('next_month')[1]:buttons(gtable.join(
    awful.button({}, 1, function()
      ret.date.month = ret.date.month + 1
      if ret.date.month == 13 then
        ret.date.month = 1
        ret.date.year = ret.date.year + 1
      end
      ret:get_widget():get_children_by_id('month')[1].text = ret._private.months[ret.date.month]
      ret:get_widget():get_children_by_id('year')[1].text = ret.date.year
      ret:create_calendar_weeks_widget()
      ret:create_calendar_widget()
    end)
  ))

  --- Calendar switch year back
  ret:get_widget():get_children_by_id('prev_year')[1]:buttons(gtable.join(
    awful.button({}, 1, function()
      ret.date.year = ret.date.year - 1
      ret:get_widget():get_children_by_id('year')[1].text = ret.date.year
      ret:create_calendar_weeks_widget()
      ret:create_calendar_widget()
    end)
  ))

  --- Calendar switch year forward
  ret:get_widget():get_children_by_id('next_year')[1]:buttons(gtable.join(
    awful.button({}, 1, function()
      ret.date.year = ret.date.year + 1
      ret:get_widget():get_children_by_id('year')[1].text = ret.date.year
      ret:create_calendar_weeks_widget()
      ret:create_calendar_widget()
    end)
  ))

  hover.bg_hover { widget = ret:get_widget():get_children_by_id('add_ical')[1] }
  hover.bg_hover { widget = ret:get_widget():get_children_by_id('add_task')[1] }

  return ret
end

function calendar.mt:__call(...)
  return calendar.new(...)
end

return setmetatable(calendar, calendar.mt)
