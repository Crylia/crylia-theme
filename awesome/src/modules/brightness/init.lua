local setmetatable = setmetatable

local apopup = require('awful.popup')
local aplacement = require('awful.placement')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi
local gcolor = require('gears.color')
local gobject = require('gears.object')
local gtable = require('gears.table')
local gtimer = require('gears.timer')
local gfilesystem = require('gears.filesystem')
local gshape = require('gears.shape')
local wibox = require('wibox')

local backlight_helper = require('src.tools.helpers.backlight')

local icondir = gfilesystem.get_configuration_dir() .. 'src/assets/icons/brightness/'

local capi = {
  awesome = awesome,
}

local osd = gobject {}

-- Show the popup for x seconds, default is 3
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
    ---Create a backlight osd that shows when the backlight is changed
    ---@param ... table[display_time]
    __call = function(self, ...)
      local args = ... or {}

      -- Set to visible on creation so the popup is cached on startup
      self.popup = apopup {
        widget = {
          {
            {
              {  -- Icon
                {
                  image = gcolor.recolor_image(icondir .. 'brightness-high.svg',
                    beautiful.colorscheme.bg_blue),
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
              {  -- Progressbar
                {
                  {
                    id = 'progressbar',
                    value = 0,
                    max_value = 100,
                    color = beautiful.colorscheme.bg_blue,
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
            widget = wibox.container.margin,
            margins = dpi(20),
          },
          widget = wibox.container.background,
          shape = beautiful.shape[12],
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

      local progressbar = self.popup.widget:get_children_by_id('progressbar')[1]
      local brightness_text = self.popup.widget:get_children_by_id('text_role')[1]
      local brightness_icon = self.popup.widget:get_children_by_id('icon_role')[1]

      backlight_helper:connect_signal('brightness_changed', function()
        backlight_helper.brightness_get_async(function(brightness)
          if not brightness then return end
          brightness = math.floor((tonumber(brightness) / (backlight_helper.brightness_max or 24000) * 100) + 0.5)

          local icon = icondir .. 'brightness'
          if brightness >= 0 and brightness < 34 then
            icon = icon .. '-low.svg'
          elseif brightness >= 34 and brightness < 67 then
            icon = icon .. '-medium.svg'
          elseif brightness >= 67 then
            icon = icon .. '-high.svg'
          end

          brightness_icon.image = gcolor.recolor_image(icon,
            beautiful.colorscheme.bg_blue)
          progressbar.value = brightness
          brightness_text.text = brightness .. '%'

          self:display()
        end)
      end)

      return self
    end,
  })
end
return instance
