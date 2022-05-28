-----------------------------------------------------
-- Helper to get icons from a program/program name --
-----------------------------------------------------
local awful = require("awful")

local LIP = require("src.lib.LIP.LIP")

local icon_finder = {}

local icon_extensions = { "png", "svg", "xmp" }
local default_icon = user_vars.application_default_icon or awful.util.getdir("config") .. "src/assets/icons/application-default-icon.svg"
local icon_cache = {}
local fallback_icon_dirs = {}

local do_icon_lookup = function(icon_name, theme_file)
  local theme = LIP.load(theme_file)
  local theme_name = theme_file:match('.*/(.*)/')

  -- get the sizes of dirs
  local dir_sizes = {}
  for subdir in theme["Icon Theme"]["Directories"]:gmatch("([^,]+)") do
    table.insert(dir_sizes, { dir = subdir, size = theme[subdir]["Size"] })
  end

  -- sort them by size
  table.sort(dir_sizes, function(a, b) return a["size"] > b["size"] end)

  -- we'll now search for a file beginning with the greatest
  for _, dir_size in pairs(dir_sizes) do
    for _, icon_dir in ipairs(fallback_icon_dirs) do
      for _, ext in ipairs(icon_extensions) do
        local file_name = string.format("%s/%s/%s/%s.%s", icon_dir, theme_name, dir_size["dir"], icon_name, ext)
        if io.open(file_name, "r") ~= nil then
          return file_name
        end
      end
    end
  end
end

local lookup_theme_file = function(theme)
  -- lookup thmefile
  for _, icon_dir in ipairs(fallback_icon_dirs) do
    local index_file = icon_dir .. "/" .. theme .. "/index.theme"
    if io.open(index_file, "r") then
      return index_file
    end
  end
  return nil
end

local do_recursive_icon_lookup
do_recursive_icon_lookup = function(icon_name, theme_name, checked_themes)
  -- exclude multiple scans
  if checked_themes[theme_name] then
    return nil
  end
  checked_themes[theme_name] = true

  -- check if theme exists
  local theme_file = lookup_theme_file(theme_name)
  if theme_file == nil then
    return nil
  end

  -- check if icon exists
  local icon_path
  icon_path = do_icon_lookup(icon_name, theme_file)
  if icon_path ~= nil then
    return icon_path
  end

  -- check its parents too
  local theme = LIP.load(theme_file)
  local inherits = theme["Icon Theme"]["Inherits"]
  if inherits == nil or inherits == "" then
    if theme["Icon Theme"]["Name"] ~= "hicolor" then
      inherits = "hicolor"
    else
      inherits = ""
    end
  end

  for parent in inherits:gmatch("([^,]+)") do
    icon_path = do_recursive_icon_lookup(icon_name, parent, checked_themes)
    if icon_path ~= nil then
      return icon_path
    end
  end

end

-- tries to find a matching file name in /usr/share/icons/THEME/RESOLUTION/apps/ and if not found tried with first letter
-- as uppercase, this should get almost all icons to work with the papirus theme atleast
function icon_finder.search(icon_name, theme)
  theme = theme or user_vars.icon_theme

  -- if we have an absolute path, just return it
  if icon_name:sub(1, 1) == "/" then
    if io.open(icon_name, "r") ~= nil then
      return icon_name
    else
      return default_icon
    end
  end

  -- check if it has an extension and strip it
  for _, ext in ipairs(icon_extensions) do
    ext = "." .. ext
    if icon_name:sub(-ext:len()) == ext then
      icon_name = icon_name:sub(1, -ext:len() - 1)
      break
    end
  end

  -- check cache
  if icon_cache[icon_name] then
    return icon_cache[icon_name]
  end

  local checked_themes = {}
  local icon_path
  -- lookup themefile
  icon_path = do_recursive_icon_lookup(icon_name, theme, checked_themes)
  if icon_path ~= nil then
    icon_cache[icon_name] = icon_path
    return icon_path
  end

  -- lookup in hicolor
  if checked_themes["hicolor"] == nil then
    icon_path = do_recursive_icon_lookup(icon_name, "hicolor", checked_themes)
    if icon_path ~= nil then
      icon_cache[icon_name] = icon_path
      return icon_path
    end
  end

  -- now search unsorted
  for _, icon_dir in ipairs(fallback_icon_dirs) do
    for _, ext in ipairs(icon_extensions) do
      icon_path = string.format("%s/%s.%s", icon_dir, icon_name, ext)
      if io.open(icon_path, "r") then
        icon_cache[icon_name] = icon_path
        return icon_path
      end
    end
  end

  -- nothing found, save though to avoid repeated expensive lookups
  icon_cache[icon_name] = default_icon
  return default_icon
end

function icon_finder.init()
  -- retrieve fallback_icon_dirs
  if io.open(os.getenv("HOME") .. "/.icons", "r") ~= nil then
    table.insert(fallback_icon_dirs, os.getenv("HOME") .. "/.icons")
  end

  for _, base_dir in ipairs({ os.getenv("HOME") .. "/.local/share", "/usr/local/share", "/usr/share" }) do
    if io.open(base_dir .. "/icons", "r") ~= nil then
      table.insert(fallback_icon_dirs, base_dir .. "/icons")
    end
  end

  if io.open("/usr/share/pixmaps", "r") ~= nil then
    table.insert(fallback_icon_dirs, "/usr/share/pixmaps")
  end
end

function icon_finder.from_client(client)
  local name = default_icon
  if client.class then
    name = client.class
  elseif client.name then
    name = client.name
  elseif client.icon then
    return client.icon
  else
    return default_icon
  end

  local icon_path = icon_finder.search(name:lower())
  if icon_path ~= default_icon then
    return icon_path
  end
  icon_path = icon_finder.search(name:gsub(" ", "-"):lower())
  if icon_path ~= default_icon then
    return icon_path
  end
  return icon_finder.search(name:gsub("^%L", string.lower):gsub("[A-Z]", function(char)
    return " " .. char
  end):gsub(" ", "-"):lower())
end

function icon_finder.from_class_or_program(class, program)
  local icon_path = icon_finder.search(class)
  if icon_path ~= default_icon then
    return icon_path
  end
  return icon_finder.search(program)
end

return icon_finder
