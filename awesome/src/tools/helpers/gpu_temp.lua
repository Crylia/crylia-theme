local awatch = require('awful.widget.watch')
local gobject = require('gears.object')

local instance = nil

local function new()
  local self = gobject {}
  awatch([[ bash -c "nvidia-smi -q -d TEMPERATURE | grep 'GPU Current Temp' | awk '{print $5}' | head -n 1"]], 3, function(_, stdout)
    stdout = stdout:match('%d+')
    if not stdout then return end
    self:emit_signal('update::gpu_temp', stdout)
  end)
  return self
end

if not instance then
  instance = new()
end
return instance
