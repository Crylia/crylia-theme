-----------------------------------------------------
-- Helper to get icons from a program/program name --
-----------------------------------------------------
local naughty = require("naughty")
-- tries to find a matching file name in /usr/share/icons/THEME/RESOLUTION/apps/ and if not found tried with first letter
-- as uppercase, this should get almost all icons to work with the papirus theme atleast
-- TODO: try with more icon themes
function Get_icon(theme, c, is_steam)
    if theme ~= nil and c ~= nil then
        local clientName
        if type(c) == "string" then
            if c:match("com.*%a") ~= nil then
                c = c:gsub("com.", ""):gsub(".Client", ""):gsub("flatpak", ""):gsub("run", ""):gsub(" ", "")
            end
        end
        if is_steam then
            clientName = "steam_icon_" .. tostring(c) .. ".svg"
        else
            if c.class ~= nil then
                clientName = string.lower(c.class) .. ".svg"
            elseif c.name ~= nil then
                clientName = string.lower(c.name) .. ".svg"
            elseif type(c) == "string" then
                clientName = c .. ".svg"
            else
                return
            end
        end
        local resolutions = { "128x128", "96x96", "64x64", "48x48", "42x42", "32x32", "24x24", "16x16" }
        for i, res in ipairs(resolutions) do
            local iconDir = "/usr/share/icons/" .. theme .. "/" .. res .. "/apps/"
            local ioStream = io.open(iconDir .. clientName, "r")
            if ioStream ~= nil then
                return iconDir .. clientName
            else
                clientName = clientName:gsub("^%l", string.upper)
                iconDir = "/usr/share/icons/" .. theme .. "/" .. res .. "/apps/"
                ioStream = io.open(iconDir .. clientName, "r")
                if ioStream ~= nil then
                    return iconDir .. clientName
                elseif type(c) ~= type("") then
                    if pcall(
                        function()
                            if c:Get_icon(1) then
                                error("icon error")
                            else
                                return c:Get_icon(1)
                            end
                        end
                    ) then
                        return nil
                    end
                end
            end
        end
    end
    if c.icon == nil then
        return "/usr/share/icons/Papirus-Dark/128x128/apps/application-default-icon.svg"
    else
        return c.icon
    end
end
