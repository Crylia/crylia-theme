-------------------------------
-- The Notification defaults --
-------------------------------
-- Awesome Libs
local awful = require("awful")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local menubar = require('menubar')
local naughty = require("naughty")
local wibox = require("wibox")

local rubato = require("src.lib.rubato")

local icondir = awful.util.getdir("config") .. "src/assets/icons/notifications/"

naughty.config.defaults.ontop = true
naughty.config.defaults.icon_size = dpi(80)
naughty.config.defaults.timeout = Theme_config.notification.timeout
naughty.config.defaults.title = "System Notification"
naughty.config.defaults.margin = dpi(10)
naughty.config.defaults.position = Theme_config.notification.position
naughty.config.defaults.shape = Theme_config.notification.shape
naughty.config.defaults.border_width = Theme_config.notification.border_width
naughty.config.defaults.border_color = Theme_config.notification.border_color
naughty.config.defaults.spacing = Theme_config.notification.spacing

Theme.notification_spacing = Theme_config.notification.corner_spacing

naughty.connect_signal(
  'request::icon',
  function(n, context, hints)
    if context ~= 'app_icon' then
      return
    end
    local path = menubar.utils.lookup_icon(hints.app_icon) or menubar.utils.lookup_icon(hints.app_icon:lower())
    if path then
      n.icon = path
    end
  end
)

