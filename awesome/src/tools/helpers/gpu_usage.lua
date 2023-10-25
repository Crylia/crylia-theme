local awatch = require('awful.widget.watch')
local aspawn = require('awful.spawn')
local gobject = require('gears.object')

local instance

local json = require('src.lib.json-lua.json-lua')

local function new()
  local self = gobject {}
  aspawn.easy_async_with_shell([[ lspci | grep ' VGA ' | cut -d" " -f 1 ]], function(stdout)
    if stdout:match('00:03.0') then  -- Nvidia
      awatch([[ bash -c "nvidia-smi -q -d UTILIZATION | grep Gpu | awk '{print $3}'"]], 3, function(_, stdout)
        stdout = stdout:match('%d+')
        if not stdout then return end
        self:emit_signal('update::gpu_usage', stdout)
      end)
    elseif stdout:match('00:02.0') then  -- Intel
      awatch([[ bash -c "intel_gpu_top -J & sleep 1 && pkill intel_gpu_top" ]], 3, function(_, stdout)
        local gpu_data = json:decode('[' .. stdout:gsub('/', '') .. ']')[2]

        if not gpu_data or type(gpu_data) ~= table then return end

        local gpu_usage = (gpu_data.engines.Render3D0.busy +
          gpu_data.engines.Blitter0.busy +
          gpu_data.engines.Video0.busy +
          gpu_data.engines.VideoEnhance0.busy) / 4

        self:emit_signal('update::gpu_usage', math.floor(gpu_usage + 0.5))
      end)
    elseif stdout:match('00:01.0') then  -- AMD
      -- AMD
    end
  end)

  return self
end

if not instance then
  instance = new()
end
return instance
