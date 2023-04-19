local gfilesystem = require('gears.filesystem')
local gobject = require('gears.object')
local gtable = require('gears.table')
local naughty = require('naughty')

local json = require('src.lib.json-lua.json-lua')

local ical = { mt = {} }
ical.VCALENDAR = {}
ical._private = {}
ical._private.cache = {}
ical._private.parser = {}

--[[
  The structure of ical looks like this:
  ical = {
    VCALENDAR = {
      PRODID = "...",
      VERSION = "...",
      CALSCALE = "...",
      METHOD = "...",
      X-WR-CALNAME = "...",
      X-WR-CALDESC = "...",
      X-WR-TIMEZONE = "...",
      VTIMEZONE = {
        TZID = "...",
        TZURL = "...",
        X-LIC-LOCATION = "...",
        STANDARD = {
          TZOFFSETFROM = "...",
          TZOFFSETTO = "...",
          TZNAME = "...",
          DTSTART = "...",
          TZRDATE = "...",
          TZRULE = "...",
          TZUNTIL = "...",
          TZPERIOD = "...",
        },
        DAYLIGHT = {
          TZOFFSETFROM = "...",
          TZOFFSETTO = "...",
          TZNAME = "...",
          DTSTART = "...",
          TZRDATE = "...",
          TZRULE = "...",
          TZUNTIL = "...",
          TZPERIOD = "...",
        },
      },
      VEVENT = {
        UID = "...",
        DTSTAMP = "...",
        DTSTART = "...",
        DTEND = "...",
        SUMMARY = "...",
        DESCRIPTION = "...",
        LOCATION = "...",
        RRULE = "...",
        RDATE = "...",
        EXDATE = "...",
        CLASS = "...",
        STATUS = "...",
        TRANSP = "...",
        SEQUENCE = "...",
        ORGANIZER = "...",
        ATTENDEE = "...",
        CATEGORIES = "...",
        PRIORITY = "...",
        URL = "...",
        UID = "...",
        DTSTAMP = "...",
]]

function ical._private.add_to_cache(file, vcal)
  -- Copy file to src/config/files/calendar/
  local path = gfilesystem.get_configuration_dir() .. 'src/config/'
  local file_name = file:match('.*/(.*)')
  if not
      os.execute('cp ' ..
        file .. ' ' .. gfilesystem.get_configuration_dir() .. 'src/config/files/calendar/' .. file_name) then
    naughty.notification {
      app_name = 'Systemnotification',
      title = 'Error',
      text = 'Could not copy file to config/files/calendar/',
      timeout = 0,
      urgency = 'critical',
    }
    return
  end
  local handler = io.open(path .. 'calendar.json', 'r')
  if not handler then return end
  local json_data = json:decode(handler:read('a'))
  handler:close()
  if not (type(json_data) == 'table') then return end
  table.insert(json_data, {
    file = file_name,
    VCALENDAR = vcal,
  })

  json_data = json:encode(json_data)

  handler = io.open(path .. 'calendar.json', 'w')
  if not handler then return end
  handler:write(json_data)
  handler:close()
end

function ical:add_calendar(file)
  local handler = io.open(file, 'r')
  if not handler then return end
  -- Check if the line is a BEGIN:VCALENDAR
  local v, k = handler:read('l'):match('([A-Z]+):([A-Z]+)')
  local vcal = {}
  if v:match('BEGIN') and k:match('VCALENDAR') then
    vcal = self._private.parser:VCALENDAR(handler)
    table.insert(self.VCALENDAR, vcal)
    self._private.add_to_cache(file, vcal)
  end
end

function ical.new(args)
  args = args or {}
  local ret = gobject { enable_properties = true, enable_auto_signals = true }
  gtable.crush(ret, ical, true)
  local path = gfilesystem.get_configuration_dir() .. 'src/config/calendar.json'
  local handler = io.open(path, 'r')
  if not handler then return ret end
  local json_data = json:decode(handler:read('a'))
  handler:close()
  if not (type(json_data) == 'table') then return end
  --Load into the cache
  for _, v in ipairs(json_data) do
    ret._private.cache[v.file] = v.VCALENDAR
    table.insert(ret.VCALENDAR, v.VCALENDAR)
  end

  local function get_random_color()
    local colors = {
      '#FF0000',
    }

    return colors[math.random(1, 15)]
  end

  ret.color = get_random_color()

  return ret
end

function ical._private.parser:VEVENT(handler)
  local VEVENT = {}

  while true do
    local line = handler:read('l')

    if not line or line:match('END:VEVENT') then
      break
    end

    local v, k = line:match('(.*):(.*)')
    if v:match('CREATED') then
      VEVENT.CREATED = self.to_datetime(k)
    elseif v:match('LAST-MODIFIED') then
      VEVENT.LAST_MODIFIED = self.to_datetime(k)
    elseif v:match('DTSTAMP') then
      VEVENT.DTSTAMP = self.to_datetime(k)
    elseif v:match('UID') then
      VEVENT.UID = k
    elseif v:match('SUMMARY') then
      VEVENT.SUMMARY = k
    elseif v:match('STATUS') then
      VEVENT.STATUS = k
    elseif v:match('RRULE') then
      VEVENT.RRULE = {
        FREQ = k:match('FREQ=([A-Z]+)'),
        UNTIL = self.to_datetime(k:match('UNTIL=([TZ0-9]+)')),
        WKST = k:match('WKST=([A-Z]+)'),
        COUNT = k:match('COUNT=([0-9]+)'),
        INTERVAL = k:match('INTERVAL=([0-9]+)'),
      }
    elseif v:match('DTSTART') then
      VEVENT.DTSTART = {
        DTSTART = self.to_datetime(k),
        TZID = v:match('TZID=([a-zA-Z-\\/]+)'),
        VALUE = v:match('VALUE=([A-Z]+)'),
      }
    elseif v:match('DTEND') then
      VEVENT.DTEND = {
        DTEND = self.to_datetime(k),
        TZID = v:match('TZID=([a-zA-Z-\\/]+)'),
        VALUE = v:match('VALUE=([A-Z]+)'),
      }
    elseif v:match('TRANSP') then
      VEVENT.TRANSP = k
    elseif v:match('LOCATION') then
      VEVENT.LOCATION = k
    elseif v:match('SEQUENCE') then
      VEVENT.SEQUENCE = k
    elseif v:match('DESCRIPTION') then
      VEVENT.DESCRIPTION = k
    elseif v:match('URL') then
      VEVENT.URL = {
        URL = k,
        VALUE = v:match('VALUE=([A-Z]+)'),
      }
    elseif v:match('BEGIN') then
      if k:match('VALARM') then
        VEVENT.VALARM = self:VALARM(handler)
      end
    elseif v:match('UID') then
      VEVENT.UID = k
    end
  end
  --VEVENT.duration = VEVENT.DTSTART.DTSTART - VEVENT.DTEND.DTEND

  return VEVENT
end

function ical._private.parser.alarm_to_time(alarm)
  if not alarm then return end
  --Parse alarm into a time depending on its value. The value will be -PT15M where - mean before and with no leading - it means after. PT can be ignored and 15 is the time M then the unit where M is minute, H is out etc
  local time = alarm:match('([-]?[0-9]+)[A-Z]')
  local unit = alarm:match('[-]?[A-Z][A-Z][0-9]+([A-Z]*)')

  return time .. unit
end

function ical._private.parser:VALARM(handler)
  local VALARM = {}

  while true do
    local line = handler:read('l')

    if not line or line:match('END:VALARM') then
      break
    end

    local v, k = line:match('(.*):(.*)')
    if v:match('ACTION') then
      VALARM.ACTION = k
    elseif v:match('TRIGGER;VALUE=DURATION') then
      VALARM.TRIGGER = {
        VALUE = v:match('VALUE=(.*):'),
        TRIGGER = self._private.parser.alarm_to_time(k),
      }
    elseif v:match('DESCRIPTION') then
      VALARM.DESCRIPTION = k
    end
  end

  return VALARM
end

function ical._private.parser:VCALENDAR(handler)
  local VCALENDAR = {}
  VCALENDAR.VEVENT = {}
  VCALENDAR.VTIMEZONE = {}

  while true do
    local line = handler:read('l')

    if not line or line:match('END:VCALENDAR') then
      break
    end

    local v, k = line:match('(.*):(.*)')
    if v and k then
      if v:match('PRODID') then
        VCALENDAR.PRODID = k
      elseif v:match('VERSION') then
        VCALENDAR.VERSION = k
      elseif v:match('BEGIN') then
        if k:match('VTIMEZONE') then
          VCALENDAR.VTIMEZONE = self:VTIMEZONE(handler)
        elseif k:match('VEVENT') then
          table.insert(VCALENDAR.VEVENT, self:VEVENT(handler))
        end
      end
    end
  end

  handler:close()
  return VCALENDAR
end

function ical._private.parser:VTIMEZONE(handler)
  local VTIMEZONE = {}

  while true do
    local line = handler:read('l')

    if not line or line:match('END:VTIMEZONE') then
      break
    end

    local v, k = line:match('(.*):(.*)')
    if v:match('TZID') then
      VTIMEZONE.TZID = k
    end
    if v:match('BEGIN') then
      if k:match('DAYLIGHT') then
        VTIMEZONE.DAYLIGHT = self:DAYLIGHT(handler)
      elseif k:match('STANDARD') then
        VTIMEZONE.STANDARD = self:STANDARD(handler)
      end
    end
  end

  return VTIMEZONE
end

function ical._private.parser:DAYLIGHT(handler)
  local DAYLIGHT = {}

  while true do
    local line = handler:read('l')

    if not line or line:match('END:DAYLIGHT') then
      break
    end

    local v, k = line:match('(.*):(.*)')
    if v:match('TZOFFSETFROM') then
      DAYLIGHT.TZOFFSETFROM = self.offset(k)
    elseif v:match('TZOFFSETTO') then
      DAYLIGHT.TZOFFSETTO = self.offset(k)
    elseif v:match('TZNAME') then
      DAYLIGHT.TZNAME = k
    elseif v:match('DTSTART') then
      DAYLIGHT.DTSTART = self.to_datetime(k)
    elseif v:match('RRULE') then
      DAYLIGHT.RRULE = {
        FREQ = k:match('FREQ=([A-Z]+)'),
        BYDAY = k:match('BYDAY=([%+%-0-9A-Z,]+)'),
        BYMONTH = k:match('BYMONTH=([0-9]+)'),
      }
    end
  end

  return DAYLIGHT
end

---Parses the STANDARD property into a table
---@param handler table
---@return table STANDARD The STANDARD property as a table
function ical._private.parser:STANDARD(handler)
  local STANDARD = {}

  -- Read each line until END:STANDARD is read
  while true do
    local line = handler:read('l')

    if not line or line:match('END:STANDARD') then
      break
    end

    -- Break down each line into the property:value
    local v, k = line:match('(.*):(.*)')
    if v:match('TZOFFSETFROM') then
      STANDARD.TZOFFSETFROM = self.offset(k)
    elseif v:match('TZOFFSETTO') then
      STANDARD.TZOFFSETTO = self.offset(k)
    elseif v:match('TZNAME') then
      STANDARD.TZNAME = k
    elseif v:match('DTSTART') then
      STANDARD.DTSTART = self.to_datetime(k)
    elseif v:match('RRULE') then
      STANDARD.RRULE = {
        FREQ = k:match('FREQ=([A-Z]+)'),
        BYDAY = k:match('BYDAY=([%+%-0-9A-Z,]+)'),
        BYMONTH = k:match('BYMONTH=([0-9]+)'),
      }
    end
  end

  return STANDARD
end

---Parse the ical date time format into an os.time integer and the utc
---@param datetime string The datetime from the ical
---@return date|nil time Parsed os.time()
---@return unknown|nil utc UTC identifier
function ical._private.parser.to_datetime(datetime)
  if not datetime then return end
  local dt, utc = {}, nil

  dt.year, dt.month, dt.day = datetime:match('^(%d%d%d%d)(%d%d)(%d%d)')
  dt.hour, dt.min, dt.sec, utc = datetime:match('T(%d%d)(%d%d)(%d%d)(Z?)')

  if (dt.hour == nil) or (dt.min == nil) or (dt.sec == nil) then
    dt.hour, dt.min, dt.sec, utc = 0, 0, 0, nil
  end

  for k, v in pairs(dt) do dt[k] = tonumber(v) end
  return dt, utc
end

function ical._private.parser.offset(offset)
  local s, h, m = offset:match('([+-])(%d%d)(%d%d)')
  if s == '+' then s = 1 else s = -1 end
  return s * (tonumber(h) * 3600 + tonumber(m) * 60)
end

function ical.mt:__call(...)
  return ical.new(...)
end

return setmetatable(ical, ical.mt)
