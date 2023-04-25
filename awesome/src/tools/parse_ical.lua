local gfilesystem = require('gears.filesystem')

local config = require('src.tools.config')

local ical_cache_path = gfilesystem.get_configuration_dir() .. 'src/config/ical_cache.json'
local ical_calendar_cache = {}

local date_time = {}

setmetatable(date_time, {
  __call = function(self, args)

    self.day = args.day or 1
    self.month = args.month or 1
    self.year = args.year or 1970

    self.hour = args.hour or 0
    self.minute = args.minute or 0
    self.second = args.second or 0

    return self
  end,
  __newindex = function(self, ...)
    if ... == 'weeknum' then
      if not self.weeknum then
        self.weeknum = 1 --TODO: calculate weeknum
      end
      return self.weeknum
    end
  end,
  __tostring = function(self)
    return string.format('%d-%d-%d %d:%d:%d', self.year, self.month, self.day, self.hour, self.minute, self.second)
  end,
});

local parser = {}

function parser.VCALENDAR(handler)
  local parse = {}
  local line
  while true do
    line = handler:read('*l')
    if not line then break end
    local key, value = line:match('^(%w+):(.*)$')

    if key == 'END' then
      return parse
    end

    if key == 'BEGIN' then
      if value == 'VEVENT' then
        parse[value] = parser.VEVENT(handler)
      elseif value == 'VTIMEZONE' then
        parse[value] = parser.VTIMEZONE(handler)
      end
    elseif key == 'VERSION' then
      parse[key] = value
    elseif key == 'PRODID' then
      parse[key] = value
    elseif key == 'CALSCALE' then
      parse[key] = value
    elseif key == 'METHOD' then
      parse[key] = value
    elseif key == 'X-WR-CALNAME' then
      parse[key] = value
    elseif key == 'X-WR-TIMEZONE' then
      parse[key] = value
    elseif key == 'X-WR-CALDESC' then
      parse[key] = value
    end
  end
end

function parser.VTIMEZONE(handler)
  local parse = {}
  local line
  while true do
    line = handler:read('*l')
    if not line then break end
    local key, value = line:match('^(%w+):(.*)$')

    if key == 'END' then
      return parse
    end

    if key == 'BEGIN' then
      if value == 'DAYLIGHT' or value == 'STANDARD' then
        parse[value] = parser.TZ(handler)
      end
    elseif key == 'TZID' then
      parse[key] = value
    elseif key == 'LAST-MODIFIED' then
      parse[key] = value
    elseif key == 'X-LIC-LOCATION' then
      parse[key] = value
    end
  end
end

function parser.TZ(handler)
  local parse = {}
  local line
  while true do
    line = handler:read('*l')
    if not line then break end
    local key, value = line:match('^(%w+):(.*)$')

    if key == 'END' then
      return parse
    end

    if key == 'TZNAME' then
      parse[key] = value
    elseif key == 'TZOFFSETFROM' then
      parse[key] = value
    elseif key == 'TZOFFSETTO' then
      parse[key] = value
    elseif key == 'DTSTART' then
      parse[key] = parse.DT(value)
    elseif key == 'RRULE' then
      parse[key] = parse.RRULE(value)
    end
  end
end

function parser.VEVENT(handler)
  local parse = {}
  local line

  while true do
    line = handler:read('*l')
    if not line then break end
    local key, value = line:match('^(%w+):(.*)$')

    if key == 'END' then
      return parse
    end

    if key == 'UID' then
      parse[key] = value
    elseif key == 'SEQUENCE' then
      parse[key] = value
    elseif key == 'SUMMARY' then
      parse[key] = value
    elseif key == 'LOCATION' then
      parse[key] = value
    elseif key == 'STATUS' then
      parse[key] = value
    elseif key == 'RRULE' then
      parse[key] = parser.RRULE(value)
    end



  end
end

function parser.new(path)
  local cal = {}

  -- Get the file from the path
  local ical_name = path

  -- Check if the calendar has been parsed previously
  if ical_calendar_cache[ical_name] then
    return ical_calendar_cache[ical_name]
  end

  local handler = io.open(path, 'r')
  if not handler then return end

  while true do
    local line = handler:read('*l')
    if not line then break end

    local key, value = line:match('^(%w+):(.*)$')
    if key and value then
      if key == 'BEGIN' and value == 'VCALENDAR' then
        cal[value] = parser.VCALENDAR(handler)
      end
    end
  end

  handler:close()

  return ical_calendar_cache[ical_name]
end

local instance = nil
if not instance then
  instance = setmetatable(parser, {
    -- If this module is called load all cached calendars from the cache
    __call = function(self)
      local cache_t = config.read_json(ical_cache_path)

      -- Read all the calendars from the cache
      for k, v in pairs(cache_t) do
        self[k] = v
      end
    end,
  })
end

return instance
