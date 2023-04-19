local tinsert = table.insert
local ipairs = ipairs

local beautiful = require('beautiful')

return setmetatable({}, {
  __call = function(_, s)
    local function get_widgets(widgets)
      local widget_table = {}
      if widgets then
        for _, widget in ipairs(widgets) do
          if widget == 'Audio' then
            tinsert(widget_table, require('src.widgets.audio')(s))
          elseif widget == 'Battery' then
            tinsert(widget_table, require('src.widgets.battery')(beautiful.user_config.battery_kind))
          elseif widget == 'Bluetooth' then
            tinsert(widget_table, require('src.widgets.bluetooth')(s))
          elseif widget == 'Clock' then
            tinsert(widget_table, require('src.widgets.clock') {})
          elseif widget == 'Cpu Frequency' then
            tinsert(widget_table, require('src.widgets.cpu_info')('freq'))
          elseif widget == 'Cpu Temperature' then
            tinsert(widget_table, require('src.widgets.cpu_info')('temp'))
          elseif widget == 'Cpu Usage' then
            tinsert(widget_table, require('src.widgets.cpu_info')('usage'))
          elseif widget == 'Date' then
            tinsert(widget_table, require('src.widgets.date')(s))
          elseif widget == 'Gpu Temperature' then
            tinsert(widget_table, require('src.widgets.gpu_info')('temp'))
          elseif widget == 'Gpu Usage' then
            tinsert(widget_table, require('src.widgets.gpu_info')('usage'))
          elseif widget == 'Keyboard Layout' then
            tinsert(widget_table, require('src.widgets.kblayout')(s))
          elseif widget == 'Tiling Layout' then
            tinsert(widget_table, require('src.widgets.layout_list')(s))
          elseif widget == 'Network' then
            tinsert(widget_table, require('src.widgets.network')(s))
          elseif widget == 'Power Button' then
            tinsert(widget_table, require('src.widgets.power') {})
          elseif widget == 'Ram Usage' then
            tinsert(widget_table, require('src.widgets.ram_info') {})
          elseif widget == 'Systray' then
            tinsert(widget_table, require('src.widgets.systray') {})
          elseif widget == 'Taglist' then
            tinsert(widget_table, require('src.widgets.taglist')(s))
          elseif widget == 'Tasklist' then
            tinsert(widget_table, require('src.widgets.tasklist')(s))
          end
        end
      end
      return widget_table
    end

    if beautiful.user_config.crylia_bar then
      for index, screen in ipairs(beautiful.user_config.crylia_bar) do
        if index == s.index then
          if screen.left_bar then
            require('src.modules.crylia_bar.left_bar')(s, get_widgets(screen.left_bar))
          end
          if screen.center_bar then
            require('src.modules.crylia_bar.center_bar')(s, get_widgets(screen.center_bar))
          end
          if screen.right_bar then
            require('src.modules.crylia_bar.right_bar')(s, get_widgets(screen.right_bar))
          end
        end
      end
    end
    require('src.modules.crylia_bar.dock') { screen = s }
  end,
})
