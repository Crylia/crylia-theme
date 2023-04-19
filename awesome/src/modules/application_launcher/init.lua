--------------------------------------
-- This is the application launcher --
--------------------------------------

-- Awesome Libs
local abutton = require('awful.button')
local akeygrabber = require('awful.keygrabber')
local aplacement = require('awful.placement')
local apopup = require('awful.popup')
local awidget = require('awful.widget')
local beautiful = require('beautiful')
local dpi = require('beautiful').xresources.apply_dpi
local gtable = require('gears.table')
local wibox = require('wibox')
local gtimer = require('gears.timer')

-- Own libs
local app_grid = require('src.modules.application_launcher.application')
local input = require('src.modules.inputbox')

local capi = {
  awesome = awesome,
  mouse = mouse,
}

-- This grid object is shared to avoid having multipe unnecessary instances
local application_grid = app_grid {}

local application_launcher = {}

function application_launcher.new(args)
  args = args or {}

  -- Create a new inputbox
  local searchbar = input {
    text_hint = 'Search...',
    mouse_focus = true,
    fg = beautiful.colorscheme.fg,
    password_mode = true,
  }
  -- Application launcher popup
  local application_container = apopup {
    widget = {
      {
        {
          {
            {
              {
                {
                  searchbar.widget,
                  halign = 'left',
                  valign = 'center',
                  widget = wibox.container.place,
                },
                widget = wibox.container.margin,
                margins = 5,
              },
              widget = wibox.container.constraint,
              strategy = 'exact',
              height = dpi(50),
            },
            widget = wibox.container.background,
            bg = beautiful.colorscheme.bg,
            fg = beautiful.colorscheme.fg,
            border_color = beautiful.colorscheme.border_color,
            border_width = dpi(2),
            shape = beautiful.shape[4],
            id = 'searchbar_bg',
          },
          {
            application_grid,
            layout = require('src.lib.overflow_widget.overflow').vertical,
            scrollbar_width = 0,
            step = dpi(100),
          },
          spacing = dpi(10),
          layout = wibox.layout.fixed.vertical,
        },
        margins = dpi(20),
        widget = wibox.container.margin,
      },
      height = args.screen.geometry.height / 100 * 60,
      strategy = 'exact',
      widget = wibox.container.constraint,
    },
    ontop = true,
    visible = false,
    stretch = false,
    screen = args.screen,
    placement = aplacement.centered,
    bg = beautiful.colorscheme.bg,
    border_color = beautiful.colorscheme.border_color,
    border_width = dpi(2),
  }

  -- Delayed call to give the popup some time to evaluate its width
  gtimer.delayed_call(function()
    if application_container.width then
      application_container.widget.width = application_container.width
    end
  end)

  gtable.crush(application_container, application_launcher, true)

  --#region Hover signals to change the cursor to a text cursor
  local old_cursor, old_wibox
  searchbar:connect_signal('mouse::enter', function()
    local wid = capi.mouse.current_wibox
    if wid then
      old_cursor, old_wibox = wid.cursor, wid
      wid.cursor = 'xterm'
    end
  end)
  searchbar:connect_signal('mouse::leave', function()
    old_wibox.cursor = old_cursor
    old_wibox = nil
  end)
  --#endregion

  -- Get a reference to the searchbar background value
  local searchbar_bg = application_container.widget:get_children_by_id('searchbar_bg')[1]

  -- Toggle visible for the application launcher and init the searchbar
  capi.awesome.connect_signal('application_launcher::show', function()
    if capi.mouse.screen == args.screen then
      capi.awesome.emit_signal('update::selected')
      if capi.mouse.screen == args.screen then
        application_container.visible = not application_container.visible
      end
      if application_container.visible then
        searchbar_bg.border_color = beautiful.colorscheme.bg_blue
        searchbar:focus()
      else
        searchbar:set_text('')
        akeygrabber.stop()
      end
    end
  end)

  -- Hide the application launcher when the keygrabber stops and reset the searchbar
  searchbar:connect_signal('inputbox::stop', function(_, stop_key)
    if stop_key == 'Escape' then
      capi.awesome.emit_signal('application_launcher::show')
    end
    searchbar:set_text('')
    application_grid:set_applications(searchbar:get_text())
    searchbar_bg.border_color = beautiful.colorscheme.border_color
  end)

  -- When started change the background for the searchbar
  searchbar:connect_signal('inputbox::start', function()
    searchbar_bg.border_color = beautiful.colorscheme.bg_blue
  end)

  -- On every keypress in the searchbar check for certain inputs
  searchbar:connect_signal('inputbox::keypressed', function(_, modkey, key)
    if key == 'Escape' then -- Escape to stop the keygrabber, hide the launcher and reset the searchbar
      searchbar:unfocus()
      capi.awesome.emit_signal('application_launcher::show')
      application_grid:reset()
      searchbar:set_text('')
    elseif key == 'Return' then
      application_grid:execute()
      capi.awesome.emit_signal('application_launcher::show')
      searchbar:set_text('')
      application_grid:set_applications(searchbar:get_text())
      searchbar_bg.border_color = beautiful.colorscheme.border_color
    elseif key == 'Down' then --If down or right is pressed initiate the grid navigation
      if key == 'Down' then
        application_grid:move_down()
      elseif key == 'Right' then
        application_grid:move_right()
      end
      searchbar:unfocus()
      --New keygrabber to allow for key navigation
      akeygrabber.run(function(mod, key2, event)
        if event == 'press' then
          if key2 == 'Down' then
            application_grid:move_down()
          elseif key2 == 'Up' then
            local old_y = application_grid._private.curser.y
            application_grid:move_up()
            if old_y - application_grid._private.curser.y == 0 then
              searchbar:focus()
            end
          elseif key2 == 'Left' then
            application_grid:move_left()
          elseif key2 == 'Right' then
            application_grid:move_right()
          elseif key2 == 'Return' then
            akeygrabber.stop()
            application_grid:execute()
            capi.awesome.emit_signal('application_launcher::show')
            application_grid:reset()
            searchbar:set_text('')
            application_grid:set_applications(searchbar:get_text())
          elseif key2 == 'Escape' then
            capi.awesome.emit_signal('application_launcher::show')
            application_grid:reset()
            searchbar:set_text('')
            application_grid:set_applications(searchbar:get_text())
            akeygrabber.stop()
          end
        end
      end)
      searchbar_bg.border_color = beautiful.colorscheme.border_color
    end
    -- Update the applications in the grid
    application_grid:set_applications(searchbar:get_text())
  end)
end

return setmetatable(application_launcher, { __call = function(_, ...) return application_launcher.new(...) end })
