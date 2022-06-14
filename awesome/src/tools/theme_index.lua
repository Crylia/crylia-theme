local theme_index = { mt = {} }

theme_index.new = function(cls, theme, basedirs)
  local self = {}
  setmetatable(self, { __index = cls })

  self.icon_theme_name = theme or User_config.icon_theme
  self.base_dir = nil
  self["Directories"] = {}
  self["Inherits"] = {}
  self.per_directory_keys = {}

  local basedir, handler = nil, nil
  for _, dir in ipairs(basedirs) do
    basedir = dir .. "/" .. self.icon_theme_name
    handler = io.open(basedir .. "/index.theme", "r")
    if handler then
      break
    end
  end

  if not handler then
    return self
  end
  self.base_dir = basedir

  while true do
    local line = handler:read()

    if not line then
      break
    end

    local header = line:match("^%[(.+)%]$")
    if header then
      if header == "Icon Theme" then
        while true do
          local property = handler:read()

          if not property then
            break
          end

          if property:match("^%[(.+)%]$") then
            handler:seek("cur", -string.len(property) - 1)
            break
          end

          local key, value = property:match("^(%w+)=(.*)$")
          if key == "Directories" or key == "Inherits" then
            string.gsub(value, "([^,]+),?", function(match)
              table.insert(self[key], match)
            end)
          end
        end

      else
        local keys = {}

        while true do
          local property = handler:read()
          if not property then
            break
          end

          if property:match("^%[(.+)%]$") then
            handler:seek("cur", -string.len(property) - 1)
            break
          end

          local key, value = property:match("^(%w+)=(%w+)$")
          if key == "Size" or key == "MinSize" or key == "MaxSize" or key == "Threshold" then
            keys[key] = tonumber(value)
          elseif key == "Type" then
            keys[key] = value
          end
        end

        if keys["Size"] then
          if not keys["Type"] then keys["Type"] = "Threshold" end
          if not keys["MinSize"] then keys["MinSize"] = keys["Size"] end
          if not keys["MaxSize"] then keys["MaxSize"] = keys["Size"] end
          if not keys["Threshold"] then keys["Threshold"] = 2 end
          self.per_directory_keys[header] = keys
        end
      end
    end
  end
  handler:close()

  return self
end

theme_index.get_subdirectories = function(self)
  return self["Directories"]
end

theme_index.get_inherits = function(self)
  return self["Inherits"]
end

theme_index.mt.__call = function(cls, theme, basedirs)
  return theme_index.new(cls, theme, basedirs)
end

return setmetatable(theme_index, theme_index.mt)
