-------------------------------
-- The Notification defaults --
-------------------------------
-- Awesome Libs

local aspawn = require('awful.spawn')
local dpi = require('beautiful').xresources.apply_dpi
local gcolor = require('gears.color')
local gfilesystem = require('gears.filesystem')
local gshape = require('gears.shape')
local naughty = require('naughty')
local wibox = require('wibox')
local abutton = require('awful.button')
local gtable = require('gears.table')

local rubato = require('src.lib.rubato')
local hover = require('src.tools.hover')

local capi = {
  client = client,
  screen = screen,
}

local icondir = gfilesystem.get_configuration_dir() .. 'src/assets/icons/notifications/'

naughty.config.defaults.ontop = true
naughty.config.defaults.icon_size = dpi(80)
naughty.config.defaults.timeout = 5
naughty.config.defaults.title = 'System Notification'
naughty.config.defaults.margin = dpi(10)
naughty.config.defaults.position = Theme_config.notification.position
naughty.config.defaults.border_width = Theme_config.notification.border_width
naughty.config.defaults.border_color = Theme_config.notification.border_color
naughty.config.defaults.spacing = Theme_config.notification.spacing

Theme.notification_spacing = Theme_config.notification.corner_spacing

naughty.connect_signal('request::display', function(n)
  if User_config.dnd then
    n:destroy()
  else
    if not n.icon then n.icon = gfilesystem.get_configuration_dir() .. 'src/assets/CT.svg' end
    if not n.app_name then n.app_name = 'System' end
    if not n.title then n.title = 'System Notification' end
    if not n.message then n.message = 'No message provided' end

    local color = Theme_config.notification.bg_normal
    if n.urgency == 'critical' then
      color = Theme_config.notification.fg_urgent_message
    end

    if n.app_name == 'Spotify' then
      n.actions = {
        naughty.action {
          program = 'Spotify',
          id = 'skip-prev',
          name = 'Previous',
          position = 1,
        }, naughty.action {
          program = 'Spotify',
          id = 'play-pause',
          name = 'Play/Pause',
          position = 2,
        }, naughty.action {
          program = 'Spotify',
          id = 'skip-next',
          name = 'Next',
          position = 3,
        },
      }
      n.resident = true
    end

    if n.category == 'device.added' or n.category == 'network.connected' then
      aspawn('ogg123 /usr/share/sounds/Pop/stereo/notification/device-added.oga')
    elseif n.category == 'device.removed' or n.category == 'network.disconnected' then
      aspawn('ogg123 /usr/share/sounds/Pop/stereo/notification/device-removed.oga')
    elseif n.category == 'device.error' or n.category == 'im.error' or n.category == 'network.error' or n.category ==
        'transfer.error' then
      aspawn('ogg123 ogg123 /usr/share/sounds/Pop/stereo/alert/battery-low.oga')
    elseif n.category == 'email.arrived' then
      aspawn('ogg123 /usr/share/sounds/Pop/stereo/notification/message-new-email.oga')
    end

    local action_template = wibox.widget {
      notification = n,
      base_layout = wibox.widget {
        spacing = dpi(90),
        layout = wibox.layout.flex.horizontal,
      },
      widget_template = {
        {
          {
            widget = wibox.widget.textbox,
            id = 'text_role',
            valign = 'center',
            halign = 'center',
            font = 'JetBrainsMono Nerd Font, Bold 16',
          },
          widget = wibox.container.constraint,
          height = dpi(35),
          strategy = 'exact',
        },
        id = 'background_role',
        widget = wibox.container.background,
        bg = color,
        fg = Theme_config.notification.bg,
        shape = function(cr, width, height)
          gshape.rounded_rect(cr, width, height, dpi(8))
        end,
      },
      style = {
        underline_normal = false,
        underline_selected = false,
        shape_normal = function(cr, width, height)
          gshape.rounded_rect(cr, width, height, dpi(8))
        end,
        --Don't remove or it will break
        bg_normal = color,
        bg_selected = color,
        fg_normal = Theme_config.notification.bg,
        fg_selected = Theme_config.notification.bg,
      },
      widget = naughty.list.actions,
    }

    -- Hack to get the action buttons to work even after update
    --[[ for i = 1, #action_template._private.layout.children, 1 do
      hover.bg_hover { widget = action_template._private.layout.children[i].children[1], overlay = 12, press_overlay = 24 }
    end
    if (#action_template._private.layout.children > 0) and action_template._private.notification[1].actions[1].program == 'Spotify' then
      action_template._private.layout.children[1].children[1]:connect_signal('button::press', function()
        aspawn('playerctl previous')
      end)
      action_template._private.layout.children[2].children[1]:connect_signal('button::press', function()
        aspawn('playerctl play-pause')
      end)
      action_template._private.layout.children[3].children[1]:connect_signal('button::press', function()
        aspawn('playerctl next')
      end)
    end ]]

    local start_timer = n.timeout
    if n.timeout == 0 then
      start_timer = 5
    end

    local notification = wibox.template {
      widget = wibox.widget {
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
                            shape = function(cr, width, height)
                              gshape.rounded_rect(cr, width, height, dpi(4))
                            end,
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
                              Theme_config.notification.bg .. [[" font="JetBrainsMono Nerd Font, Bold 16">]] .. (n.app_name or
                                  'Unknown App') .. [[</span> | <span font="JetBrainsMono Nerd Font, Regular 16">]] .. (n.title or 'System Notification') .. [[</span>]],
                          halign = 'left',
                          valign = 'center',
                        },
                        widget = wibox.container.constraint,
                        width = dpi(430),
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
                        widget = wibox.widget.textclock,
                        format = '%H:%M',
                        font = 'JetBrainsMono Nerd Font, Bold 16',
                        fg = Theme_config.notification.bg,
                        halign = 'right',
                        valign = 'center',
                      },
                      { -- Close button
                        {
                          {
                            {
                              {
                                widget = wibox.widget.imagebox,
                                image = gcolor.recolor_image(icondir .. 'close.svg', Theme_config.notification.bg),
                                resize = true,
                                halign = 'center',
                                valign = 'center',
                              },
                              start_angle = 4.71239,
                              thickness = dpi(2),
                              min_value = 0,
                              max_value = start_timer,
                              value = start_timer,
                              widget = wibox.container.arcchart,
                              id = 'arc',
                            },
                            fg = Theme_config.notification.bg_close,
                            bg = color,
                            widget = wibox.container.background,
                            id = 'arc_bg',
                          },
                          strategy = 'exact',
                          width = dpi(18),
                          height = dpi(18),
                          widget = wibox.container.constraint,
                        },
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
                fg = '#212121',
                shape = function(cr, width, height)
                  gshape.rounded_rect(cr, width, height, dpi(8))
                end,
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
                    shape = function(cr, width, height)
                      gshape.rounded_rect(cr, width, height, dpi(10))
                    end,
                  },
                  widget = wibox.container.constraint,
                  strategy = 'exact',
                  height = dpi(128),
                  width = dpi(128),
                },
                {
                  {
                    notification = n,
                    widget = naughty.widget.message,
                    font = 'JetBrainsMono Nerd Font, Regular 10',
                    halign = 'left',
                    valign = 'center',
                  },
                  widget = wibox.container.constraint,
                  strategy = 'exact',
                  height = dpi(128),
                },
                spacing = dpi(15),
                layout = wibox.layout.fixed.horizontal,
              },
              { -- Spacer
                {
                  widget = wibox.container.background,
                  bg = Theme_config.notification.action_bg,
                },
                widget = wibox.container.constraint,
                strategy = 'exact',
                height = dpi(2),
              },
              action_template,
              spacing = dpi(15),
              id = 'main_layout',
              layout = wibox.layout.fixed.vertical,
            },
            widget = wibox.container.margin,
            margins = dpi(15),
          },
          bg = '#212121',
          border_color = '#414141',
          border_width = dpi(2),
          shape = function(cr, width, height)
            gshape.rounded_rect(cr, width, height, dpi(8))
          end,
          widget = wibox.container.background,
        },
        widget = wibox.container.constraint,
        strategy = 'exact',
        width = dpi(600),
      },
    }

    if #action_template._private.layout.children < 1 then
      notification:get_widget().children[1].children[1].children[1].children[3] = nil
    end

    local arc_bg = notification:get_widget().children[1].children[1].children[1].children[1].children[1].children[2].children[1].children[2].children[1].children[1]
    local arc = arc_bg.children[1]

    local timeout = n.timeout

    if timeout ~= 0 then

      local rubato_timer = rubato.timed {
        duration = n.timeout,
        pos = n.timeout,
        easing = rubato.linear,
        clamp_position = true,
        subscribed = function(value)
          arc.value = value
        end,
      }

      rubato_timer.target = 0

      notification:get_widget():connect_signal('mouse::enter', function()
        n.timeout = 99999
        rubato_timer.pause = true
      end)

      notification:get_widget():connect_signal('mouse::leave', function()
        n.timeout = rubato_timer.pos
        rubato_timer.pause = false
        rubato_timer.target = 0
      end)
    end

    hover.bg_hover { widget = arc_bg }

    arc_bg:connect_signal('button::press', function()
      n:destroy()
    end)

    notification:get_widget():buttons { gtable.join(
      abutton({}, 1, function()
        for _, client in ipairs(capi.client.get()) do
          if client.class:lower():match(n.app_name:lower()) then
            if not client:isvisible() and client.first_tag then
              client.first_tag:view_only()
            end
            client:emit_signal('request::activate')
            client:raise()
          end
        end
      end),
      abutton({}, 3, function()
        n:destroy()
      end)
    ), }

    local box = naughty.layout.box {
      notification = n,
      timeout = 5,
      type = 'notification',
      screen = capi.screen.primary,
      widget_template = notification,
    }
    box.buttons = {}
    n.buttons = {}

    -- This is stupid but there is on way to clone the notifaction widget and being able to modify only the clone
    --[=[ naughty.emit_signal('notification_surface', wibox.template {
      widget = wibox.widget {
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
                              --image = n.icon or '',
                              resize = true,
                            },
                            widget = wibox.container.background,
                            shape = function(cr, width, height)
                              gshape.rounded_rect(cr, width, height, dpi(4))
                            end,
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
                              Theme_config.notification.bg .. [[" font="JetBrainsMono Nerd Font, Bold 16">]] .. (n.app_name or
                                  'Unknown App') .. [[</span> | <span font="JetBrainsMono Nerd Font, Regular 16">]] .. (n.title or 'System Notification') .. [[</span>]],
                          halign = 'left',
                          valign = 'center',
                        },
                        widget = wibox.container.constraint,
                        width = dpi(280),
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
                        widget = wibox.widget.textclock,
                        format = '%H:%M',
                        font = 'JetBrainsMono Nerd Font, Bold 16',
                        fg = Theme_config.notification.bg,
                        halign = 'right',
                        valign = 'center',
                      },
                      { -- Close button
                        {
                          {
                            {
                              {
                                widget = wibox.widget.imagebox,
                                image = gcolor.recolor_image(icondir .. 'close.svg', Theme_config.notification.bg),
                                resize = true,
                                halign = 'center',
                                valign = 'center',
                              },
                              start_angle = 4.71239,
                              thickness = dpi(2),
                              min_value = 0,
                              max_value = start_timer,
                              value = start_timer,
                              widget = wibox.container.arcchart,
                              id = 'arc',
                            },
                            fg = Theme_config.notification.bg_close,
                            bg = color,
                            widget = wibox.container.background,
                            id = 'arc_bg',
                          },
                          strategy = 'exact',
                          width = dpi(18),
                          height = dpi(18),
                          widget = wibox.container.constraint,
                        },
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
                fg = '#212121',
                shape = function(cr, width, height)
                  gshape.rounded_rect(cr, width, height, dpi(8))
                end,
              },
              { -- Main body
                { -- Image
                  {
                    {
                      notification = n,
                      --image = n.icon or '',
                      valign = 'center',
                      halign = 'center',
                      upscale = true,
                      resize_strategy = 'scale',
                      widget = naughty.widget.icon,
                    },
                    widget = wibox.container.background,
                    shape = function(cr, width, height)
                      gshape.rounded_rect(cr, width, height, dpi(10))
                    end,
                  },
                  widget = wibox.container.constraint,
                  strategy = 'exact',
                  height = dpi(128),
                  width = dpi(128),
                },
                {
                  {
                    notification = n,
                    widget = naughty.widget.message,
                    text = n.message,
                    font = 'JetBrainsMono Nerd Font, Regular 8',
                    halign = 'left',
                    valign = 'center',
                  },
                  widget = wibox.container.constraint,
                  strategy = 'exact',
                  height = dpi(128),
                },
                spacing = dpi(15),
                layout = wibox.layout.fixed.horizontal,
              },
            },
            widget = wibox.container.margin,
            margins = dpi(15),
          },
          bg = '#212121',
          border_color = '#414141',
          border_width = dpi(2),
          shape = function(cr, width, height)
            gshape.rounded_rect(cr, width, height, dpi(8))
          end,
          widget = wibox.container.background,
        },
        widget = wibox.container.constraint,
        strategy = 'exact',
        width = dpi(600),
      },
    }) ]=]
  end
end)
--[[ 
naughty.notification {
  app_name = 'Spotify',
  title = 'The Beatles - Here Comes The Sun',
  message = 'Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.',
  icon = '/home/crylia/Bilder/57384097.jpg',
  timeout = 30,
  actions = {
    naughty.action {
      name = 'amet',
      position = 1,
      text = 'Test',
    },
    naughty.action {
      name = 'Lorem ipsum dolor sit amet',
      position = 2,
    },
    naughty.action {
      name = 'Lorem',
      position = 3,
    },
  },
}
 ]]
