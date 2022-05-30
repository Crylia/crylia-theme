-------------------------------------
-- This is the notification-center --
-------------------------------------

-- Awesome Libs
local awful = require("awful")
local color = require("src.theme.colors")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")

-- Icon directory path
local icondir = awful.util.getdir("config") .. "src/assets/icons/notifications/"

return function(s)

  --#region Activation area

  local activation_area = awful.popup {
    bg = '#00000000',
    widget = wibox.container.background,
    ontop = true,
    screen = s,
    type = 'dock',
    placement = function(c)
      awful.placement.top(c)
    end,
  }

  activation_area:setup({
    widget = wibox.container.background,
    forced_height = dpi(1),
    forced_width = dpi(300),
    bg = '#00000000',
    layout = wibox.layout.fixed.horizontal
  })

  --#endregion

  --#region Widgets
  local nl = require("src.modules.notification-center.notification_list").notification_list
  local music_widget = require("src.modules.notification-center.song_info")()
  local time_date = require("src.modules.notification-center.time_date")()
  local weather_widget = require("src.modules.notification-center.weather")()
  local profile_widget = require("src.modules.notification-center.profile")()
  local status_bars_widget = require("src.modules.notification-center.status_bars")()
  --#endregion

  --#region Notification buttons
  local clear_all_widget = wibox.widget { -- Clear all button
    {
      {
        {
          text = "Clear",
          valign = "center",
          align = "center",
          widget = wibox.widget.textbox,
          id = "clearall"
        },
        id = "background4",
        fg = color["Grey900"],
        bg = color["Blue200"],
        shape = function(cr, width, height)
          gears.shape.rounded_rect(cr, width, height, 12)
        end,
        forced_width = dpi(80),
        forced_height = dpi(40),
        widget = wibox.container.background
      },
      id = "margin3",
      margins = dpi(10),
      widget = wibox.container.margin
    },
    id = "place",
    widget = wibox.container.place,
    valign = "bottom",
    halign = "right",
  }

  local left_button = wibox.widget {
    {
      {
        widget = wibox.container.background,
        bg = color["Grey700"],
        shape = function(cr, width, height)
          gears.shape.rounded_rect(cr, width, height, dpi(8))
        end,
        forced_height = dpi(30),
        forced_width = dpi(30),
        id = "circle"
      },
      left = dpi(5),
      right = dpi(5),
      widget = wibox.container.margin,
      id = "margin"
    },
    visible = true,
    valign = "center",
    halign = "left",
    widget = wibox.container.place,
  }

  local right_button = wibox.widget {
    {
      {
        widget = wibox.container.background,
        bg = color["Purple200"],
        shape = function(cr, width, height)
          gears.shape.rounded_rect(cr, width, height, dpi(8))
        end,
        forced_height = dpi(30),
        forced_width = dpi(30),
        id = "circle"
      },
      left = dpi(5),
      right = dpi(5),
      widget = wibox.container.margin,
      id = "margin"
    },
    valign = "center",
    halign = "right",
    visible = false,
    widget = wibox.container.place,
  }

  local toggle_button = wibox.widget {
    {
      left_button,
      right_button,
      widget = wibox.layout.flex.horizontal
    },
    active = false,
    widget = wibox.container.background,
    bg = color["Grey900"],
    border_color = color["Grey800"],
    border_width = dpi(2),
    forced_height = dpi(40),
    forced_width = dpi(80),
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(10))
    end,
  }

  toggle_button:connect_signal(
    "button::press",
    function()
      if toggle_button.active then
        left_button.visible = true
        right_button.visible = false
        toggle_button.active = not toggle_button.active
        toggle_button.border_color = color["Grey800"]
        user_vars.dnd = false
      else
        left_button.visible = false
        right_button.visible = true
        toggle_button.active = not toggle_button.active
        toggle_button.border_color = color["Purple200"]
        user_vars.dnd = true
      end
    end
  )

  local dnd = wibox.widget { -- Clear all button
    {
      {
        {
          {
            text = "Do Not Disturb",
            valign = "center",
            align = "center",
            widget = wibox.widget.textbox,
            id = "clearall"
          },
          toggle_button,
          spacing = dpi(10),
          layout = wibox.layout.fixed.horizontal,
          id = "layout12"
        },
        id = "background4",
        fg = color["Pink200"],
        shape = function(cr, width, height)
          gears.shape.rounded_rect(cr, width, height, 12)
        end,
        forced_height = dpi(40),
        widget = wibox.container.background
      },
      id = "margin3",
      margins = dpi(10),
      widget = wibox.container.margin
    },
    id = "place",
    widget = wibox.container.place,
    valign = "bottom",
    halign = "right",
  }

  -- TODO: Add rubato animation. For this the widget needs to be rewritten to use a single moving square
  local no_notification_widget = wibox.widget {
    {
      {
        valign = "center",
        halign = "center",
        resize = true,
        forced_height = dpi(200),
        forced_width = dpi(200),
        image = icondir .. "megamind.svg",
        widget = wibox.widget.imagebox,
        id = "icon"
      },
      {
        id = "txt",
        markup = "<span color='#414141' font='JetBrainsMono Nerd Font, ExtraBold 20'>No Notifications?</span>",
        valign = "center",
        halign = "center",
        widget = wibox.widget.textbox
      },
      id = "lay",
      layout = wibox.layout.fixed.vertical
    },
    valign = "center",
    halign = "center",
    widget = wibox.container.place
  }

  --#endregion

  --#region Notification center
  local notification_center = awful.popup {
    widget = wibox.container.background,
    bg = color["Grey900"],
    border_color = color["Grey800"],
    border_width = dpi(4),
    placement = function(c)
      awful.placement.top(c, { margins = dpi(10) })
    end,
    ontop = true,
    screen = s,
    visible = false,
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, 12)
    end,
  }

  -- TODO: Currently awesome doesn't come with a scroll container, there is a PR(#3309) and once its merged we can use it
  local function notification_center_setup()
    notification_center:setup({
      widget = notification_center,
      -- Custom widgets
      {
        time_date,
        require("src.modules.notification-center.spacingline_widget")(),
        {
          {
            weather_widget,
            {
              profile_widget,
              layout = wibox.layout.fixed.vertical
            },
            layout = wibox.layout.fixed.horizontal
          },
          layout = wibox.layout.fixed.horizontal
        },
        status_bars_widget,
        music_widget,
        layout = wibox.layout.fixed.vertical
      },
      -- Notification list
      {
        {
          {
            nl,
            height = dpi(680),
            strategy = "max",
            widget = wibox.container.constraint
          },
          {
            no_notification_widget,
            strategy = "max",
            height = dpi(400),
            widget = wibox.container.constraint
          },
          {
            dnd,
            nil,
            clear_all_widget,
            layout = wibox.layout.align.horizontal
          },
          id = "layout5",
          layout = wibox.layout.align.vertical
        },
        id = "margin6",
        margins = dpi(20),
        widget = wibox.container.margin
      },
      id = "yes",
      spacing_widget = {
        {
          fg = color["Grey800"],
          bg = color["Grey800"],
          widget = wibox.container.background
        },
        top = dpi(40),
        bottom = dpi(40),
        widget = wibox.container.margin
      },
      spacing = dpi(1),
      forced_height = dpi(800),
      forced_width = dpi(1000),
      layout = wibox.layout.flex.horizontal
    })
  end

  --#endregion

  --#region Signals
  -- Toggle notification_center visibility when mouse is over activation_area
  activation_area:connect_signal(
    "mouse::enter",
    function()
      notification_center.visible = true
      notification_center_setup()
    end
  )

  -- Update the notification center popup and check if there are no notifications
  awesome.connect_signal(
    "notification_center:update::needed",
    function()
      if #nl == 0 then
        math.randomseed(os.time())
        local prob = math.random(1, 10)

        if (prob == 5) or (prob == 6) then
          no_notification_widget.lay.icon.image = icondir .. "megamind.svg"
          no_notification_widget.lay.txt.markup = "<span color='#414141' font='JetBrainsMono Nerd Font, ExtraBold 20'>No Notifications?</span>"
        else
          no_notification_widget.lay.icon.image = icondir .. "bell-outline.svg"
          no_notification_widget.lay.txt.markup = "<span color='#414141' font='JetBrainsMono Nerd Font, ExtraBold 20'>No Notification</span>"
        end
        no_notification_widget.visible = true
      else
        no_notification_widget.visible = false
      end
      notification_center_setup()
    end
  )

  -- Hide notification_center when mouse leaves it
  notification_center:connect_signal(
    "mouse::leave",
    function()
      notification_center.visible = false
    end
  )

  -- Clear all notifications on button press
  clear_all_widget:connect_signal(
    "button::press",
    function()
      local size = #nl
      for i = 0, size do
        nl[i] = nil
      end
      awesome.emit_signal("notification_center:update::needed")
    end
  )

  Hover_signal(clear_all_widget, color["Blue200"], color["Grey900"])
  --#endregion

end
