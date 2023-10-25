local setmetatable = setmetatable

local wibox = require('wibox')
local gtable = require('gears.table')
local gobject = require('gears.object')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi
local base = require('wibox.widget.base')
local gfilesystem = require('gears.filesystem')
local gcolor = require('gears.color')
local gshape = require('gears.shape')
local abutton = require('awful.button')

local rubato = require('src.lib.rubato')

local bt = require('src.tools.bluetooth.adapter')()
local dev = require('src.tools.bluetooth.device')
local dnd_widget = require('awful.widget.toggle_widget')

local icondir = gfilesystem.get_configuration_dir() .. 'src/assets/icons/bluetooth/'

local bluetooth = gobject {}


---Add a device to a specified list
---@param path string device
function bluetooth:add_device_to_list(path)
  if not path then return end

  local paired_list = self:get_children_by_id('paired_list')[1]
  local discovered_list = self:get_children_by_id('discovered_list')[1]

  local device = dev(path)

  local bg, fg
  if device.Paired then
    bg = beautiful.colorscheme.bg_blue
    fg = beautiful.colorscheme.bg
  else
    bg = beautiful.colorscheme.bg
    fg = beautiful.colorscheme.bg_blue
  end

  local w = base.make_widget_from_value {
    {
      {
        {
          {
            {
              widget = wibox.widget.imagebox,
              halign = 'center',
              valign = 'center',
              resize = true,
              id = 'icon_role',
              image = gcolor.recolor_image(
                icondir .. device.Icon .. '.svg', beautiful.colorscheme.bg_blue),
            },
            height = dpi(24),
            width = dpi(24),
            strategy = 'exact',
            widget = wibox.container.constraint,
          },
          {
            {
              {
                text = device.Alias or device.Name or path or '',
                widget = wibox.widget.textbox,
              },
              widget = wibox.container.constraint,
              width = dpi(300),
              strategy = 'exact',
            },
            strategy = 'max',
            height = dpi(40),
            width = dpi(260),
            widget = wibox.container.constraint,
          },
          spacing = dpi(10),
          layout = wibox.layout.fixed.horizontal,
        },
        { -- Spacing
          width = dpi(10),
          widget = wibox.container.constraint,
        },
        {
          {
            {
              halign = 'center',
              valign = 'center',
              resize = false,
              id = 'con_icon',
              image = gcolor.recolor_image(icondir .. 'link-off.svg', fg),
              widget = wibox.widget.imagebox,
            },
            width = dpi(24),
            height = dpi(24),
            strategy = 'exact',
            widget = wibox.container.constraint,
          },
          margins = dpi(5),
          widget = wibox.container.margin,
        },
        layout = wibox.layout.align.horizontal,
      },
      margins = dpi(5),
      widget = wibox.container.margin,
    },
    shape = beautiful.shape[4],
    bg = bg,
    fg = fg,
    border_color = beautiful.colorscheme.border_color,
    border_width = dpi(2),
    widget = wibox.container.background,
    object_path = path,
  }

  if device.Paired then
    table.insert(paired_list.children, w)
  else
    table.insert(discovered_list.children, w)
  end
end

