-------------------------------------
-- This is the notification-center --
-------------------------------------

-- Awesome Libs
local beautiful = require('beautiful')
local dpi = require('beautiful').xresources.apply_dpi
local gfilesystem = require('gears.filesystem')
local base = require('wibox.widget.base')
local wibox = require('wibox')
local apopup = require('awful.popup')
local aplacement = require('awful.placement')
local gshape = require('gears.shape')
local gcolor = require('gears.color')

-- Own Libs
local dnd_widget = require('awful.widget.toggle_widget')
local notification_list = require('src.modules.notification-center.widgets.notification_list')()
local weather_widget = require('src.modules.notification-center.widgets.weather')()
local profile_widget = require('src.modules.notification-center.widgets.profile')()
local status_bars = require('src.modules.notification-center.widgets.status_bars')()
local music_widget = require('src.modules.notification-center.widgets.song_info')()
local hover = require('src.tools.hover')

-- Icon directory path
local icondir = gfilesystem.get_configuration_dir() .. 'src/assets/icons/notifications/'

local capi = {
  client = client,
}

local instance = nil

local info_center = {}

function info_center:toggle()
  if self.container.visible then
    self.container.visible = false
  else
    self.container.visible = true
  end
end

function info_center.new(args)
  args = args or {}

  local w = base.make_widget_from_value {
    {
      {
        {
          {
            {
              { -- Time
                halign = 'center',
                valign = 'center',
                format = "<span foreground='#18FFFF' font='JetBrainsMono Nerd Font, Bold 46'><b>%H:%M</b></span>",
                widget = wibox.widget.textclock,
              },
              { -- Date and Day
                { -- Date
                  halign = 'left',
                  valign = 'bottom',
                  format = "<span foreground='#69F0AE' font='JetBrainsMono Nerd Font, Regular 18'><b>%d</b></span><span foreground='#18FFFF' font='JetBrainsMono Nerd Font, Regular 18'><b> %b %Y</b></span>",
                  widget = wibox.widget.textclock,
                },
                { -- Day
                  halign = 'left',
                  valign = 'top',
                  format = "<span foreground='#69F0AE' font='JetBrainsMono Nerd Font, Bold 20'><b>%A</b></span>",
                  widget = wibox.widget.textclock,
                },
                layout = wibox.layout.flex.vertical,
              },
              spacing = dpi(20),
              layout = wibox.layout.fixed.horizontal,
            },
            widget = wibox.container.place,
          },
          margins = dpi(20),
          widget = wibox.container.margin,
        },
        {
          {
            {
              bg = beautiful.colorscheme.bg1,
              widget = wibox.container.background,
            },
            widget = wibox.container.constraint,
            height = dpi(2),
            strategy = 'exact',
          },
          left = dpi(60),
          right = dpi(60),
          widget = wibox.container.margin,
        },
        {
          {
            weather_widget,
            {
              profile_widget,
              layout = wibox.layout.fixed.vertical,
            },
            layout = wibox.layout.fixed.horizontal,
          },
          layout = wibox.layout.fixed.horizontal,
        },
        status_bars,
        music_widget,
        layout = wibox.layout.fixed.vertical,
      },
      -- Notification list
      {
        {
          {
            notification_list,
            height = dpi(680),
            strategy = 'max',
            widget = wibox.container.constraint,
          },
          {
            {
              {
                {
                  {
                    valign = 'center',
                    halign = 'center',
                    resize = true,
                    image = icondir .. 'megamind.svg',
                    widget = wibox.widget.imagebox,
                    id = 'no_notification_icon',
                  },
                  widget = wibox.container.constraint,
                  height = dpi(200),
                  width = dpi(200),
                  strategy = 'exact',
                },
                {
                  markup = "<span color='#414141' font='JetBrainsMono Nerd Font, ExtraBold 20'>No Notifications?</span>",
                  valign = 'center',
                  halign = 'center',
                  widget = wibox.widget.textbox,
                  id = 'no_notification_text',
                },
                layout = wibox.layout.fixed.vertical,
              },
              widget = wibox.container.place,
            },
            strategy = 'max',
            height = dpi(400),
            widget = wibox.container.constraint,
          },
          {
            {
              dnd_widget {
                text = 'Do not disturb',
                color = beautiful.colorscheme.bg_purple,
                fg = beautiful.colorscheme.bg_red,
                size = dpi(40),
              },
              id = 'dnd',
              widget = wibox.container.place,
            },
            nil,
            { -- Clear all button
              {
                {
                  {
                    {
                      text = 'Clear',
                      valign = 'center',
                      halign = 'center',
                      widget = wibox.widget.textbox,
                      id = 'clear',
                    },
                    fg = beautiful.colorscheme.bg,
                    bg = beautiful.colorscheme.bg_blue,
                    shape = beautiful.shape[12],
                    id = 'clear_all_bg',
                    widget = wibox.container.background,
                  },
                  widget = wibox.container.constraint,
                  width = dpi(80),
                  height = dpi(40),
                  strategy = 'exact',
                },
                margins = dpi(10),
                widget = wibox.container.margin,
              },
              widget = wibox.container.place,
              valign = 'bottom', --? Needed?
              halign = 'right', --? Needed?
            },
            layout = wibox.layout.align.horizontal,
          },
          layout = wibox.layout.align.vertical,
        },
        margins = dpi(20),
        widget = wibox.container.margin,
      },
      spacing_widget = {
        thickness = dpi(2),
        color = beautiful.colorscheme.bg1,
        span_ratio = 0.9,
        widget = wibox.widget.separator,
      },
      spacing = dpi(2),
      layout = wibox.layout.flex.horizontal,
    },
    widget = wibox.container.constraint,
    height = dpi(800),
    width = dpi(1000),
    strategy = 'exact',
  }

  hover.bg_hover { widget = w:get_children_by_id('clear_all_bg')[1] }

  assert(type(w) == 'table', 'Widget creation failed')

  notification_list:connect_signal('new_children', function()
    if #notification_list.children == 0 then
      math.randomseed(os.time())
      local prob = math.random(1, 10)

      if (prob == 5) or (prob == 6) then
        w:get_children_by_id('no_notification_icon')[1].image = icondir .. 'megamind.svg'
        w:get_children_by_id('no_notification_text')[1].markup = "<span color='#414141' font='JetBrainsMono Nerd Font, ExtraBold 20'>No Notifications?</span>"
      else
        w:get_children_by_id('no_notification_icon')[1].image = icondir .. 'bell-outline.svg'
        w:get_children_by_id('no_notification_text')[1].markup = "<span color='#414141' font='JetBrainsMono Nerd Font, ExtraBold 20'>No Notification</span>"
      end
      w:get_children_by_id('no_notification_icon')[1].visible = true
      w:get_children_by_id('no_notification_text')[1].visible = true
    else
      w:get_children_by_id('no_notification_icon')[1].visible = false
      w:get_children_by_id('no_notification_text')[1].visible = false
    end
  end)

  w:get_children_by_id('clear')[1]:connect_signal('button::press', function()
    notification_list.children = {}
    notification_list:emit_signal('new_children')
  end)

  w:get_children_by_id('dnd')[1]:get_widget():connect_signal('dnd::toggle', function(enabled)
    beautiful.user_config.dnd = enabled
  end)

  w.container = apopup {
    widget = w,
    bg = beautiful.colorscheme.bg,
    border_color = beautiful.colorscheme.border_color,
    border_width = dpi(2),
    placement = function(c)
      aplacement.top(c, { margins = dpi(10) })
    end,
    ontop = true,
    screen = args.screen,
    visible = false,
  }

  local activation_area = apopup {
    bg = gcolor.transparent,
    widget = {
      forced_height = dpi(1),
      forced_width = dpi(300),
      bg = gcolor.transparent,
      layout = wibox.layout.fixed.horizontal,
    },
    ontop = true,
    screen = args.screen,
    type = 'dock',
    placement = function(c)
      aplacement.top(c)
    end,
  }

  capi.client.connect_signal('property::fullscreen', function(c)
    if c.fullscreen then
      activation_area.visible = false
    else
      activation_area.visible = true
    end
  end)

  activation_area:connect_signal('mouse::enter', function()
    w.container.visible = true
  end)

  w.container:connect_signal('mouse::leave', function()
    w.container.visible = false
  end)

  return w
end

if not instance then
  instance = setmetatable(info_center, {
    __call = function(self, ...)
      self.new(...)
    end,
  })
end

return instance
