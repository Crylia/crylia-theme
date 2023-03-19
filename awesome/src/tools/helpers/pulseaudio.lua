package.cpath = package.cpath .. ';./?.so'

local gobject = require('gears.object')
local gtable = require('gears.table')

local pulseaudio = require('lua_libpulse_glib')

local p = {}

function p.new()
  local ret = gobject {}
  ret._private = {}

  gtable.crush(ret, p, true)

  local pa = pulseaudio.new()

  local ctx = pa:context('My Test App')

  if not ctx then return end

  ctx:connect(nil, function(state)
    if state == 4 then
      print('Connection is ready')

      ctx:get_sinks(function(sinks)
        print(sinks)
      end)
    end
  end)

  return ret
end

return setmetatable(p, { __call = function(_, ...) return p.new() end })
