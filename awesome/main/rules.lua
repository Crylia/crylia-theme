-------------------------------------------------------------------------------------------------
-- This class contains rules for float exceptions or special themeing for certain applications --
-------------------------------------------------------------------------------------------------

-- Awesome Libs
local awful = require("awful")
local beautiful = require("beautiful")

local _M = { }

function _M.get(clientkeys, clientbuttons)
    local rules = {
        {
            rule = { },
            properties = {
                border_width = beautiful.border_width,
                border_color = beautiful.border_normal,
                focus  = awful.client.focus.filter,
                raise = true,
                keys = clientkeys,
                buttons = clientbuttons,
                screen = awful.screen.preferred,
                placement = awful.placement.no_overlap+awful.placement.no_offscreen
            }
        },
        {
            rule_any = {
                instance = { },
                class = {
                    "Arandr",
                    "Tor Browser"
                },
                name = { },
                role = {
                    "AlarmWindow",
                    "ConfigManager",
                    "pop-up"
                }
            },
            properties = { floating = true, titlebars_enabled = true }
        },
        {
            id = "titlebar",
            rule_any = {
                type = { "normal", "dialog", "modal", "utility" }
            },
            properties = { titlebars_enabled = true }
        }
    }
    return rules
end

return _M.get