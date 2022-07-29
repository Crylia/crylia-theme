-----------------------------------------------------
-- Helper to get icons from a program/program name --
-----------------------------------------------------

local gears = require("gears")
local GLib = require("lgi").GLib

local theme_index = require("src.tools.theme_index")

local function get_basedir()
  local dirs = {}

  local dir = GLib.build_filenamev({ GLib.get_home_dir(), ".icons" })
  if gears.filesystem.dir_readable(dir) then
    table.insert(dirs, dir)
  end

  dir = GLib.build_filenamev({ GLib.get_user_data_dir(), "icons" })
  if gears.filesystem.dir_readable(dir) then table.insert(dirs, dir) end

  for _, value in ipairs(GLib.get_system_data_dirs()) do
    dir = GLib.build_filenamev({ value, "icons" })
    if gears.filesystem.dir_readable(dir) then table.insert(dirs, dir) end
  end

  local need_usr_share_pixmaps = true
  for _, value in ipairs(GLib.get_system_data_dirs()) do
    dir = GLib.build_filenamev({ value, "icons" })
    if gears.filesystem.dir_readable(dir) then table.insert(dirs, dir) end
    if dir == "/usr/share/pixmaps" then
      need_usr_share_pixmaps = false
    end
  end

  dir = "/usr/share/pixmaps"
  if gears.filesystem.dir_readable(dir) then table.insert(dirs, dir) end
  if need_usr_share_pixmaps and gears.filesystem.dir_readable(dir) then
    table.insert(dirs, dir)
  end

  return dirs
end

local xdg_icon_lookup = { mt = {} }

local icon_cache = {}

xdg_icon_lookup.new = function(theme, base_dirs)
  local self = {}

  self.icon_theme = theme or User_config.icon_theme
  self.base_directories = base_dirs or get_basedir()
  self.file_extension = { "svg", "png", "xpm" }

  if not icon_cache[self.icon_theme] then
    icon_cache[self.icon_theme] = {}
  end

  local cache_key = table.concat(self.base_directories, ":")
  if not icon_cache[self.icon_theme][cache_key] then
    icon_cache[self.icon_theme][cache_key] = theme_index(self.icon_theme, self.base_directories)
  end
  self.theme_index = icon_cache[self.icon_theme][cache_key]

  return setmetatable(self, { __index = xdg_icon_lookup })
end

---Look for an fallback icon
---@param iconname any
---@return string|nil nil
local function lookup_fallback_icon(self, iconname)
  for _, dir in ipairs(self.base_directories) do
    for _, ext in ipairs(self.file_extension) do
      local filename = string.format("%s/%s.%s", dir, iconname, ext)
      if gears.filesystem.file_readable(filename) then
        return filename
      end
    end
  end
  return nil
end

---Checkes if the size equals the actual icon size
---@param subdir any
---@param iconsize any
---@return boolean
local function directory_matches_size(self, subdir, iconsize)
  local type, size, min_size, max_size, threshold = self.theme_index.per_directory_keys[subdir]["Type"],
      self.theme_index.per_directory_keys[subdir]["Size"], self.theme_index.per_directory_keys[subdir]["MinSize"],
      self.theme_index.per_directory_keys[subdir]["MaxSize"], self.theme_index.per_directory_keys[subdir]["Threshold"]

  if type == "Fixed" then
    return iconsize == size
  elseif type == "Scalable" then
    return iconsize >= min_size and iconsize <= max_size
  elseif type == "Threshold" then
    return iconsize >= size - threshold and iconsize <= size + threshold
  end

  return false
end

