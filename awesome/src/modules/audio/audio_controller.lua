-- Awesome Libs
local abutton = require('awful.button')
local aspawn = require('awful.spawn')
local base = require('wibox.widget.base')
local beautiful = require('beautiful')
local dpi = require('beautiful').xresources.apply_dpi
local gcolor = require('gears.color')
local gshape = require('gears.shape')
local gtable = require('gears.table')
local gfilesystem = require('gears.filesystem')
local wibox = require('wibox')

-- Third party libs
local rubato = require('src.lib.rubato')

-- Local libs
local audio_helper = require('src.tools.helpers.audio')
local hover = require('src.tools.hover')

-- Icon directory path
local icondir = gfilesystem.get_configuration_dir() .. 'src/assets/icons/audio/'

local audio_controller = {}

--#region wibox.widget.base boilerplate

function audio_controller:layout(_, width, height)
  if self._private.widget then
    return { base.place_widget_at(self._private.widget, 0, 0, width, height) }
  end
end

function audio_controller:fit(context, width, height)
  local w, h = 0, 0 ---@type number|nil, number|nil
  if self._private.widget then
    w, h = base.fit_widget(self, context, self._private.widget, width, height)
  end
  return w, h
end

--#endregion

---Set the default source asynchronously
---@param sink any
function audio_controller:set_default_sink(sink)
  if not sink then return end
  aspawn('pactl set-default-sink ' .. sink)
  self:emit_signal('AC::device_changed')
end

---Set the default source asynchronously
function audio_controller:set_default_source(source)
  if not source then return end
  aspawn('pactl set-default-source ' .. source)
  self:emit_signal('AC::device_changed')
end

---Get the default sink asynchronously
---@param callback function returns the default sink as string
function audio_controller:get_default_sink_async(callback)
  aspawn.easy_async_with_shell('pactl get-default-sink', function(stdout) callback(stdout:gsub('\n', '')) end)
end

---Takes a sink and name and returns a new device widget, the device_type is for the color
---@param device string sink
---@param name string name of the device
---@param device_type string sink or source
---@return wibox.widget
function audio_controller:get_device_widget(device, name, device_type)
  --remove leading spaces from name
  name = name:gsub('^%s*(.-)%s*$', '%1')
  local icon_color, fg
  if device_type == 'source' then
    icon_color = beautiful.colorscheme.bg_blue
    fg = beautiful.colorscheme.bg_blue
  elseif device_type == 'sink' then
    icon_color = beautiful.colorscheme.bg_purple
    fg = beautiful.colorscheme.bg_purple
  end

  local device_widget = wibox.widget {
    {
      {
        {
          {
            id = 'icon',
            resize = true,
            image = gcolor.recolor_image(icondir .. 'volume-high.svg', icon_color),
            valign = 'center',
            halign = 'center',
            widget = wibox.widget.imagebox,
          },
          widget = wibox.container.constraint,
          width = dpi(24),
          height = dpi(24),
          strategy = 'exact',
        },
        {
          {
            id = 'name',
            text = name,
            halign = 'center',
            valign = 'center',
            widget = wibox.widget.textbox,
          },
          widget = wibox.container.constraint,
          height = dpi(24),
          strategy = 'exact',
        },
        spacing = dpi(10),
        layout = wibox.layout.fixed.horizontal,
      },
      margins = dpi(10),
      widget = wibox.container.margin,
    },
    bg = beautiful.colorscheme.bg,
    fg = fg,
    border_color = beautiful.colorscheme.border_color,
    border_width = dpi(2),
    shape = beautiful.shape[4],
    widget = wibox.container.background,
    sink = device,
  }

  if device_type == 'sink' then
    device_widget:buttons(gtable.join(
      abutton({}, 1, function()
        self:set_default_sink(device)
      end)
    ))
  elseif device_type == 'source' then
    device_widget:buttons(gtable.join(
      abutton({}, 1, function()
        self:set_default_source(device)
      end)
    ))
  end

  self:connect_signal('AC::device_changed', function(new_sink)
    if device_widget.device == new_sink then
      device_widget.bg = beautiful.colorscheme.bg_purple
      device_widget.fg = beautiful.colorscheme.bg
      device_widget:get_children_by_id('icon')[1].image = gcolor.recolor_image(icondir .. 'volume-high.svg', beautiful.colorscheme.bg)
    else
      device_widget.bg = beautiful.colorscheme.bg
      device_widget.fg = fg
      device_widget:get_children_by_id('icon')[1].image = gcolor.recolor_image(icondir .. 'volume-high.svg', icon_color)
    end
  end)

  hover.bg_hover { widget = device_widget }

  return device_widget
