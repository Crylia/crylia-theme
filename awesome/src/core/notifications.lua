local setmetatable = setmetatable

-- Awesome Libs
local abutton = require('awful.button')
local aspawn = require('awful.spawn')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi
local gcolor = require('gears.color')
local gfilesystem = require('gears.filesystem')
local gtable = require('gears.table')
local naughty = require('naughty')
local wibox = require('wibox')

-- Third party libs
local rubato = require('src.lib.rubato')

-- Local Libs
local hover = require('src.tools.hover')

local capi = {
  client = client,
  screen = screen,
}

local instance = nil
if not instance then
  instance = setmetatable({}, {
    __call = function()
      local icondir = gfilesystem.get_configuration_dir() .. 'src/assets/icons/notifications/'

      naughty.config.defaults.border_color = beautiful.colorscheme.border_color
      naughty.config.defaults.border_width = dpi(2)
      naughty.config.defaults.icon_size = dpi(64)
      naughty.config.defaults.margin = dpi(10)
      naughty.config.defaults.ontop = true
      naughty.config.defaults.position = 'bottom_right'
      naughty.config.defaults.spacing = dpi(10)
      naughty.config.defaults.timeout = 5
      naughty.config.defaults.title = 'System Notification'

      naughty.connect_signal('request::display', function(n)
        if beautiful.user_config.dnd then
          n:destroy()
        else
          n.app_name = n.app_name or 'System'
          n.icon = n.icon or gfilesystem.get_configuration_dir() .. 'src/assets/CT.svg'
          n.message = n.message or 'No message provided'
          n.title = n.title or 'System Notification'

          local color = beautiful.colorscheme.bg_blue
          if n.urgency == 'critical' then
            color = beautiful.colorscheme.bg_red
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
                  font = beautiful.user_config.font .. ' bold 16',
                },
                widget = wibox.container.constraint,
                height = dpi(35),
                strategy = 'exact',
              },
              id = 'background_role',
              widget = wibox.container.background,
              bg = color,
              fg = beautiful.colorscheme.bg,
              shape = beautiful.shape[8],
            },
            style = {
              underline_normal = false,
              underline_selected = false,
              shape_normal = beautiful.shape[8],
              --Don't remove or it will break
              bg_normal = color,
              bg_selected = color,
              fg_normal = beautiful.colorscheme.bg,
              fg_selected = beautiful.colorscheme.bg,
            },
            widget = naughty.list.actions,
          }

          -- Hack to get the action buttons to work even after update
          for i = 1, #action_template._private.layout.children, 1 do
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
          end

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
                                    beautiful.colorscheme.bg .. [[" font="]] .. beautiful.user_config.font .. ' bold 16' .. [[">]] .. (n.app_name or
                                        'Unknown App') .. [[</span> | <span font="]] .. beautiful.user_config.font .. ' regular 16' .. [[">]] .. (n.title or 'System Notification') .. [[</span>]],
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
                              font = beautiful.user_config.font .. ' bold 16',
                              fg = beautiful.colorscheme.bg,
                              halign = 'right',
                              valign = 'center',
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
                                    max_value = start_timer,
                                    value = start_timer,
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
                        height = dpi(128),
                        width = dpi(128),
                      },
                      {
                        {
                          notification = n,
                          widget = naughty.widget.message,
                          font = beautiful.user_config.font .. ' bold 10',
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
                        bg = beautiful.colorscheme.bg,
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
                bg = beautiful.colorscheme.bg,
                border_color = beautiful.colorscheme.border_color,
                border_width = dpi(2),
                shape = beautiful.shape[8],
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
        end
      end)
    end,
  })
end
return instance