return setmetatable(bluetooth, {
  __call = function(self)

    local dnd = dnd_widget {
      color = beautiful.colorscheme.bg_blue,
      size = dpi(40),
    }

    local w = base.make_widget_from_value {
      {
        {
          {
            { -- Paired header
              {
                {
                  {
                    widget = wibox.widget.imagebox,
                    resize = false,
                    id = 'paired_icon',
                    image = gcolor.recolor_image(icondir .. 'menu-down.svg', beautiful.colorscheme.bg_blue),
                  },
                  widget = wibox.container.place,
                },
                {
                  {
                    text = 'Paired Devices',
                    widget = wibox.widget.textbox,
                  },
                  margins = dpi(5),
                  widget = wibox.container.margin,
                },
                layout = wibox.layout.fixed.horizontal,
              },
              id = 'paired_list_bar',
              bg = beautiful.colorscheme.bg1,
              fg = beautiful.colorscheme.bg_blue,
              shape = beautiful.shape[4],
              widget = wibox.container.background,
            },
            { -- Paired list
              {
                {
                  {
                    id = 'paired_list',
                    scrollbar_width = 0,
                    spacing = dpi(10),
                    step = dpi(50),
                    layout = require('src.lib.overflow_widget.overflow').vertical,
                  },
                  margins = dpi(10),
                  widget = wibox.container.margin,
                },
                border_color = beautiful.colorscheme.border_color,
                border_width = dpi(2),
                shape = function(cr, width, height)
                  gshape.partially_rounded_rect(cr, width, height, false, false, true, true, dpi(4))
                end,
                widget = wibox.container.background,
              },
              id = 'paired_list_height',
              strategy = 'exact',
              height = 0,
              widget = wibox.container.constraint,
            },
            { -- Spacer
              widget = wibox.container.constraint,
              strategy = 'exact',
              height = dpi(10),
            },
            { -- discovered header
              {
                {
                  {
                    widget = wibox.widget.imagebox,
                    resize = false,
                    id = 'discovered_icon',
                    image = gcolor.recolor_image(icondir .. 'menu-down.svg', beautiful.colorscheme.bg_blue),
                  },
                  widget = wibox.container.place,
                },
                {
                  {
                    text = 'Discovered Devices',
                    widget = wibox.widget.textbox,
                  },
                  margins = dpi(5),
                  widget = wibox.container.margin,
                },
                layout = wibox.layout.fixed.horizontal,
              },
              id = 'discovered_list_bar',
              bg = beautiful.colorscheme.bg1,
              fg = beautiful.colorscheme.bg_blue,
              shape = beautiful.shape[4],
              widget = wibox.container.background,
            },
            { -- discovered list
              {
                {
                  {
                    id = 'discovered_list',
                    scrollbar_width = 0,
                    spacing = dpi(10),
                    step = dpi(50),
                    layout = require('src.lib.overflow_widget.overflow').vertical,
                  },
                  margins = dpi(10),
                  widget = wibox.container.margin,
                },
                border_color = beautiful.colorscheme.border_color,
                border_width = dpi(2),
                shape = function(cr, width, height)
                  gshape.partially_rounded_rect(cr, width, height, false, false, true, true, dpi(4))
                end,
                widget = wibox.container.background,
              },
              id = 'discovered_list_height',
              strategy = 'exact',
              height = 0,
              widget = wibox.container.constraint,
            },
            { -- widgets
              {
                {
                  dnd,
                  widget = wibox.container.place,
                },
                nil,
                {
                  {
                    {
                      image = gcolor.recolor_image(icondir .. 'refresh.svg', beautiful.colorscheme.bg_blue),
                      resize = false,
                      valign = 'center',
                      halign = 'center',
                      widget = wibox.widget.imagebox,
                    },
                    widget = wibox.container.margin,
                    margins = dpi(5),
                  },
                  id = 'refresh_button',
                  border_color = beautiful.colorscheme.border_color,
                  border_width = dpi(2),
                  shape = beautiful.shape[4],
                  bg = beautiful.colorscheme.bg,
                  widget = wibox.container.background,
                },
                layout = wibox.layout.align.horizontal,
              },
              top = dpi(10),
              widget = wibox.container.margin,
            },
            layout = wibox.layout.fixed.vertical,
          },
          margins = dpi(15),
          widget = wibox.container.margin,
        },
        shape = beautiful.shape[8],
        border_color = beautiful.colorscheme.border_color,
        bg = beautiful.colorscheme.bg,
        border_width = dpi(2),
        widget = wibox.container.background,
      },
      strategy = 'exact',
      width = dpi(400),
      widget = wibox.container.constraint,
    }

    gtable.crush(self, w, true)

    local paired_list = w:get_children_by_id('paired_list')[1]
    local discovered_list = w:get_children_by_id('discovered_list')[1]

    local paired_list_height = w:get_children_by_id('paired_list_height')[1]
    local discovered_list_height = w:get_children_by_id('discovered_list_height')[1]

    local paired_list_bar = w:get_children_by_id('paired_list_bar')[1]
    local discovered_list_bar = w:get_children_by_id('discovered_list_bar')[1]

    local paired_icon = w:get_children_by_id('paired_icon')[1]
    local discovered_icon = w:get_children_by_id('discovered_icon')[1]

    local paired_list_anim = rubato.timed {
      duration = 0.2,
      pos = paired_list_height.height,
      clamp_position = true,
      rate = 24,
      subscribed = function(v)
        paired_list_height.height = v
      end,
    }
    local discovered_list_anim = rubato.timed {
      duration = 0.2,
      pos = discovered_list_height.height,
      clamp_position = true,
      rate = 24,
      subscribed = function(v)
        discovered_list_height.height = v
      end,
    }

    paired_list_bar:buttons(gtable.join {
      abutton({}, 1, function()
        if paired_list_height.height == 0 then
          local size = (paired_list.children and #paired_list.children or 0) * dpi(50)
          if size > dpi(330) then
            size = dpi(330)
          end
          paired_list_anim.target = dpi(size)
          paired_list_bar.shape = function(cr, width, height)
            gshape.partially_rounded_rect(cr, width, height, true, true, false, false, dpi(4))
          end
          if #paired_list.children > 0 then
            paired_icon:set_image(gcolor.recolor_image(icondir .. 'menu-up.svg',
              beautiful.colorscheme.bg_blue))
          else
            paired_icon:set_image(gcolor.recolor_image(icondir .. 'menu-down.svg',
              beautiful.colorscheme.bg_blue))
          end
        else
          paired_list_anim.target = 0
          paired_list_bar.shape = function(cr, width, height)
            gshape.partially_rounded_rect(cr, width, height, true, true, true, true, dpi(4))
          end
          paired_icon:set_image(gcolor.recolor_image(icondir .. 'menu-down.svg',
            beautiful.colorscheme.bg_blue))
        end
      end),
    })

    discovered_list_bar:buttons(gtable.join {
      abutton({}, 1, function()
        if discovered_list_height.height == 0 then
          local size = (discovered_list.children and #discovered_list.children or 0) * dpi(50)
          if size > dpi(330) then
            size = dpi(330)
          end
          discovered_list_anim.target = dpi(size)
          discovered_list_bar.shape = function(cr, width, height)
            gshape.partially_rounded_rect(cr, width, height, true, true, false, false, dpi(4))
          end
          if #discovered_list.children > 0 then
            discovered_icon:set_image(gcolor.recolor_image(icondir .. 'menu-up.svg',
              beautiful.colorscheme.bg_blue))
          else
            discovered_icon:set_image(gcolor.recolor_image(icondir .. 'menu-down.svg',
              beautiful.colorscheme.bg_blue))
          end
        else
          discovered_list_anim.target = 0
          discovered_list_bar.shape = function(cr, width, height)
            gshape.partially_rounded_rect(cr, width, height, true, true, true, true, dpi(4))
          end
          discovered_icon:set_image(gcolor.recolor_image(icondir .. 'menu-down.svg',
            beautiful.colorscheme.bg_blue))
        end
      end),
    })

    local refresh_button = w:get_children_by_id('refresh_button')[1]
    refresh_button:buttons(gtable.join {
      abutton({}, 1, nil, function()
        bt:StartDiscovery()
      end),
    })

    dnd:buttons(gtable.join {
      abutton({}, 1, function()
        bt:toggle_wifi()
      end),
    })

    if bt.Powered then
      dnd:set_enabled()
    else
      dnd:set_disabled()
    end
    bt:connect_signal('Bluetooth::Powered', function(_, powered)
      if powered then
        dnd:set_enabled()
      else
        dnd:set_disabled()
      end
      print(powered)
    end)

    bt:connect_signal('Bluetooth::DeviceAdded', function(_, path)
      self:add_device_to_list(path)
    end)

    bt:connect_signal('Bluetooth::DeviceRemoved', function(_, path)
      self:remove_device_from_list(path)
    end)

    return self
  end,
})
