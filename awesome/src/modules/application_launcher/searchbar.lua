-------------------------------------------------------
-- This is the seachbar for the application launcher --
-------------------------------------------------------

-- Awesome Libs
local awful = require("awful")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local gfs = gears.filesystem
local gtable = gears.table
local gdebug = gears.debug
local gstring = gears.string
local keygrabber = require("awful.keygrabber")
local wibox = require("wibox")

local icondir = awful.util.getdir("config") .. "src/assets/icons/application_launcher/searchbar/"

local kgrabber

return function()

  local searchbar = wibox.widget {
    {
      {
        { -- Search icon
          {
            {
              resize = false,
              valign = "center",
              halign = "center",
              image = gears.color.recolor_image(icondir .. "search.svg",
                Theme_config.application_launcher.searchbar.icon_color),
              widget = wibox.widget.imagebox
            },
            bg = Theme_config.application_launcher.searchbar.icon_background,
            widget = wibox.container.background
          },
          strategy = "exact",
          width = dpi(30),
          widget = wibox.container.constraint
        },
        {
          {
            fg = Theme_config.application_launcher.searchbar.fg_hint,
            markup = "Search",
            valign = "center",
            align = "center",
            widget = wibox.widget.textbox,
            id = "search_hint"
          },
          margins = dpi(5),
          widget = wibox.container.margin,
          id = "s_margin"
        },
        widget = wibox.layout.fixed.horizontal,
        id = "s_layout"
      },
      bg = Theme_config.application_launcher.searchbar.bg,
      fg = Theme_config.application_launcher.searchbar.fg,
      border_color = Theme_config.application_launcher.searchbar.border_color,
      border_width = Theme_config.application_launcher.searchbar.border_width,
      widget = wibox.container.background,
      shape = Theme_config.application_launcher.searchbar.shape,
      id = "s_background"
    },
    width = dpi(400),
    height = dpi(40),
    strategy = "exact",
    widget = wibox.container.constraint
  }

  local old_wibox, old_cursor
  local mouse_enter = function()
    local w = mouse.current_wibox
    if w then
      old_cursor, old_wibox = w.cursor, w
      w.cursor = "xterm"
    end
  end

  local mouse_leave = function()
    old_wibox.cursor = old_cursor
    old_wibox = nil
  end

  searchbar:disconnect_signal("mouse::enter", mouse_enter)
  searchbar:disconnect_signal("mouse::leave", mouse_leave)
  searchbar:connect_signal("mouse::enter", mouse_enter)
  searchbar:connect_signal("mouse::leave", mouse_leave)

  local function have_multibyte_char_at(text, position)
    return #text:sub(position, position) == -1
  end

  local search_text = searchbar:get_children_by_id("search_hint")[1]

  local function promt_text_with_cursor(text, cursor_pos)
    local char, spacer, text_start, text_end

    local cursor_color = Theme_config.application_launcher.searchbar.bg_cursor
    local text_color = Theme_config.application_launcher.searchbar.fg_cursor

    if text == "" then
      return "<span foreground='" .. Theme_config.application_launcher.searchbar.fg_hint .. "'>Search</span>"
    end

    if #text < cursor_pos then
      char = " "
      spacer = ""
      text_start = gstring.xml_escape(text)
      text_end = ""
    else
      local offset = 0
      if have_multibyte_char_at(text, cursor_pos) then
        offset = 1
      end
      char = gstring.xml_escape(text:sub(cursor_pos, cursor_pos + offset))
      spacer = " "
      text_start = gstring.xml_escape(text:sub(1, cursor_pos - 1))
      text_end = gstring.xml_escape(text:sub(cursor_pos + offset + 1))
    end

    return text_start ..
        "<span background='" ..
        cursor_color .. "' foreground='" .. text_color .. "'>" .. char .. "</span>" .. text_end .. spacer
  end

  local text_string = ""

  ---Start a new keygrabber to simulate an input textbox
  local function keygrabber_start()
    local cur_pos = #text_string + 1

    --Draws the string on each keypress
    local function update()
      search_text:set_markup(promt_text_with_cursor(text_string, cur_pos))
      --Send the string over to the application to filter applications
      awesome.emit_signal("update::application_list", text_string)
    end

    update()

    kgrabber = keygrabber.run(
      function(modifiers, key, event)
        awesome.connect_signal("searchbar::stop", function()
          keygrabber.stop(kgrabber)
          awesome.emit_signal("application_launcher::kgrabber_start")
        end)

        local mod = {}
        for _, v in ipairs(modifiers) do
          mod[v] = true
        end

        if event ~= "press" then
          return
        end

        --Escape cases
        if (mod.Control and (key == "c" or key == "g"))
            or (not mod.Control and key == "Escape") then
          keygrabber.stop(kgrabber)
          search_text:set_markup(promt_text_with_cursor("", 1))
          text_string = ""
          awesome.emit_signal("application_launcher::show")
        elseif (not mod.Control and key == "Return") or
            (not mod.Control and key == "KP_Enter") then
          keygrabber.stop(kgrabber)
          searchbar.s_background.border_color = Theme_config.application_launcher.searchbar.border_color
          searchbar.s_background.fg = Theme_config.application_launcher.searchbar.fg_hint
          search_text:set_markup(promt_text_with_cursor("", 1))
          text_string = ""
          awesome.emit_signal("application_launcher::execute")
          awesome.emit_signal("application_launcher::show")
        end

        if mod.Control then
        elseif mod.Mod1 or mod.Mod3 then
        else
          --Delete character to the left and move cursor
          if key == "BackSpace" then
            if cur_pos > 1 then
              local offset = 0
              if have_multibyte_char_at(text_string, cur_pos - 1) then
                offset = 1
              end
              text_string = text_string:sub(1, cur_pos - 2 - offset) .. text_string:sub(cur_pos)
              cur_pos = cur_pos - 1 - offset
            end
            update()
            --Delete character to the right
          elseif key == "Delete" then
            text_string = text_string:sub(1, cur_pos - 1) .. text_string:sub(cur_pos + 1)
            update()
            -- Move cursor to the left
          elseif key == "Left" then
            --cur_pos = cur_pos - 1
            awesome.emit_signal("application::left")
            -- Move cursor to the right
          elseif key == "Right" then
            --cur_pos = cur_pos + 1
            awesome.emit_signal("application::right")
          elseif key == "Up" then
            awesome.emit_signal("application::up")
          elseif key == "Down" then
            awesome.emit_signal("application::down")
          else
            --Add key at cursor position
            if key:wlen() == 1 then
              text_string = text_string:sub(1, cur_pos - 1) .. key .. text_string:sub(cur_pos)
              cur_pos = cur_pos + #key
            end
            update()
          end
          --Make sure cursor can't leave string bounds
          if cur_pos < 1 then
            cur_pos = 1
          elseif cur_pos > #text_string + 1 then
            cur_pos = #text_string + 1
          end
        end
      end
    )
  end

  --Start the keygrabber when the searchbar is left clicked
  searchbar:buttons(gears.table.join(
    awful.button({}, 1, function()
      if not awful.keygrabber.is_running then
        keygrabber_start()
        searchbar.s_background.border_color = Theme_config.application_launcher.searchbar.border_active
        searchbar.s_background.fg = Theme_config.application_launcher.searchbar.fg
        search_text:set_markup(promt_text_with_cursor("", 1))
      end
    end)
  ))

  awesome.connect_signal(
    "searchbar::start",
    function()
      if not awful.keygrabber.is_running then
        keygrabber_start()
        searchbar.s_background.border_color = Theme_config.application_launcher.searchbar.border_active
        searchbar.s_background.fg = Theme_config.application_launcher.searchbar.fg
        search_text:set_markup(promt_text_with_cursor("", 1))
      end

    end
  )

  return searchbar
end
