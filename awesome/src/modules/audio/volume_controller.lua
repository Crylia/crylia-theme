-----------------------------------
-- This is the volume controller --
-----------------------------------

-- Awesome Libs
local awful = require("awful")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")
local gobject = require("gears.object")

local capi = {
  awesome = awesome,
  mousegrabber = mousegrabber,
}

local rubato = require("src.lib.rubato")

-- Icon directory path
local icondir = gears.filesystem.get_configuration_dir() .. "src/assets/icons/audio/"

local volume_controler = { mt = {} }

function volume_controler.get_device_widget()
  local device = wibox.widget {
    {
      {
        {
          id = "icon",
          resize = false,
          valign = "center",
          halign = "center",
          widget = wibox.widget.imagebox
        },
        spacing = dpi(10),
        {
          text = name,
          id = "node",
          widget = wibox.widget.textbox
        },
        id = "device_layout",
        layout = wibox.layout.fixed.horizontal
      },
      id = "device_margin",
      margins = dpi(9),
      widget = wibox.container.margin
    },
    id = "background",
    bg = Theme_config.volume_controller.device_bg,
    border_color = Theme_config.volume_controller.device_border_color,
    border_width = Theme_config.volume_controller.device_border_width,
    shape = Theme_config.volume_controller.device_shape,
    widget = wibox.container.background
  }
  if true then
    device:connect_signal(
      "button::press",
      function(_, _, _, key)
        if key == 1 then
          if node then
            --awful.spawn("./.config/awesome/src/scripts/vol.sh set_sink " .. node)
            --capi.awesome.emit_signal("update::bg_sink", node)
          end
        end
      end
    )
    --[[ capi.awesome.connect_signal(
      "update::bg_sink",
      function(new_node)
        if node == new_node then
          device:get_children_by_id("icon")[1].image = gears.color.recolor_image(icondir .. "headphones.svg",
            Theme_config.volume_controller.device_icon_color)
          device.bg = Theme_config.volume_controller.device_headphones_selected_bg
          device.fg = Theme_config.volume_controller.device_headphones_selected_fg
          Hover_signal(device)
        else
          device:get_children_by_id("icon")[1].image = gears.color.recolor_image(icondir .. "headphones.svg",
            Theme_config.volume_controller.device_headphones_selected_icon_color)
          device.bg = Theme_config.volume_controller.device_bg
          device.fg = Theme_config.volume_controller.device_headphones_fg
          Hover_signal(device)
        end
      end
    ) ]]
  else
    device:connect_signal(
      "button::press",
      function(_, _, _, key)
        if key == 1 then
          if node then
            --awful.spawn("./.config/awesome/src/scripts/mic.sh set_source " .. node)
            --capi.awesome.emit_signal("update::bg_source", node)
          end
        end
      end
    )
    --[[     capi.awesome.connect_signal(
      "update::bg_source",
      function(new_node)
        if node == new_node then
          device:get_children_by_id("icon")[1].image = gears.color.recolor_image(icondir .. "microphone.svg",
            Theme_config.volume_controller.device_icon_color)
          device.bg = Theme_config.volume_controller.device_microphone_selected_bg
          device.fg = Theme_config.volume_controller.device_microphone_selected_fg
          Hover_signal(device)
        else
          device:get_children_by_id("icon")[1].image = gears.color.recolor_image(icondir .. "microphone.svg",
            Theme_config.volume_controller.device_microphone_selected_icon_color)
          device.bg = Theme_config.volume_controller.device_bg
          device.fg = Theme_config.volume_controller.device_microphone_fg
          Hover_signal(device)
        end
      end
    ) ]]
  end
  return device
end

-- Get all source devices
function volume_controler:get_source_devices()

end

-- Get all input devices
function volume_controler:get_input_devices()

end

function volume_controler:toggle()
  volume_controler.popup.visible = not volume_controler.popup.visible
end

