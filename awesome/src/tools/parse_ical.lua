local gfilesystem = require('gears.filesystem')

local config = require('src.tools.config')

local ical_cache_path = gfilesystem.get_configuration_dir() .. 'src/config/ical_cache.json'
local ical_calendar_cache = {}

local date_time = {}

setmetatable(date_time, {
  __call = function(args)
    local dt = table.copy(date_time)

    dt.day = args.day or 1
    dt.month = args.month or 1
    dt.year = args.year or 1970

    dt.hour = args.hour or 0
    dt.minute = args.minute or 0
    dt.second = args.second or 0

    return dt
  end,
  __newindex = function(self, ...)
    if ... == 'weeknum' then
      if not self.weeknum then
        self.weeknum = 1 --TODO: calculate weeknum
      end
      return self.weeknum
    end
  end,
  __add = function(a, b)
    local dt = table.copy(date_time)
    if type(a) == 'table' and type(b) == 'table' then

    elseif type(a) == 'table' and type(b) == 'number' then

    else
      error('Cannot add number with date')
    end
  end,
  __sub = function(a, b)

  end,
  __mul = function(a, b)

  end,
  __div = function(a, b)

  end,
});

local parser = {}

local instance = nil

function parser:VEVENT()

end

---Start parsing a new calendar
---@param path string path to .ical file
function parser.parse(path)

  local ical_name = path

  -- Check if the calendar has been parsed previously
  if ical_calendar_cache[ical_name] then
    return ical_calendar_cache[ical_name]
  else
    -- If not create a new one in the cache
    ical_calendar_cache[ical_name] = {}
  end

  return ical_calendar_cache[ical_name]
end

function parser.new(path)

  -- Get the file from the path
  local ical_name = path

  -- Check if the calendar has been parsed previously
  if ical_calendar_cache[ical_name] then
    return ical_calendar_cache[ical_name]
  end

  -- If not create a new one in the cache
  ical_calendar_cache[ical_name] = { mt = {} }

  return ical_calendar_cache[ical_name]
end

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
