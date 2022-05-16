---------------------------------------
-- This is the brightness_osd module --
---------------------------------------

-- Awesome Libs
local awful = require("awful")
local color = require("src.theme.colors")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")

-- Icon directory path
local icondir = awful.util.getdir("config") .. "src/assets/icons/brightness/"

BACKLIGHT_MAX_BRIGHTNESS = 0
BACKLIGHT_SEPS = 0
awful.spawn.easy_async_with_shell(
  "pkexec xfpm-power-backlight-helper --get-max-brightness",
  function(stdout)
  BACKLIGHT_MAX_BRIGHTNESS = tonumber(stdout)
  BACKLIGHT_SEPS = BACKLIGHT_MAX_BRIGHTNESS / 100
  BACKLIGHT_SEPS = math.floor(BACKLIGHT_SEPS)
end
)

return function(s)

  local brightness_osd_widget = wibox.widget {
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
                image = icondir .. "brightness-high.svg",
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
              text = "Brightness",
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
              id = "brightness_slider",
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
    bg = color["Grey900"] .. "88",
    widget = wibox.container.background,
    ontop = true,
    visible = true,
    type = "notification",
    forced_height = dpi(300),
    forced_width = dpi(300),
    offset = dpi(5),
  }

  brightness_osd_widget.container.osd_layout.icon_slider_layout.slider_layout.brightness_slider:connect_signal(
    "property::value",
    function()
    awful.spawn.easy_async_with_shell(
      "pkexec xfpm-power-backlight-helper --get-brightness",
      function(stdout)
      local brightness_value = math.floor((tonumber(stdout) - 1) / (BACKLIGHT_MAX_BRIGHTNESS - 1) * 100)
      brightness_osd_widget.container.osd_layout.icon_slider_layout.label_value_layout.value:set_text(tostring(brightness_value) .. "%")

      awesome.emit_signal(
        "widget::brightness:update",
        brightness_value
      )

      if awful.screen.focused().show_brightness_osd then
        awesome.emit_signal(
          "module::brightness_osd:show",
          true
        )
      end

      local icon = icondir .. "brightness"
      if brightness_value >= 0 and brightness_value < 34 then
        icon = icon .. "-low"
      elseif brightness_value >= 34 and brightness_value < 67 then
        icon = icon .. "-medium"
      elseif brightness_value >= 67 then
        icon = icon .. "-high"
      end
      brightness_osd_widget.container.osd_layout.icon_slider_layout.icon_margin1.icon_margin2.icon:set_image(icon .. ".svg")
    end
    )
  end
  )

  local update_slider = function()
    awful.spawn.easy_async_with_shell(
      [[ pkexec xfpm-power-backlight-helper --get-brightness ]],
      function(stdout)
      stdout = math.floor((tonumber(stdout) - 1) / (BACKLIGHT_MAX_BRIGHTNESS - 1) * 100)
      brightness_osd_widget.container.osd_layout.icon_slider_layout.slider_layout.brightness_slider:set_value(stdout)
    end
    )
  end

  awesome.connect_signal(
    "module::brightness_slider:update",
    function()
    update_slider()
  end
  )

  awesome.connect_signal(
    "widget::brightness:update",
    function(value)
    brightness_osd_widget.container.osd_layout.icon_slider_layout.slider_layout.brightness_slider:set_value(tonumber(value))
  end
  )

  update_slider()

  local brightness_container = awful.popup {
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

  local hide_brightness_osd = gears.timer {
    timeout = 2,
    autostart = true,
    callback = function()
      brightness_container.visible = false
    end
  }

  brightness_container:setup {
    brightness_osd_widget,
    layout = wibox.layout.fixed.horizontal
  }

  awesome.connect_signal(
    "widget::brightness_osd:rerun",
    function()
    if hide_brightness_osd.started then
      hide_brightness_osd:again()
    else
      hide_brightness_osd:start()
    end
  end
  )

  awesome.connect_signal(
    "module::brightness_osd:show",
    function()
    if s == mouse.screen then
      brightness_container.visible = true
    end
  end
  )

  brightness_container:connect_signal(
    "mouse::enter",
    function()
    brightness_container.visible = true
    hide_brightness_osd:stop()
  end
  )

  brightness_container:connect_signal(
    "mouse::leave",
    function()
    brightness_container.visible = true
    hide_brightness_osd:again()
  end
  )
end
