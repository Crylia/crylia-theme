--------------------------------
-- This is the network widget --
--------------------------------

-- Awesome Libs
local abutton = require('awful.button')
local apopup = require('awful.popup')
local atooltip = require('awful.tooltip')
local base = require('wibox.widget.base')
local dpi = require('beautiful').xresources.apply_dpi
local gears = require('gears')
local gtable = require('gears.table')
local wibox = require('wibox')

local capi = {
  awesome = awesome,
  mouse = mouse,
}

-- Icon directory path
local icondir = gears.filesystem.get_configuration_dir() .. 'src/assets/icons/network/'

local nm_widget = require('src.modules.network_controller.init')
local hover = require('src.tools.hover')

local network = { mt = {} }

function network.new(args)
  args = args or {}

  local w = base.make_widget_from_value {
    {
      {
        {
          {
            id = 'wifi_icon',
            image = gears.color.recolor_image(icondir .. 'no-internet.svg', Theme_config.network.fg),
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
    bg = Theme_config.network.bg,
    fg = Theme_config.network.fg,
    shape = Theme_config.network.shape,
    widget = wibox.container.background,
  }

  assert(w, 'Failed to create widget')

  hover.bg_hover { widget = w }

  gtable.crush(w, network, true)

  capi.awesome.connect_signal('NM::AccessPointStrength', function(strength)
    strength = math.floor(strength)
    w:get_children_by_id('wifi_strength')[1].text = strength .. '%'
    w:get_children_by_id('wifi_icon')[1].image = gears.color.recolor_image(icondir ..
      'wifi-strength-' .. math.floor(strength / 25) + 1 .. '.svg', Theme_config.network.fg)
  end)

  capi.awesome.connect_signal('NM::EthernetStatus', function(connected, speed)
    local tt = atooltip {
      objects = { w },
      mode = 'outside',
      preferred_alignments = 'middle',
      margins = dpi(10),
    }
    if connected then
      w:get_children_by_id('wifi_icon')[1].image = gears.color.recolor_image(icondir .. 'ethernet.svg',
        Theme_config.network.fg)
      tt.text = 'Connected via Ethernet at ' .. math.floor(speed or 0) .. '/Mbps'
    else
      w:get_children_by_id('wifi_icon')[1].image = gears.color.recolor_image(icondir .. 'no-internet.svg',
        Theme_config.network.fg)
      tt.text = 'No connection found'
    end
  end)

  local nm = nm_widget { screen = args.screen }

  local network_controler_popup = apopup {
    widget = nm,
    visible = false,
    ontop = true,
    screen = args.screen,
  }

  w:buttons(gtable.join(
    abutton({}, 1, function()
      --This gets the wrong wibox, get all wiboxed and find the correct widget
      network_controler_popup.x = capi.mouse.coords().x - (network_controler_popup:geometry().width / 2)
      network_controler_popup.y = dpi(65)
      network_controler_popup.visible = not network_controler_popup.visible
    end)
  ))

  return w
end

function network.mt:__call(...)
  return network.new(...)
end

return setmetatable(network, network.mt)
