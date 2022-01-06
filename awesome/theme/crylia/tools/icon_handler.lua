------------------------------
-- This is the audio widget --
------------------------------
local naughty = require("naughty")
local awful = require("awful")

function Get_icon(theme, c)
    if theme and c then
        local clientName
        clientName = string.lower(c.class) .. ".svg"
        local resolutions = {"128x128", "96x96", "64x64", "48x48", "42x42", "32x32", "24x24", "16x16"}
        for i, res in ipairs(resolutions) do
            local iconDir = "/usr/share/icons/" .. theme .. "/" .. res .."/apps/"
            local ioStream = io.open(iconDir .. clientName, "r")
            if ioStream ~= nil then
                return iconDir .. clientName
            else
                return c.icon
            end
        end
    end
    return c:Get_icon(1)
end

function Get_icon_by_class_name(theme, c)
    if theme and c then
        local c_name = string.lower(c) .. ".svg"
        local resolutions = {"128x128", "96x96", "64x64", "48x48", "42x42", "32x32", "24x24", "16x16"}
        for i, res in ipairs(resolutions) do
            local iconDir = "/usr/share/icons/" .. theme .. "/" .. res .."/apps/"
            local ioStream = io.open(iconDir .. c_name, "r")
            if ioStream ~= nil then
                return iconDir .. c_name
            end
        end
    end
end

function Get_icon_by_desktop(theme, c)
    
end