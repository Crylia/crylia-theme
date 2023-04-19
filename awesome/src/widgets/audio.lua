local setmetatable = setmetatable
local tonumber = tonumber

-- Awesome Libs
local abutton = require('awful.button')
local apopup = require('awful.popup')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi
local gcolor = require('gears.color')
local gfilesystem = require('gears.filesystem')
local gtable = require('gears.table')
local gtimer = require('gears.timer')
local wibox = require('wibox')

-- Local libs
local audio_controller = require('src.modules.audio.audio_controller')
local audio_helper = require('src.tools.helpers.audio')
local hover = require('src.tools.hover')

local capi = { mouse = mouse }

-- Icon directory path
local icondir = gfilesystem.get_configuration_dir() .. 'src/assets/icons/audio/'

return setmetatable({}, { __call = function(_, screen)

  local ac_popup = apopup {
    widget = audio_controller,
    ontop = true,
    visible = true,
    screen = screen,
    border_color = beautiful.colorscheme.border_color,
    border_width = dpi(2),
    bg = beautiful.colorscheme.bg,
  }

  gtimer.delayed_call(function()
    ac_popup.visible = false
  end)

  local w = wibox.widget {
    {
      {
        {
          {
            id = 'icon',
            widget = wibox.widget.imagebox,
            valign = 'center',
            halign = 'center',
            resize = true,
          },
          width = dpi(25),
          height = dpi(25),
          strategy = 'exact',
          widget = wibox.container.constraint,
        },
        {
          id = 'label',
          halign = 'center',
          valign = 'center',
          widget = wibox.widget.textbox,
        },
        spacing = dpi(10),
        id = 'audio_layout',
        layout = wibox.layout.fixed.horizontal,
      },
      id = 'container',
      left = dpi(8),
      right = dpi(8),
      widget = wibox.container.margin,
    },
    bg = beautiful.colorscheme.bg_yellow,
    fg = beautiful.colorscheme.fg_dark,
    shape = beautiful.shape[6],
    widget = wibox.container.background,
    buttons = { gtable.join(
      abutton({}, 1, function()
        local geo = capi.mouse.coords()
        ac_popup.y = dpi(70)
        ac_popup.x = geo.x - ac_popup.width / 2
        ac_popup.visible = not ac_popup.visible
      end)
    ), },
  }

  hover.bg_hover { widget = w }

  local audio_label = w:get_children_by_id('label')[1]
  local audio_icon = w:get_children_by_id('icon')[1]
  local audio_spacing = w:get_children_by_id('audio_layout')[1]
  audio_helper:connect_signal('sink::get', function(_, muted, volume)
    volume = tonumber(volume)

    if w.volume == volume and w.muted == muted then return end
    w.volume = volume
    w.muted = muted

    if muted then
      audio_label.visible = false
      audio_icon:set_image(gcolor.recolor_image(icondir .. 'volume-mute' .. '.svg', beautiful.colorscheme.fg_dark))
    else
      if not volume then return end
      w.container:set_right(10)
      audio_spacing.spacing = dpi(5)
      audio_label.visible = true
      local icon = icondir .. 'volume'
      if volume < 1 then
        icon = icon .. '-mute'
        audio_spacing.spacing = 0
        audio_label.visible = false
      elseif volume >= 1 and volume < 34 then
        icon = icon .. '-low'
      elseif volume >= 34 and volume < 67 then
        icon = icon .. '-medium'
      elseif volume >= 67 then
        icon = icon .. '-high'
      end
      audio_label:set_text(volume .. '%')
      audio_icon:set_image(gcolor.recolor_image(icon .. '.svg', beautiful.colorscheme.fg_dark))
    end
  end)

  return w
end, })
