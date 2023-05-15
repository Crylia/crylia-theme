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
local nm_widget = require('src.modules.network')
local networkManager = require('src.tools.network')()

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

    --  Little workaround because signals from nm_widget are not working?
    --! Find out why the signals are not working
    local function update_ethernet(device)
      w.tt = atooltip {
        objects = { w },
        mode = 'outside',
        preferred_alignments = 'middle',
        margins = dpi(10),
        text = 'Connected via Ethernet at ' .. mfloor(device.Speed or 0) .. '/Mbps',
      }
    end

    local nm = nm_widget { screen = screen }

    local function active_access_point_strength(strength)
      local s
      if strength > 80 then
        s = 5
      elseif strength >= 60 and strength < 80 then
        s = 4
      elseif strength >= 40 and strength < 60 then
        s = 3
      elseif strength >= 20 and strength < 40 then
        s = 2
      else
        s = 1
      end
      w:get_children_by_id('wifi_strength')[1].text = math.floor(strength) .. '%'
      w:get_children_by_id('wifi_icon')[1].image = gcolor.recolor_image(icondir ..
        'wifi-strength-' .. s .. '.svg', beautiful.colorscheme.bg)
    end

    capi.awesome.connect_signal('ActiveAccessPointStrength', active_access_point_strength)

    -- Remove the wifi signals when no wifi is active/readd them when wifi is active
    networkManager:connect_signal('NetworkManager::WirelessEnabled', function(enabled)
      if enabled then
        capi.awesome.connect_signal('ActiveAccessPointStrength', active_access_point_strength)
        w:get_children_by_id('wifi_strength')[1].visible = true
        w.tt = nil
      else
        -- If its nil then there is no internet
        local dev = networkManager:get_wireless_device()
        if not dev then
          w:get_children_by_id('wifi_icon')[1].image = gcolor.recolor_image(icondir .. 'no-internet.svg', beautiful.colorscheme.bg)
        else
          w:get_children_by_id('wifi_icon')[1].image = gcolor.recolor_image(icondir .. 'ethernet.svg', beautiful.colorscheme.bg)
          update_ethernet(dev)
          w.tt = nil
        end
        capi.awesome.disconnect_signal('ActiveAccessPointStrength', active_access_point_strength)
        w:get_children_by_id('wifi_strength')[1].visible = false
      end
    end)

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
