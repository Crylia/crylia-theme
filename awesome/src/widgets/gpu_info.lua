---------------------------------
-- This is the gpu Info widget --
---------------------------------

-- Awesome Libs
local base = require('wibox.widget.base')
local dpi = require('beautiful').xresources.apply_dpi
local gcolor = require('gears.color')
local gfilesystem = require('gears.filesystem')
local wibox = require('wibox')

-- Third Party Libs
local color = require('src.lib.color')
local rubato = require('src.lib.rubato')
local hover = require('src.tools.hover')

local icon_dir = gfilesystem.get_configuration_dir() .. 'src/assets/icons/cpu/'

local gpu_info = {}

local function gpu_temp_new()
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
              image = gcolor.recolor_image(icon_dir .. 'gpu.svg', Theme_config.gpu_temp.fg),
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
    bg = Theme_config.gpu_temp.bg,
    fg = Theme_config.gpu_temp.fg,
    shape = Theme_config.gpu_temp.shape,
    widget = wibox.container.background,
  })

  assert(w, 'Widget not created')

  local r = rubato.timed { duration = 2.5 }
  local g = rubato.timed { duration = 2.5 }
  local b = rubato.timed { duration = 2.5 }

  r.pos, g.pos, b.pos = color.utils.hex_to_rgba(Theme_config.cpu_temp.bg_low)

  -- Subscribable function to have rubato set the bg/fg color
  local function update_bg()
    w:set_bg('#' .. color.utils.rgba_to_hex { math.max(0, r.pos), math.max(0, g.pos),
      math.max(0, b.pos), })
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
        temp_color = Theme_config.gpu_temp.bg_low
        temp_icon = icon_dir .. 'thermometer-low.svg'
      elseif temp_num >= 50 and temp_num < 80 then
        temp_color = Theme_config.gpu_temp.bg_mid
        temp_icon = icon_dir .. 'thermometer.svg'
      elseif temp_num >= 80 then
        temp_color = Theme_config.gpu_temp.bg_high
        temp_icon = icon_dir .. 'thermometer-high.svg'
      end
    else
      temp_color = Theme_config.gpu_temp.bg_low
      temp_icon = icon_dir .. 'thermometer-low.svg'
    end
    w:get_children_by_id('icon_role')[1]:set_image(temp_icon)
    set_bg(temp_color)
    w:get_children_by_id('text_role')[1].text = tostring(temp_num) .. '°C'
  end)

  return w
end

local function gpu_usage_new()
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
              image = gcolor.recolor_image(icon_dir .. 'gpu.svg', Theme_config.gpu_usage.fg),
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
    bg = Theme_config.gpu_usage.bg,
    fg = Theme_config.gpu_usage.fg,
    shape = Theme_config.gpu_usage.shape,
    widget = wibox.container.background,
  })

  assert(w, 'Widget not created')

  hover.bg_hover { widget = w }

  gpu_usage_helper:connect_signal('update::gpu_usage', function(_, stdout)
    w:get_children_by_id('text_role')[1].text = stdout:gsub('\n', '') .. '%'
  end)

  return w
end

return setmetatable(gpu_info, { __call = function(_, widget)
  if widget == 'usage' then
    return gpu_usage_new()
  elseif widget == 'temp' then
    return gpu_temp_new()
  end
end, })
