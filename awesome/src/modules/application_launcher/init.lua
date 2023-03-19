--------------------------------------
-- This is the application launcher --
--------------------------------------

-- Awesome Libs
local abutton = require('awful.button')
local akeygrabber = require('awful.keygrabber')
local aplacement = require('awful.placement')
local apopup = require('awful.popup')
local awidget = require('awful.widget')
local dpi = require('beautiful').xresources.apply_dpi
local gtable = require('gears.table')
local wibox = require('wibox')

-- Own libs
local app_grid = require('src.modules.application_launcher.application')

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
  local searchbar = awidget.inputbox {
    hint_text = 'Search...',
    valign = 'center',
    halign = 'left',
  }
  -- Application launcher popup
  local application_container = apopup {
    widget = {
      {
        {
          {
            {
              {
                searchbar,
                widget = wibox.container.margin,
                margins = 5,
              },
              widget = wibox.container.constraint,
              strategy = 'exact',
              height = dpi(50),
            },
            widget = wibox.container.background,
            bg = Theme_config.application_launcher.searchbar.bg,
            fg = Theme_config.application_launcher.searchbar.fg,
            border_color = Theme_config.application_launcher.searchbar.border_color,
            border_width = Theme_config.application_launcher.searchbar.border_width,
            shape = Theme_config.application_launcher.searchbar.shape,
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
    bg = Theme_config.application_launcher.bg,
    border_color = Theme_config.application_launcher.border_color,
    border_width = Theme_config.application_launcher.border_width,
  }

  gtable.crush(application_container, application_launcher, true)

  -- Focus the searchbar when its left clicked
  searchbar:buttons(gtable.join {
    abutton({}, 1, function()
      searchbar:focus()
    end),
  })

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
        searchbar_bg.border_color = Theme_config.application_launcher.searchbar.border_active
        searchbar:focus()
      else
        searchbar:set_text('')
        akeygrabber.stop()
      end
    end
  end)

  -- Execute the currently selected application, reset the searchbar and hide the launcher
  searchbar:connect_signal('submit', function(_, text)
    application_grid:execute()
    capi.awesome.emit_signal('application_launcher::show')
    searchbar:set_text('')
    application_grid:set_applications(searchbar:get_text())
    searchbar_bg.border_color = Theme_config.application_launcher.searchbar.border_color
  end)

  -- Hide the application launcher when the keygrabber stops and reset the searchbar
  searchbar:connect_signal('stopped', function(_, stop_key)
    if stop_key == 'Escape' then
      capi.awesome.emit_signal('application_launcher::show')
    end
    searchbar:set_text('')
    application_grid:set_applications(searchbar:get_text())
    searchbar_bg.border_color = Theme_config.application_launcher.searchbar.border_color
  end)

  -- When started change the background for the searchbar
  searchbar:connect_signal('started', function()
    searchbar_bg.border_color = Theme_config.application_launcher.searchbar.border_active
  end)

  -- On every keypress in the searchbar check for certain inputs
  searchbar:connect_signal('inputbox::key_pressed', function(_, modkey, key)
    if key == 'Escape' then -- Escape to stop the keygrabber, hide the launcher and reset the searchbar
      searchbar:stop()
      capi.awesome.emit_signal('application_launcher::show')
      application_grid:reset()
      searchbar:set_text('')
    elseif key == 'Down' or key == 'Right' then --If down or right is pressed initiate the grid navigation
      if key == 'Down' then
        application_grid:move_down()
      elseif key == 'Right' then
        application_grid:move_right()
      end
      searchbar:stop()
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
      searchbar_bg.border_color = Theme_config.application_launcher.searchbar.border_color
    end
    -- Update the applications in the grid
    application_grid:set_applications(searchbar:get_text())
  end)
end

return setmetatable(application_launcher, { __call = function(_, ...) return application_launcher.new(...) end })
