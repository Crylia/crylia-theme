-------------------------------------------------------------------------------------------------
-- This class contains rules for float exceptions or special themeing for certain applications --
-------------------------------------------------------------------------------------------------

-- Awesome Libs
local awful = require("awful")
local beautiful = require("beautiful")
local ruled = require("ruled")

local json = require("src.lib.json-lua.json-lua")

awful.rules.rules = {
  {
    rule = {},
    properties = {
      border_width = beautiful.border_width,
      border_color = beautiful.border_normal,
      focus        = awful.client.focus.filter,
      raise        = true,
      keys         = require("src.bindings.client_keys"),
      buttons      = require("src.bindings.client_buttons"),
      screen       = awful.screen.preferred,
      placement    = awful.placement.under_mouse + awful.placement.no_overlap + awful.placement.no_offscreen +
          awful.placement.centered
    }
  },
  {
    id = "titlebar",
    rule_any = {
      type = {
        "normal",
        "dialog",
        "modal",
        "utility"
      }
    },
    properties = {
      titlebars_enabled = true
    }
  }
}

local handler = io.open("/home/crylia/.config/awesome/src/config/floating.json", "r")

if not handler then return end
local data = json:decode(handler:read("a"))
handler:close()

if type(data) ~= "table" then return end

for _, c in ipairs(data) do
  ruled.client.append_rule {
    rule = { class = c.WM_CLASS, instance = c.WM_INSTANCE },
    properties = {
      floating = true
    },
  }
end
