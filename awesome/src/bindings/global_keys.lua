-- Awesome libs
local akeygrabber = require('awful.keygrabber')
local akey = require('awful.key')
local gtable = require('gears.table')
local atag = require('awful.tag')
local aclient = require('awful.client')
local aspawn = require('awful.spawn')
local alayout = require('awful.layout')
local ascreen = require('awful.screen')
local hotkeys_popup = require('awful.hotkeys_popup')
local ruled = require('ruled')

-- Local libs
local config = require('src.tools.config')
local audio_helper = require('src.tools.helpers.audio')
local backlight_helper = require('src.tools.helpers.backlight')
local powermenu = require('src.modules.powermenu.init')
local kb_helper = require('src.tools.helpers.kb_helper')

local capi = {
  awesome = awesome,
  mousegrabber = mousegrabber,
  mouse = mouse,
}

local modkey = User_config.modkey

akeygrabber {
  keybindings = {
    akey {
      modifiers = { 'Mod1' },
      key = 'Tab',
      on_press = function()
        capi.awesome.emit_signal('window_switcher::select_next')
      end,
    },
  },
  root_keybindings = {
    akey {
      modifiers = { 'Mod1' },
      key = 'Tab',
      on_press = function()
      end,
    },
  },
  stop_key = 'Mod1',
  stop_event = 'release',
  start_callback = function()
    capi.awesome.emit_signal('toggle_window_switcher')
  end,
  stop_callback = function()
    capi.awesome.emit_signal('window_switcher::raise')
    capi.awesome.emit_signal('toggle_window_switcher')
  end,
  export_keybindings = true,
}

