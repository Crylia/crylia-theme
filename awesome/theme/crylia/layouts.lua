--Awesome Libs
local color = require("theme.crylia.colors")
local gears = require("gears")

-- Icon directory path
local layout_path = Theme_path .. "assets/layout/"

-- Here are the icons for the layouts defined, if you want to add more layouts go to main/layouts.lua
Theme.layout_floating = gears.color.recolor_image(layout_path .. "floating.svg", color.color["Grey900"])
Theme.layout_tile = gears.color.recolor_image(layout_path .. "tile.svg", color.color["Grey900"])
--Theme.layout_dwindle = gears.color.recolor_image(layout_path .. "dwindle.svg", color.color["Grey900"])
--Theme.layout_fairh = gears.color.recolor_image(layout_path .. "fairh.svg", color.color["Grey900"])
--Theme.layout_fullscreen = gears.color.recolor_image(layout_path .. "fullscreen.svg", color.color["Grey900"])
--Theme.layout_max = gears.color.recolor_image(layout_path .. "max.svg", color.color["Grey900"])