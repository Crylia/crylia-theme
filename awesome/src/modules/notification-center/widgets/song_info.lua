---------------------------
-- This is the song-info --
---------------------------

-- Awesome Libs
local dpi = require('beautiful').xresources.apply_dpi
local wibox = require('wibox')
local gfilesystem = require('gears.filesystem')
local gtable = require('gears.table')
local gcolor = require('gears.color')
local gshape = require('gears.shape')
local base = require('wibox.widget.base')
local abutton = require('awful.button')

local mh = require('src.tools.helpers.playerctl')

-- Icon directory path
local icondir = gfilesystem.get_configuration_dir() .. 'src/assets/icons/notifications/'

local music_player = {}

return setmetatable({}, { __call = function()
  local w = base.make_widget_from_value {
    {
      {
        {
          {
            { -- Album art
              {
                image = icondir .. 'default_image.svg',
                resize = true,
                clip_shape = function(cr, width, height)
                  gshape.rounded_rect(cr, width, height, dpi(8))
                end,
                valign = 'center',
                halign = 'center',
                widget = wibox.widget.imagebox,
                id = 'album_art',
              },
              width = dpi(80),
              height = dpi(80),
              strategy = 'exact',
              widget = wibox.container.constraint,
            },
            {
              {
                {
                  {
                    { --Title
                      valign = 'center',
                      halign = 'center',
                      text = 'Unknown Title',
                      id = 'title',
                      widget = wibox.widget.textbox,
                    },
                    fg = Theme_config.notification_center.song_info.title_fg,
                    widget = wibox.container.background,
                  },
                  strategy = 'max',
                  width = dpi(400),
                  widget = wibox.container.constraint,
                },
                widget = wibox.container.place,
              },
              {
                {
                  {
                    { --Artist
                      halign = 'center',
                      valign = 'center',
                      id = 'artist',
                      text = 'Unknown Artist',
                      widget = wibox.widget.textbox,
                    },
                    fg = Theme_config.notification_center.song_info.artist_fg,
                    widget = wibox.container.background,
                  },
                  strategy = 'max',
                  width = dpi(400),
                  widget = wibox.container.constraint,
                },
                widget = wibox.container.place,
              },
              { --Buttons
                {
                  {
                    resize = false,
                    image = gcolor.recolor_image(icondir .. 'shuffle.svg',
                      Theme_config.notification_center.song_info.shuffle_disabled),
                    valign = 'center',
                    halign = 'center',
                    id = 'shuffle',
                    widget = wibox.widget.imagebox,
                  },
                  {
                    resize = false,
                    valign = 'center',
                    halign = 'center',
                    id = 'prev',
                    image = gcolor.recolor_image(icondir .. 'skip-prev.svg', Theme_config.notification_center.song_info.prev_enabled),
                    widget = wibox.widget.imagebox,
                  },
                  {
                    resize = false,
                    valign = 'center',
                    halign = 'center',
                    id = 'play_pause',
                    image = gcolor.recolor_image(icondir .. 'play-pause.svg',
                      Theme_config.notification_center.song_info.play_enabled),
                    widget = wibox.widget.imagebox,
                  },
                  {
                    resize = false,
                    valign = 'center',
                    halign = 'center',
                    id = 'next',
                    image = gcolor.recolor_image(icondir .. 'skip-next.svg', Theme_config.notification_center.song_info.next_enabled),
                    widget = wibox.widget.imagebox,
                  },
                  {
                    resize = false,
                    image = gcolor.recolor_image(icondir .. 'repeat.svg', Theme_config.notification_center.song_info.repeat_disabled),
                    widget = wibox.widget.imagebox,
                    valign = 'center',
                    halign = 'center',
                    id = 'repeat',
                  },
                  spacing = dpi(15),
                  layout = wibox.layout.fixed.horizontal,
                },
                widget = wibox.container.place,
              },
              layout = wibox.layout.flex.vertical,
            },
            fill_space = true,
            spacing = dpi(10),
            layout = wibox.layout.fixed.horizontal,
          },
          { --Song Duration
            {
              {
                {
                  widget = wibox.widget.textbox,
                  id = 'position',
                  text = '00:00',
                  valign = 'center',
                  halign = 'center',
                },
                fg = Theme_config.notification_center.song_info.duration_fg,
                widget = wibox.container.background,
              },
              right = dpi(10),
              widget = wibox.container.margin,
            },
            { -- Progressbar
              {
                color = Theme_config.notification_center.song_info.progress_color,
                background_color = Theme_config.notification_center.song_info.progress_background_color,
                max_value = 100,
                value = 0,
                id = 'progress',
                forced_height = dpi(5),
                shape = function(cr, width)
                  gshape.rounded_bar(cr, width, dpi(5))
                end,
                widget = wibox.widget.progressbar,
              },
              widget = wibox.container.place,
            },
            {
              {
                {
                  widget = wibox.widget.textbox,
                  id = 'length',
                  text = '00:00',
                  valign = 'center',
                  halign = 'center',
                },
                fg = Theme_config.notification_center.song_info.duration_fg,
                widget = wibox.container.background,
              },
              left = dpi(10),
              widget = wibox.container.margin,
            },
            layout = wibox.layout.align.horizontal,
          },
          widget = wibox.layout.fixed.vertical,
        },
        widget = wibox.container.margin,
        margins = dpi(10),
      },
      border_color = Theme_config.notification_center.song_info.border_color,
      border_width = Theme_config.notification_center.song_info.border_width,
      shape = Theme_config.notification_center.song_info.shape,
      widget = wibox.container.background,
    },
    widget = wibox.container.margin,
    top = dpi(10),
    bottom = dpi(20),
    left = dpi(20),
    right = dpi(20),
  }
  assert(type(w) == 'table', 'Widget must be a table')

  gtable.crush(w, music_player, true)

  local music_handler = mh(w)

  --#region Buttons
  w:get_children_by_id('play_pause')[1]:buttons(gtable.join(
    abutton({}, 1, function()
      music_handler:play_pause()
    end)
  ))

  w:get_children_by_id('next')[1]:buttons(gtable.join(
    abutton({}, 1, function()
      music_handler:next()
    end)
  ))

  w:get_children_by_id('prev')[1]:buttons(gtable.join(
    abutton({}, 1, function()
      music_handler:prev()
    end)
  ))

  w:get_children_by_id('repeat')[1]:buttons(gtable.join(
    abutton({}, 1, function()
      music_handler:set_loop_status()
    end)
  ))

  w:get_children_by_id('shuffle')[1]:buttons(gtable.join(
    abutton({}, 1, function()
      music_handler:set_shuffle()
    end)
  ))
  --#endregion
  return w
end, })
