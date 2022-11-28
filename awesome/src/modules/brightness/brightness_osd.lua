---------------------------------------
-- This is the brightness_osd module --
---------------------------------------

-- Awesome Libs
local aplacement = require("awful.placement")
local apopup = require("awful.popup")
local dpi = require("beautiful").xresources.apply_dpi
local gcolor = require("gears.color")
local gfilesystem = require("gears.filesystem")
local gtable = require("gears.table")
local gshape = require("gears.shape")
local gtimer = require("gears.timer")
local wibox = require("wibox")

local backlight_helper = require("src.tools.helpers.backlight")

local capi = {
  awesome = awesome,
  mouse = mouse,
}

-- Icon directory path
local icondir = gfilesystem.get_configuration_dir() .. "src/assets/icons/brightness/"

local brightness_osd = { mt = {} }

-- Hide the brightness_osd after 3 seconds
function brightness_osd:hide()
  self.timer:stop(false)
end

-- Rerun the timer
function brightness_osd:rerun()
  self.visible = true
  self.timer:again(true)
end

-- Show the brightness_osd for 3 seconds
function brightness_osd:show()
  self.visible = true
  self.timer:start(true)
end

function brightness_osd.new(args)
  args = args or {}

  local osd = apopup {
    widget = {
      {
        {
          { -- Brightness Icon
            image = gcolor.recolor_image(icondir .. "brightness-high.svg", Theme_config.brightness_osd.icon_color),
            valign = "center",
            halign = "center",
            resize = false,
            id = "icon",
            widget = wibox.widget.imagebox
          },
          { -- Brightness Bar
            {
              {
                id = "progressbar1",
                color = Theme_config.brightness_osd.bar_bg_active,
                background_color = Theme_config.brightness_osd.bar_bg,
                max_value = 100,
                value = 0,
                forced_height = dpi(6),
                shape = function(cr, width, height)
                  gshape.rounded_bar(cr, width, height, dpi(6))
                end,
                widget = wibox.widget.progressbar
              },
              id = "progressbar_container2",
              halign = "center",
              valign = "center",
              widget = wibox.container.place
            },
            id = "progressbar_container",
            width = dpi(240),
            heigth = dpi(20),
            stragety = "max",
            widget = wibox.container.constraint
          },
          id = "layout1",
          spacing = dpi(10),
          layout = wibox.layout.fixed.horizontal
        },
        id = "margin",
        margins = dpi(10),
        widget = wibox.container.margin
      },
      forced_width = dpi(300),
      forced_height = dpi(80),
      border_color = Theme_config.brightness_osd.border_color,
      border_width = Theme_config.brightness_osd.border_width,
      fg = Theme_config.brightness_osd.fg,
      bg = Theme_config.brightness_osd.bg,
      widget = wibox.container.background
    },
    ontop = true,
    stretch = false,
    visible = false,
    screen = args.screen,
    placement = function(c) aplacement.bottom_left(c, { margins = dpi(20) }) end,
    shape = function(cr, width, height)
      gshape.rounded_rect(cr, width, height, dpi(14))
    end
  }

  gtable.crush(osd, brightness_osd, true)

  -- Called when the brightness changes, updates the brightness osd and icon
  capi.awesome.connect_signal("brightness::changed", function(brightness)
    if not capi.mouse.screen == args.screen then return end
    assert(type(brightness) == "number", "brightness must be a number")

    brightness = (brightness - 0) / ((backlight_helper.brightness_max or 24000) - 0) * 100
    osd.widget:get_children_by_id("progressbar1")[1].value = brightness

    local icon = icondir .. "brightness"
    if brightness >= 0 and brightness < 34 then
      icon = icon .. "-low.svg"
    elseif brightness >= 34 and brightness < 67 then
      icon = icon .. "-medium.svg"
    elseif brightness >= 67 then
      icon = icon .. "-high.svg"
    end

    osd:rerun(true)
    osd.widget:get_children_by_id("icon")[1]:set_image(gcolor.recolor_image(icon,
      Theme_config.brightness_osd.icon_color))
  end)

  -- osd timer
  osd.timer = gtimer {
    timeout = 3,
    single_shot = true,
    callback = function()
      osd.visible = false
    end
  }
end

function brightness_osd.mt:__call(...)
  return brightness_osd.new(...)
end

return setmetatable(brightness_osd, brightness_osd.mt)
