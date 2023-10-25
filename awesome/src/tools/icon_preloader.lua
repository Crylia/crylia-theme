local setmetatable = setmetatable

local aspawn = require("awful.spawn")
local lgi = require('lgi')
local cairo = lgi.cairo
local gfilesystem = require('gears.filesystem')
local gsurface = require('gears.surface')
local gtable = require('gears.table')
local gobject = require('gears.object')

--[[
  Preload all external image or svg files as cairo surfaces and return them,
  if no icon is found an empty surface is returned
]]

local cache = {}
local ret = {}

local instance = nil
if not instance then
  instance = setmetatable(ret, {
    __call = function()
      gtable.crush(ret, gobject{}, true)

      local icon_path = gfilesystem.get_configuration_dir() .. 'src/assets/icons/'
      local layout_path = gfilesystem.get_configuration_dir() .. 'src/assets/layout/'
      aspawn.easy_async_with_shell('ls -a "' .. icon_path .. '"', function(stdout)
        for str in stdout:gmatch("([^\n]*)\n?") do
          if str ~= "" and str ~= "." and str ~= ".." then
            local surface = cairo.ImageSurface(cairo.ARGB, 64, 64)
            cache[str] = surface
          end
        end
        ret:emit_signal("done")
      end)
      aspawn.easy_async_with_shell('ls -a "' .. layout_path .. '"', function(stdout)
        for str in stdout:gmatch("([^\n]*)\n?") do
          if str ~= "" and str ~= "." and str ~= ".." then
            local surface = cairo.ImageSurface(cairo.ARGB, 64, 64)
            cache[str] = surface
          end
        end
      end)
      return ret
    end,
    __index = function(self,key)
      print(key, cache[key])
      if key and cache[key] then
        print("test")
        return cache[key]
      elseif(key == "user_image") or (key == "background") or (key == "os_logo") then
        return cache[key]
      else
        --return cairo.ImageSurface()
      end
    end
  })
end

return instance
