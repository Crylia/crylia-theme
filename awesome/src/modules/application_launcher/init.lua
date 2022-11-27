--------------------------------------
-- This is the application launcher --
--------------------------------------

-- Awesome Libs
local awful = require("awful")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")
local gshape = require("gears.shape")
local gtable = require("gears.table")
local gobject = require("gears.object")
local abutton = require("awful.button")

local capi = {
  awesome = awesome,
  mouse = mouse,
}

local application_launcher = { mt = {} }


application_launcher.application_grid = require("src.modules.application_launcher.application") {}


function application_launcher.new(args)
  args = args or {}

  local ret = gobject { enable_properties = true }

  gtable.crush(ret, application_launcher, true)

  local searchbar = awful.widget.inputbox {
    hint_text = "Search...",
    valign = "center",
    halign = "left",
  }

  searchbar:buttons(
    gtable.join {
      abutton({}, 1, function()
        searchbar:focus()
      end)
    }
  )

  local old_cursor, old_wibox
  searchbar:connect_signal("mouse::enter", function()
    local wid = capi.mouse.current_wibox
    if wid then
      old_cursor, old_wibox = wid.cursor, wid
      wid.cursor = "xterm"
    end
  end)
  searchbar:connect_signal("mouse::leave", function()
    old_wibox.cursor = old_cursor
    old_wibox = nil
  end)

  local applicaton_launcher = wibox.widget {
    {
      {
        {
          {
            {
              searchbar,
              widget = wibox.container.margin,
              margins = 5,
              id = "marg"
            },
            widget = wibox.container.constraint,
            strategy = "exact",
            width = 400,
            height = 50,
            id = "const"
          },
          widget = wibox.container.background,
          bg = Theme_config.application_launcher.searchbar.bg,
          fg = Theme_config.application_launcher.searchbar.fg,
          border_color = Theme_config.application_launcher.searchbar.border_color,
          border_width = Theme_config.application_launcher.searchbar.border_width,
          shape = gshape.rounded_rect,
          id = "searchbar_bg"
        },
        {
          ret.application_grid,
          spacing = dpi(10),
          layout = require("src.lib.overflow_widget.overflow").vertical,
          scrollbar_width = 0,
          step = dpi(100),
          id = "scroll_bar",
        },
        spacing = dpi(10),
        layout = wibox.layout.fixed.vertical
      },
      margins = dpi(20),
      widget = wibox.container.margin
    },
    height = args.screen.geometry.height / 100 * 60,
    --width = s.geometry.width / 100 * 60,
    strategy = "exact",
    widget = wibox.container.constraint
  }

  ret.application_container = awful.popup {
    widget = applicaton_launcher,
    ontop = true,
    visible = false,
    stretch = false,
    screen = args.screen,
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(12))
    end,
    placement = awful.placement.centered,
    bg = Theme_config.application_launcher.bg,
    border_color = Theme_config.application_launcher.border_color,
    border_width = Theme_config.application_launcher.border_width
  }

  local searchbar_bg = applicaton_launcher:get_children_by_id("searchbar_bg")[1]

  capi.awesome.connect_signal(
    "application_launcher::show",
    function()
      capi.awesome.emit_signal("update::selected")
      if capi.mouse.screen == args.screen then
        ret.application_container.visible = not ret.application_container.visible
      end
      if ret.application_container.visible then
        searchbar_bg.border_color = Theme_config.application_launcher.searchbar.border_active
        searchbar:focus()
      else
        searchbar:set_text("")
        awful.keygrabber.stop()
      end
    end
  )

  searchbar:connect_signal(
    "submit",
    function(_, text)
      ret.application_grid:execute()
      capi.awesome.emit_signal("application_launcher::show")
      searchbar:set_text("")
      ret.application_grid:set_applications(searchbar:get_text())
      searchbar_bg.border_color = Theme_config.application_launcher.searchbar.border_color
    end
  )

  searchbar:connect_signal(
    "stopped",
    function(_, stop_key)
      if stop_key == "Escape" then
        capi.awesome.emit_signal("application_launcher::show")
      end
      searchbar:set_text("")
      ret.application_grid:set_applications(searchbar:get_text())
      searchbar_bg.border_color = Theme_config.application_launcher.searchbar.border_color
    end
  )

  searchbar:connect_signal(
    "started",
    function()
      searchbar_bg.border_color = Theme_config.application_launcher.searchbar.border_active
    end
  )

  searchbar:connect_signal(
    "inputbox::key_pressed",
    function(_, modkey, key)
      if key == "Escape" then
        searchbar:stop()
        capi.awesome.emit_signal("application_launcher::show")
        ret.application_grid:reset()
        searchbar:set_text("")
      elseif key == "Down" or key == "Right" then
        if key == "Down" then
          ret.application_grid:move_down()
        elseif key == "Right" then
          ret.application_grid:move_right()
        end
        searchbar:stop()
        awful.keygrabber.run(function(mod, key2, event)
          if event == "press" then
            if key2 == "Down" then
              ret.application_grid:move_down()
            elseif key2 == "Up" then
              local old_y = ret.application_grid._private.curser.y
              ret.application_grid:move_up()
              if old_y - ret.application_grid._private.curser.y == 0 then
                searchbar:focus()
              end
            elseif key2 == "Left" then
              ret.application_grid:move_left()
            elseif key2 == "Right" then
              ret.application_grid:move_right()
            elseif key2 == "Return" then
              awful.keygrabber.stop()
              ret.application_grid:execute()
              capi.awesome.emit_signal("application_launcher::show")
              ret.application_grid:reset()
              searchbar:set_text("")
              ret.application_grid:set_applications(searchbar:get_text())
            elseif key2 == "Escape" then
              capi.awesome.emit_signal("application_launcher::show")
              ret.application_grid:reset()
              searchbar:set_text("")
              ret.application_grid:set_applications(searchbar:get_text())
              awful.keygrabber.stop()
            end
          end
        end)
        searchbar_bg.border_color = Theme_config.application_launcher.searchbar.border_color
      end
      ret.application_grid:set_applications(searchbar:get_text())
    end
  )

  return ret
end

function application_launcher.mt:__call(...)
  return application_launcher.new(...)
end

return setmetatable(application_launcher, application_launcher.mt)
