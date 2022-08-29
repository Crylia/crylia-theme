local ical = {}
ical.VCALENDAR = {}
ical._private = {}
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

---Takes a path to an .ical file then parses it into a lua table and returns it
---@param path string Path to the .ical file
---@return table | nil calendar New calendar table or nil on error
function ical.new(path)
  local handler = io.open(path, "r")
  if not handler then return end

  -- Check if the line is a BEGIN:VCALENDAR
  local v, k = handler:read("l"):match("([A-Z]+):([A-Z]+)")

  if v:match("BEGIN") and k:match("VCALENDAR") then
    table.insert(ical.VCALENDAR, ical._private.parser.VCALENDAR(handler))
    return ical
  end
  return ical
end

function ical._private.parser.VEVENT(handler)
  local VEVENT = {}

  while true do
    local line = handler:read("l")

    if not line or line:match("END:VEVENT") then
      break
    end

    local v, k = line:match("(.*):(.*)")
    if v:match("CREATED") then
      VEVENT.CREATED = ical._private.parser.to_datetime(k)
    elseif v:match("LAST-MODIFIED") then
      VEVENT.LAST_MODIFIED = ical._private.parser.to_datetime(k)
    elseif v:match("DTSTAMP") then
      VEVENT.DTSTAMP = ical._private.parser.to_datetime(k)
    elseif v:match("UID") then
      VEVENT.UID = k
    elseif v:match("SUMMARY") then
      VEVENT.SUMMARY = k
    elseif v:match("RRULE") then
      VEVENT.RRULE = {
        FREQ = k:match("FREQ=([A-Z]+)"),
        UNTIL = ical._private.parser.to_datetime(k:match("UNTIL=([TZ0-9]+)")),
        WKST = k:match("WKST=([A-Z]+)"),
        COUNT = k:match("COUNT=([0-9]+)"),
        INTERVAL = k:match("INTERVAL=([0-9]+)")
      }
    elseif v:match("DTSTART") then
      VEVENT.DTSTART = {
        DTSTART = ical._private.parser.to_datetime(k),
        TZID = v:match("TZID=([a-zA-Z-\\/]+)"),
        VALUE = v:match("VALUE=([A-Z]+)")
      }
    elseif v:match("DTEND") then
      VEVENT.DTEND = {
        DTEND = ical._private.parser.to_datetime(k),
        TZID = v:match("TZID=([a-zA-Z-\\/]+)"),
        VALUE = v:match("VALUE=([A-Z]+)")
      }
    elseif v:match("TRANSP") then
      VEVENT.TRANSP = k
    elseif v:match("LOCATION") then
      VEVENT.LOCATION = k
    elseif v:match("DESCRIPTION") then
      VEVENT.DESCRIPTION = k
    elseif v:match("URL") then
      VEVENT.URL = {
        URL = k,
        VALUE = v:match("VALUE=([A-Z]+)")
      }
    elseif v:match("BEGIN") then
      if k:match("VALARM") then
        VEVENT.VALARM = ical._private.parser.VALARM(handler)
      end
    end
  end

  --VEVENT.duration = VEVENT.DTSTART.DTSTART - VEVENT.DTEND.DTEND

  return VEVENT
end

function ical._private.parser.alarm_to_time(alarm)
  if not alarm then return end
  --Parse alarm into a time depending on its value. The value will be -PT15M where - mean before and with no leading - it means after. PT can be ignored and 15 is the time M then the unit where M is minute, H is out etc
  local time = alarm:match("([-]?[0-9]+)[A-Z]")
  local unit = alarm:match("[-]?[A-Z][A-Z][0-9]+([A-Z]*)")

  return time .. unit
end

function ical._private.parser.VALARM(handler)
  local VALARM = {}

  while true do
    local line = handler:read("l")

    if not line or line:match("END:VALARM") then
      break
    end

    local v, k = line:match("(.*):(.*)")
    if v:match("ACTION") then
      VALARM.ACTION = k
    elseif v:match("TRIGGER;VALUE=DURATION") then
      VALARM.TRIGGER = {
        VALUE = v:match("VALUE=(.*):"),
        TRIGGER = ical._private.parser.alarm_to_time(k)
      }
    elseif v:match("DESCRIPTION") then
      VALARM.DESCRIPTION = k
    end
  end

  return VALARM
end

