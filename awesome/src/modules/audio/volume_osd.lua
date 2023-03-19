-----------------------------------
-- This is the volume_old module --
-----------------------------------

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

local audio_helper = require('src.tools.helpers.audio')

-- Icon directory path
local icondir = gfilesystem.get_configuration_dir() .. 'src/assets/icons/audio/'

local osd = {}

function osd:run()
  self.visible = true
  if self.timer.started then
    self.timer:again()
  else
    self.timer:start()
  end
end

function osd.new(args)
  args = args or {}
  args.screen = args.screen or 1

  local w = apopup {
    widget = {
      {
        {
          { -- Volume Icon
            {
              image = gcolor.recolor_image(icondir .. 'volume-off.svg', Theme_config.volume_osd.icon_color),
              valign = 'center',
              halign = 'center',
              resize = true,
              id = 'icon_role',
              widget = wibox.widget.imagebox,
            },
            widget = wibox.container.constraint,
            width = dpi(25),
            height = dpi(25),
            strategy = 'exact',
          },
          { -- Volume Bar
            {
              {
                id = 'progressbar',
                color = Theme_config.volume_osd.bar_bg_active,
                background_color = Theme_config.volume_osd.bar_bg,
                max_value = 100,
                value = 0,
                shape = gshape.rounded_rect,
                widget = wibox.widget.progressbar,
              },
              widget = wibox.container.constraint,
              width = dpi(250),
              height = dpi(5),
            },
            widget = wibox.container.place,
          },
          { -- Volume text
            widget = wibox.widget.textbox,
            id = 'text_role',
            text = '0',
            valign = 'center',
            halign = 'center',
          },
          spacing = dpi(10),
          layout = wibox.layout.fixed.horizontal,
        },
        left = dpi(10),
        right = dpi(10),
        top = dpi(20),
        bottom = dpi(20),
        widget = wibox.container.margin,
      },
      shape = Theme_config.volume_osd.shape,
      widget = wibox.container.background,
    },
    ontop = true,
    stretch = false,
    visible = false,
    border_color = Theme_config.volume_osd.border_color,
    border_width = Theme_config.volume_osd.border_width,
    fg = Theme_config.volume_osd.fg,
    bg = Theme_config.volume_osd.bg,
    screen = 1,
    placement = function(c) aplacement.bottom(c, { margins = dpi(20) }) end,
  }

  gtable.crush(w, osd)

  w.timer = gtimer {
    timeout = 2,
    autostart = true,
    callback = function()
      w.visible = false
    end,
  }

  audio_helper:connect_signal('output::get', function(_, muted, volume)
    volume = tonumber(volume or 0)
    if muted then
      w.widget:get_children_by_id('icon_role')[1]:set_image(gcolor.recolor_image(icondir .. 'volume-mute' .. '.svg', Theme_config.volume_osd.icon_color))
      w.widget:get_children_by_id('progressbar')[1].value = 0
    else
      w.widget:get_children_by_id('progressbar')[1].value = volume
      local icon = icondir .. 'volume'
      if volume < 1 then
        icon = icon .. '-mute'
      elseif volume >= 1 and volume < 34 then
        icon = icon .. '-low'
      elseif volume >= 34 and volume < 67 then
        icon = icon .. '-medium'
      elseif volume >= 67 then
        icon = icon .. '-high'
      end

      w.widget:get_children_by_id('icon_role')[1]:set_image(gcolor.recolor_image(icon .. '.svg', Theme_config.volume_osd.icon_color))
      w.widget:get_children_by_id('text_role')[1].text = volume
    end
    w:run()
  end)

  return w
end

return setmetatable(osd, { __call = function(_, ...) return osd.new(...) end })
