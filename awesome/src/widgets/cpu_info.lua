---------------------------------
-- This is the CPU Info widget --
---------------------------------

-- Awesome Libs
local base = require('wibox.widget.base')
local dpi = require('beautiful').xresources.apply_dpi
local gcolor = require('gears.color')
local gfilesystem = require('gears.filesystem')
local gtable = require('gears.table')
local wibox = require('wibox')

-- Third Party Libs
local color = require('src.lib.color')
local rubato = require('src.lib.rubato')
local hover = require('src.tools.hover')

local icon_dir = gfilesystem.get_configuration_dir() .. 'src/assets/icons/cpu/'

local cpu_info = {}

local function cpu_temp_new()
  local cpu_temp_helper = require('src.tools.helpers.cpu_temp')

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
              image = gcolor.recolor_image(icon_dir .. 'thermometer.svg', Theme_config.cpu_temp.fg),
              resize = true,
            },
            widget = wibox.container.constraint,
            width = dpi(25),
            height = dpi(25),
            strategy = 'exact',
          },
          {
            id = 'text_role',
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
    bg = Theme_config.cpu_temp.bg,
    fg = Theme_config.cpu_temp.fg,
    shape = Theme_config.cpu_temp.shape,
    widget = wibox.container.background,
  })

  assert(w, 'Failed to create widget')

  gtable.crush(w, cpu_info, true)

  local r = rubato.timed { duration = 2.5 }
  local g = rubato.timed { duration = 2.5 }
  local b = rubato.timed { duration = 2.5 }

  r.pos, g.pos, b.pos = color.utils.hex_to_rgba(Theme_config.cpu_temp.bg_low)

  -- Subscribable function to have rubato set the bg/fg color
  local function update_bg()
    w:set_bg('#' .. color.utils.rgba_to_hex { r.pos, g.pos, b.pos })
  end

  r:subscribe(update_bg)
  g:subscribe(update_bg)
  b:subscribe(update_bg)

  -- Both functions to set a color, if called they take a new color
  local function set_bg(newbg)
    r.target, g.target, b.target = color.utils.hex_to_rgba(newbg)
  end

  cpu_temp_helper:connect_signal('update::cpu_temp', function(_, temp)
    local temp_icon
    local temp_color

    if temp < 50 then
      temp_color = Theme_config.cpu_temp.bg_low
      temp_icon = icon_dir .. 'thermometer-low.svg'
    elseif temp >= 50 and temp < 80 then
      temp_color = Theme_config.cpu_temp.bg_mid
      temp_icon = icon_dir .. 'thermometer.svg'
    elseif temp >= 80 then
      temp_color = Theme_config.cpu_temp.bg_high
      temp_icon = icon_dir .. 'thermometer-high.svg'
    end
    w:get_children_by_id('icon_role')[1].image = temp_icon
    set_bg(temp_color)
    w:get_children_by_id('text_role')[1].text = math.floor(temp) .. '°C'
  end)

  return w
end

local function cpu_usage_new()
  local cpu_usage_helper = require('src.tools.helpers.cpu_usage')

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
              image = gcolor.recolor_image(icon_dir .. 'cpu.svg', Theme_config.cpu_usage.fg),
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
    bg = Theme_config.cpu_usage.bg,
    fg = Theme_config.cpu_usage.fg,
    shape = Theme_config.cpu_usage.shape,
    widget = wibox.container.background,
  })

  assert(w, 'failed to create widget')

  hover.bg_hover { widget = w }

  gtable.crush(w, cpu_info, true)

  cpu_usage_helper:connect_signal('update::cpu_usage', function(_, usage)
    w:get_children_by_id('text_role')[1].text = usage .. '%'
  end)

  return w
end

local function cpu_freq_new()
  local cpu_freq_helper = require('src.tools.helpers.cpu_freq')

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
              image = gcolor.recolor_image(icon_dir .. 'cpu.svg', Theme_config.cpu_freq.fg),
              resize = true,
            },
            widget = wibox.container.constraint,
            width = dpi(25),
            height = dpi(25),
            strategy = 'exact',
          },
          {
            id = 'text_role',
            text = '0Mhz',
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
    bg = Theme_config.cpu_freq.bg,
    fg = Theme_config.cpu_freq.fg,
    shape = Theme_config.cpu_freq.shape,
    widget = wibox.container.background,
  })

  assert(w, 'failed to create widget')

  hover.bg_hover { widget = w }

  gtable.crush(w, cpu_info, true)

  cpu_freq_helper:connect_signal('update::cpu_freq_average', function(_, average)
    w:get_children_by_id('text_role')[1].text = average .. 'Mhz'
  end)

  cpu_freq_helper:connect_signal('update::cpu_freq_core', function(_, freq)
    w:get_children_by_id('text_role')[1].text = freq .. 'Mhz'
  end)

  return w
end

return setmetatable(cpu_info, { __call = function(_, widget)
  if widget == 'temp' then
    return cpu_temp_new()
  elseif widget == 'usage' then
    return cpu_usage_new()
  elseif widget == 'freq' then
    return cpu_freq_new()
  else
    return nil
  end
end, })
