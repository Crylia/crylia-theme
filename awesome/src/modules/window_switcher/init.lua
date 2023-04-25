---------------------------------
-- This is the window_switcher --
---------------------------------

-- Awesome Libs
local aplacement = require('awful.placement')
local apopup = require('awful.popup')
local beautiful = require('beautiful')
local dpi = require('beautiful').xresources.apply_dpi
local gcolor = require('gears.color')
local gshape = require('gears.shape')
local gsurface = require('gears.surface')
local gtable = require('gears.table')
local wibox = require('wibox')
local gobject = require('gears.object')
local base = require('wibox.widget.base')
local gtimer = require('gears.timer')
local cairo = require('lgi').cairo
local awidget = require('awful.widget')
local ascreenshot = require('awful.screenshot')
local wtemplate = require('wibox.template')
local akeygrabber = require('awful.keygrabber')
local akey = require('awful.key')
local abutton = require('awful.button')
local aclient = require('awful.client')
local awful = require('awful')

local client_preview = {}

local instance = nil
if not instance then
  instance = setmetatable(client_preview, {
    __call = function(self, s)

      self.popup = apopup {
        widget = awidget.tasklist {
          screen = 1,
          layout = wibox.layout.fixed.horizontal,
          filter = awidget.tasklist.filter.alltags,
          style = {
            font = beautiful.user_config.font .. ' regular 12',
          },
          widget_template = wibox.template {
            {
              {
                {
                  {
                    {
                      { -- icon and text
                        {
                          {
                            widget = wibox.widget.imagebox,
                            valign = 'center',
                            halign = 'center',
                            id = 'icon_role',
                          },
                          {
                            widget = wibox.widget.textbox,
                            id = 'text_role',
                          },
                          spacing = dpi(10),
                          layout = wibox.layout.fixed.horizontal,
                        },
                        widget = wibox.container.constraint,
                        height = dpi(32),
                        width = dpi(256),
                      },
                      { -- preview
                        id = 'screenshot',
                        width = dpi(256),
                        widget = wibox.container.constraint,
                      },
                      spacing = dpi(10),
                      layout = wibox.layout.fixed.vertical,
                    },
                    widget = wibox.container.place,
                  },
                  widget = wibox.container.margin,
                  margins = dpi(20),
                },
                widget = wibox.container.background,
                border_color = beautiful.colorscheme.border_color,
                id = 'border',
                border_width = dpi(2),
                bg = beautiful.colorscheme.bg1,
                shape = beautiful.shape[8],
              },
              widget = wibox.container.margin,
              margins = dpi(20),
            },
            bg = beautiful.colorscheme.bg,
            widget = wibox.container.background,
            create_callback = function(sself, c)
              local ss = ascreenshot {
                client = c,
              }
              ss:refresh()
              local ib = ss.content_widget
              ib.clip_shape = beautiful.shape[12]
              ib.valign = 'center'
              ib.halign = 'center'
              sself:get_widget():get_children_by_id('screenshot')[1].widget = ib
            end,
            update_callback = function(sself, c)
              if c.active and self.popup.visible then
                local ss = ascreenshot {
                  client = c,
                }
                ss:refresh()
                local ib = ss.content_widget
                ib.clip_shape = beautiful.shape[12]
                ib.valign = 'center'
                ib.halign = 'center'
                sself:get_widget():get_children_by_id('screenshot')[1].widget = ib
                sself:get_widget():get_children_by_id('border')[1].border_color = beautiful.colorscheme.bg_purple
              else
                sself:get_widget():get_children_by_id('border')[1].border_color = beautiful.colorscheme.border_color
              end
            end,
          },
        },
        ontop = true,
        visible = false,
        screen = s,
        bg = beautiful.colorscheme.bg,
        border_color = beautiful.colorscheme.border_color,
        border_width = dpi(2),
        placement = aplacement.centered,
      }
    end,
  })
end
return instance
