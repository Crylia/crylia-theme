---------------------------
-- This is the song-info --
---------------------------

-- Awesome Libs
local awful = require("awful")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")

local capi = {
  awesome = awesome,
  mouse = mouse,
}

-- Icon directory path
local icondir = gears.filesystem.get_configuration_dir() .. "src/assets/icons/notifications/"

return function(s)

  --#region Music control button widgets

  local function button_hover_effect(widget, svg, color, color2)
    local mouse_enter = function()
      widget.image = gears.surface.load_uncached(gears.color.recolor_image(icondir .. svg, color2))
      local w = capi.mouse.current_wibox
      if w then
        w.cursor = "hand1"
      end
    end

    local mouse_leave = function()
      widget.image = gears.surface.load_uncached(gears.color.recolor_image(icondir .. svg, color))
      capi.mouse.cursor = "left_ptr"
      local w = capi.mouse.current_wibox
      if w then
        w.cursor = "left_ptr"
      end
    end

    widget:disconnect_signal("mouse::enter", mouse_enter)
    widget:connect_signal("mouse::enter", mouse_enter)
    widget:disconnect_signal("mouse::leave", mouse_leave)
    widget:connect_signal("mouse::leave", mouse_leave)
  end

  local shuffle_button = wibox.widget {
    resize = false,
    image = gears.color.recolor_image(icondir .. "shuffle.svg",
      Theme_config.notification_center.song_info.shuffle_disabled),
    valign = "center",
    halign = "center",
    widget = wibox.widget.imagebox,
  }

  local function suffle_handler()
    awful.spawn.easy_async_with_shell(
      "playerctl shuffle",
      function(stdout)
        if stdout:match("On") then
          awful.spawn.with_shell("playerctl shuffle off")
          shuffle_button.image = gears.color.recolor_image(icondir .. "shuffle.svg",
            Theme_config.notification_center.song_info.shuffle_disabled)
        else
          awful.spawn.with_shell("playerctl shuffle on")
          shuffle_button.image = gears.color.recolor_image(icondir .. "shuffle.svg",
            Theme_config.notification_center.song_info.shuffle_enabled)
        end
      end
    )
  end

  local function update_shuffle()
    awful.spawn.easy_async_with_shell(
      "playerctl shuffle",
      function(stdout)
        if stdout:match("On") then
          shuffle_button.image = gears.color.recolor_image(icondir .. "shuffle.svg",
            Theme_config.notification_center.song_info.shuffle_enabled)
        else
          shuffle_button.image = gears.color.recolor_image(icondir .. "shuffle.svg",
            Theme_config.notification_center.song_info.shuffle_disabled)
        end
      end
    )
  end

  update_shuffle()

  local repeat_button = wibox.widget {
    resize = false,
    image = gears.color.recolor_image(icondir .. "repeat.svg", Theme_config.notification_center.song_info.repeat_disabled),
    widget = wibox.widget.imagebox,
    valign = "center",
    halign = "center",
    id = "imagebox"
  }

  -- On first time load set the correct loop
  local function update_loop()
    awful.spawn.easy_async_with_shell(
      "playerctl loop",
      function(stdout)
        local loop_mode = stdout:gsub("\n", "")
        if loop_mode == "Track" then
          repeat_button.image = gears.color.recolor_image(gears.surface.load_uncached(icondir .. "repeat-once.svg"),
            Theme_config.notification_center.song_info.repeat_single)
        elseif loop_mode == "None" then
          repeat_button.image = gears.color.recolor_image(gears.surface.load_uncached(icondir .. "repeat.svg"),
            Theme_config.notification_center.song_info.repeat_disabled)
        elseif loop_mode == "Playlist" then
          repeat_button.image = gears.color.recolor_image(gears.surface.load_uncached(icondir .. "repeat.svg"),
            Theme_config.notification_center.song_info.repeat_all)
        end
      end
    )
  end

  update_loop()
  -- Activate shuffle when button is clicked
  shuffle_button:buttons(gears.table.join(
    awful.button({}, 1, suffle_handler)))

  local prev_button = wibox.widget {
    resize = false,
    valign = "center",
    halign = "center",
    image = gears.color.recolor_image(icondir .. "skip-prev.svg", Theme_config.notification_center.song_info.prev_enabled),
    widget = wibox.widget.imagebox
  }

  -- Activate previous song when button is clicked
  prev_button:buttons(gears.table.join(
    awful.button({}, 1, function()
      awful.spawn.easy_async_with_shell(
        "playerctl previous && sleep 1",
        function()
          update_loop()
        end
      )
    end)
  ))

  local pause_play_button = wibox.widget {
    resize = false,
    valign = "center",
    halign = "center",
    image = gears.color.recolor_image(icondir .. "play-pause.svg",
      Theme_config.notification_center.song_info.play_enabled),
    widget = wibox.widget.imagebox
  }

  -- Activate play/pause when button is clicked
  pause_play_button:buttons(gears.table.join(
    awful.button({}, 1, function()
      awful.spawn.with_shell("playerctl play-pause")
    end)
  ))

  local next_button = wibox.widget {
    resize = false,
    valign = "center",
    halign = "center",
    image = gears.color.recolor_image(icondir .. "skip-next.svg", Theme_config.notification_center.song_info.next_enabled),
    widget = wibox.widget.imagebox
  }

  -- Activate next song when button is clicked
  next_button:buttons(gears.table.join(
    awful.button({}, 1, function()
      awful.spawn.easy_async_with_shell(
        "playerctl next  && sleep 1",
        function()
          update_loop()
        end
      )
    end)
  ))

  --- This function updates the repeat button svg and changes the mode on click
  local function loop_handler()
    awful.spawn.easy_async_with_shell(
      "playerctl loop",
      function(stdout)
        local loop_mode = stdout:gsub("\n", "")
        if loop_mode == "None" then
          awful.spawn.with_shell("playerctl loop playlist")
          repeat_button.image = gears.color.recolor_image(gears.surface.load_uncached(icondir .. "repeat.svg"),
            Theme_config.notification_center.song_info.repeat_all)
        elseif loop_mode == "Playlist" then
          awful.spawn.with_shell("playerctl loop track")
          repeat_button.image = gears.color.recolor_image(gears.surface.load_uncached(icondir .. "repeat-once.svg"),
            Theme_config.notification_center.song_info.repeat_single)
        elseif loop_mode == "Track" then
          awful.spawn.with_shell("playerctl loop none")
          repeat_button.image = gears.color.recolor_image(gears.surface.load_uncached(icondir .. "repeat.svg"),
            Theme_config.notification_center.song_info.repeat_disabled)
        end
      end
    )
  end

  repeat_button:buttons(gears.table.join(awful.button({}, 1, loop_handler)))

  button_hover_effect(prev_button, "skip-prev.svg", Theme_config.notification_center.song_info.prev_enabled,
    Theme_config.notification_center.song_info.prev_hover)
  button_hover_effect(pause_play_button, "play-pause.svg", Theme_config.notification_center.song_info.play_enabled,
    Theme_config.notification_center.song_info.play_hover)
  button_hover_effect(next_button, "skip-next.svg", Theme_config.notification_center.song_info.next_enabled,
    Theme_config.notification_center.song_info.next_hover)

  --#endregion

  -- Main music widget
  local music_widget = wibox.widget {
    {
      {
        {
          {
            {
              { -- Album art
                {
                  image = icondir .. "default_image.svg",
                  resize = true,
                  clip_shape = function(cr, width, height)
                    gears.shape.rounded_rect(cr, width, height, dpi(8))
                  end,
                  valign = "center",
                  halign = "center",
                  widget = wibox.widget.imagebox,
                  id = "imagebox"
                },
                width = dpi(80),
                height = dpi(80),
                strategy = "exact",
                widget = wibox.container.constraint,
                id = "const"
              },
              {
                {
                  {
                    {
                      { --Title
                        valign = "center",
                        align = "center",
                        widget = wibox.widget.textbox,
                        id = "textbox4"
                      },
                      fg = Theme_config.notification_center.song_info.title_fg,
                      id = "textbox5",
                      widget = wibox.container.background
                    },
                    id = "textbox_const",
                    strategy = "max",
                    width = dpi(400),
                    widget = wibox.container.constraint
                  },
                  halign = "center",
                  valign = "center",
                  id = "textbox_container4",
                  widget = wibox.container.place
                },
                {
                  {
                    {
                      { --Artist
                        halign = "center",
                        align = "center",
                        widget = wibox.widget.textbox,
                        id = "textbox3"
                      },
                      fg = Theme_config.notification_center.song_info.artist_fg,
                      id = "background",
                      widget = wibox.container.background
                    },
                    strategy = "max",
                    width = dpi(400),
                    widget = wibox.container.constraint
                  },
                  halign = "center",
                  valign = "center",
                  id = "artist_container",
                  widget = wibox.container.place
                },
                { --Buttons
                  {
                    {
                      shuffle_button,
                      prev_button,
                      pause_play_button,
                      next_button,
                      repeat_button,
                      spacing = dpi(15),
                      layout = wibox.layout.fixed.horizontal,
                      id = "layout5"
                    },
                    halign = "center",
                    widget = wibox.container.place,
                    id = "place2"
                  },
                  widget = wibox.container.margin,
                  id = "margin6"
                },
                layout = wibox.layout.flex.vertical,
                id = "layout4"
              },
              fill_space = true,
              spacing = dpi(10),
              layout = wibox.layout.fixed.horizontal,
              id = "layout3"
            },
            widget = wibox.container.margin,
            id = "margin5"
          },
          { --Song Duration
            {
              {
                {
                  markup = "0:00",
                  widget = wibox.widget.textbox,
                  id = "textbox2"
                },
                fg = Theme_config.notification_center.song_info.duration_fg,
                widget = wibox.container.background,
                id = "background3"
              },
              right = dpi(10),
              widget = wibox.container.margin,
              id = "margin4"
            },
            { -- Progressbar
              {
                color = Theme_config.notification_center.song_info.progress_color,
                background_color = Theme_config.notification_center.song_info.progress_background_color,
                max_value = 100,
                value = 50,
                forced_height = dpi(5),
                shape = function(cr, width)
                  gears.shape.rounded_bar(cr, width, dpi(5))
                end,
                widget = wibox.widget.progressbar,
                id = "progressbar1"
              },
              valign = "center",
              halign = "center",
              widget = wibox.container.place,
              id = "place1"
            },
            {
              {
                {
                  text = "00:00",
                  widget = wibox.widget.textbox,
                  id = "text1"
                },
                id = "background2",
                fg = Theme_config.notification_center.song_info.duration_fg,
                widget = wibox.container.background
              },
              id = "margin3",
              left = dpi(10),
              widget = wibox.container.margin
            },
            id = "layout2",
            layout = wibox.layout.align.horizontal
          },
          id = "layout1",
          spacing = dpi(10),
          layout = wibox.layout.fixed.vertical
        },
        id = "margin2",
        widget = wibox.container.margin,
        margins = dpi(10)
      },
      id = "background1",
      border_color = Theme_config.notification_center.song_info.border_color,
      border_width = Theme_config.notification_center.song_info.border_width,
      shape = Theme_config.notification_center.song_info.shape,
      widget = wibox.container.background
    },
    id = "margin1",
    widget = wibox.container.margin,
    top = dpi(10),
    bottom = dpi(20),
    left = dpi(20),
    right = dpi(20)
  }

  -- Used to check if the music changed and if everthing should be updated
  local trackid = ""
  local artist = ""
  local title = ""

  -- Function to get spotify title, artist, album, album_art, length and track_id
  local function get_spotify_metadata(skip_check)
    skip_check = skip_check or false
    awful.spawn.easy_async_with_shell(
      "playerctl metadata",
      function(stdout)
        -- Only fetch info if the track changed or if the title/artist is empty
        if skip_check or (not stdout:match(trackid)) or (not stdout:match(artist)) or (not stdout:match(title)) then
          -- Get the song title
          awful.spawn.easy_async_with_shell(
            "playerctl metadata xesam:title",
            function(stdout2)
              local tit = stdout2:gsub("\n", "")
              title = tit
              music_widget:get_children_by_id("textbox4")[1].text = tit
            end
          )

          -- Get the song artist
          awful.spawn.easy_async_with_shell(
            "playerctl metadata xesam:artist",
            function(stdout2)
              local art = stdout2:gsub("\n", "")
              artist = art
              music_widget:get_children_by_id("textbox3")[1].text = art
            end
          )

          -- Get the song album image
          awful.spawn.easy_async_with_shell(
            "playerctl metadata mpris:artUrl",
            function(album_art)
              local url = album_art:gsub("\n", "")
              awful.spawn.easy_async_with_shell(
              -- TODO: curl does not stdout and is returns before it finished. This causes the image to sometimes not show correctly.
              -- !Find a better solution than sleep 0.1
              -- Maybe cache the image? Not sure if that would be a waste of space or not.
                "curl -s " .. url .. " -o /tmp/album_art.jpg && echo /tmp/album_art.jpg && sleep 0.5",
                function()
                  music_widget:get_children_by_id("imagebox")[1].image = gears.surface.load_uncached("/tmp/album_art.jpg")
                      or icondir .. "default_image.svg"
                end
              )
            end
          )

          -- Get the length of the song
          awful.spawn.easy_async_with_shell(
            "playerctl metadata mpris:length",
            function(stdout2)
              local length = stdout2:gsub("\n", "")
              if length ~= "" then
                local length_formated = string.format("%02d:%02d", math.floor((tonumber(length) or 1) / 60000000) or 0,
                  (math.floor((tonumber(length) or 1) / 1000000) % 60) or 0)
                music_widget:get_children_by_id("progressbar1")[1].max_value = tonumber(math.floor(tonumber(length) /
                  1000000))
                music_widget:get_children_by_id("text1")[1].markup = string.format("<span foreground='%s' font='JetBrainsMono Nerd Font, Bold 14'>%s</span>"
                  , Theme_config.notification_center.song_info.duration_fg, length_formated)
              end
            end
          )
        end

        awful.spawn.easy_async_with_shell(
          "playerctl metadata mpris:trackid",
          function(stdout2)
            trackid = stdout2:gsub("\n", "")
          end
        )
        -- Update track id
        trackid, artist, title = stdout, music_widget:get_children_by_id("textbox3")[1].text,
            music_widget:get_children_by_id("textbox4")[1].text
      end
    )
    -- Always update the current song progression
    awful.spawn.easy_async_with_shell(
      "playerctl position",
      function(stdout)
        local time = stdout:gsub("\n", "")
        if time ~= "" then
          local time_formated = string.format("%02d:%02d", math.floor((tonumber(time) or 1) / 60),
            math.floor(tonumber(time) or 1) % 60)
          music_widget:get_children_by_id("textbox2")[1].markup = string.format("<span foreground='%s' font='JetBrainsMono Nerd Font, Bold 14'>%s</span>"
            , Theme_config.notification_center.song_info.duration_fg, time_formated)
          music_widget:get_children_by_id("progressbar1")[1].value = tonumber(time)
        end
      end
    )
  end

  -- Call every second, if performance is bad, set the timer to a higher value
  gears.timer {
    timeout = 1,
    autostart = true,
    call_now = true,
    callback = function()
      --!Rewrite entire playerctl module for better performance
      --get_spotify_metadata()
    end
  }

  -- get_spotify_metadata() on awesome reload
  capi.awesome.connect_signal("startup", function()
    get_spotify_metadata(true)
  end)

  return music_widget
end
