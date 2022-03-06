-----------------------------------------------------
-- Helper to get icons from a program/program name --
-----------------------------------------------------

-- tries to find a matching file name in /usr/share/icons/THEME/RESOLUTION/apps/ and if not found tried with first letter
-- as uppercase, this should get almost all icons to work with the papirus theme atleast
-- TODO: try with more icon themes
function Get_icon(theme, c, is_steam)
    if theme and c then
        local clientName
        -- TODO: Access steamdb api to fetch the clienticon if there is no icon found in this theme
        if is_steam then
            clientName = "steam_icon_" .. tostring(c) .. ".svg"
        else
            if type(c) == type("") then
                clientName = string.lower(c) .. ".svg"
            else
                clientName = string.lower(c.class) .. ".svg"
            end
        end
        local resolutions = {"128x128", "96x96", "64x64", "48x48", "42x42", "32x32", "24x24", "16x16"}
        for i, res in ipairs(resolutions) do
            local iconDir = "/usr/share/icons/" .. theme .. "/" .. res .."/apps/"
            local ioStream = io.open(iconDir .. clientName, "r")
            if ioStream ~= nil then
                return iconDir .. clientName
            else
                clientName = clientName:gsub("^%l", string.upper)
                iconDir = "/usr/share/icons/" .. theme .. "/" .. res .."/apps/"
                ioStream = io.open(iconDir .. clientName, "r")
                 if ioStream ~= nil then
                    return iconDir .. clientName
                elseif type(c) ~= type("") then
                    local naughty = require("naughty")
                    if pcall(
                        function ()
                            if c:Get_icon(1) then
                                 error("icon error")
                            else
                                return c:Get_icon(1)
                            end
                    end
                    ) then
                        return nil
                    end
                    return "/usr/share/icons/Papirus-Dark/128x128/apps/Zoom.svg"
                    
                end
            end
        end
    end
    return nil
end