function ical._private.parser.VCALENDAR(handler)
  local VCALENDAR = {}
  VCALENDAR.VEVENT = {}
  VCALENDAR.VTIMEZONE = {}

  while true do
    local line = handler:read("l")

    if not line or line:match("END:VCALENDAR") then
      break
    end

    local v, k = line:match("(.*):(.*)")
    if v and k then
      if v:match("PRODID") then
        VCALENDAR.PRODID = k
      elseif v:match("VERSION") then
        VCALENDAR.VERSION = k
      elseif v:match("BEGIN") then
        if k:match("VTIMEZONE") then
          VCALENDAR.VTIMEZONE = ical._private.parser.VTIMEZONE(handler)
        elseif k:match("VEVENT") then
          table.insert(VCALENDAR.VEVENT, ical._private.parser.VEVENT(handler))
        end
      end
    end
  end

  handler:close()
  return VCALENDAR
end

function ical._private.parser.VTIMEZONE(handler)
  local VTIMEZONE = {}

  while true do
    local line = handler:read("l")

    if not line or line:match("END:VTIMEZONE") then
      break
    end

    local v, k = line:match("(.*):(.*)")
    if v:match("TZID") then
      VTIMEZONE.TZID = k
    end
    if v:match("BEGIN") then
      if k:match("DAYLIGHT") then
        VTIMEZONE.DAYLIGHT = ical._private.parser.DAYLIGHT(handler)
      elseif k:match("STANDARD") then
        VTIMEZONE.STANDARD = ical._private.parser.STANDARD(handler)
      end
    end
  end

  return VTIMEZONE
end

function ical._private.parser.DAYLIGHT(handler)
  local DAYLIGHT = {}

  while true do
    local line = handler:read("l")

    if not line or line:match("END:DAYLIGHT") then
      break
    end

    local v, k = line:match("(.*):(.*)")
    if v:match("TZOFFSETFROM") then
      DAYLIGHT.TZOFFSETFROM = ical._private.parser.offset(k)
    elseif v:match("TZOFFSETTO") then
      DAYLIGHT.TZOFFSETTO = ical._private.parser.offset(k)
    elseif v:match("TZNAME") then
      DAYLIGHT.TZNAME = k
    elseif v:match("DTSTART") then
      DAYLIGHT.DTSTART = ical._private.parser.to_datetime(k)
    elseif v:match("RRULE") then
      DAYLIGHT.RRULE = {
        FREQ = k:match("FREQ=([A-Z]+)"),
        BYDAY = k:match("BYDAY=([%+%-0-9A-Z,]+)"),
        BYMONTH = k:match("BYMONTH=([0-9]+)")
      }
    end
  end

  return DAYLIGHT
end

---Parses the STANDARD property into a table
---@param handler table
---@return table STANDARD The STANDARD property as a table
function ical._private.parser.STANDARD(handler)
  local STANDARD = {}

  -- Read each line until END:STANDARD is read
  while true do
    local line = handler:read("l")

    if not line or line:match("END:STANDARD") then
      break
    end

    -- Break down each line into the property:value
    local v, k = line:match("(.*):(.*)")
    if v:match("TZOFFSETFROM") then
      STANDARD.TZOFFSETFROM = ical._private.parser.offset(k)
    elseif v:match("TZOFFSETTO") then
      STANDARD.TZOFFSETTO = ical._private.parser.offset(k)
    elseif v:match("TZNAME") then
      STANDARD.TZNAME = k
    elseif v:match("DTSTART") then
      STANDARD.DTSTART = ical._private.parser.to_datetime(k)
    elseif v:match("RRULE") then
      STANDARD.RRULE = {
        FREQ = k:match("FREQ=([A-Z]+)"),
        BYDAY = k:match("BYDAY=([%+%-0-9A-Z,]+)"),
        BYMONTH = k:match("BYMONTH=([0-9]+)")
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

  dt.year, dt.month, dt.day = datetime:match("^(%d%d%d%d)(%d%d)(%d%d)")
  dt.hour, dt.min, dt.sec, utc = datetime:match("T(%d%d)(%d%d)(%d%d)(Z?)")

  if (dt.hour == nil) or (dt.min == nil) or (dt.sec == nil) then
    dt.hour, dt.min, dt.sec, utc = 0, 0, 0, nil
  end

  for k, v in pairs(dt) do dt[k] = tonumber(v) end
  return dt, utc
end

function ical._private.parser.offset(offset)
  local s, h, m = offset:match("([+-])(%d%d)(%d%d)")
  if s == "+" then s = 1 else s = -1 end
  return s * (tonumber(h) * 3600 + tonumber(m) * 60)
end

return ical
