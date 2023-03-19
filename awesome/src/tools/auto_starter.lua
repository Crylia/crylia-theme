local Gio = require('lgi').Gio
local aspawn = require('awful.spawn')
local gfilesystem = require('gears.filesystem')

return function(table)
  for _, t in ipairs(table) do
    aspawn(t);
  end
  local path = gfilesystem.get_xdg_config_home() .. 'autostart/'
  local handler = io.popen('ls ' .. path)
  if not handler then return end

  for file in handler:lines() do
    local app = Gio.DesktopAppInfo.new_from_filename(path .. file)
    if app then
      Gio.AppInfo.launch_uris_async(Gio.AppInfo.create_from_commandline(Gio.DesktopAppInfo.get_string(app, 'Exec'), nil, 0))
    end
  end
end