end

---Get all sink devices
---@param callback function returns a list of sinks
function audio_controller:get_sink_devices_async(callback)
  -- This command gets all audio sources and their descriptions in this format: "source_name;source_description\n"
  aspawn.easy_async_with_shell([=[
    LC_ALL=C pactl list sinks | awk '/Name:/ { name=$0 } /Description:/ { sub(/Name: /, "", name); sub(/Description: /, "", $0); print name ";" $0 }'
    ]=], function(stdout)
    local sinks = wibox.layout.fixed.vertical {}
    for line in stdout:gmatch('[^\r\n]+') do
      -- Call the callback function with the name and description
      local s, n = line:match('(.-);(.+)')
      table.insert(sinks, self:get_device_widget(s, n, 'sink'))
    end
    self.sinks = sinks
    callback()
  end)
end

---Get all source devices
---@param callback function returns a list of sources
function audio_controller:get_source_devices_async(callback)
  -- This command gets all audio sources and their descriptions in this format: "source_name;source_description\n"
  aspawn.easy_async_with_shell([=[
    LC_ALL=C pactl list sources | awk '/Name:/ { name=$0 } /Description:/ { sub(/Name: /, "", name); sub(/Description: /, "", $0); print name ";" $0 }'
    ]=], function(stdout)
    local sources = wibox.layout.fixed.vertical {}
    for line in stdout:gmatch('[^\r\n]+') do
      local s, n = line:match('(.-);(.+)')
      table.insert(sources, self:get_device_widget(s, n, 'source'))
    end
    self.sources = sources
    callback()
  end)
end

