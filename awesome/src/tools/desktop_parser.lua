local gears = require("gears")
local GLib = require("lgi").GLib

---Will return every $XDG_DATA_DIRS
---@return table
local function get_paths()
  local dirs = {}

  local dir
  for _, value in ipairs(GLib.get_system_data_dirs()) do
    dir = GLib.build_filenamev({ value, "applications" })
    if gears.filesystem.dir_readable(dir) then table.insert(dirs, dir) end
  end

  dir = GLib.build_filenamev({ GLib.get_user_data_dir(), "applications" })
  if gears.filesystem.dir_readable(dir) then table.insert(dirs, dir) end

  return dirs
end

---Returns every .desktop file into a table
---@param file table .desktop files
---@return table
return function(file)

  if not file or file == "" then
    return
  end

  local handler = nil

  for _, dir in ipairs(get_paths()) do
    handler = io.open(dir .. "/" .. file, "r")
    if handler then
      break
    end
  end

  if not handler then
    return
  end

  local desktop_table = {}
  while true do
    local line = handler:read()

    if not line then
      break
    end

    if line:match("[Desktop Entry]") then
      while true do
        local property = handler:read()
        if not property then
          break
        end

        if property:match("^%[(.+)%]") then
          return desktop_table
        end

        if property:match("^Name=") then
          desktop_table["Name"] = property:match("Name=(.+)")
        elseif property:match("^Exec") then
          -- Second match is to remove the %u and %F some applications use to open a URI. It's not needed here
          desktop_table["Exec"] = property:match("Exec=(.+)"):gsub("%%u", ""):gsub("%%F", "")
        elseif property:match("^Icon=") then
          desktop_table["Icon"] = property:match("Icon=(.+)")
        end
      end
    end
  end
  return desktop_table
end
