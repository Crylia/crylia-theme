local lgi = require('lgi')
local GLib = lgi.GLib
local Gio = lgi.Gio
local gobject = require('gears.object')
local gtable = require('gears.table')
local gfilesystem = require('gears.filesystem')
local aspawn = require('awful.spawn')

local json = require('src.lib.json-lua.json-lua')

local config = {}

local instance

---Takes a file path and puts the content into the callback
---@param path string file path, caller has to make sure it exists
---@return string|nil file_content
config.read = function(path)
  local handler = io.open(path, 'r')
  if not handler then error('Invalid path') return end

  local content = handler:read('*all')
  handler:close()
  return content
end

---Writes a string to a file
---@param path string file path, caller has to make sure it exists
---@param content string content to write
config.write = function(path, content)
  local handler = io.open(path, 'w')
  if not handler then error('Invalid path') return end

  handler:write(content)
  handler:close()
end

config.read_json = function(path)
  local handler = io.open(path, 'r')
  if not handler then error('Invalid path') return end

  local content = handler:read('*all')
  handler:close()

  local json_content = json:decode(content) or {}
  assert(type(json_content) == 'table', 'json is not a table')
  return json_content
end

config.write_json = function(path, content)
  local json_content = json:encode(content)
  assert(type(json_content) == 'string', 'json is not a string')

  local handler = io.open(path, 'w')
  if not handler then error('Invalid path') return end

  handler:write(json_content)
  handler:close()
end

local function new()
  local ret = gobject {}

  gtable.crush(ret, config, true)

  -- Create config files if they don't exist
  for _, file in pairs { 'floating.json', 'dock.json', 'desktop.json', 'applications.json' } do
    if not gfilesystem.file_readable(gfilesystem.get_configuration_dir() .. 'src/config/' .. file) then
      aspawn('touch ' .. gfilesystem.get_configuration_dir() .. 'src/config/' .. file)
    end
  end

  -- Create config directories if they don't exist
  for _, dir in pairs { 'files/desktop/icons' } do
    if not gfilesystem.dir_readable(gfilesystem.get_configuration_dir() .. 'src/config/' .. dir) then
      gfilesystem.make_directories(gfilesystem.get_configuration_dir() .. 'src/config/' .. dir)
    end
  end

  return ret
end

if not instance then
  instance = new()
end

return instance
