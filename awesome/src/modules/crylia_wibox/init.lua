--------------------------------------------------------------------------------------------------------------
-- This is the statusbar, every widget, module and so on is combined to all the stuff you see on the screen --
--------------------------------------------------------------------------------------------------------------
local wibox = require('wibox')
local dpi = require('beautiful').xresources.apply_dpi
local gshape = require('gears.shape')
local beautiful = require('beautiful')

return function(s)
  ---Lookup function to return the widget from its easy name string
  ---@param widgets table
  ---@return widget
  local function get_widgets(widgets)
    local widget_table = {}
    if widgets then
      for _, widget in ipairs(widgets) do
        if widget == 'Audio' then
          table.insert(widget_table, require('src.widgets.audio')(s))
        elseif widget == 'Battery' then
          table.insert(widget_table, require('src.widgets.battery')(beautiful.user_config.battery_kind))
        elseif widget == 'Bluetooth' then
          table.insert(widget_table, require('src.widgets.bluetooth')())
        elseif widget == 'Clock' then
          table.insert(widget_table, require('src.widgets.clock')())
        elseif widget == 'Cpu Frequency' then
          table.insert(widget_table, require('src.widgets.cpu_info')('freq', beautiful.user_config.cpu_frequency))
        elseif widget == 'Cpu Temperature' then
          table.insert(widget_table, require('src.widgets.cpu_info')('temp'))
        elseif widget == 'Cpu Usage' then
          table.insert(widget_table, require('src.widgets.cpu_info')('usage'))
        elseif widget == 'Date' then
          table.insert(widget_table, require('src.widgets.date')())
        elseif widget == 'Gpu Temperature' then
          table.insert(widget_table, require('src.widgets.gpu_info')('temp'))
        elseif widget == 'Gpu Usage' then
          table.insert(widget_table, require('src.widgets.gpu_info')('usage'))
        elseif widget == 'Keyboard Layout' then
          table.insert(widget_table, require('src.widgets.kblayout')(s))
        elseif widget == 'Tiling Layout' then
          table.insert(widget_table, require('src.widgets.layout_list')())
        elseif widget == 'Network' then
          table.insert(widget_table, require('src.widgets.network')())
        elseif widget == 'Power Button' then
          table.insert(widget_table, require('src.widgets.power')())
        elseif widget == 'Ram Usage' then
          table.insert(widget_table, require('src.widgets.ram_info')())
        elseif widget == 'Systray' then
          table.insert(widget_table, require('src.widgets.systray')())
        elseif widget == 'Taglist' then
          table.insert(widget_table, require('src.widgets.taglist')(s))
        elseif widget == 'Tasklist' then
          table.insert(widget_table, require('src.widgets.tasklist')(s))
        end
      end
    end
    return widget_table
  end

  if beautiful.user_config.crylia_wibox then
    for index, screen in ipairs(beautiful.user_config.crylia_wibox) do
      if index == s.index then
        local function prepare_widgets(widgets)
          local layout = {
            forced_height = dpi(50),
            layout = wibox.layout.fixed.horizontal,
          }
          for i, widget in pairs(widgets) do
            if i == 1 then
              table.insert(layout,
                {
                  widget,
                  left = dpi(6),
                  right = dpi(3),
                  top = dpi(6),
                  bottom = dpi(6),
                  widget = wibox.container.margin,
                })
            elseif i == #widgets then
              table.insert(layout,
                {
                  widget,
                  left = dpi(3),
                  right = dpi(6),
                  top = dpi(6),
                  bottom = dpi(6),
                  widget = wibox.container.margin,
                })
            else
              table.insert(layout,
                {
                  widget,
                  left = dpi(3),
                  right = dpi(3),
                  top = dpi(6),
                  bottom = dpi(6),
                  widget = wibox.container.margin,
                })
            end
          end
          return layout
        end

        local w = wibox {
          widget = {
            prepare_widgets(get_widgets(screen.left_bar)),
            prepare_widgets(get_widgets(screen.center_bar)),
            prepare_widgets(get_widgets(screen.right_bar)),
            layout = wibox.layout.align.horizontal,
          },
          visible = true,
          x = 0,
          y = 1035,
          type = 'desktop',
          height = dpi(55),
          width = 1920,
          bg = beautiful.colorscheme.bg,
          shape = function(cr, width, height)
            gshape.partially_rounded_rect(cr, width, height, true, true, false, false, dpi(8))
          end,
        }

        w:struts {
          bottom = dpi(60),
        }
      end
    end
  end
end
