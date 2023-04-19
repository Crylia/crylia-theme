local setmetatable = setmetatable
local mfloor = math.floor

-- Awesome Libs
local abutton = require('awful.button')
local apopup = require('awful.popup')
local atooltip = require('awful.tooltip')
local base = require('wibox.widget.base')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi
local gcolor = require('gears.color')
local gfilesystem = require('gears.filesystem')
local gtable = require('gears.table')
local gtimer = require('gears.timer')
local wibox = require('wibox')

-- Local Libs
local hover = require('src.tools.hover')
local nm_widget = require('src.modules.network_controller')

local capi = {
  awesome = awesome,
  mouse = mouse,
}

-- Icon directory path
local icondir = gfilesystem.get_configuration_dir() .. 'src/assets/icons/network/'

return setmetatable({}, {
  __call = function(_, screen)
    local w = base.make_widget_from_value {
      {
        {
          {
            {
              id = 'wifi_icon',
              image = gcolor.recolor_image(icondir .. 'no-internet.svg', beautiful.colorscheme.bg),
              widget = wibox.widget.imagebox,
              resize = false,
            },
            {
              id = 'wifi_strength',
              visible = true,
              widget = wibox.widget.textbox,
            },
            spacing = dpi(10),
            layout = wibox.layout.fixed.horizontal,
          },
          left = dpi(8),
          right = dpi(8),
          widget = wibox.container.margin,
        },
        widget = wibox.container.place,
        halign = 'center',
        valign = 'center',
      },
      bg = beautiful.colorscheme.bg_red,
      fg = beautiful.colorscheme.bg,
      shape = beautiful.shape[6],
      widget = wibox.container.background,
    }

    hover.bg_hover { widget = w }

    capi.awesome.connect_signal('NM::AccessPointStrength', function(strength)
      strength = mfloor(strength)
      w:get_children_by_id('wifi_strength')[1].text = strength .. '%'
      w:get_children_by_id('wifi_icon')[1].image = gcolor.recolor_image(icondir ..
        'wifi-strength-' .. mfloor(strength / 25) + 1 .. '.svg', beautiful.colorscheme.bg)
    end)

    capi.awesome.connect_signal('NM::EthernetStatus', function(connected, speed)
      local tt = atooltip {
        objects = { w },
        mode = 'outside',
        preferred_alignments = 'middle',
        margins = dpi(10),
      }
      if connected then
        w:get_children_by_id('wifi_icon')[1].image = gcolor.recolor_image(icondir .. 'ethernet.svg',
          beautiful.colorscheme.bg)
        tt.text = 'Connected via Ethernet at ' .. mfloor(speed or 0) .. '/Mbps'
      else
        w:get_children_by_id('wifi_icon')[1].image = gcolor.recolor_image(icondir .. 'no-internet.svg',
          beautiful.colorscheme.bg)
        tt.text = 'No connection found'
      end
    end)

    local nm = nm_widget { screen = screen }

    local network_controler_popup = apopup {
      widget = nm,
      visible = true,
      ontop = true,
      screen = screen,
    }

    gtimer.delayed_call(function()
      network_controler_popup.visible = false
    end)

    w:buttons(gtable.join(
      abutton({}, 1, function()
        --This gets the wrong wibox, get all wiboxed and find the correct widget
        network_controler_popup.x = capi.mouse.coords().x - (network_controler_popup:geometry().width / 2)
        network_controler_popup.y = dpi(70)
        network_controler_popup.visible = not network_controler_popup.visible
      end)
    ))

    return w
  end,
})
