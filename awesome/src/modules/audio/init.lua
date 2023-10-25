-----------------------------------
-- This is the volume_old module --
-----------------------------------

-- Awesome Libs
local aplacement = require('awful.placement')
local apopup = require('awful.popup')
local beautiful = require('beautiful')
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

local capi = {
  awesome = awesome,
}

local osd = {}

function osd:display()
  self.popup.visible = true
  if self.timer.started then
    self.timer:again()
  else
    self.timer:start()
  end
end

local instance = nil
if not instance then
  instance = setmetatable(osd, {
    __call = function(self, ...)
      local args = ... or {}

      self.popup = apopup {
        widget = {
          {
            {
              {  -- Volume Icon
                {
                  image = gcolor.recolor_image(icondir .. 'volume-off.svg',
                    beautiful.colorscheme.bg_yellow),
                  resize = true,
                  id = 'icon_role',
                  widget = wibox.widget.imagebox,
                },
                widget = wibox.container.constraint,
                width = dpi(36),
                height = dpi(36),
                strategy = 'exact',
              },
              {
                widget = wibox.container.constraint,
                width = dpi(24),
                strategy = 'exact',
              },
              {  -- Volume Bar
                {
                  {
                    id = 'progressbar',
                    value = 0,
                    max_value = 100,
                    color = beautiful.colorscheme.bg_yellow,
                    background_color = beautiful.colorscheme.bg1,
                    shape = gshape.rounded_rect,
                    widget = wibox.widget.progressbar,
                  },
                  widget = wibox.container.constraint,
                  width = dpi(250),
                  height = dpi(12),
                },
                widget = wibox.container.place,
              },
              {  -- Value text
                {
                  widget = wibox.widget.textbox,
                  halign = 'right',
                  id = 'text_role',
                  text = 'NAN%',
                },
                widget = wibox.container.constraint,
                width = dpi(60),
                strategy = 'min',
              },
              spacing = dpi(10),
              layout = wibox.layout.fixed.horizontal,
            },
            margins = dpi(20),
            widget = wibox.container.margin,
          },
          shape = beautiful.shape[12],
          widget = wibox.container.background,
        },
        ontop = true,
        stretch = false,
        visible = true,
        border_color = beautiful.colorscheme.border_color,
        border_width = dpi(2),
        fg = beautiful.colorscheme.fg,
        bg = beautiful.colorscheme.bg,
        screen = 1,
        placement = function(c) aplacement.bottom(c, { margins = dpi(20) }) end,
      }
      self.popup.visible = false

      self.timer = gtimer {
        timeout = args.display_time or 3,
        autostart = true,
        callback = function()
          self.popup.visible = false
        end,
      }

      local volume_icon = self.popup.widget:get_children_by_id('icon_role')[1]
      local volume_text = self.popup.widget:get_children_by_id('text_role')[1]
      local volume_progressbar = self.popup.widget:get_children_by_id('progressbar')[1]

      audio_helper:connect_signal('sink::get', function(_, muted, volume)
        volume = tonumber(volume or 0)
        local icon = 'volume-mute.svg'
        if muted then
          volume_progressbar.value = 0
        else
          volume_progressbar.value = volume
          icon = icondir .. 'volume'
          if volume < 1 then
            icon = icon .. '-mute'
          elseif volume >= 1 and volume < 34 then
            icon = icon .. '-low'
          elseif volume >= 34 and volume < 67 then
            icon = icon .. '-medium'
          elseif volume >= 67 then
            icon = icon .. '-high'
          end
        end
        volume_icon:set_image(gcolor.recolor_image(icon .. '.svg', beautiful.colorscheme.bg_yellow))

        volume_text.text = volume .. '%'

        self:display()
      end)
    end,
  })
end
return instance