function volume_controler.run(args)

  args = args or {}

  local ret = gobject {}

  local w = wibox.widget {
    {
      {
        -- Audio Device selector
        {
          {
            {
              {
                {
                  resize = false,
                  image = gears.color.recolor_image(icondir .. "menu-down.svg",
                    Theme_config.volume_controller.device_headphones_selected_icon_color),
                  widget = wibox.widget.imagebox,
                  valign = "center",
                  halign = "center",
                  id = "icon"
                },
                id = "center",
                halign = "center",
                valign = "center",
                widget = wibox.container.place,
              },
              {
                {
                  text = "Output Device",
                  widget = wibox.widget.textbox,
                  id = "device_name"
                },
                margins = dpi(5),
                widget = wibox.container.margin
              },
              id = "audio_volume",
              layout = wibox.layout.fixed.horizontal
            },
            id = "audio_bg",
            bg = Theme_config.volume_controller.list_bg,
            fg = Theme_config.volume_controller.list_headphones_fg,
            shape = Theme_config.volume_controller.list_shape,
            widget = wibox.container.background
          },
          id = "audio_selector_margin",
          left = dpi(10),
          right = dpi(10),
          top = dpi(10),
          widget = wibox.container.margin
        },
        {
          id = "volume_list",
          widget = {
            {
              {
                {
                  {
                    spacing = dpi(10),
                    layout = require("src.lib.overflow_widget.overflow").vertical,
                    scrollbar_width = 0,
                    step = dpi(50),
                    id = "volume_device_list",
                  },
                  id = "margin",
                  margins = dpi(10),
                  widget = wibox.container.margin
                },
                id = "place",
                height = dpi(200),
                strategy = "max",
                widget = wibox.container.constraint
              },
              border_color = Theme_config.volume_controller.list_border_color,
              border_width = Theme_config.volume_controller.list_border_width,
              id = "volume_device_background",
              shape = Theme_config.volume_controller.list_shape,
              widget = wibox.container.background
            },
            left = dpi(10),
            right = dpi(10),
            widget = wibox.container.margin
          },
          forced_height = 0
        },
        -- Microphone selector
        {
          {
            {
              {
                {
                  resize = false,
                  image = gears.color.recolor_image(icondir .. "menu-down.svg",
                    Theme_config.volume_controller.device_microphone_selected_icon_color),
                  widget = wibox.widget.imagebox,
                  valign = "center",
                  halign = "center",
                  id = "icon",
                },
                id = "center",
                halign = "center",
                valign = "center",
                widget = wibox.container.place,
              },
              {
                {
                  text = "Input Device",
                  widget = wibox.widget.textbox,
                  id = "device_name"
                },
                margins = dpi(5),
                widget = wibox.container.margin
              },
              id = "mic_volume",
              layout = wibox.layout.fixed.horizontal
            },
            id = "mic_bg",
            bg = Theme_config.volume_controller.list_bg,
            fg = Theme_config.volume_controller.list_microphone_fg,
            shape = Theme_config.volume_controller.selector_shape,
            widget = wibox.container.background
          },
          id = "mic_selector_margin",
          left = dpi(10),
          right = dpi(10),
          top = dpi(10),
          widget = wibox.container.margin
        },
        {
          id = "mic_list",
          widget = {
            {
              {
                {
                  {
                    spacing = dpi(10),
                    layout = require("src.lib.overflow_widget.overflow").vertical,
                    id = "volume_device_list",
                    scrollbar_width = 0,
                    step = dpi(50),
                  },
                  id = "margin",
                  margins = dpi(10),
                  widget = wibox.container.margin
                },
                id = "place",
                height = dpi(200),
                strategy = "max",
                widget = wibox.container.constraint
              },
              id = "volume_device_background",
              border_color = Theme_config.volume_controller.list_border_color,
              border_width = Theme_config.volume_controller.list_border_width,
              shape = Theme_config.volume_controller.list_shape,
              widget = wibox.container.background
            },
            left = dpi(10),
            right = dpi(10),
            widget = wibox.container.margin
          },
          forced_height = 0
        },
        -- Audio volume slider
        {
          {
            {
              resize = false,
              widget = wibox.widget.imagebox,
              valign = "center",
              halign = "center",
              image = gears.color.recolor_image(icondir .. "volume-high.svg", Theme_config.volume_controller.volume_fg),
              id = "icon",
            },
            {
              {
                bar_shape = function(cr, width, height)
                  gears.shape.rounded_rect(cr, width, height, dpi(5))
                end,
                bar_height = dpi(5),
                bar_color = Theme_config.volume_controller.border_color,
                bar_active_color = Theme_config.volume_controller.volume_fg,
                handle_color = Theme_config.volume_controller.volume_fg,
                handle_shape = gears.shape.circle,
                handle_border_color = Theme_config.volume_controller.volume_fg,
                handle_width = dpi(12),
                maximum = 100,
                forced_height = dpi(26),
                widget = wibox.widget.slider,
                id = "slider"
              },
              left = dpi(5),
              id = "slider_margin",
              widget = wibox.container.margin
            },
            id = "audio_volume",
            layout = wibox.layout.align.horizontal
          },
          id = "audio_volume_margin",
          top = dpi(10),
          left = dpi(10),
          right = dpi(10),
          widget = wibox.container.margin
        },
        -- Microphone volume slider
        {
          {
            {
              resize = false,
              widget = wibox.widget.imagebox,
              valign = "center",
              halign = "center",
              image = gears.color.recolor_image(icondir .. "microphone.svg", Theme_config.volume_controller.microphone_fg),
              id = "icon"
            },
            {
              {
                bar_shape = function(cr, width, height)
                  gears.shape.rounded_rect(cr, width, height, dpi(5))
                end,
                bar_height = dpi(5),
                bar_color = Theme_config.volume_controller.device_border_color,
                bar_active_color = Theme_config.volume_controller.microphone_fg,
                handle_color = Theme_config.volume_controller.microphone_fg,
                handle_shape = gears.shape.circle,
                handle_border_color = Theme_config.volume_controller.microphone_fg,
                handle_width = dpi(12),
                maximum = 100,
                forced_height = dpi(26),
                widget = wibox.widget.slider,
                id = "slider"
              },
              left = dpi(5),
              id = "slider_margin",
              widget = wibox.container.margin
            },
            id = "mic_volume",
            layout = wibox.layout.align.horizontal
          },
          id = "mic_volume_margin",
          left = dpi(10),
          right = dpi(10),
          top = dpi(10),
          widget = wibox.container.margin
        },
        id = "controller_layout",
        layout = wibox.layout.fixed.vertical
      },
      id = "controller_margin",
      margins = dpi(10),
      widget = wibox.container.margin
    },
    bg = Theme_config.volume_controller.bg,
    border_color = Theme_config.volume_controller.border_color,
    border_width = Theme_config.volume_controller.border_width,
    shape = Theme_config.volume_controller.shape,
    forced_width = dpi(400),
    widget = wibox.container.background
  }

  ret.widget = w
  ret.audio_dropdown = w:get_children_by_id("audio_list")[1]
  ret.mic_dropdown = w:get_children_by_id("mic_list")[1]
  ret.audio_slider = w:get_children_by_id("slider")[1]
  ret.mic_slider = w:get_children_by_id("slider")[1]

  -- Main container
  ret.popup = awful.popup {
    widget = w,
    ontop = true,
    bg = Theme_config.volume_controller.bg,
    stretch = false,
    visible = false,
    screen = args.screen,
    --! Calculate the popup position instead of hardcoding it
    placement = function(c) awful.placement.align(c,
        { position = "top_right", margins = { right = dpi(305), top = dpi(60) } })
    end,
    shape = Theme_config.volume_controller.shape,
  }

  -- Set the volume and icon
  capi.awesome.connect_signal(
    "audio::get",
    function(muted, volume)
      if muted then
        volume_controller.controller_margin.controller_layout.audio_volume_margin.audio_volume.icon:set_image(gears.color
          .recolor_image(icondir .. "volume-mute.svg", Theme_config.volume_controller.volume_fg))
      else
        volume = tonumber(volume)
        if not volume then
          return
        end
        local icon = icondir .. "volume"
        if volume < 1 then
          icon = icon .. "-mute"
        elseif volume >= 1 and volume < 34 then
          icon = icon .. "-low"
        elseif volume >= 34 and volume < 67 then
          icon = icon .. "-medium"
        elseif volume >= 67 then
          icon = icon .. "-high"
        end

        volume_controller.controller_margin.controller_layout.audio_volume_margin.audio_volume.slider_margin.slider:
            set_value(volume)
        volume_controller.controller_margin.controller_layout.audio_volume_margin.audio_volume.icon:set_image(gears.color
          .recolor_image(icon
            .. ".svg", Theme_config.volume_controller.volume_fg))
      end
    end
  )

  -- Get microphone volume
  capi.awesome.connect_signal(
    "microphone::get",
    function(muted, volume)
      if muted then
        --volume_controller:get_children_by_id("mic_volume_margin")[1].mic_volume.slider_margin.slider:set_value(tonumber(0))
        volume_controller:get_children_by_id("mic_volume_margin")[1].mic_volume.icon:set_image(gears.color.recolor_image(icondir
          .. "microphone-off.svg", Theme_config.volume_controller.microphone_fg))
      else
        volume = tonumber(volume)
        if not volume then
          return
        end
        volume_controller:get_children_by_id("mic_volume_margin")[1].mic_volume.slider_margin.slider:set_value(tonumber(volume))
        if volume > 0 then
          volume_controller:get_children_by_id("mic_volume_margin")[1].mic_volume.icon:set_image(gears.color.recolor_image(icondir
            .. "microphone.svg", Theme_config.volume_controller.microphone_fg))
        else
          volume_controller:get_children_by_id("mic_volume_margin")[1].mic_volume.icon:set_image(gears.color.recolor_image(icondir
            .. "microphone-off.svg", Theme_config.volume_controller.microphone_fg))
        end
      end
    end
  )

  -- Microphone slider change event
  ret.widget:connect_signal(
    "property::value",
    function()
    end
  )

  -- Slide animation
  ret.audio_dropdown:connect_signal(
    "button::press",
    function(_, _, _, key)
      if key == 1 then
        local rubato_timer = rubato.timed {
          duration = 0.4,
          intro = 0.1,
          outro = 0.1,
          pos = mic_list.forced_height,
          easing = rubato.linear,
          subscribed = function(v)
            mic_list.forced_height = v
          end
        }
        if mic_list.forced_height == 0 then
          rubato_timer.target = dpi(200)
          mic_selector_margin.mic_bg.shape = function(cr, width, height)
            gears.shape.partially_rounded_rect(cr, width, height, true, true, false, false, dpi(4))
          end
          mic_volume.icon:set_image(gears.color.recolor_image(icondir .. "menu-up.svg",
            Theme_config.volume_controller.device_microphone_selected_icon_color))
        else
          rubato_timer.target = 0
          mic_bg.shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, dpi(4))
          end
          mic_volume.icon:set_image(gears.color.recolor_image(icondir .. "menu-down.svg",
            Theme_config.volume_controller.device_microphone_selected_icon_color))
        end
      end
    end
  )

  -- Slide animation
  ret.mic_dropdown:connect_signal(
    "button::press",
    function(_, _, _, key)
      if key == 1 then
        local rubato_timer = rubato.timed {
          duration = 0.4,
          intro = 0.1,
          outro = 0.1,
          pos = volume_list.forced_height,
          easing = rubato.linear,
          subscribed = function(v)
            volume_list.forced_height = v
          end
        }
        if volume_list.forced_height == 0 then
          rubato_timer.target = dpi(200)
          audio_bg.shape = function(cr, width, height)
            gears.shape.partially_rounded_rect(cr, width, height, true, true, false, false, dpi(4))
          end
          audio_volume.icon:set_image(gears.color.recolor_image(icondir .. "menu-up.svg",
            Theme_config.volume_controller.device_headphones_selected_icon_color))
        else
          rubato_timer.target = 0
          audio_bg.shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, dpi(4))
          end
          audio_volume.icon:set_image(gears.color.recolor_image(icondir .. "menu-down.svg",
            Theme_config.volume_controller.device_headphones_selected_icon_color))
        end
      end
    end
  )

  return ret
end

function volume_controler.mt:__call(...)
  return volume_controler.run(...)
end

return setmetatable(volume_controler, volume_controler.mt)
