-----------------------------------
-- This is the titlebar module --
-----------------------------------

-- Awesome Libs
local awful = require("awful")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")

-- Icon directory path
local icondir = awful.util.getdir("config") .. "src/assets/icons/titlebar/"

awful.titlebar.enable_tooltip = true
awful.titlebar.fallback_name = 'Client'

-- Normal AND Focus(active/inactive) have to be set or errors will appear in stdout
Theme.titlebar_close_button_normal = icondir .. "close.svg"
Theme.titlebar_close_button_focus = icondir .. "close.svg"
Theme.titlebar_minimize_button_normal = icondir .. "minimize.svg"
Theme.titlebar_minimize_button_focus = icondir .. "minimize.svg"
Theme.titlebar_maximized_button_normal = icondir .. "maximize.svg"
Theme.titlebar_maximized_button_active = icondir .. "maximize.svg"
Theme.titlebar_maximized_button_inactive = icondir .. "maximize.svg"

local double_click_event_handler = function(double_click_event)
  if double_click_timer then
    double_click_timer:stop()
    double_click_timer = nil
    double_click_event()
    return
  end
  double_click_timer = gears.timer.start_new(
    0.20,
    function()
      double_click_timer = nil
      return false
    end
  )
end

local create_click_events = function(c)
  local buttons = gears.table.join(
    awful.button(
      {},
      1,
      function()
        double_click_event_handler(function()
          if c.floating then
            c.float = false
            return
          end
          c.maximized = not c.maximized
          c:raise()
        end)
        c:activate { context = 'titlebar', action = 'mouse_move' }
      end
    ),
    awful.button(
      {},
      3,
      function()
        c:activate { context = 'titlebar', action = 'mouse_resize' }
      end
    )
  )
  return buttons
end

local create_titlebar = function(c, size)
  local titlebar = awful.titlebar(c, {
    position = "left",
    bg = Theme_config.titlebar.bg,
    size = size
  })

  titlebar:setup {
    {
      {
        {
          {
            widget = awful.titlebar.widget.closebutton(c),
          },
          widget = wibox.container.background,
          bg = Theme_config.titlebar.close_button_bg,
          shape = function(cr, height, width)
            gears.shape.rounded_rect(cr, width, height, dpi(4))
          end,
          id = "closebutton"
        },
        {
          {
            widget = awful.titlebar.widget.maximizedbutton(c),
          },
          widget = wibox.container.background,
          bg = Theme_config.titlebar.minimize_button_bg,
          shape = function(cr, height, width)
            gears.shape.rounded_rect(cr, width, height, dpi(4))
          end,
          id = "maximizebutton"
        },
        {
          {
            widget = awful.titlebar.widget.minimizebutton(c),
          },
          widget = wibox.container.background,
          bg = Theme_config.titlebar.maximize_button_bg,
          shape = function(cr, height, width)
            gears.shape.rounded_rect(cr, width, height, dpi(4))
          end,
          id = "minimizebutton"
        },
        spacing = dpi(10),
        layout  = wibox.layout.fixed.vertical,
        id      = "spacing"
      },
      margins = dpi(8),
      widget = wibox.container.margin,
      id = "margin"
    },
    {
      buttons = create_click_events(c),
      layout = wibox.layout.flex.vertical
    },
    {
      {
        widget = awful.titlebar.widget.iconwidget(c),
      },
      margins = dpi(5),
      widget = wibox.container.margin
    },
    layout = wibox.layout.align.vertical,
    id = "main"
  }
  Hover_signal(titlebar.main.margin.spacing.closebutton, Theme_config.titlebar.close_button_bg,
    Theme_config.titlebar.close_button_fg)
  Hover_signal(titlebar.main.margin.spacing.maximizebutton, Theme_config.titlebar.minimize_button_bg,
    Theme_config.titlebar.minimize_button_fg)
  Hover_signal(titlebar.main.margin.spacing.minimizebutton, Theme_config.titlebar.maximize_button_bg,
    Theme_config.titlebar.maximize_button_fg)
end

local create_titlebar_dialog_modal = function(c, size)
  local titlebar = awful.titlebar(c, {
    position = "left",
    bg = Theme_config.titlebar.bg,
    size = size
  })

  titlebar:setup {
    {
      {
        {
          awful.titlebar.widget.closebutton(c),
          widget = wibox.container.background,
          bg = Theme_config.titlebar.close_button_bg,
          shape = function(cr, height, width)
            gears.shape.rounded_rect(cr, width, height, dpi(4))
          end,
          id = "closebutton"
        },
        {
          awful.titlebar.widget.minimizebutton(c),
          widget = wibox.container.background,
          bg = Theme_config.titlebar.minimize_button_bg,
          shape = function(cr, height, width)
            gears.shape.rounded_rect(cr, width, height, dpi(4))
          end,
          id = "minimizebutton"
        },
        spacing = dpi(10),
        layout  = wibox.layout.fixed.vertical,
        id      = "spacing"
      },
      margins = dpi(8),
      widget = wibox.container.margin,
      id = "margin"
    },
    {
      buttons = create_click_events(c),
      layout = wibox.layout.flex.vertical
    },
    {
      {
        widget = awful.widget.clienticon(c)
      },
      margins = dpi(5),
      widget = wibox.container.margin
    },
    layout = wibox.layout.align.vertical,
    id = "main"
  }
  Hover_signal(titlebar.main.margin.spacing.closebutton, Theme_config.titlebar.close_button_bg,
    Theme_config.titlebar.close_button_fg)
  Hover_signal(titlebar.main.margin.spacing.minimizebutton, Theme_config.titlebar.minimize_button_bg,
    Theme_config.titlebar.minimize_button_fg)
end

client.connect_signal(
  "request::titlebars",
  function(c)
    if c.type == "normal" then
      create_titlebar(c, dpi(35))
    elseif c.type == "dialog" then
      create_titlebar_dialog_modal(c, dpi(35))
    elseif c.type == "modal" then
      create_titlebar_dialog_modal(c, dpi(35))
    else
      create_titlebar(c, dpi(35))
    end

    if not c.floating or c.maximized or c.fullscreen then
      awful.titlebar.hide(c, "left")
    end
  end
)

client.connect_signal(
  "property::floating",
  function(c)
    if c.floating and not (c.maximized or c.fullscreen) then
      awful.titlebar.show(c, "left")
    else
      awful.titlebar.hide(c, "left")
    end
  end
)
