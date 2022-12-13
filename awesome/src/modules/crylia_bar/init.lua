--------------------------------------------------------------------------------------------------------------
-- This is the statusbar, every widget, module and so on is combined to all the stuff you see on the screen --
--------------------------------------------------------------------------------------------------------------

return function(s)
  ---Lookup function to return the widget from its easy name string
  ---@param widgets table
  ---@return widget
  local function get_widgets(widgets)
    local widget_table = {}
    if widgets then
      for _, widget in ipairs(widgets) do
        if widget == "Audio" then
          table.insert(widget_table, require("src.widgets.audio")(s))
        elseif widget == "Battery" then
          table.insert(widget_table, require("src.widgets.battery")(User_config.battery_kind))
        elseif widget == "Bluetooth" then
          table.insert(widget_table, require("src.widgets.bluetooth")(s))
        elseif widget == "Clock" then
          table.insert(widget_table, require("src.widgets.clock")())
        elseif widget == "Cpu Frequency" then
          table.insert(widget_table, require("src.widgets.cpu_info")("freq"))
        elseif widget == "Cpu Temperature" then
          table.insert(widget_table, require("src.widgets.cpu_info")("temp"))
        elseif widget == "Cpu Usage" then
          table.insert(widget_table, require("src.widgets.cpu_info")("usage"))
        elseif widget == "Date" then
          table.insert(widget_table, require("src.widgets.date")(s))
        elseif widget == "Gpu Temperature" then
          table.insert(widget_table, require("src.widgets.gpu_info")("temp"))
        elseif widget == "Gpu Usage" then
          table.insert(widget_table, require("src.widgets.gpu_info")("usage"))
        elseif widget == "Keyboard Layout" then
          table.insert(widget_table, require("src.widgets.kblayout")(s))
        elseif widget == "Tiling Layout" then
          table.insert(widget_table, require("src.widgets.layout_list")())
        elseif widget == "Network" then
          table.insert(widget_table, require("src.widgets.network") { screen = s })
        elseif widget == "Power Button" then
          table.insert(widget_table, require("src.widgets.power")())
        elseif widget == "Ram Usage" then
          table.insert(widget_table, require("src.widgets.ram_info")())
        elseif widget == "Systray" then
          table.insert(widget_table, require("src.widgets.systray")(s))
        elseif widget == "Taglist" then
          table.insert(widget_table, require("src.widgets.taglist")(s))
        elseif widget == "Tasklist" then
          table.insert(widget_table, require("src.widgets.tasklist")(s))
        end
      end
    end
    return widget_table
  end

  if User_config.crylia_bar then
    for index, screen in ipairs(User_config.crylia_bar) do
      if index == s.index then
        if screen.left_bar then
          require("src.modules.crylia_bar.left_bar")(s, get_widgets(screen.left_bar))
        end
        if screen.center_bar then
          require("src.modules.crylia_bar.center_bar")(s, get_widgets(screen.center_bar))
        end
        if screen.right_bar then
          require("src.modules.crylia_bar.right_bar")(s, get_widgets(screen.right_bar))
        end
      end
    end
  end
  require("src.modules.crylia_bar.dock")(s)
end
