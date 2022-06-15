-----------------------------------
-- This is the volume controller --
-----------------------------------

-- Awesome Libs
local awful = require("awful")
local color = require("src.theme.colors")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local naughty = require("naughty")
local wibox = require("wibox")
require("src.core.signals")

-- Icon directory path
local icondir = awful.util.getdir("config") .. "src/assets/icons/audio/"

-- Returns the volume controller
return function(s)

  -- Function to create source/sink devices
  local function create_device(name, node, sink)
    local device = wibox.widget {
      {
        {
          {
            {
              image = "",
              id = "icon",
              resize = false,
              widget = wibox.widget.imagebox
            },
            {
              text = name,
              id = "node",
              widget = wibox.widget.textbox
            },
            id = "device_layout",
            layout = wibox.layout.align.horizontal
          },
          id = "device_margin",
          margins = dpi(5),
          widget = wibox.container.margin
        },
        id = "background",
        shape = function(cr, width, height)
          gears.shape.rounded_rect(cr, width, height, 4)
        end,
        widget = wibox.container.background
      },
      margins = dpi(5),
      widget = wibox.container.margin
    }

    if sink == true then
      device:connect_signal(
        "button::press",
        function()
          awful.spawn.spawn("./.config/awesome/src/scripts/vol.sh set_sink " .. node)

          awesome.emit_signal("update::background:vol", node)
        end
      )

      --#region Signal Functions
      local old_wibox, old_cursor, old_bg, old_fg
      local bg = ""
      local fg = ""
      local mouse_enter = function()
        if bg then
          old_bg = device.background.bg
          device.background.bg = bg .. 'dd'
        end
        if fg then
          old_fg = device.background.fg
          device.background.fg = fg
        end
        local w = mouse.current_wibox
        if w then
          old_cursor, old_wibox = w.cursor, w
          w.cursor = "hand1"
        end
      end

      local button_press = function()
        if bg then
          if bg then
            if string.len(bg) == 7 then
              device.background.bg = bg .. 'bb'
            else
              device.background.bg = bg
            end
          end
        end
        if fg then
          device.background.fg = fg
        end
      end

      local button_release = function()
        if bg then
          if bg then
            if string.len(bg) == 7 then
              device.background.bg = bg .. 'dd'
            else
              device.background.bg = bg
            end
          end
        end
        if fg then
          device.background.fg = fg
        end
      end

      local mouse_leave = function()
        if bg then
          device.background.bg = old_bg
        end
        if fg then
          device.background.fg = old_fg
        end
        if old_wibox then
          old_wibox.cursor = old_cursor
          old_wibox = nil
        end
      end

      device:connect_signal(
        "mouse::enter",
        mouse_enter
      )

      device:connect_signal(
        "button::press",
        button_press
      )

      device:connect_signal(
        "button::release",
        button_release
      )

      device:connect_signal(
        "mouse::leave",
        mouse_leave
      )
      --#endregion

      awesome.connect_signal(
        "update::background:vol",
        function(new_node)
          if node == new_node then
            old_bg = color["Purple200"]
            old_fg = color["Grey900"]
            bg = color["Purple200"]
            fg = color["Grey900"]
            device.background:set_bg(color["Purple200"])
            device.background:set_fg(color["Grey900"])
          else
            fg = color["Purple200"]
            bg = color["Grey700"]
            device.background:set_fg(color["Purple200"])
            device.background:set_bg(color["Grey700"])
          end
        end
      )
      awful.spawn.easy_async_with_shell(
        [[ pactl get-default-sink ]],
        function(stdout)
          if stdout:gsub("\n", "") ~= "" then
            local node_active = stdout:gsub("\n", "")
            if node == node_active then
              bg = color["Purple200"]
              fg = color["Grey900"]
              device.background:set_bg(color["Purple200"])
              device.background:set_fg(color["Grey900"])
            else
              fg = color["Purple200"]
              bg = color["Grey700"]
              device.background:set_fg(color["Purple200"])
              device.background:set_bg(color["Grey700"])
            end
          else
            awful.spawn.easy_async_with_shell(
              [[LC_ALL=C pactl info | perl -n -e'/Default Sink: (.+)\s/ && print $1']],
              function(stdout2)
                if stdout2:gsub("\n", "") ~= "" then
                  local node_active = stdout2:gsub("\n", "")
                  if node == node_active then
                    bg = color["Purple200"]
                    fg = color["Grey900"]
                    device.background:set_bg(color["Purple200"])
                    device.background:set_fg(color["Grey900"])
                  else
                    fg = color["Purple200"]
                    bg = color["Grey700"]
                    device.background:set_fg(color["Purple200"])
                    device.background:set_bg(color["Grey700"])
                  end
                end
              end
            )
          end
        end
      )
    else

      device:connect_signal(
        "button::press",
        function()
          awful.spawn.spawn("./.config/awesome/src/scripts/mic.sh set_source " .. node)

          awesome.emit_signal("update::background:mic", node)
        end
      )

      --#region Signal Functions
      local old_wibox, old_cursor, old_bg, old_fg
      local bg = ""
      local fg = ""
      local mouse_enter = function()
        if bg then
          old_bg = device.background.bg
          device.background.bg = bg .. 'dd'
        end
        if fg then
          old_fg = device.background.fg
          device.background.fg = fg
        end
        local w = mouse.current_wibox
        if w then
          old_cursor, old_wibox = w.cursor, w
          w.cursor = "hand1"
        end
      end

      local button_press = function()
        if bg then
          if bg then
            if string.len(bg) == 7 then
              device.background.bg = bg .. 'bb'
            else
              device.background.bg = bg
            end
          end
        end
        if fg then
          device.background.fg = fg
        end
      end

      local button_release = function()
        if bg then
          if bg then
            if string.len(bg) == 7 then
              device.background.bg = bg .. 'dd'
            else
              device.background.bg = bg
            end
          end
        end
        if fg then
          device.background.fg = fg
        end
      end

      local mouse_leave = function()
        if bg then
          device.background.bg = old_bg
        end
        if fg then
          device.background.fg = old_fg
        end
        if old_wibox then
          old_wibox.cursor = old_cursor
          old_wibox = nil
        end
      end

      device:connect_signal(
        "mouse::enter",
        mouse_enter
      )

      device:connect_signal(
        "button::press",
        button_press
      )

      device:connect_signal(
        "button::release",
        button_release
      )

      device:connect_signal(
        "mouse::leave",
        mouse_leave
      )
      --#endregion

      awesome.connect_signal(
        "update::background:mic",
        function(new_node)
          if node == new_node then
            old_bg = color["Blue200"]
            old_fg = color["Grey900"]
            bg = color["Blue200"]
            fg = color["Grey900"]
            device.background:set_bg(color["Blue200"])
            device.background:set_fg(color["Grey900"])
          else
            fg = color["Blue200"]
            bg = color["Grey700"]
            device.background:set_fg(color["Blue200"])
            device.background:set_bg(color["Grey700"])
          end
        end
      )
      awful.spawn.easy_async_with_shell(
        [[ pactl get-default-source ]],
        function(stdout)
          local node_active = stdout:gsub("\n", "")
          if node == node_active then
            bg = color["Blue200"]
            fg = color["Grey900"]
            device.background:set_bg(color["Blue200"])
            device.background:set_fg(color["Grey900"])
          else
            fg = color["Blue200"]
            bg = color["Grey700"]
            device.background:set_fg(color["Blue200"])
            device.background:set_bg(color["Grey700"])
          end
        end
      )
      awful.spawn.easy_async_with_shell(
        [[ pactl get-default-source ]],
        function(stdout)
          if stdout:gsub("\n", "") ~= "" then
            local node_active = stdout:gsub("\n", "")
            if node == node_active then
              bg = color["Blue200"]
              fg = color["Grey900"]
              device.background:set_bg(color["Blue200"])
              device.background:set_fg(color["Grey900"])
            else
              fg = color["Blue200"]
              bg = color["Grey700"]
              device.background:set_fg(color["Blue200"])
              device.background:set_bg(color["Grey700"])
            end
          else
            awful.spawn.easy_async_with_shell(
              [[LC_ALL=C pactl info | perl -n -e'/Default Source: (.+)\s/ && print $1']],
              function(stdout2)
                if stdout2:gsub("\n", "") ~= "" then
                  local node_active = stdout:gsub("\n", "")
                  if node == node_active then
                    bg = color["Blue200"]
                    fg = color["Grey900"]
                    device.background:set_bg(color["Blue200"])
                    device.background:set_fg(color["Grey900"])
                  else
                    fg = color["Blue200"]
                    bg = color["Grey700"]
                    device.background:set_fg(color["Blue200"])
                    device.background:set_bg(color["Grey700"])
                  end
                end
              end
            )
          end
        end
      )
    end
    return device
  end

  -- Container for the source devices
  local dropdown_list_volume = wibox.widget {
    {
      {
        layout = wibox.layout.fixed.vertical,
        id = "volume_device_list"
      },
      id = "volume_device_background",
      bg = color["Grey800"],
      shape = function(cr, width, height)
        gears.shape.partially_rounded_rect(cr, width, height, false, false, true, true, 4)
      end,
      widget = wibox.container.background
    },
    left = dpi(10),
    right = dpi(10),
    widget = wibox.container.margin
  }

  -- Container for the sink devices
  local dropdown_list_microphone = wibox.widget {
    {
      {
        layout = wibox.layout.fixed.vertical,
        id = "volume_device_list"
      },
      id = "volume_device_background",
      bg = color["Grey800"],
      shape = function(cr, width, height)
        gears.shape.partially_rounded_rect(cr, width, height, false, false, true, true, 4)
      end,
      widget = wibox.container.background
    },
    left = dpi(10),
    right = dpi(10),
    widget = wibox.container.margin
  }

  local volume_controller = wibox.widget {
    {
      {
        -- Audio Device selector
        {
          {
            {
              {
                {
                  resize = false,
                  image = gears.color.recolor_image(icondir .. "menu-down.svg", color["Purple200"]),
                  widget = wibox.widget.imagebox,
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
            bg = color["Grey800"],
            fg = color["Purple200"],
            shape = function(cr, width, height)
              gears.shape.rounded_rect(cr, width, height, 4)
            end,
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
          widget = dropdown_list_volume,
          visible = false
        },
        -- Microphone selector
        {
          {
            {
              {
                {
                  resize = false,
                  image = gears.color.recolor_image(icondir .. "menu-down.svg", color["LightBlueA200"]),
                  widget = wibox.widget.imagebox,
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
            bg = color["Grey800"],
            fg = color["LightBlueA200"],
            shape = function(cr, width, height)
              gears.shape.rounded_rect(cr, width, height, 4)
            end,
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
          widget = dropdown_list_microphone,
          visible = false
        },
        -- Audio volume slider
        {
          {
            {
              resize = false,
              widget = wibox.widget.imagebox,
              image = gears.color.recolor_image(icondir .. "volume-high.svg", color["Purple200"]),
              id = "icon",
            },
            {
              {
                bar_shape = function(cr, width, height)
                  gears.shape.rounded_rect(cr, width, height, 5)
                end,
                bar_height = dpi(5),
                bar_color = color["Grey800"],
                bar_active_color = color["Purple200"],
                handle_color = color["Purple200"],
                handle_shape = gears.shape.circle,
                handle_border_color = color["Purple200"],
                handle_width = dpi(15),
                maximum = 100,
                forced_height = dpi(26),
                widget = wibox.widget.slider,
                id = "slider"
              },
              bottom = dpi(12),
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
              image = gears.color.recolor_image(icondir .. "microphone.svg", color["Blue200"]),
              id = "icon"
            },
            {
              {
                bar_shape = function(cr, width, height)
                  gears.shape.rounded_rect(cr, width, height, 5)
                end,
                bar_height = dpi(5),
                bar_color = color["Grey800"],
                bar_active_color = color["Blue200"],
                handle_color = color["Blue200"],
                handle_shape = gears.shape.circle,
                handle_border_color = color["Blue200"],
                handle_width = dpi(15),
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
          widget = wibox.container.margin
        },
        id = "controller_layout",
        layout = wibox.layout.fixed.vertical
      },
      id = "controller_margin",
      margins = dpi(10),
      widget = wibox.container.margin
    },
    bg = color["Grey900"],
    border_color = color["Grey800"],
    border_width = dpi(4),
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, 12)
    end,
    forced_width = dpi(400),
    widget = wibox.container.background
  }

  -- Variables for easier access and better readability
  local audio_selector_margin = volume_controller:get_children_by_id("audio_selector_margin")[1]
  local volume_list = volume_controller:get_children_by_id("volume_list")[1]
  local audio_bg = volume_controller:get_children_by_id("audio_bg")[1]
  local audio_volume = volume_controller:get_children_by_id("audio_volume")[1].center

  -- Click event for the audio dropdown
  audio_selector_margin:connect_signal(
    "button::press",
    function()
      volume_list.visible = not volume_list.visible
      if volume_list.visible then
        audio_bg.shape = function(cr, width, height)
          gears.shape.partially_rounded_rect(cr, width, height, true, true, false, false, 4)
        end
        audio_volume.icon:set_image(gears.color.recolor_image(icondir .. "menu-up.svg", color["Teal200"]))
      else
        audio_bg.shape = function(cr, width, height)
          gears.shape.rounded_rect(cr, width, height, 4)
        end
        audio_volume.icon:set_image(gears.color.recolor_image(icondir .. "menu-down.svg", color["Teal200"]))
      end
    end
  )

  -- Variables for easier access and better readability
  local mic_selector_margin = volume_controller:get_children_by_id("mic_selector_margin")[1]
  local mic_list = volume_controller:get_children_by_id("mic_list")[1]
  local mic_bg = volume_controller:get_children_by_id("mic_bg")[1]
  local mic_volume = volume_controller:get_children_by_id("mic_volume")[1].center

  -- Click event for the microphone dropdown
  mic_selector_margin:connect_signal(
    "button::press",
    function()
      mic_list.visible = not mic_list.visible
      if mic_list.visible then
        mic_selector_margin.mic_bg.shape = function(cr, width, height)
          gears.shape.partially_rounded_rect(cr, width, height, true, true, false, false, 4)
        end
        mic_volume.icon:set_image(gears.color.recolor_image(icondir .. "menu-up.svg", color["Teal200"]))
      else
        mic_bg.shape = function(cr, width, height)
          gears.shape.rounded_rect(cr, width, height, 4)
        end
        mic_volume.icon:set_image(gears.color.recolor_image(icondir .. "menu-down.svg", color["Teal200"]))
      end
    end
  )

  local audio_slider_margin = volume_controller:get_children_by_id("audio_volume_margin")[1].audio_volume.slider_margin.
      slider

  -- Volume slider change event
  audio_slider_margin:connect_signal(
    "property::value",
    function()
      local volume = audio_slider_margin.value
      awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ " .. tonumber(volume) .. "%")
    end
  )

  local mic_slider_margin = volume_controller:get_children_by_id("mic_volume_margin")[1].mic_volume.slider_margin.slider

  -- Microphone slider change event
  mic_slider_margin:connect_signal(
    "property::value",
    function()
      local volume = mic_slider_margin.value
      awful.spawn("pactl set-source-volume @DEFAULT_SOURCE@ " .. tonumber(volume) .. "%")
      awesome.emit_signal("get::mic_volume", volume)
    end
  )

  -- Main container
  local volume_controller_container = awful.popup {
    widget = wibox.container.background,
    ontop = true,
    bg = color["Grey900"],
    stretch = false,
    visible = false,
    screen = s,
    placement = function(c) awful.placement.align(c,
        { position = "top_right", margins = { right = dpi(305), top = dpi(60) } })
    end,
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, 12)
    end
  }

  -- Get all source devices
  local function get_source_devices()
    awful.spawn.easy_async_with_shell(
      [[ pactl list sinks | grep -E 'node.name|alsa.card_name' | awk '{gsub(/"/, ""); for(i = 3;i < NF;i++) printf $i " "; print $NF}' ]]
      ,

      function(stdout)
        local i, j = 1, 1
        local device_list = { layout = wibox.layout.fixed.vertical }

        local node_names, alsa_names = {}, {}
        for node_name in stdout:gmatch("[^\n]+") do
          if (i % 2) == 0 then
            table.insert(node_names, node_name)
          end
          i = i + 1
        end

        for alsa_name in stdout:gmatch("[^\n]+") do
          if (j % 2) == 1 then
            table.insert(alsa_names, alsa_name)
          end
          j = j + 1
        end

        for k = 1, #alsa_names, 1 do
          device_list[#device_list + 1] = create_device(alsa_names[k], node_names[k], true)
        end
        dropdown_list_volume.volume_device_background.volume_device_list.children = device_list
      end
    )
  end

  get_source_devices()

  -- Get all input devices
  local function get_input_devices()
    awful.spawn.easy_async_with_shell(
      [[ pactl list sources | grep -E "node.name|alsa.card_name" | awk '{gsub(/"/, ""); for(i = 3;i < NF;i++) printf $i " "; print $NF}' ]]
      ,

      function(stdout)
        local i, j = 1, 1
        local device_list = { layout = wibox.layout.fixed.vertical }

        local node_names, alsa_names = {}, {}
        for node_name in stdout:gmatch("[^\n]+") do
          if (i % 2) == 0 then
            table.insert(node_names, node_name)
          end
          i = i + 1
        end

        for alsa_name in stdout:gmatch("[^\n]+") do
          if (j % 2) == 1 then
            table.insert(alsa_names, alsa_name)
          end
          j = j + 1
        end

        for k = 1, #alsa_names, 1 do
          device_list[#device_list + 1] = create_device(alsa_names[k], node_names[k], false)
        end
        dropdown_list_microphone.volume_device_background.volume_device_list.children = device_list
      end
    )
  end

  get_input_devices()

  -- Event watcher, detects when device is addes/removed
  awful.spawn.with_line_callback(
    [[bash -c "LC_ALL=C pactl subscribe | grep --line-buffered 'on server'"]],
    {
      stdout = function(line)
        get_input_devices()
        get_source_devices()
      end
    }
  )

  -- Get microphone volume
  local function get_mic_volume()
    awful.spawn.easy_async_with_shell(
      "./.config/awesome/src/scripts/mic.sh volume",
      function(stdout)
        local volume = stdout:gsub("%%", ""):gsub("\n", "")
        volume_controller:get_children_by_id("mic_volume_margin")[1].mic_volume.slider_margin.slider:set_value(tonumber(volume))
        if volume > 0 then
          volume_controller:get_children_by_id("mic_volume_margin")[1].icon:set_image(gears.color.recolor_image(icondir
            .. "microphone.svg", color["LightBlue200"]))
        else
          volume_controller:get_children_by_id("mic_volume_margin")[1].icon:set_image(gears.color.recolor_image(icondir
            .. "microphone-off.svg", color["LightBlue200"]))
        end
      end
    )
  end

  get_mic_volume()

  -- Check if microphone is muted
  local function get_mic_mute()
    awful.spawn.easy_async_with_shell(
      "./.config/awesome/src/scripts/mic.sh mute",
      function(stdout)
        if stdout:match("yes") then
          volume_controller:get_children_by_id("mic_volume_margin")[1].mic_volume.slider_margin.slider:set_value(tonumber(0))
          volume_controller:get_children_by_id("mic_volume_margin")[1].icon:set_image(gears.color.recolor_image(icondir
            .. "microphone-off.svg", color["LightBlue200"]))
        else
          get_mic_volume()
        end
      end
    )
  end

  get_mic_mute()

  -- When the mouse leaves the popup it stops the mousegrabber and hides the popup.
  volume_controller_container:connect_signal(
    "mouse::leave",
    function()
      mousegrabber.run(
        function()
          awesome.emit_signal("volume_controller::toggle", s)
          mousegrabber.stop()
          return true
        end,
        "arrow"
      )
    end
  )

  volume_controller_container:connect_signal(
    "mouse::enter",
    function()
      mousegrabber.stop()
    end
  )

  -- Grabs all keys and hides popup when anything is pressed
  -- TODO: Make it possible to navigate and select using the kb
  local volume_controller_keygrabber = awful.keygrabber {
    autostart = false,
    stop_event = 'release',
    keypressed_callback = function(self, mod, key, command)
      awesome.emit_signal("volume_controller::toggle", s)
      mousegrabber.stop()
    end
  }

  -- Draw the popup
  volume_controller_container:setup {
    volume_controller,
    layout = wibox.layout.fixed.horizontal
  }

  --[[ awesome.connect_signal(
    "volume_controller::toggle:keygrabber",
    function()
      if awful.keygrabber.is_running then
        volume_controller_keygrabber:stop()
      else
        volume_controller_keygrabber:start()
      end

    end
  ) ]]

  -- Set the volume and icon
  awesome.connect_signal(
    "get::volume",
    function(volume)
      volume = tonumber(volume)
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
      volume_controller.controller_margin.controller_layout.audio_volume_margin.audio_volume.icon:set_image(gears.color.
        recolor_image(icon .. ".svg", color["Purple200"]))
    end
  )

  -- Check if the volume is muted
  awesome.connect_signal(
    "get::volume_mute",
    function(mute)
      if mute then
        volume_controller.controller_margin.controller_layout.audio_volume_margin.audio_volume.icon:set_image(gears.
          color.recolor_image(icondir .. "volume-mute.svg", color["Purple200"]))
      end
    end
  )

  -- Set the microphone volume
  awesome.connect_signal(
    "get::mic_volume",
    function(volume)
      if volume > 0 then
        volume_controller:get_children_by_id("mic_volume_margin")[1].mic_volume.icon:set_image(gears.color.recolor_image(icondir
          .. "microphone.svg", color["LightBlue200"]))
      else
        volume_controller:get_children_by_id("mic_volume_margin")[1].mic_volume.icon:set_image(gears.color.recolor_image(icondir
          .. "microphone-off.svg", color["LightBlue200"]))
      end
    end
  )

  -- Toggle container visibility
  awesome.connect_signal(
    "volume_controller::toggle",
    function(scr)
      if scr == s then
        volume_controller_container.visible = not volume_controller_container.visible
      end

    end
  )

end
