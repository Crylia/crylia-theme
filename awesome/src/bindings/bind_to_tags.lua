-- Awesome Libs
local awful = require("awful")
local gears = require("gears")
local globalkeys = require("src.bindings.global_keys")
local modkey = User_config.modkey

local capi = {
  client = client,
  root = root
}

for i = 1, 9 do
  globalkeys = gears.table.join(globalkeys,

    -- View tag only
    awful.key(
      { modkey },
      "#" .. i + 9,
      function()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        if tag then
          tag:view_only()
        end
        capi.client.emit_signal("tag::switched")
      end,
      { description = "View Tag " .. i, group = "Tag" }
    ),
    -- Brings the window over without chaning the tag, reverts automatically on tag change
    awful.key(
      { modkey, "Control" },
      "#" .. i + 9,
      function()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        if tag then
          awful.tag.viewtoggle(tag)
        end
      end,
      { description = "Toggle Tag " .. i, group = "Tag" }
    ),
    -- Brings the window over without chaning the tag, reverts automatically on tag change
    awful.key(
      { modkey, "Shift" },
      "#" .. i + 9,
      function()
        local screen = awful.screen.focused()
        if capi.client.focus then
          local tag = screen.tags[i]
          if tag then
            capi.client.focus:move_to_tag(tag)
          end
        end
      end,
      { description = "Move focused client on tag " .. i, group = "Tag" }
    ),
    -- Brings the window over without chaning the tag, reverts automatically on tag change
    awful.key(
      { modkey, "Control", "Shift" },
      "#" .. i + 9,
      function()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        if tag then
          awful.tag.viewtoggle(tag)
        end
      end,
      { description = "Move focused client on tag " .. i, group = "Tag" }
    )
  )
end
capi.root.keys(globalkeys)
