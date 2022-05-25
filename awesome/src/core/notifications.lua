-------------------------------
-- The Notification defaults --
-------------------------------
-- Awesome Libs
local awful = require("awful")
local color = require("src.theme.colors")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local menubar = require('menubar')
local naughty = require("naughty")
local wibox = require("wibox")

local icondir = awful.util.getdir("config") .. "src/assets/icons/notifications/"

-- TODO: Figure out how to use hover effects without messing up the actions
naughty.config.defaults.ontop = true
naughty.config.defaults.icon_size = dpi(80)
naughty.config.defaults.timeout = 3
naughty.config.defaults.title = "System Notification"
naughty.config.defaults.margin = dpi(10)
naughty.config.defaults.position = "bottom_right"
naughty.config.defaults.shape = function(cr, width, height)
  gears.shape.rounded_rect(cr, width, height, dpi(10))
end
naughty.config.defaults.border_width = dpi(4)
naughty.config.defaults.border_color = color["Grey800"]
naughty.config.defaults.spacing = dpi(10)

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
    if n.urgency == "critical" then
      n.title = string.format("<span foreground='%s' font='JetBrainsMono Nerd Font, ExtraBold 16'>%s</span>",
        color["RedA200"], n.title) or ""
      n.message = string.format("<span foreground='%s'>%s</span>", color["Red200"], n.message) or ""
      n.app_name = string.format("<span foreground='%s'>%s</span>", color["RedA400"], n.app_name) or ""
      n.bg = color["Grey900"]
    else
      n.title = string.format("<span foreground='%s' font='JetBrainsMono Nerd Font, ExtraBold 16'>%s</span>",
        color["Pink200"], n.title) or ""
      n.message = string.format("<span foreground='%s'>%s</span>", "#ffffffaa", n.message) or ""
      n.bg = color["Grey900"]
      n.timeout = n.timeout or 3
    end

    local use_image = false

    if n.app_name == "Spotify" then
      n.actions = { naughty.action {
        program = "Spotify",
        id = "skip-prev",
        icon = gears.color.recolor_image(icondir .. "skip-prev.svg", color["Cyan200"])
      }, naughty.action {
        program = "Spotify",
        id = "play-pause",
        icon = gears.color.recolor_image(icondir .. "play-pause.svg", color["Cyan200"])
      }, naughty.action {
        program = "Spotify",
        id = "skip-next",
        icon = gears.color.recolor_image(icondir .. "skip-next.svg", color["Cyan200"])
      } }
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
          fg = color["Cyan200"],
          bg = color["Grey800"],
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
          fg = color["Green200"],
          bg = color["Grey800"],
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
        underline_selected = true,
        bg_normal = color["Grey100"],
        bg_selected = color["Grey200"]
      },
      widget = naughty.list.actions
    }

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
                          image = gears.color.recolor_image(icondir .. "notification-outline.svg", color["Teal200"]),
                          resize = false,
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
                    fg = color["Teal200"],
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
                    fg = color["Teal200"],
                    widget = wibox.container.background
                  },
                  {
                    {
                      {
                        {
                          {
                            font = user_vars.font.specify .. ", 10",
                            text = "✕",
                            align = "center",
                            valign = "center",
                            widget = wibox.widget.textbox
                          },
                          start_angle = 4.71239,
                          thickness = dpi(2),
                          min_value = 0,
                          max_value = 360,
                          value = 360,
                          widget = wibox.container.arcchart,
                          id = "arc_chart"
                        },
                        id = "background",
                        fg = color["Teal200"],
                        bg = color["Grey900"],
                        widget = wibox.container.background
                      },
                      strategy = "exact",
                      width = dpi(20),
                      height = dpi(20),
                      widget = wibox.container.constraint,
                      id = "const"
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
              border_color = color["Grey800"],
              border_width = dpi(2),
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
      bg = color["Grey900"],
      border_color = color["Grey800"],
      border_width = dpi(4),
      shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, 4)
      end,
      widget = wibox.container.background
    }

    local close = w_template.max_size.min_size.widget_layout.arc_app_bg.arc_app_layout.arc_app_layout_2.arc_margin.const.background
    local arc = close.arc_chart

    local timeout = n.timeout
    local remove_time = timeout

    if timeout ~= 0 then
      arc.value = 360
      local arc_timer = gears.timer {
        timeout = 0.1,
        call_now = true,
        autostart = true,
        callback = function()
          arc.value = (remove_time - 0) / (timeout - 0) * 360
          remove_time = remove_time - 0.1
        end
      }

      w_template:connect_signal(
        "mouse::enter",
        function()
          -- Setting to 0 doesn't work
          arc_timer:stop()
          n.timeout = 99999
        end
      )

      w_template:connect_signal(
        "mouse::leave",
        function()
          arc_timer:start()
          n.timeout = remove_time
        end
      )
    end

    Hover_signal(close, color["Grey900"], color["Teal200"])

    close:connect_signal(
      "button::press",
      function()
        n:destroy()
      end
    )

    w_template:connect_signal(
      "button::press",
      function(c, d, e, key)
        if key == 3 then
          n:destroy()
        end
        -- TODO: Find out how to get the associated client
        --[[ if key == 1 then
          if n.clients then
            n.clients[1]:activate {
              switch_to_tag = true,
              raise         = true
            }
          end
        end ]]
      end
    )

    local box = naughty.layout.box {
      notification = n,
      timeout = 3,
      type = "notification",
      screen = awful.screen.focused(),
      shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, 10)
      end,
      widget_template = w_template
    }

    box.buttons = {}
    n.buttons = {}
  end
)

naughty.connect_signal(
  "destroyed",
  function()

  end
)

-- Test notification
--[[naughty.notification {
  app_name = "System Notification",
  title    = "A notification 3",
  message  = "This is very informative and overflowing",
  icon     = "/home/crylia/.config/awesome/src/assets/userpfp/crylia.png",
  urgency  = "normal",
  timeout  = 1,
  actions  = {
    naughty.action {
      name = "Accept",
    },
    naughty.action {
      name = "Refuse",
    },
    naughty.action {
      name = "Ignore",
    },
  }
}--]]

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
