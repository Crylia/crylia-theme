local mmax = math.max
local setmetatable = setmetatable
local tonumber = tonumber
local tostring = tostring

-- Awesome Libs
local base = require('wibox.widget.base')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi
local gcolor = require('gears.color')
local gfilesystem = require('gears.filesystem')
local wibox = require('wibox')

-- Third Party Libs
local color = require('src.lib.color')
local hover = require('src.tools.hover')
local rubato = require('src.lib.rubato')

local icon_dir = gfilesystem.get_configuration_dir() .. 'src/assets/icons/cpu/'

local gpu_info = {}

local instance = nil
if not instance then
  instance = setmetatable(gpu_info, { __call = function(_, widget)
    if widget == 'temp' then
      local gpu_temp_helper = require('src.tools.helpers.gpu_temp')

      local w = base.make_widget_from_value(wibox.widget {
        {
          {
            {
              {
                {
                  id = 'icon_role',
                  widget = wibox.widget.imagebox,
                  valign = 'center',
                  halign = 'center',
                  image = gcolor.recolor_image(icon_dir .. 'gpu.svg', beautiful.colorscheme.bg),
                  resize = true,
                },
                widget = wibox.container.constraint,
                width = dpi(25),
                height = dpi(25),
                strategy = 'exact',
              },
              {
                id = 'text_role',
                text = '0°C',
                halign = 'center',
                valign = 'center',
                widget = wibox.widget.textbox,
              },
              spacing = dpi(5),
              layout = wibox.layout.fixed.horizontal,
            },
            widget = wibox.container.place,
          },
          left = dpi(5),
          right = dpi(5),
          widget = wibox.container.margin,
        },
        bg = beautiful.colorscheme.bg_green,
        fg = beautiful.colorscheme.bg,
        shape = beautiful.shape[6],
        widget = wibox.container.background,
      })

      local r = rubato.timed { duration = 2.5 }
      local g = rubato.timed { duration = 2.5 }
      local b = rubato.timed { duration = 2.5 }

      r.pos, g.pos, b.pos = color.utils.hex_to_rgba(beautiful.colorscheme.bg_green)

      -- Subscribable function to have rubato set the bg/fg color
      local function update_bg()
        w:set_bg('#' .. color.utils.rgba_to_hex { mmax(0, r.pos), mmax(0, g.pos),
          mmax(0, b.pos), })
      end

      r:subscribe(update_bg)
      g:subscribe(update_bg)
      b:subscribe(update_bg)

      -- Both functions to set a color, if called they take a new color
      local function set_bg(newbg)
        r.target, g.target, b.target = color.utils.hex_to_rgba(newbg)
      end

      -- GPU Temperature
      gpu_temp_helper:connect_signal('update::gpu_temp', function(_, stdout)
        local temp_icon
        local temp_color
        local temp_num = tonumber(stdout) or 0
        if temp_num then
          if temp_num < 50 then
            temp_color = beautiful.colorscheme.bg_green
            temp_icon = icon_dir .. 'thermometer-low.svg'
          elseif temp_num >= 50 and temp_num < 80 then
            temp_color = beautiful.colorscheme.bg_yellow
            temp_icon = icon_dir .. 'thermometer.svg'
          elseif temp_num >= 80 then
            temp_color = beautiful.colorscheme.bg_red
            temp_icon = icon_dir .. 'thermometer-high.svg'
          end
        else
          temp_color = beautiful.colorscheme.bg_green
          temp_icon = icon_dir .. 'thermometer-low.svg'
        end
        w:get_children_by_id('icon_role')[1]:set_image(temp_icon)
        set_bg(temp_color)
        w:get_children_by_id('text_role')[1].text = tostring(temp_num) .. '°C'
      end)

      return w
    elseif widget == 'usage' then
      local gpu_usage_helper = require('src.tools.helpers.gpu_usage')

      local w = base.make_widget_from_value(wibox.widget {
        {
          {
            {
              {
                {
                  id = 'icon_role',
                  widget = wibox.widget.imagebox,
                  valign = 'center',
                  halign = 'center',
                  image = gcolor.recolor_image(icon_dir .. 'gpu.svg', beautiful.colorscheme.bg),
                  resize = true,
                },
                widget = wibox.container.constraint,
                width = dpi(25),
                height = dpi(25),
                strategy = 'exact',
              },
              {
                id = 'text_role',
                text = '0%',
                halign = 'center',
                valign = 'center',
                widget = wibox.widget.textbox,
              },
              spacing = dpi(5),
              layout = wibox.layout.fixed.horizontal,
            },
            widget = wibox.container.place,
          },
          left = dpi(5),
          right = dpi(5),
          widget = wibox.container.margin,
        },
        bg = beautiful.colorscheme.bg_green,
        fg = beautiful.colorscheme.bg,
        shape = beautiful.shape[6],
        widget = wibox.container.background,
      })

      hover.bg_hover { widget = w }

      gpu_usage_helper:connect_signal('update::gpu_usage', function(_, stdout)
        w:get_children_by_id('text_role')[1].text = stdout:gsub('\n', '') .. '%'
      end)

      return w
    end
  end, })
end
return instance
