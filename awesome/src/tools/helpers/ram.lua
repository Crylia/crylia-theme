local awatch = require('awful.widget.watch')
local gobject = require('gears.object')

local instance = nil

local function new()
  local self = gobject {}
  awatch([[ bash -c "cat /proc/meminfo| grep Mem | awk '{print $2}'" ]], 3, function(_, stdout)
    local MemTotal, MemFree, MemAvailable = stdout:match('(%d+)\n(%d+)\n(%d+)\n')
    self:emit_signal('update::ram_widget', MemTotal, MemFree, MemAvailable)
  end)
  return self
end

if not instance then
  instance = new()
end
return instance
