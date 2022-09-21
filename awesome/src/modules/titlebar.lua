-----------------------------------
-- This is the titlebar module --
-----------------------------------

-- Awesome Libs
local awful = require("awful")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")

local capi = {
  awesome = awesome,
  client = client
}

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

local create_buttons = function(c)
  local buttons = gears.table.join(
    awful.button(
      {},
      1,
      function()
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

local create_titlebar = function(c, size, position)
  local close_button = awful.titlebar.widget.closebutton(c)
  local minimize_button = awful.titlebar.widget.minimizebutton(c)
  local maximize_button = awful.titlebar.widget.maximizedbutton(c)

  local tb

  if position == "left" then
    local titlebar = awful.titlebar(c, {
      position = "left",
      bg = Theme_config.titlebar.bg,
      size = size
    })

    tb = wibox.widget {
      {
        {
          {
            close_button,
            widget = wibox.container.background,
            border_color = Theme_config.titlebar.close_button.border_color,
            border_width = dpi(2),
            shape = function(cr, height, width)
              gears.shape.rounded_rect(cr, width, height, dpi(6))
            end,
            id = "closebutton"
          },
          {
            maximize_button,
            widget = wibox.container.background,
            border_color = Theme_config.titlebar.maximize_button.border_color,
            border_width = dpi(2),
            shape = function(cr, height, width)
              gears.shape.rounded_rect(cr, width, height, dpi(6))
            end,
            id = "maximizebutton"
          },
          {
            minimize_button,
            widget = wibox.container.background,
            border_color = Theme_config.titlebar.minimize_button.border_color,
            border_width = dpi(2),
            shape = function(cr, height, width)
              gears.shape.rounded_rect(cr, width, height, dpi(6))
            end,
            id = "minimizebutton"
          },
          spacing = dpi(10),
          layout  = wibox.layout.fixed.vertical,
          id      = "spacing"
        },
        margins = dpi(5),
        widget = wibox.container.margin,
        id = "margin"
      },
      {
        buttons = create_buttons(c),
        layout = wibox.layout.flex.vertical
      },
      {
        awful.titlebar.widget.iconwidget(c),
        margins = dpi(5),
        widget = wibox.container.margin
      },
      layout = wibox.layout.align.vertical,
      id = "main"
    }

    titlebar:setup { tb, layout = wibox.layout.fixed.horizontal }

  elseif position == "top" then
    local titlebar = awful.titlebar(c, {
      position = "top",
      bg = Theme_config.titlebar.bg,
      size = size
    })

    tb = wibox.widget {
      {
        awful.titlebar.widget.iconwidget(c),
        margins = dpi(5),
        widget = wibox.container.margin
      },
      {
        {
          awful.titlebar.widget.titlewidget(c),
          valign = "center",
          halign = "center",
          layout = wibox.container.place,
        },
        buttons = create_buttons(c),
        fill_space = true,
        layout = wibox.layout.stack
      },
      {
        {
          {
            minimize_button,
            widget = wibox.container.background,
            border_color = Theme_config.titlebar.minimize_button.border_color,
            border_width = dpi(2),
            shape = function(cr, height, width)
              gears.shape.rounded_rect(cr, width, height, dpi(6))
            end,
            id = "minimizebutton"
          },
          {
            maximize_button,
            widget = wibox.container.background,
            border_color = Theme_config.titlebar.maximize_button.border_color,
            border_width = dpi(2),
            shape = function(cr, height, width)
              gears.shape.rounded_rect(cr, width, height, dpi(6))
            end,
            id = "maximizebutton"
          },
          {
            close_button,
            widget = wibox.container.background,
            border_color = Theme_config.titlebar.close_button.border_color,
            border_width = dpi(2),
            shape = function(cr, height, width)
              gears.shape.rounded_rect(cr, width, height, dpi(6))
            end,
            id = "closebutton"
          },
          spacing = dpi(10),
          layout  = wibox.layout.fixed.horizontal,
          id      = "spacing"
        },
        margins = dpi(5),
        widget = wibox.container.margin,
        id = "margin"
      },
      layout = wibox.layout.align.horizontal,
      id = "main"
    }

    titlebar:setup { tb, layout = wibox.layout.fixed.vertical }
  end

  if not tb then return end

  close_button:connect_signal(
    "mouse::enter",
    function()
      c.border_color = Theme_config.titlebar.close_button.hover_border
      local cb = tb:get_children_by_id("closebutton")[1]
      cb.border_color = Theme_config.titlebar.close_button.hover_border
      cb.bg = Theme_config.titlebar.close_button.hover_bg
    end
  )

  close_button:connect_signal(
    "mouse::leave",
    function()
      c.border_color = Theme_config.window.border_normal
      local cb = tb:get_children_by_id("closebutton")[1]
      cb.border_color = Theme_config.titlebar.close_button.border_color
      cb.bg = Theme_config.titlebar.close_button.bg
    end
  )

  minimize_button:connect_signal(
    "mouse::enter",
    function()
      c.border_color = Theme_config.titlebar.minimize_button.hover_border
      local mb = tb:get_children_by_id("minimizebutton")[1]
      mb.border_color = Theme_config.titlebar.minimize_button.hover_border
      mb.bg = Theme_config.titlebar.minimize_button.hover_bg
    end
  )

  minimize_button:connect_signal(
    "mouse::leave",
    function()
      c.border_color = Theme_config.window.border_normal
      local mb = tb:get_children_by_id("minimizebutton")[1]
      mb.border_color = Theme_config.titlebar.minimize_button.border_color
      mb.bg = Theme_config.titlebar.minimize_button.bg
    end
  )

  maximize_button:connect_signal(
    "mouse::enter",
    function()
      c.border_color = Theme_config.titlebar.maximize_button.hover_border
      local mb = tb:get_children_by_id("maximizebutton")[1]
      mb.border_color = Theme_config.titlebar.maximize_button.hover_border
      mb.bg = Theme_config.titlebar.maximize_button.hover_bg
    end
  )

  maximize_button:connect_signal(
    "mouse::leave",
    function()
      c.border_color = Theme_config.window.border_normal
      local mb = tb:get_children_by_id("maximizebutton")[1]
      mb.border_color = Theme_config.titlebar.maximize_button.border_color
      mb.bg = Theme_config.titlebar.maximize_button.bg
    end
  )
end

local create_titlebar_dialog_modal = function(c, size, position)
  local close_button = awful.titlebar.widget.closebutton(c)
  local minimize_button = awful.titlebar.widget.minimizebutton(c)
  local maximize_button = awful.titlebar.widget.maximizedbutton(c)

  local tb

  if position == "left" then
    local titlebar = awful.titlebar(c, {
      position = "left",
      bg = Theme_config.titlebar.bg,
      size = size
    })

    tb = wibox.widget {
      {
        {
          close_button,
          widget = wibox.container.background,
          border_color = Theme_config.titlebar.close_button.border_color,
          border_width = dpi(2),
          shape = function(cr, height, width)
            gears.shape.rounded_rect(cr, width, height, dpi(6))
          end,
          id = "closebutton"
        },
        margins = dpi(5),
        widget = wibox.container.margin,
        id = "margin"
      },
      {
        buttons = create_buttons(c),
        layout = wibox.layout.flex.vertical
      },
      {
        awful.titlebar.widget.iconwidget(c),
        margins = dpi(5),
        widget = wibox.container.margin
      },
      layout = wibox.layout.align.vertical,
      id = "main"
    }

    titlebar:setup { tb, layout = wibox.layout.fixed.horizontal }

  elseif position == "top" then
    local titlebar = awful.titlebar(c, {
      position = "top",
      bg = Theme_config.titlebar.bg,
      size = size
    })

    tb = wibox.widget {
      {
        awful.titlebar.widget.iconwidget(c),
        margins = dpi(5),
        widget = wibox.container.margin
      },
      {
        {
          awful.titlebar.widget.titlewidget(c),
          valign = "center",
          halign = "center",
          layout = wibox.container.place,
        },
        buttons = create_buttons(c),
        fill_space = true,
        layout = wibox.layout.stack
      },
      {
        {
          close_button,
          widget = wibox.container.background,
          border_color = Theme_config.titlebar.close_button.border_color,
          border_width = dpi(2),
          shape = function(cr, height, width)
            gears.shape.rounded_rect(cr, width, height, dpi(6))
          end,
          id = "closebutton"
        },
        margins = dpi(5),
        widget = wibox.container.margin,
        id = "margin"
      },
      layout = wibox.layout.align.horizontal,
      id = "main"
    }

    titlebar:setup { tb, layout = wibox.layout.fixed.vertical }
  end

  if not tb then return end

  close_button:connect_signal(
    "mouse::enter",
    function()
      c.border_color = Theme_config.titlebar.close_button.hover_border
      local cb = tb:get_children_by_id("closebutton")[1]
      cb.border_color = Theme_config.titlebar.close_button.hover_border
      cb.bg = Theme_config.titlebar.close_button.hover_bg
    end
  )

  close_button:connect_signal(
    "mouse::leave",
    function()
      c.border_color = Theme_config.window.border_normal
      local cb = tb:get_children_by_id("closebutton")[1]
      cb.border_color = Theme_config.titlebar.close_button.border_color
      cb.bg = Theme_config.titlebar.close_button.bg
    end
  )

  minimize_button:connect_signal(
    "mouse::enter",
    function()
      c.border_color = Theme_config.titlebar.minimize_button.hover_border
      local mb = tb:get_children_by_id("minimizebutton")[1]
      mb.border_color = Theme_config.titlebar.minimize_button.hover_border
      mb.bg = Theme_config.titlebar.minimize_button.hover_bg
    end
  )

  minimize_button:connect_signal(
    "mouse::leave",
    function()
      c.border_color = Theme_config.window.border_normal
      local mb = tb:get_children_by_id("minimizebutton")[1]
      mb.border_color = Theme_config.titlebar.minimize_button.border_color
      mb.bg = Theme_config.titlebar.minimize_button.bg
    end
  )

  maximize_button:connect_signal(
    "mouse::enter",
    function()
      c.border_color = Theme_config.titlebar.maximize_button.hover_border
      local mb = tb:get_children_by_id("maximizebutton")[1]
      mb.border_color = Theme_config.titlebar.maximize_button.hover_border
      mb.bg = Theme_config.titlebar.maximize_button.hover_bg
    end
  )

  maximize_button:connect_signal(
    "mouse::leave",
    function()
      c.border_color = Theme_config.window.border_normal
      local mb = tb:get_children_by_id("maximizebutton")[1]
      mb.border_color = Theme_config.titlebar.maximize_button.border_color
      mb.bg = Theme_config.titlebar.maximize_button.bg
    end
  )
end

capi.client.connect_signal(
  "request::titlebars",
  function(c)
    if c.type == "dialog" then
      create_titlebar_dialog_modal(c, dpi(35), User_config.titlebar_position)
    elseif c.type == "modal" then
      create_titlebar_dialog_modal(c, dpi(35), User_config.titlebar_position)
    else
      create_titlebar(c, dpi(35), User_config.titlebar_position)
    end

    if not c.floating or c.maximized or c.fullscreen then
      if User_config.titlebar_position == "left" then
        awful.titlebar.hide(c, "left")
      elseif User_config.titlebar_position == "top" then
        awful.titlebar.hide(c, "top")
      end
    end
  end
)

capi.client.connect_signal(
  "property::floating",
  function(c)
    if c.floating and not (c.maximized or c.fullscreen) then
      if User_config.titlebar_position == "left" then
        awful.titlebar.show(c, "left")
      elseif User_config.titlebar_position == "top" then
        awful.titlebar.show(c, "top")
      end
    else
      if User_config.titlebar_position == "left" then
        awful.titlebar.hide(c, "left")
      elseif User_config.titlebar_position == "top" then
        awful.titlebar.hide(c, "top")
      end
    end
  end
)
