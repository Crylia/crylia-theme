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

local capi = {
  awesome = awesome,
  mouse = mouse,
}

local application_launcher = { mt = {} }

application_launcher.searchbar = awful.widget.inputbox {
  widget_template = wibox.template {
    widget = wibox.widget {
      {
        {
          {
            widget = wibox.widget.textbox,
            halign = "left",
            valign = "center",
            id = "text_role",
          },
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
      bg = "#212121",
      fg = "#F0F0F0",
      border_color = "#414141",
      border_width = 2,
      shape = gshape.rounded_rect,
    },
    update_callback = function(template_widget, args)
      template_widget.widget.const.marg.text_role.markup = args.text
    end
  }
}

application_launcher.application_grid = require("src.modules.application_launcher.application") {}


function application_launcher.new(args)
  args = args or {}

  local ret = gobject { enable_properties = true }

  gtable.crush(ret, application_launcher, true)

  local applicaton_launcher = wibox.widget {
    {
      {
        ret.searchbar,
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

  capi.awesome.connect_signal(
    "application_launcher::show",
    function()
      if capi.mouse.screen == args.screen then
        ret.application_container.visible = not ret.application_container.visible
      end
      if ret.application_container.visible then
        ret.searchbar:focus()
      else
        awful.keygrabber.stop()
      end
    end
  )

  ret.searchbar:connect_signal(
    "submit",
    function(text)
      ret.application_grid:execute()
      capi.awesome.emit_signal("application_launcher::show")
    end
  )

  ret.searchbar:connect_signal(
    "stopped",
    function()
      ret.searchbar:get_widget().widget.border_color = Theme_config.application_launcher.searchbar.border_color
    end
  )

  ret.searchbar:connect_signal(
    "started",
    function()
      ret.searchbar:get_widget().widget.border_color = Theme_config.application_launcher.searchbar.border_active
    end
  )

  awesome.connect_signal(
    "inputbox::key_pressed",
    function(modkey, key)
      if key == "Escape" then
        ret.searchbar:stop()
        capi.awesome.emit_signal("application_launcher::show")
        ret.application_grid:reset()
        ret.searchbar:set_text("")
      elseif key == "Down" or key == "Right" then
        ret.searchbar:stop()
        awful.keygrabber.run(function(mod, key2, event)
          if event == "press" then
            if key2 == "Down" then
              ret.application_grid:move_down()
            elseif key2 == "Up" then
              local old_y = ret.application_grid._private.curser.y
              ret.application_grid:move_up()
              if old_y - ret.application_grid._private.curser.y == 0 then
                ret.searchbar:focus()
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
              ret.searchbar:set_text("")
            elseif key2 == "Escape" then
              capi.awesome.emit_signal("application_launcher::show")
              ret.application_grid:reset()
              ret.searchbar:set_text("")
              awful.keygrabber.stop()
            end
          end
        end)
      end
      ret.application_grid:set_applications(ret.searchbar:get_text())
    end
  )

  return ret
end

function application_launcher.mt:__call(...)
  return application_launcher.new(...)
end

return setmetatable(application_launcher, application_launcher.mt)
