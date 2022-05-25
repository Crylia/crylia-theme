-----------------------------------------------------
-- Helper to get icons from a program/program name --
-----------------------------------------------------
local icon_cache = {}

-- tries to find a matching file name in /usr/share/icons/THEME/RESOLUTION/apps/ and if not found tried with first letter
-- as uppercase, this should get almost all icons to work with the papirus theme atleast
-- TODO: try with more icon themes
function Get_icon(theme, client, program_string, class_string, is_steam)

  client = client or nil
  program_string = program_string or nil
  class_string = class_string or nil
  is_steam = is_steam or nil

  if theme and (client or program_string or class_string) then
    local clientName
    if is_steam then
      clientName = "steam_icon_" .. tostring(client) .. ".svg"
    elseif client then
      if client.class then
        clientName = string.lower(client.class:gsub(" ", "")) .. ".svg"
      elseif client.name then
        clientName = string.lower(client.name:gsub(" ", "")) .. ".svg"
      else
        if client.icon then
          return client.icon
        else
          return "/usr/share/icons/Papirus-Dark/128x128/apps/application-default-icon.svg"
        end
      end
    else
      if program_string then
        clientName = program_string .. ".svg"
      else
        clientName = class_string .. ".svg"
      end
    end

    for _, icon in ipairs(icon_cache) do
      if icon:match(clientName) then
        return icon
      end
    end

    local resolutions = { "128x128", "96x96", "64x64", "48x48", "42x42", "32x32", "24x24", "16x16" }
    for _, res in ipairs(resolutions) do
      local iconDir = "/usr/share/icons/" .. theme .. "/" .. res .. "/apps/"
      local ioStream = io.open(iconDir .. clientName, "r")
      if ioStream ~= nil then
        icon_cache[#icon_cache + 1] = iconDir .. clientName
        return iconDir .. clientName
      else
        clientName = clientName:gsub("^%l", string.upper)
        iconDir = "/usr/share/icons/" .. theme .. "/" .. res .. "/apps/"
        ioStream = io.open(iconDir .. clientName, "r")
        if ioStream ~= nil then
          icon_cache[#icon_cache + 1] = iconDir .. clientName
          return iconDir .. clientName
        elseif not class_string then
          return "/usr/share/icons/Papirus-Dark/128x128/apps/application-default-icon.svg"
        else
          clientName = class_string .. ".svg"
          iconDir = "/usr/share/icons/" .. theme .. "/" .. res .. "/apps/"
          ioStream = io.open(iconDir .. clientName, "r")
          if ioStream ~= nil then
            icon_cache[#icon_cache + 1] = iconDir .. clientName
            return iconDir .. clientName
          else
            return "/usr/share/icons/Papirus-Dark/128x128/apps/application-default-icon.svg"
          end
        end
      end
    end
    if client then
      return "/usr/share/icons/Papirus-Dark/128x128/apps/application-default-icon.svg"
    end
  end
end

--———————————No swiches?———————————
--⠀⣞⢽⢪⢣⢣⢣⢫⡺⡵⣝⡮⣗⢷⢽⢽⢽⣮⡷⡽⣜⣜⢮⢺⣜⢷⢽⢝⡽⣝
--⠸⡸⠜⠕⠕⠁⢁⢇⢏⢽⢺⣪⡳⡝⣎⣏⢯⢞⡿⣟⣷⣳⢯⡷⣽⢽⢯⣳⣫⠇
--⠀⠀⢀⢀⢄⢬⢪⡪⡎⣆⡈⠚⠜⠕⠇⠗⠝⢕⢯⢫⣞⣯⣿⣻⡽⣏⢗⣗⠏⠀
--⠀⠪⡪⡪⣪⢪⢺⢸⢢⢓⢆⢤⢀⠀⠀⠀⠀⠈⢊⢞⡾⣿⡯⣏⢮⠷⠁⠀⠀
--⠀⠀⠀⠈⠊⠆⡃⠕⢕⢇⢇⢇⢇⢇⢏⢎⢎⢆⢄⠀⢑⣽⣿⢝⠲⠉⠀⠀⠀⠀
--⠀⠀⠀⠀⠀⡿⠂⠠⠀⡇⢇⠕⢈⣀⠀⠁⠡⠣⡣⡫⣂⣿⠯⢪⠰⠂⠀⠀⠀⠀
--⠀⠀⠀⠀⡦⡙⡂⢀⢤⢣⠣⡈⣾⡃⠠⠄⠀⡄⢱⣌⣶⢏⢊⠂⠀⠀⠀⠀⠀⠀
--⠀⠀⠀⠀⢝⡲⣜⡮⡏⢎⢌⢂⠙⠢⠐⢀⢘⢵⣽⣿⡿⠁⠁⠀⠀⠀⠀⠀⠀⠀
--⠀⠀⠀⠀⠨⣺⡺⡕⡕⡱⡑⡆⡕⡅⡕⡜⡼⢽⡻⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
--⠀⠀⠀⠀⣼⣳⣫⣾⣵⣗⡵⡱⡡⢣⢑⢕⢜⢕⡝⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
--⠀⠀⠀⣴⣿⣾⣿⣿⣿⡿⡽⡑⢌⠪⡢⡣⣣⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
--⠀⠀⠀⡟⡾⣿⢿⢿⢵⣽⣾⣼⣘⢸⢸⣞⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
--⠀⠀⠀⠀⠁⠇⠡⠩⡫⢿⣝⡻⡮⣒⢽⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
--—————————————————————————————
