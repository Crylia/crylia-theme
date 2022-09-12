-- Libraries
local lgi = require("lgi")
local Gtk = lgi.require("Gtk", "3.0")
local Gio = lgi.Gio
local gears = require("gears")
local GLib = require("lgi").GLib

-- Get all .desktop files as gobjects
local app_info = Gio.AppInfo
local app_list = app_info.get_all()

-- Init a new Gtk theme from the users string
local gtk_theme = Gtk.IconTheme.new()
Gtk.IconTheme.set_custom_theme(gtk_theme, User_config.icon_theme)

---Gets the icon path from an AppInfo gicon.
---@param app Gio.AppInfo
---@return string path
function Get_gicon_path(app)
  local icon_info = gtk_theme:lookup_by_gicon(app, 64, 0)
  if icon_info then
    local path = icon_info:get_filename()
    if path then
      return path
    end
  end
  return ""
end

---Takes a class and name string and tries to match it to an icon.
---@param class string
---@param name string
---@return string | nil icon_path
function Get_icon(class, name)
  class = string.lower(class or "")
  name = string.lower(name or "")
  for _, app in ipairs(app_list) do
    local desktop_app_info = Gio.DesktopAppInfo.new(app_info.get_id(app))
    local icon_string = Gio.DesktopAppInfo.get_string(desktop_app_info, "Icon")
    if icon_string then
      icon_string = string.lower(icon_string)
      if icon_string == class or icon_string == name then
        return Get_gicon_path(app_info.get_icon(app))
      elseif icon_string:match(class) then
        return Get_gicon_path(app_info.get_icon(app))
      end
    end
  end
  return nil
end

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
---@param file string .desktop files
---@return string | nil path
function Get_desktop_values(file)

  if not file or file == "" then
    return
  end

  for _, dir in ipairs(get_paths()) do
    if gears.filesystem.file_readable(dir .. "/" .. file, "r") then
      return dir .. "/" .. file
    end
  end
end