---Creates a new audio controller
---@return wibox.widget auio_controller the audio controller widget
function audio_controller.new()
  local w = base.make_widget_from_value(wibox.widget {
    {
      {
        { -- sink Device selector
          {
            {
              resize = false,
              image = gcolor.recolor_image(icondir .. 'menu-down.svg',
                beautiful.colorscheme.bg_purple),
              widget = wibox.widget.imagebox,
              valign = 'center',
              halign = 'center',
              id = 'sink_dd_icon',
            },
            {
              {
                text = 'Output Devices',
                valign = 'center',
                halign = 'center',
                widget = wibox.widget.textbox,
              },
              margins = dpi(5),
              widget = wibox.container.margin,
            },
            layout = wibox.layout.fixed.horizontal,
          },
          id = 'sink_dd_shape',
          bg = beautiful.colorscheme.bg1,
          fg = beautiful.colorscheme.bg_purple,
          shape = function(cr, width, height)
            gshape.partially_rounded_rect(cr, width, height, false, false, true, true, dpi(4))
          end,
          widget = wibox.container.background,
        },
        { -- sink dropdown
          {
            {
              {
                spacing = dpi(10),
                layout = require('src.lib.overflow_widget.overflow').vertical,
                scrollbar_width = 0,
                step = dpi(50),
                id = 'sink_list',
              },
              margins = dpi(10),
              widget = wibox.container.margin,
            },
            border_color = beautiful.colorscheme.border_color,
            border_width = dpi(2),
            id = 'sink_list_shape',
            shape = function(cr, width, height)
              gshape.partially_rounded_rect(cr, width, height, false, false, true, true, dpi(4))
            end,
            widget = wibox.container.background,
          },
          id = 'sink_height',
          strategy = 'exact',
          height = 0,
          width = dpi(300),
          widget = wibox.container.constraint,
        },
        { -- Spacer
          widget = wibox.container.background,
          forced_height = dpi(10),
        },
        { -- source Device selector
          {
            {
              resize = false,
              image = gcolor.recolor_image(icondir .. 'menu-down.svg',
                beautiful.colorscheme.bg_purple),
              widget = wibox.widget.imagebox,
              valign = 'center',
              halign = 'center',
              id = 'source_dd_icon',
            },
            {
              {
                text = 'Input Devices',
                valign = 'center',
                halign = 'center',
                widget = wibox.widget.textbox,
              },
              margins = dpi(5),
              widget = wibox.container.margin,
            },
            layout = wibox.layout.fixed.horizontal,
          },
          id = 'source_dd_shape',
          bg = beautiful.colorscheme.bg1,
          fg = beautiful.colorscheme.bg_purple,
          shape = function(cr, width, height)
            gshape.partially_rounded_rect(cr, width, height, false, false, true, true, dpi(4))
          end,
          widget = wibox.container.background,
        },
        { -- source dropdown
          {
            {
              {
                spacing = dpi(10),
                layout = require('src.lib.overflow_widget.overflow').vertical,
                scrollbar_width = 0,
                step = dpi(50),
                id = 'source_list',
              },
              margins = dpi(10),
              widget = wibox.container.margin,
            },
            border_color = beautiful.colorscheme.border_color,
            border_width = dpi(2),
            id = 'source_list_shape',
            shape = function(cr, width, height)
              gshape.partially_rounded_rect(cr, width, height, false, false, true, true, dpi(4))
            end,
            widget = wibox.container.background,
          },
          id = 'source_height',
          strategy = 'exact',
          height = 0,
          width = dpi(300),
          widget = wibox.container.constraint,
        },
        { -- Spacer
          widget = wibox.container.background,
          forced_height = dpi(10),
        },
        { -- sink volume slider
          {
            {
              {
                resize = true,
                widget = wibox.widget.imagebox,
                valign = 'center',
                halign = 'center',
                image = gcolor.recolor_image(icondir .. 'volume-high.svg', beautiful.colorscheme.bg_purple),
                id = 'sink_icon',
              },
              widget = wibox.container.constraint,
              width = dpi(26),
              height = dpi(26),
              strategy = 'exact',
            },
            {
              bar_shape = beautiful.shape[4],
              bar_height = dpi(5),
              bar_color = beautiful.colorscheme.border_color,
              bar_active_color = beautiful.colorscheme.bg_purple,
              handle_color = beautiful.colorscheme.bg_purple,
              handle_shape = gshape.circle,
              handle_border_color = beautiful.colorscheme.bg_purple,
              handle_width = dpi(15),
              handle_cursor = 'left_ptr',
              maximum = 100,
              forced_height = 0, -- No idea why its needed but it makes the widget not go into infinity
              value = 50,
              widget = wibox.widget.slider,
              id = 'sink_slider',
            },
            spacing = dpi(10),
            layout = wibox.layout.fixed.horizontal,
          },
          widget = wibox.container.constraint,
          width = dpi(300),
          height = dpi(26),
          strategy = 'exact',
        },
        { -- Spacer
          widget = wibox.container.background,
          forced_height = dpi(10),
        },
        { -- source volume slider
          {
            {
              {
                resize = true,
                widget = wibox.widget.imagebox,
                valign = 'center',
                halign = 'center',
                image = gcolor.recolor_image(icondir .. 'microphone.svg', beautiful.colorscheme.bg_purple),
                id = 'source_icon',
              },
              widget = wibox.container.constraint,
              width = dpi(26),
              height = dpi(26),
              strategy = 'exact',
            },
            {
              bar_shape = beautiful.shape[4],
              bar_height = dpi(5),
              bar_color = beautiful.colorscheme.border_color,
              bar_active_color = beautiful.colorscheme.bg_purple,
              handle_color = beautiful.colorscheme.bg_purple,
              handle_shape = gshape.circle,
              handle_border_color = beautiful.colorscheme.bg_purple,
              handle_width = dpi(15),
              handle_cursor = 'left_ptr',
              maximum = 100,
              forced_height = 0, -- No idea why its needed but it makes the widget not go into infinity
              value = 50,
              widget = wibox.widget.slider,
              id = 'source_slider',
            },
            spacing = dpi(10),
            layout = wibox.layout.fixed.horizontal,

          },
          widget = wibox.container.constraint,
          width = dpi(400),
          height = dpi(26),
          strategy = 'exact',
        },
        layout = wibox.layout.fixed.vertical,
      },
      margins = dpi(15),
      widget = wibox.container.margin,
    },
    -- The parent margin doesn't render without an empty widget here???
    widget = wibox.container.margin,
  })

  assert(w, 'Failed to create volume controller widget')

  gtable.crush(w, audio_controller, true)

  local sink_icon = w:get_children_by_id('sink_icon')[1]
  local sink_slider = w:get_children_by_id('sink_slider')[1]

  sink_slider:connect_signal('property::value', function(_, value)
    audio_helper.set_sink_volume(value)
  end)

  -- Set the volume and icon
  audio_helper:connect_signal('sink::get', function(_, muted, volume)
    volume = tonumber(volume)
    assert(type(muted) == 'boolean' and type(volume) == 'number', 'audio::get signal expects boolean and number')
    if w.sink_volume == volume and w.sink_muted == muted then return end
    w.sink_volume = volume
    w.sink_muted = muted
    if muted then
      sink_icon:set_image(gcolor.recolor_image(icondir .. 'volume-mute.svg', beautiful.colorscheme.bg_purple))
    else
      local icon = icondir .. 'volume'
      if volume == 0 then
        icon = icon .. '-mute'
      elseif volume > 0 and volume < 34 then
        icon = icon .. '-low'
      elseif volume >= 34 and volume < 67 then
        icon = icon .. '-medium'
      elseif volume >= 67 then
        icon = icon .. '-high'
      end

      sink_slider:set_value(volume)
      sink_icon:set_image(gcolor.recolor_image(icon .. '.svg', beautiful.colorscheme.bg_purple))
    end
  end)

  local source_icon = w:get_children_by_id('source_icon')[1]
  local source_slider = w:get_children_by_id('source_slider')[1]

  -- Microphone slider change event
  source_slider:connect_signal('property::value', function(_, value)
    audio_helper.set_source_volume(value)
  end)

  --- Set the source volume and icon
  audio_helper:connect_signal('source::get', function(_, muted, volume)
    volume = tonumber(volume)
    assert(type(muted) == 'boolean' and type(volume) == 'number', 'microphone::get signal expects boolean and number')
    if w.source_volume == volume and w.source_muted == muted then return end
    w.source_volume = volume
    w.source_muted = muted
    if muted then
      source_icon:set_image(gcolor.recolor_image(icondir .. 'microphone-off.svg', beautiful.colorscheme.bg_blue))
    else
      if not volume then return end
      source_slider:set_value(tonumber(volume))
      if volume > 0 then
        source_icon:set_image(gcolor.recolor_image(icondir .. 'microphone.svg', beautiful.colorscheme.bg_blue))
      else
        source_icon:set_image(gcolor.recolor_image(icondir .. 'microphone-off.svg', beautiful.colorscheme.bg_blue))
      end
    end
  end)

  local sink_dd_shape = w:get_children_by_id('sink_dd_shape')[1]
  local sink_height = w:get_children_by_id('sink_height')[1]
  local sink_dd_icon = w:get_children_by_id('sink_dd_icon')[1]

  local rubato_timer = rubato.timed {
    duration = 0.2,
    pos = sink_height.height,
    clamp_position = true,
    subscribed = function(v)
      sink_height.height = v
    end,
  }

  sink_dd_shape:buttons(gtable.join {
    abutton({}, 1, function()
      if sink_height.height == 0 then
        local size = dpi((#w.sinks * 44) + ((#w.sinks - 1) * 10) + 20)

        if #w.sinks > 4 then
          size = dpi(226)
        end
        rubato_timer.target = size

        sink_dd_shape.shape = function(cr, width, height)
          gshape.partially_rounded_rect(cr, width, height, true, true, false, false, dpi(4))
        end

        sink_dd_icon:set_image(gcolor.recolor_image(icondir .. 'menu-up.svg',
          beautiful.colorscheme.bg_purple))
      else
        rubato_timer.target = 0

        sink_dd_shape.shape = beautiful.shape[4]

        sink_dd_icon:set_image(gcolor.recolor_image(icondir .. 'menu-down.svg',
          beautiful.colorscheme.bg_purple))
      end
    end),
  })

  local source_dd_shape = w:get_children_by_id('source_dd_shape')[1]
  local source_height = w:get_children_by_id('source_height')[1]
  local source_dd_icon = w:get_children_by_id('source_dd_icon')[1]

  local rubato_timer = rubato.timed {
    duration = 0.2,
    pos = source_height.height,
    clamp_position = true,
    subscribed = function(v)
      source_height.height = v
    end,
  }

  source_dd_shape:buttons(gtable.join {
    abutton({}, 1, function()
      if source_height.height == 0 then
        local size = dpi(((#w.sources * 44) + ((#w.sources - 1) * 10) + 20))

        if #w.sources > 4 then
          size = dpi(226)
        end

        rubato_timer.target = size

        source_dd_shape.shape = function(cr, width, height)
          gshape.partially_rounded_rect(cr, width, height, true, true, false, false, dpi(4))
        end

        source_dd_icon:set_image(gcolor.recolor_image(icondir .. 'menu-up.svg',
          beautiful.colorscheme.bg_purple))
      else
        rubato_timer.target = 0

        source_dd_shape.shape = beautiful.shape[4]

        source_dd_icon:set_image(gcolor.recolor_image(icondir .. 'menu-down.svg',
          beautiful.colorscheme.bg_purple))
      end
    end),
  })

  local sink_list = w:get_children_by_id('sink_list')[1]
  w:get_sink_devices_async(function()
    sink_list.children = w.sinks
  end)

  local source_list = w:get_children_by_id('source_list')[1]
  w:get_source_devices_async(function()
    source_list.children = w.sources
  end)

  hover.bg_hover { widget = sink_dd_shape }
  hover.bg_hover { widget = source_dd_shape }
  return w
end

return setmetatable(audio_controller, { __call = function() return audio_controller.new() end })
