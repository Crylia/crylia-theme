-- Awesome Libs
local gears = require("gears")
local awful = require("awful")

local capi = {
  root = root
}

capi.root.buttons = gears.table.join(
  awful.button({}, 4, awful.tag.viewnext),
  awful.button({}, 5, awful.tag.viewprev)
)