return gtable.join(
  akey(
    { modkey },
    '#39',
    hotkeys_popup.show_help,
    { description = 'Cheat sheet', group = 'Awesome' }
  ),
  --[[   akey(
    { modkey },
    '#113',
    atag.viewprev,
    { description = 'View previous tag', group = 'Tag' }
  ),
  akey(
    { modkey },
    '#114',
    atag.viewnext,
    { description = 'View next tag', group = 'Tag' }
  ), ]]
  akey(
    { modkey },
    '#66',
    atag.history.restore,
    { description = 'Go back to last tag', group = 'Tag' }
  ),
  akey(
    { modkey },
    '#44',
    function()
      aclient.focus.byidx(1)
    end,
    { description = 'Focus next client by index', group = 'Client' }
  ),
  akey(
    { modkey },
    '#45',
    function()
      aclient.focus.byidx(-1)
    end,
    { description = 'Focus previous client by index', group = 'Client' }
  ),
  akey(
    { modkey, 'Shift' },
    '#44',
    function()
      aclient.swap.byidx(1)
    end,
    { description = 'Swap with next client by index', group = 'Client' }
  ),
  akey(
    { modkey, 'Shift' },
    '#45',
    function()
      aclient.swap.byidx(-1)
    end,
    { description = 'Swap with previous client by index', group = 'Client' }
  ),
  akey(
    { modkey, 'Control' },
    '#44',
    function()
      ascreen.focus_relative(1)
    end,
    { description = 'Focus the next screen', group = 'Screen' }
  ),
  akey(
    { modkey, 'Control' },
    '#45',
    function()
      ascreen.focus_relative(-1)
    end,
    { description = 'Focus the previous screen', group = 'Screen' }
  ),
  akey(
    { modkey },
    '#30',
    aclient.urgent.jumpto,
    { description = 'Jump to urgent client', group = 'Client' }
  ),
  akey(
    { modkey },
    '#36',
    function()
      aspawn(User_config.terminal)
    end,
    { description = 'Open terminal', group = 'Applications' }
  ),
  akey(
    { modkey, 'Control' },
    '#27',
    capi.awesome.restart,
    { description = 'Reload awesome', group = 'Awesome' }
  ),
  akey(
    { modkey },
    '#46',
    function()
      atag.incmwfact(0.05)
    end,
    { description = 'Increase client width', group = 'Layout' }
  ),
  akey(
    { modkey },
    '#43',
    function()
      atag.incmwfact(-0.05)
    end,
    { description = 'Decrease client width', group = 'Layout' }
  ),
  akey(
    { modkey, 'Control' },
    '#43',
    function()
      atag.incncol(1, nil, true)
    end,
    { description = 'Increase the number of columns', group = 'Layout' }
  ),
  akey(
    { modkey, 'Control' },
    '#46',
    function()
      atag.incncol(-1, nil, true)
    end,
    { description = 'Decrease the number of columns', group = 'Layout' }
  ),
  akey(
    { modkey, 'Shift' },
    '#65',
    function()
      alayout.inc(-1)
    end,
    { description = 'Select previous layout', group = 'Layout' }
  ),
  akey(
    { modkey, 'Shift' },
    '#36',
    function()
      alayout.inc(1)
    end,
    { description = 'Select next layout', group = 'Layout' }
  ),
  akey(
    { modkey },
    '#40',
    function()
      capi.awesome.emit_signal('application_launcher::show')
    end,
    { descripton = 'Application launcher', group = 'Application' }
  ),
  akey(
    { modkey },
    '#26',
    function()
      aspawn(User_config.file_manager)
    end,
    { descripton = 'Open file manager', group = 'System' }
  ),
  akey(
    { modkey, 'Shift' },
    '#26',
    function()
      powermenu:toggle()
    end,
    { descripton = 'Session options', group = 'System' }
  ),
  akey(
    {},
    '#107',
    function()
      aspawn(User_config.screenshot_program)
    end,
    { description = 'Screenshot', group = 'Applications' }
  ),
  akey(
    {},
    'XF86AudioLowerVolume',
    function(c)
      audio_helper.sink_volume_down()
    end,
    { description = 'Lower volume', group = 'System' }
  ),
  akey(
    {},
    'XF86AudioRaiseVolume',
    function(c)
      audio_helper.sink_volume_up()
    end,
    { description = 'Increase volume', group = 'System' }
  ),
  akey(
    {},
    'XF86AudioMute',
    function(c)
      audio_helper.sink_toggle_mute()
    end,
    { description = 'Mute volume', group = 'System' }
  ),
  akey(
    {},
    'XF86MonBrightnessUp',
    function(c)
      backlight_helper.brightness_increase()
    end,
    { description = 'Raise backlight brightness', group = 'System' }
  ),
  akey(
    {},
    'XF86MonBrightnessDown',
    function(c)
      backlight_helper.brightness_decrease()
    end,
    { description = 'Lower backlight brightness', group = 'System' }
  ),
  akey(
    {},
    'XF86AudioPlay',
    function(c)
      aspawn('playerctl play-pause')
    end,
    { description = 'Play / Pause audio', group = 'System' }
  ),
  akey(
    {},
    'XF86AudioNext',
    function(c)
      aspawn('playerctl next')
    end,
    { description = 'Play / Pause audio', group = 'System' }
  ),
  akey(
    {},
    'XF86AudioPrev',
    function(c)
      aspawn('playerctl previous')
    end,
    { description = 'Play / Pause audio', group = 'System' }
  ),
  akey(
    { modkey },
    '#65',
    function()
      kb_helper:cycle_layout()
    end,
    { description = 'Cycle keyboard layout', group = 'System' }
  ),
  akey(
    { modkey },
    '#22',
    function()
      capi.mousegrabber.run(
        function(m)
          if m.buttons[1] then
            local data = config.read_json('/home/crylia/.config/awesome/src/config/floating.json')
            if type(data) ~= 'table' then return end

            local c = capi.mouse.current_client
            if not c then return end

            local client_data = {
              WM_NAME = c.name,
              WM_CLASS = c.class,
              WM_INSTANCE = c.instance,
            }

            -- Check if data already had the client then return
            for _, v in ipairs(data) do
              if v.WM_NAME == client_data.WM_NAME and
                  v.WM_CLASS == client_data.WM_CLASS and
                  v.WM_INSTANCE == client_data.WM_INSTANCE then
                return
              end
            end

            table.insert(data, client_data)

            ruled.client.append_rule {
              rule = { class = c.class, instance = c.instance },
              properties = {
                floating = true,
              },
            }
            c.floating = true

            config.write_json('/home/crylia/.config/awesome/src/config/floating.json', data)
            capi.mousegrabber.stop()
          end
          return true
        end,
        'crosshair'
      )
    end
  ),
  akey(
    { modkey, 'Shift' },
    '#22',
    function()
      capi.mousegrabber.run(
        function(m)
          if m.buttons[1] then
            local data = config.read_json('/home/crylia/.config/awesome/src/config/floating.json')
            local c = capi.mouse.current_client
            if not c then return end

            local client_data = {
              WM_NAME = c.name,
              WM_CLASS = c.class,
              WM_INSTANCE = c.instance,
            }

            -- Remove client_data from data_table
            for k, v in ipairs(data) do
              if v.WM_CLASS == client_data.WM_CLASS and
                  v.WM_INSTANCE == client_data.WM_INSTANCE then
                table.remove(data, k)
                ruled.client.remove_rule {
                  rule = { class = c.class, instance = c.instance },
                  properties = {
                    floating = true,
                  },
                }
                c.floating = false
                break
              end
            end

            config.write_json('/home/crylia/.config/awesome/src/config/floating.json', data)
            capi.mousegrabber.stop()
          end
          return true
        end,
        'crosshair'
      )
    end
  )
)
