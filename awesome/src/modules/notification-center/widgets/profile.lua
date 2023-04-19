--------------------------------
-- This is the profile widget --
--------------------------------

-- Awesome Libs
local aspawn = require('awful.spawn')
local beautiful = require('beautiful')
local dpi = require('beautiful').xresources.apply_dpi
local gcolor = require('gears.color')
local gfilesystem = require('gears.filesystem')
local gshape = require('gears.shape')
local gsurface = require('gears.surface')
local gtimer = require('gears.timer')
local wibox = require('wibox')

-- Icon directory path
local icondir = gfilesystem.get_configuration_dir() .. 'src/assets/icons/profile/'

local instance = nil

if not instance then
  instance = setmetatable({}, { __call = function()
    local w = wibox.widget {
      {
        {
          {
            {
              {
                {
                  ---@diagnostic disable-next-line: param-type-mismatch
                  image = gsurface.load_uncached(gfilesystem.get_configuration_dir() .. 'src/assets/userpfp/userpfp.png'),
                  valign = 'center',
                  halign = 'center',
                  clip_shape = beautiful.shape[12],
                  widget = wibox.widget.imagebox,
                },
                strategy = 'exact',
                widget = wibox.container.constraint,
              },
              margins = dpi(20),
              widget = wibox.container.margin,
            },
            {
              {
                {
                  { -- Username
                    image = gcolor.recolor_image(icondir .. 'user.svg',
                      beautiful.colorscheme.bg_blue),
                    valign = 'center',
                    halign = 'left',
                    resize = true,
                    width = dpi(20),
                    widget = wibox.widget.imagebox,
                  },
                  { -- Username
                    id = 'username',
                    valign = 'center',
                    halign = 'left',
                    widget = wibox.widget.textbox,
                  },
                  spacing = dpi(10),
                  layout = wibox.layout.fixed.horizontal,
                },
                {
                  {
                    image = gcolor.recolor_image(icondir .. 'laptop.svg',
                      beautiful.colorscheme.bg_blue),
                    valign = 'center',
                    halign = 'left',
                    resize = true,
                    width = dpi(20),
                    widget = wibox.widget.imagebox,
                  },
                  { -- OS
                    id = 'os',
                    valign = 'center',
                    halign = 'left',
                    widget = wibox.widget.textbox,
                  },
                  spacing = dpi(10),
                  layout = wibox.layout.fixed.horizontal,
                },
                {
                  {
                    image = gcolor.recolor_image(icondir .. 'penguin.svg',
                      beautiful.colorscheme.bg_blue),
                    valign = 'center',
                    halign = 'left',
                    resize = true,
                    width = dpi(20),
                    widget = wibox.widget.imagebox,
                  },
                  { -- Kernel
                    id = 'kernel',
                    valign = 'center',
                    halign = 'left',
                    widget = wibox.widget.textbox,
                  },
                  spacing = dpi(10),
                  layout = wibox.layout.fixed.horizontal,
                },
                {
                  {
                    image = gcolor.recolor_image(icondir .. 'clock.svg',
                      beautiful.colorscheme.bg_blue),
                    valign = 'center',
                    halign = 'left',
                    resize = true,
                    width = dpi(20),
                    widget = wibox.widget.imagebox,
                  },
                  { -- Uptime
                    id = 'uptime',
                    valign = 'center',
                    halign = 'left',
                    widget = wibox.widget.textbox,
                  },
                  spacing = dpi(10),
                  layout = wibox.layout.fixed.horizontal,
                },
                spacing = dpi(5),
                layout = wibox.layout.flex.vertical,
              },
              bottom = dpi(20),
              left = dpi(20),
              widget = wibox.container.margin,
            },
            widget = wibox.layout.fixed.vertical,
          },
          fg = beautiful.colorscheme.bg_green,
          border_color = beautiful.colorscheme.border_color,
          border_width = dpi(2),
          shape = beautiful.shape[12],
          widget = wibox.container.background,
        },
        strategy = 'exact',
        width = dpi(250),
        height = dpi(350),
        widget = wibox.container.constraint,
      },
      top = dpi(20),
      left = dpi(10),
      right = dpi(20),
      bottom = dpi(10),
      widget = wibox.container.margin,
    }

    aspawn.easy_async_with_shell('cat /etc/os-release | grep -w NAME', function(stdout)
      w:get_children_by_id('os')[1].text = stdout:match('\"(.+)\"')
    end)

    aspawn.easy_async_with_shell('uname -r', function(stdout)
      w:get_children_by_id('kernel')[1].text = stdout:match('(%d+%.%d+%.%d+)')
    end)

    aspawn.easy_async_with_shell('echo $USER@$(hostname)', function(stdout)
      w:get_children_by_id('username')[1].text = stdout:gsub('\n', '') or ''
    end)

    gtimer {
      timeout = 60,
      autostart = true,
      call_now = true,
      callback = function()
        aspawn.easy_async_with_shell('uptime -p', function(stdout)
          local hours = stdout:match('(%d+) hours') or 0
          local minutes = stdout:match('(%d+) minutes') or 0
          w:get_children_by_id('uptime')[1].text = hours .. 'h, ' .. minutes .. 'm'
        end)
      end,
    }

    return w
  end, })
end

return instance
