---------------------------------------
-- This is the brightness_osd module --
---------------------------------------

-- Awesome Libs
local aplacement = require('awful.placement')
local apopup = require('awful.popup')
local dpi = require('beautiful').xresources.apply_dpi
local gcolor = require('gears.color')
local gfilesystem = require('gears.filesystem')
local gshape = require('gears.shape')
local gtable = require('gears.table')
local gtimer = require('gears.timer')
local wibox = require('wibox')

local backlight_helper = require('src.tools.helpers.backlight')

local capi = {
  awesome = awesome,
  mouse = mouse,
}

-- Icon directory path
local icondir = gfilesystem.get_configuration_dir() .. 'src/assets/icons/brightness/'

local brightness_osd = { mt = {} }

-- Hide the brightness_osd after 3 seconds
function brightness_osd:run()
  self.visible = true
  if self.timer.started then
    self.timer:again()
  else
    self.timer:start()
  end
end

function brightness_osd.new(args)
  args = args or {}

  local w = apopup {
    widget = {
      {
        {
          { -- Brightness Icon
            {
              image = gcolor.recolor_image(icondir .. 'volume-off.svg', Theme_config.brightness_ods.icon_color),
              valign = 'center',
              halign = 'center',
              resize = true,
              id = 'icon_role',
              widget = wibox.widget.imagebox
            },
            widget = wibox.container.constraint,
            width = dpi(25),
            height = dpi(25),
            strategy = 'exact'
          },
          { -- Brightness Bar
            {
              {
                id = 'progressbar',
                color = Theme_config.brightness_ods.bar_bg_active,
                background_color = Theme_config.brightness_ods.bar_bg,
                max_value = 100,
                value = 0,
                shape = gshape.rounded_rect,
                widget = wibox.widget.progressbar
              },
              widget = wibox.container.constraint,
              width = dpi(250),
              height = dpi(5),
            },
            widget = wibox.container.place
          },
          { -- Brightness text
            widget = wibox.widget.textbox,
            id = 'text_role',
            text = '0',
            valign = 'center',
            halign = 'center'
          },
          spacing = dpi(10),
          layout = wibox.layout.fixed.horizontal
        },
        left = dpi(10),
        right = dpi(10),
        top = dpi(20),
        bottom = dpi(20),
        widget = wibox.container.margin
      },
      shape = Theme_config.brightness_ods.shape,
      widget = wibox.container.background
    },
    ontop = true,
    stretch = false,
    visible = false,
    border_color = Theme_config.brightness_ods.border_color,
    border_width = Theme_config.brightness_ods.border_width,
    fg = Theme_config.brightness_ods.fg,
    bg = Theme_config.brightness_ods.bg,
    screen = 1,
    placement = function(c) aplacement.bottom(c, { margins = dpi(20) }) end,
  }

  gtable.crush(w, brightness_osd, true)

  w.timer = gtimer {
    timeout = 2,
    autostart = true,
    callback = function()
      w.visible = false
    end
  }

  backlight_helper:connect_signal('brightness_changed', function()
    backlight_helper:brightness_get_async(function(brightness)
      brightness = brightness / (backlight_helper.brightness_max or 24000) * 100
      w.widget:get_children_by_id('progressbar')[1].value = brightness

      local icon = icondir .. 'brightness'
      if brightness >= 0 and brightness < 34 then
        icon = icon .. '-low.svg'
      elseif brightness >= 34 and brightness < 67 then
        icon = icon .. '-medium.svg'
      elseif brightness >= 67 then
        icon = icon .. '-high.svg'
      end

      w.widget:get_children_by_id('icon')[1]:set_image(gcolor.recolor_image(icon, Theme_config.brightness_osd.icon_color))
      w.widget:get_children_by_id('text_role')[1].text = brightness
      w:run()
    end)
  end)

  return w
end

function brightness_osd.mt:__call(...)
  return brightness_osd.new(...)
end

return setmetatable(brightness_osd, brightness_osd.mt)
