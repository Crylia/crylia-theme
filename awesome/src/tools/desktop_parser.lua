local gears = require("gears")
local GLib = require("lgi").GLib

local m = {}

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

---Returns every found .desktop file that has NoDesktop=false or unset
---@return table
function m.Get_all_visible_desktop()
  local dirs = get_paths()
  local desktops = {}
  for _, dir in ipairs(dirs) do
    local files = io.popen('find "' .. dir .. '" -type f,l')
    if files then
      for file in files:lines() do
        if gears.filesystem.file_readable(file) then
          --[[ local symlink = lfs.symlinkattributes(file, "target")
          if symlink then
            file = dir .. symlink
          end ]]
          local handler = io.open(file, "r")
          if not handler then
            return {}
          end
          while true do
            local line = handler:read()
            if not line then break end
            if line:match("^%[Desktop Entry%]") then
              local name, comment, icon, exec, keywords, terminal, categories, nodisplay = "", "", "", "", "", "", "",
                  false
              while true do
                local prop = handler:read() or nil
                if ((not prop) and name ~= "") or prop:match("^%[(.+)%]") then
                  local desktop_table = {
                    name = name or "",
                    comment = comment or "",
                    icon = icon or "",
                    exec = exec or "",
                    keywords = keywords or "",
                    terminal = terminal or false,
                    categories = categories or "",
                    nodisplay = nodisplay or false,
                    file = file
                  }
                  table.insert(desktops, desktop_table)
                  break
                end

                if prop:match("^Name=") then
                  name = prop:match("Name=(.+)")
                end
                if prop:match("^Comment=") then
                  comment = prop:match("Comment=(.+)")
                end
                if prop:match("^Icon=") then
                  icon = prop:match("Icon=(.+)")
                end
                if prop:match("^Exec=") then
                  exec = prop:match("Exec=(.+)"):gsub("%%u", ""):gsub("%%U", ""):gsub("%%f", ""):gsub("%%F", ""):gsub("%%i"
                    , ""):gsub("%%c", ""):gsub("%%k", "")
                end
                if prop:match("^Keywords=") then
                  keywords = prop:match("Keywords=(.+)")
                end
                if prop:match("^Terminal=") then
                  terminal = prop:match("Terminal=(.+)")
                end
                if prop:match("^Categories=") then
                  categories = prop:match("Categories=(.+)")
                end
                if prop:match("^NoDisplay=") then
                  nodisplay = prop:match("NoDisplay=(.+)")
                  if nodisplay == "false" then
                    nodisplay = false
                  else
                    nodisplay = true
                  end
                end
              end
              break
            end
          end
          handler:close()
        end
      end
      files:close()
    end
  end
  return desktops
end

---Returns every .desktop file into a table
---@param file table .desktop files
---@return table
function m.Get_desktop_values(file)

  if not file or file == "" then
    return {}
  end

  local handler = nil

  for _, dir in ipairs(get_paths()) do
    handler = io.open(dir .. "/" .. file, "r")
    if handler then
      break
    end
  end

  if not handler then
    return {}
  end

  local desktop_table = {}
  while true do
    local line = handler:read()

    if not line then
      break
    end

    if line:match("^%[Desktop Entry%]") then
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
          -- Second match is to remove the %u, %U and %f, %F some applications use to open a URI/URL. It's not needed here
          desktop_table["Exec"] = property:match("Exec=(.+)"):gsub("%%u", ""):gsub("%%U", ""):gsub("%%f", ""):gsub("%%F"
            , ""):gsub("%%i", ""):gsub("%%c", ""):gsub("%%k", "")
        elseif property:match("^Icon=") then
          desktop_table["Icon"] = property:match("Icon=(.+)")
        end
      end
    end
  end
  handler:close()
  return desktop_table
end

return m
