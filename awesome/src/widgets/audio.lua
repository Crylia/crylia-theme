------------------------------
-- This is the audio widget --
------------------------------
-- Awesome Libs

local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")

require("src.tools.helpers.audio")

local capi = {
  awesome = awesome,
}

-- Icon directory path
local icondir = gears.filesystem.get_configuration_dir() .. "src/assets/icons/audio/"

-- Returns the audio widget
return function(s)

  local audio_widget = wibox.widget {
    {
      {
        {
          {
            {
              id = "icon",
              widget = wibox.widget.imagebox,
              valign = "center",
              halign = "center",
              resize = false
            },
            id = "icon_layout",
            widget = wibox.container.place
          },
          top = dpi(2),
          widget = wibox.container.margin,
          id = "icon_margin"
        },
        spacing = dpi(10),
        {
          id = "label",
          align = "center",
          valign = "center",
          widget = wibox.widget.textbox
        },
        id = "audio_layout",
        layout = wibox.layout.fixed.horizontal
      },
      id = "container",
      left = dpi(8),
      right = dpi(8),
      widget = wibox.container.margin
    },
    bg = Theme_config.audio.bg,
    fg = Theme_config.audio.fg,
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(6))
    end,
    widget = wibox.container.background
  }

  capi.awesome.connect_signal("audio::get", function(muted, volume)
    if muted then
      audio_widget.container.audio_layout.label.visible = false
      audio_widget.container.audio_layout.icon_margin.icon_layout.icon:set_image(
        gears.color.recolor_image(icondir .. "volume-mute" .. ".svg", Theme_config.audio.fg))
    else
      audio_widget.container:set_right(10)
      local icon = icondir .. "volume"
      audio_widget.container.audio_layout.spacing = dpi(5)
      audio_widget.container.audio_layout.label.visible = true
      volume = tonumber(volume)
      if not volume then
        return
      end
      if volume < 1 then
        icon = icon .. "-mute"
        audio_widget.container.audio_layout.spacing = dpi(0)
        audio_widget.container.audio_layout.label.visible = false
      elseif volume >= 1 and volume < 34 then
        icon = icon .. "-low"
      elseif volume >= 34 and volume < 67 then
        icon = icon .. "-medium"
      elseif volume >= 67 then
        icon = icon .. "-high"
      end
      audio_widget.container.audio_layout.label:set_text(volume .. "%")
      audio_widget.container.audio_layout.icon_margin.icon_layout.icon:set_image(
        gears.color.recolor_image(icon .. ".svg", Theme_config.audio.fg))
    end
  end)

  -- Signals
  Hover_signal(audio_widget)

  return audio_widget
end
