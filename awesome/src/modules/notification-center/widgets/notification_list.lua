local os = os
local setmetatable = setmetatable

-- Awesome Libs
local abutton = require('awful.button')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi
local gcolor = require('gears.color')
local gfilesystem = require('gears.filesystem')
local gtable = require('gears.table')
local gtimer = require('gears.timer')
local naughty = require('naughty')
local wibox = require('wibox')

-- Local Libs
local hover = require('src.tools.hover')

local icondir = gfilesystem.get_configuration_dir() .. 'src/assets/icons/notifications/'

local instance = nil
instance = setmetatable({}, {
  __call = function()
    local ret = wibox.widget {
      layout = require('src.lib.overflow_widget.overflow').vertical,
      scrollbar_width = 0,
      step = dpi(100),
      spacing = dpi(20),
    }

    naughty.connect_signal('request::display', function(n)
      local start_time = os.time()
      local color = beautiful.colorscheme.bg_blue
      local w = wibox.widget {
        {
          {
            {
              { -- Title
                {
                  {
                    { -- Icon
                      {
                        {
                          {
                            {
                              notification = n,
                              widget = naughty.widget.icon,
                              image = n.icon,
                              resize = true,
                            },
                            widget = wibox.container.background,
                            shape = beautiful.shape[4],
                          },
                          widget = wibox.container.place,
                        },
                        widget = wibox.container.constraint,
                        strategy = 'exact',
                        width = dpi(20),
                        height = dpi(20),
                      },
                      { -- Title
                        {
                          notification = n,
                          widget = naughty.widget.title,
                          markup = [[<span foreground="]] ..
                              beautiful.colorscheme.bg .. [[" font="]] .. beautiful.user_config.font .. ' bold 12' .. [[">]] .. (n.app_name or
                                  'Unknown App') .. [[</span> | <span font="]] .. beautiful.user_config.font .. ' regular 12' .. [[">]] .. (n.title or 'System Notification') .. [[</span>]],
                          halign = 'left',
                          valign = 'center',
                        },
                        widget = wibox.container.constraint,
                        width = dpi(250),
                        height = dpi(35),
                        strategy = 'max',
                      },
                      spacing = dpi(10),
                      layout = wibox.layout.fixed.horizontal,
                    },
                    widget = wibox.container.margin,
                    left = dpi(10),
                  },
                  nil,
                  {
                    {
                      { -- Clock
                        widget = wibox.widget.textbox,
                        test = 'now',
                        font = beautiful.user_config.font .. ' bold 12',
                        fg = beautiful.colorscheme.bg,
                        halign = 'center',
                        valign = 'center',
                        id = 'timer',
                      },
                      { -- Close button
                        {
                          {
                            {
                              {
                                widget = wibox.widget.imagebox,
                                image = gcolor.recolor_image(icondir .. 'close.svg', beautiful.colorscheme.bg),
                                resize = true,
                                halign = 'center',
                                valign = 'center',
                              },
                              start_angle = 4.71239,
                              thickness = dpi(2),
                              min_value = 0,
                              max_value = 1,
                              value = 1,
                              widget = wibox.container.arcchart,
                              id = 'arc',
                            },
                            fg = beautiful.colorscheme.bg,
                            bg = color,
                            widget = wibox.container.background,
                            id = 'arc_bg',
                          },
                          strategy = 'exact',
                          width = dpi(18),
                          height = dpi(18),
                          widget = wibox.container.constraint,
                        },
                        id = 'close',
                        visible = false,
                        left = dpi(5),
                        widget = wibox.container.margin,
                      },
                      layout = wibox.layout.fixed.horizontal,
                    },
                    right = dpi(5),
                    widget = wibox.container.margin,
                  },
                  layout = wibox.layout.align.horizontal,
                },
                widget = wibox.container.background,
                bg = color,
                fg = beautiful.colorscheme.bg,
                shape = beautiful.shape[8],
              },
              { -- Main body
                { -- Image
                  {
                    {
                      notification = n,
                      image = n.icon,
                      valign = 'center',
                      halign = 'center',
                      upscale = true,
                      resize_strategy = 'scale',
                      widget = naughty.widget.icon,
                    },
                    widget = wibox.container.background,
                    shape = beautiful.shape[10],
                  },
                  widget = wibox.container.constraint,
                  strategy = 'exact',
                  height = dpi(96),
                  width = dpi(96),
                },
                {
                  {
                    notification = n,
                    widget = naughty.widget.message,
                    font = beautiful.user_config.font .. ' regular 10',
                    halign = 'left',
                    valign = 'center',
                  },
                  widget = wibox.container.constraint,
                  strategy = 'exact',
                  height = dpi(96),
                },
                spacing = dpi(15),
                layout = wibox.layout.fixed.horizontal,
              },
              spacing = dpi(15),
              id = 'main_layout',
              layout = wibox.layout.fixed.vertical,
            },
            widget = wibox.container.margin,
            margins = dpi(15),
          },
          bg = beautiful.colorscheme.bg,
          border_color = beautiful.colorscheme.border_color,
          border_width = dpi(2),
          shape = beautiful.shape[8],
          widget = wibox.container.background,
        },
        widget = wibox.container.constraint,
        strategy = 'exact',
        width = dpi(600),
      }
      local close = w:get_children_by_id('close')[1]
      w:connect_signal('mouse::enter', function()
        close.visible = true
        --w:get_children_by_id('timer')[1].visible = false
      end)

      w:connect_signal('mouse::leave', function()
        close.visible = false
        --w:get_children_by_id('timer')[1].visible = true
      end)

      hover.bg_hover(close.children[1])

      close:buttons(gtable.join(
        abutton({}, 1, function()
          ret:remove_widgets(w)
          ret:emit_signal('new_children')
        end)
      ))

      gtimer {
        timeout = 1,
        autostart = true,
        call_now = true,
        callback = function()
          local time_ago = math.floor(os.time() - start_time)
          local timer_text = w:get_children_by_id('timer')[1]
          if time_ago < 5 then
            timer_text:set_text('now')
          elseif time_ago < 60 then
            timer_text:set_text(time_ago .. 's ago')
          elseif time_ago < 3600 then
            timer_text:set_text(math.floor(time_ago / 60) .. 'm ago')
          elseif time_ago < 86400 then
            timer_text:set_text(math.floor(time_ago / 3600) .. 'h ago')
          else
            timer_text:set_text(math.floor(time_ago / 86400) .. 'd ago')
          end
        end,
      }

      ret:add(w)
      ret:emit_signal('new_children')
    end)

    return ret
  end,
})
return instance