---Returns how far off the size is from the actual icon size
---@param subdir table
---@param iconsize number
---@return number
local function directory_size_distance(self, subdir, iconsize)
  local type, size, min_size, max_size, threshold = self.theme_index.per_directory_keys[subdir]["Type"],
      self.theme_index.per_directory_keys[subdir]["Size"], self.theme_index.per_directory_keys[subdir]["MinSize"],
      self.theme_index.per_directory_keys[subdir]["MaxSize"], self.theme_index.per_directory_keys[subdir]["Threshold"]

  if type and min_size and max_size and threshold then
    if type == "Fixed" then
      return math.abs(size - iconsize)
    elseif type == "Scalable" then
      if iconsize < min_size then
        return min_size - iconsize
      elseif iconsize > max_size then
        return iconsize - max_size
      end
      return 0
    elseif type == "Threshold" then
      if iconsize < size - threshold then
        return min_size - iconsize
      elseif iconsize > size + threshold then
        return iconsize - max_size
      end
      return 0
    end
  end
  return 0xffffffff
end

---Checks each and every sub directory for an icon
---@param iconname any
---@param size any
---@return string|unknown|nil path_to_icon
local function lookup_icon(self, iconname, size)
  local already_checked = {}
  for _, subdir in ipairs(self.theme_index:get_subdirectories()) do
    for _, dir in ipairs(self.base_directories) do
      for _, ext in ipairs(self.file_extension) do
        if directory_matches_size(self, subdir, size) then
          local filename = string.format("%s/%s/%s/%s.%s", dir, self.icon_theme, subdir, iconname, ext)
          if gears.filesystem.file_readable(filename) then
            return filename
          else
            already_checked[filename] = true
          end
        end
      end
    end
  end
  local min_size = 0xffffffff
  local closest_filename = nil
  for _, subdir in ipairs(self.theme_index:get_subdirectories()) do
    local dist = directory_size_distance(self, subdir, size)
    if dist < min_size then
      for _, dir in ipairs(self.base_directories) do
        for _, ext in ipairs(self.file_extension) do
          local filename = string.format("%s/%s/%s/%s.%s", dir, self.icon_theme, subdir, iconname, ext)
          if not already_checked[filename] then
            if gears.filesystem.file_readable(filename) then
              closest_filename = filename
              min_size = dist
            end
          end
        end
      end
    end
  end
  return closest_filename or nil
end

---Check if the icon inherits from another icon theme and search that for an icon
---@param icon any
---@param size any
---@param self any
---@return string|unknown|nil path_to_icon
local function find_icon_helper(self, icon, size)
  local filename = lookup_icon(self, icon, size)
  if filename then return filename end

  -- Exists purely for clients in hope to find a matching icon.
  filename = lookup_icon(self, icon:lower(), size)
  if filename then return filename end

  -- !Disabled for now until memory leak can be fixed.
  --[[ for _, parent in ipairs(self.theme_index:get_inherits()) do
    if parent == "hicolor" then
      return
    end
    filename = find_icon_helper(xdg_icon_lookup(parent, self.base_directories), icon, size)
    if filename then return filename end
  end ]]

  return nil
end

local iconcache = {}
---Takes an icon and its props and theme to search for it inside the theme
---@param icon any
---@param size any
---@return string|nil path_to_icon
function xdg_icon_lookup:find_icon(icon, size)
  size = size or 64


  if icon_cache[icon] == "" then return nil end
  if iconcache[icon] then return iconcache[icon] end

  if not icon or icon == "" then return nil end

  if gears.filesystem.file_readable(icon) then
    iconcache[icon] = icon
    return icon
  end

  local filename = find_icon_helper(self, icon, size)
  if filename then
    iconcache[icon] = filename
    return filename
  end

  filename = find_icon_helper(xdg_icon_lookup("hicolor", self.base_directories), icon, size)
  if filename then
    iconcache[icon] = filename
    return filename
  end

  filename = lookup_fallback_icon(self, icon)
  if filename then
    iconcache[icon] = filename
    return filename
  end

  iconcache[icon] = ""
  return nil
end

xdg_icon_lookup.mt.__call = function(_, ...)
  return xdg_icon_lookup.new(...)
end

return setmetatable(xdg_icon_lookup, xdg_icon_lookup.mt)
