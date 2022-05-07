-----------------------------------
-- This is the volume_old module --
-----------------------------------

-- Awesome Libs
local awful = require("awful")
local color = require("src.theme.colors")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")

-- Icon directory path
local icondir = awful.util.getdir("config") .. "src/assets/icons/audio/"

-- Returns the volume_osd
return function(s)

  local volume_osd_widget = wibox.widget {
    {
      {
        {
          {
            nil,
            {
              nil,
              {
                id = "icon",
                forced_height = dpi(220),
                image = icondir .. "volume-high.svg",
                widget = wibox.widget.imagebox
              },
              nil,
              expand = "none",
              id = "icon_margin2",
              layout = wibox.layout.align.vertical
            },
            nil,
            id = "icon_margin1",
            expand = "none",
            layout = wibox.layout.align.horizontal
          },
          {
            {
              id = "label",
              text = "Volume",
              align = "left",
              valign = "center",
              widget = wibox.widget.textbox
            },
            nil,
            {
              id = "value",
              text = "0%",
              align = "center",
              valign = "center",
              widget = wibox.widget.textbox
            },
            id = "label_value_layout",
            forced_height = dpi(48),
            layout = wibox.layout.align.horizontal,
          },
          {
            {
              id = "volume_slider",
              bar_shape = gears.shape.rounded_rect,
              bar_height = dpi(10),
              bar_color = color["Grey800"] .. "88",
              bar_active_color = "#ffffff",
              handle_color = "#ffffff",
              handle_shape = gears.shape.circle,
              handle_width = dpi(10),
              handle_border_color = color["White"],
              maximum = 100,
              widget = wibox.widget.slider
            },
            id = "slider_layout",
            forced_height = dpi(24),
            widget = wibox.container.place
          },
          id = "icon_slider_layout",
          spacing = dpi(0),
          layout = wibox.layout.align.vertical
        },
        id = "osd_layout",
        layout = wibox.layout.align.vertical
      },
      id = "container",
      left = dpi(24),
      right = dpi(24),
      widget = wibox.container.margin
    },
    bg = color["Grey900"] .. '88',
    widget = wibox.container.background,
    ontop = true,
    visible = true,
    type = "notification",
    forced_height = dpi(300),
    forced_width = dpi(300),
    offset = dpi(5),
  }

  local function update_osd()
    awful.spawn.easy_async_with_shell(
      "./.config/awesome/src/scripts/vol.sh volume",
      function(stdout)
      local volume_level = stdout:gsub("\n", ""):gsub("%%", "")
      awesome.emit_signal("widget::volume")
      volume_osd_widget.container.osd_layout.icon_slider_layout.label_value_layout.value:set_text(volume_level .. "%")

      awesome.emit_signal(
        "widget::volume:update",
        volume_level
      )

      if awful.screen.focused().show_volume_osd then
        awesome.emit_signal(
          "module::volume_osd:show",
          true
        )
      end
      volume_level = tonumber(volume_level)
      local icon = icondir .. "volume"
      if volume_level < 1 then
        icon = icon .. "-mute"
      elseif volume_level >= 1 and volume_level < 34 then
        icon = icon .. "-low"
      elseif volume_level >= 34 and volume_level < 67 then
        icon = icon .. "-medium"
      elseif volume_level >= 67 then
        icon = icon .. "-high"
      end
      volume_osd_widget.container.osd_layout.icon_slider_layout.icon_margin1.icon_margin2.icon:set_image(icon .. ".svg")
    end
    )
  end

  volume_osd_widget.container.osd_layout.icon_slider_layout.slider_layout.volume_slider:connect_signal(
    "property::value",
    function()
    update_osd()
  end
  )

  local update_slider = function()
    awful.spawn.easy_async_with_shell(
      "./.config/awesome/src/scripts/vol.sh mute",
      function(stdout)
      if stdout:match("yes") then
        volume_osd_widget.container.osd_layout.icon_slider_layout.label_value_layout.value:set_text("0%")
        volume_osd_widget.container.osd_layout.icon_slider_layout.icon_margin1.icon_margin2.icon:set_image(icondir .. "volume-mute" .. ".svg")
      else
        awful.spawn.easy_async_with_shell(
          "./.config/awesome/src/scripts/vol.sh volume",
          function(stdout2)
          stdout2 = stdout2:gsub("%%", ""):gsub("\n", "")
          volume_osd_widget.container.osd_layout.icon_slider_layout.slider_layout.volume_slider:set_value(tonumber(stdout2))
          update_osd()
        end
        )
      end
    end
    )
  end

  -- Signals
  awesome.connect_signal(
    "module::slider:update",
    function()
    update_slider()
  end
  )

  awesome.connect_signal(
    "widget::volume:update",
    function(value)
    volume_osd_widget.container.osd_layout.icon_slider_layout.slider_layout.volume_slider:set_value(tonumber(value))
  end
  )

  update_slider()

  local volume_container = awful.popup {
    widget = wibox.container.background,
    ontop = true,
    bg = color["Grey900"] .. "00",
    stretch = false,
    visible = false,
    screen = s,
    placement = function(c) awful.placement.centered(c, { margins = { top = dpi(200) } }) end,
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, 15)
    end
  }

  local hide_volume_osd = gears.timer {
    timeout = 2,
    autostart = true,
    callback = function()
      volume_container.visible = false
    end
  }

  volume_container:setup {
    volume_osd_widget,
    layout = wibox.layout.fixed.horizontal
  }

  awesome.connect_signal(
    "module::volume_osd:show",
    function()
    if s == mouse.screen then
      volume_container.visible = true
    end
  end
  )

  volume_container:connect_signal(
    "mouse::enter",
    function()
    volume_container.visible = true
    hide_volume_osd:stop()
  end
  )

  volume_container:connect_signal(
    "mouse::leave",
    function()
    volume_container.visible = true
    hide_volume_osd:again()
  end
  )

  awesome.connect_signal(
    "widget::volume_osd:rerun",
    function()
    if hide_volume_osd.started then
      hide_volume_osd:again()
    else
      hide_volume_osd:start()
    end
  end
  )
end