naughty.connect_signal(
  "request::display",
  function(n)
    if User_config.dnd then
      n:destroy()
    else
      if n.urgency == "critical" then
        n.title = string.format("<span foreground='%s' font='JetBrainsMono Nerd Font, ExtraBold 16'>%s</span>",
          Theme_config.notification.fg_urgent_title, n.title) or ""
        n.message = string.format("<span foreground='%s'>%s</span>", Theme_config.notification.fg_urgent_message,
          n.message) or ""
        n.app_name = string.format("<span foreground='%s'>%s</span>", Theme_config.notification.fg_urgent_app_name,
          n.app_name) or ""
        n.bg = Theme_config.notification.bg_urgent
      else
        n.title = string.format("<span foreground='%s' font='JetBrainsMono Nerd Font, ExtraBold 16'>%s</span>",
          Theme_config.notification.fg_normal_title, n.title) or ""
        n.message = string.format("<span foreground='%s'>%s</span>", Theme_config.notification.fg_normal_message,
          n.message) or ""
        n.bg = Theme_config.notification.bg_normal
        n.timeout = n.timeout or Theme_config.notification.timeout
      end

      local use_image = false

      if n.app_name == "Spotify" then
        n.actions = {
          naughty.action {
            program = "Spotify",
            id = "skip-prev",
            icon = gears.color.recolor_image(icondir .. "skip-prev.svg",
              Theme_config.notification.spotify_button_icon_color)
          }, naughty.action {
            program = "Spotify",
            id = "play-pause",
            icon = gears.color.recolor_image(icondir .. "play-pause.svg",
              Theme_config.notification.spotify_button_icon_color)
          }, naughty.action {
            program = "Spotify",
            id = "skip-next",
            icon = gears.color.recolor_image(icondir .. "skip-next.svg",
              Theme_config.notification.spotify_button_icon_color)
          }
        }
        use_image = true
      end

      local action_template_widget = {}

      if use_image then
        action_template_widget = {
          {
            {
              {
                {
                  id = "icon_role",
                  valign = "center",
                  halign = "center",
                  widget = wibox.widget.imagebox
                },
                id = "centered",
                valign = "center",
                halign = "center",
                widget = wibox.container.place
              },
              margins = dpi(5),
              widget = wibox.container.margin
            },
            forced_height = dpi(35),
            forced_width = dpi(35),
            bg = Theme_config.notification.action_bg,
            shape = function(cr, width, height)
              gears.shape.rounded_rect(cr, width, height, dpi(6))
            end,
            widget = wibox.container.background,
            id = "bgrnd"
          },
          id = "mrgn",
          top = dpi(10),
          bottom = dpi(10),
          widget = wibox.container.margin
        }
      else
        action_template_widget = {
          {
            {
              {
                {
                  id = "text_role",
                  font = "JetBrainsMono Nerd Font, Regular 12",
                  widget = wibox.widget.textbox
                },
                id = "centered",
                widget = wibox.container.place
              },
              margins = dpi(5),
              widget = wibox.container.margin
            },
            fg = Theme_config.notification.action_fg,
            bg = Theme_config.notification.action_bg,
            shape = function(cr, width, height)
              gears.shape.rounded_rect(cr, width, height, dpi(6))
            end,
            widget = wibox.container.background,
            id = "bgrnd"
          },
          id = "mrgn",
          top = dpi(10),
          bottom = dpi(10),
          widget = wibox.container.margin
        }
      end

      local actions_template = wibox.widget {
        notification = n,
        base_layout = wibox.widget {
          spacing = dpi(40),
          layout = wibox.layout.fixed.horizontal
        },
        widget_template = action_template_widget,
        style = {
          underline_normal = false,
          underline_selected = true
        },
        widget = naughty.list.actions
      }

      local arc_start = n.timeout
      if n.timeout == 0 then
        arc_start = 10
      end

      local w_template = wibox.widget {
        {
          {
            {
              {
                {
                  {
                    {
                      {
                        {
                          {
                            image = gears.color.recolor_image(icondir .. "notification-outline.svg",
                              Theme_config.notification.icon_color),
                            resize = false,
                            valign = "center",
                            halign = "center",
                            widget = wibox.widget.imagebox
                          },
                          right = dpi(5),
                          widget = wibox.container.margin
                        },
                        {
                          markup = n.app_name or 'System Notification',
                          align = "center",
                          valign = "center",
                          widget = wibox.widget.textbox
                        },
                        layout = wibox.layout.fixed.horizontal
                      },
                      fg = Theme_config.notification.fg_appname,
                      widget = wibox.container.background
                    },
                    margins = dpi(10),
                    widget = wibox.container.margin
                  },
                  nil,
                  {
                    {
                      {
                        text = os.date("%H:%M"),
                        widget = wibox.widget.textbox
                      },
                      id = "background",
                      fg = Theme_config.notification.fg_time,
                      widget = wibox.container.background
                    },
                    {
                      {
                        {
                          {
                            {
                              font = User_config.font.specify .. ", 10",
                              text = "✕",
                              align = "center",
                              valign = "center",
                              widget = wibox.widget.textbox
                            },
                            start_angle = 4.71239,
                            thickness = dpi(2),
                            min_value = 0,
                            max_value = arc_start,
                            value = arc_start,
                            widget = wibox.container.arcchart,
                            id = "arc_chart"
                          },
                          id = "background1",
                          fg = Theme_config.notification.fg_close,
                          bg = Theme_config.notification.bg_close,
                          widget = wibox.container.background
                        },
                        strategy = "exact",
                        width = dpi(20),
                        height = dpi(20),
                        widget = wibox.container.constraint,
                        id = "const1"
                      },
                      margins = dpi(10),
                      widget = wibox.container.margin,
                      id = "arc_margin"
                    },
                    layout = wibox.layout.fixed.horizontal,
                    id = "arc_app_layout_2"
                  },
                  id = "arc_app_layout",
                  layout = wibox.layout.align.horizontal
                },
                id = "arc_app_bg",
                border_color = Theme_config.notification.title_border_color,
                border_width = Theme_config.notification.title_border_width,
                widget = wibox.container.background
              },
              {
                {
                  {
                    {
                      {
                        image = n.icon,
                        resize = true,
                        widget = wibox.widget.imagebox,
                        valign = "center",
                        halign = "center",
                        clip_shape = function(cr, width, height)
                          gears.shape.rounded_rect(cr, width, height, 10)
                        end
                      },
                      width = naughty.config.defaults.icon_size,
                      height = naughty.config.defaults.icon_size,
                      strategy = "exact",
                      widget = wibox.container.constraint
                    },
                    halign = "center",
                    valign = "top",
                    widget = wibox.container.place
                  },
                  left = dpi(20),
                  bottom = dpi(15),
                  top = dpi(15),
                  right = dpi(10),
                  widget = wibox.container.margin
                },
                {
                  {
                    {
                      widget = naughty.widget.title,
                      align = "left"
                    },
                    {
                      widget = naughty.widget.message,
                      align = "left"
                    },
                    {
                      actions_template,
                      widget = wibox.container.place
                    },
                    layout = wibox.layout.fixed.vertical
                  },
                  left = dpi(10),
                  bottom = dpi(10),
                  top = dpi(10),
                  right = dpi(20),
                  widget = wibox.container.margin
                },
                layout = wibox.layout.fixed.horizontal
              },
              id = "widget_layout",
              layout = wibox.layout.fixed.vertical
            },
            id = "min_size",
            strategy = "min",
            width = dpi(100),
            widget = wibox.container.constraint
          },
          id = "max_size",
          strategy = "max",
          width = Theme.notification_max_width or dpi(500),
          widget = wibox.container.constraint
        },
        id = "background",
        bg = Theme_config.notification.bg,
        border_color = Theme_config.notification.border_color,
        border_width = Theme_config.notification.border_width,
        shape = Theme_config.notification.shape_inside,
        widget = wibox.container.background
      }

      local close = w_template:get_children_by_id("background1")[1]
      local arc = close.arc_chart

      local timeout = n.timeout

      if timeout ~= 0 then

        local rubato_timer = rubato.timed {
          duration = n.timeout,
          pos = n.timeout,
          easing = rubato.linear,
          subscribed = function(value)
            arc.value = value
          end
        }

        rubato_timer.target = 0

        w_template:connect_signal(
          "mouse::enter",
          function()
            n.timeout = 99999
            rubato_timer.pause = true
          end
        )

        w_template:connect_signal(
          "mouse::leave",
          function()
            n.timeout = rubato_timer.pos
            rubato_timer.pause = false
            rubato_timer.target = 0
          end
        )
      end

      Hover_signal(close)

      close:connect_signal(
        "button::press",
        function()
          n:destroy()
        end
      )

      w_template:connect_signal(
        "button::press",
        function(_, _, _, key)
          if key == 3 then
            n:destroy()
          end
          -- Raise the client on click
          if key == 1 then
            for _, client in ipairs(client.get()) do
              if client.name:match(n.app_name) then
                if not client:isvisible() and client.first_tag then
                  client.first_tag:view_only()
                end
                client:emit_signal('request::activate')
                client:raise()
              end
            end
          end
        end
      )

      local box = naughty.layout.box {
        notification = n,
        timeout = 5,
        type = "notification",
        screen = screen.primary,
        shape = function(cr, width, height)
          gears.shape.rounded_rect(cr, width, height, 10)
        end,
        widget_template = w_template
      }

      awful.spawn.easy_async_with_shell(
        "paplay /usr/share/sounds/freedesktop/stereo/message.oga"
      )

      box.buttons = {}
      n.buttons = {}
    end
  end
)

naughty.connect_signal(
  "destroyed",
  function()
  end
)

naughty.connect_signal(
  "invoked",
  function(_, action)
    if action.program == "Spotify" then
      if action.id == "skip-prev" then
        awful.spawn("playerctl previous")
      end
      if action.id == "play-pause" then
        awful.spawn("playerctl play-pause")
      end
      if action.id == "skip-next" then
        awful.spawn("playerctl next")
      end
    end
  end
)
