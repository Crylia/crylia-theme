local awatch = require('awful.widget.watch')
local gobject = require('gears.object')

local instance

local function new()
  local self = gobject {}
  awatch([[ bash -c "nvidia-smi -q -d UTILIZATION | grep Gpu | awk '{print $3}'"]], 3, function(_, stdout)
    stdout = stdout:match('%d+')
    if not stdout then return end
    self:emit_signal('update::gpu_usage', stdout)
  end)
  return self
end

if not instance then
  instance = new()
end
return instance
