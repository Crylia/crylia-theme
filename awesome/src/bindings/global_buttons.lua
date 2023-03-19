-- Awesome Libs
local gtable = require('gears.table')
local abutton = require('awful.button')
local atag = require('awful.tag')

local capi = {
  root = root
}

capi.root.buttons = gtable.join(
  abutton({}, 4, atag.viewnext),
  abutton({}, 5, atag.viewprev)
)
