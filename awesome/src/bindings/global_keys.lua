-- Awesome Libs
local gears = require("gears")
local awful = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup")
local ruled = require("ruled")

local modkey = User_config.modkey

awful.keygrabber {
  keybindings        = {
    awful.key {
      modifiers = { "Mod1" },
      key = "Tab",
      on_press = function()
        awesome.emit_signal("window_switcher::select_next")
      end
    }
  },
  root_keybindings   = {
    awful.key {
      modifiers = { "Mod1" },
      key = "Tab",
      on_press = function()
      end
    }
  },
  stop_key           = "Mod1",
  stop_event         = "release",
  start_callback     = function()
    awesome.emit_signal("toggle_window_switcher")
  end,
  stop_callback      = function()
    awesome.emit_signal("window_switcher::raise")
    awesome.emit_signal("toggle_window_switcher")
  end,
  export_keybindings = true,
}

return gears.table.join(
  awful.key(
    { modkey },
    "#39",
    hotkeys_popup.show_help,
    { description = "Cheat sheet", group = "Awesome" }
  ),
  -- Tag browsing
  awful.key(
    { modkey },
    "#113",
    awful.tag.viewprev,
    { description = "View previous tag", group = "Tag" }
  ),
  awful.key(
    { modkey },
    "#114",
    awful.tag.viewnext,
    { description = "View next tag", group = "Tag" }
  ),
  awful.key(
    { modkey },
    "#66",
    awful.tag.history.restore,
    { description = "Go back to last tag", group = "Tag" }
  ),
  awful.key(
    { modkey },
    "#44",
    function()
      awful.client.focus.byidx(1)
    end,
    { description = "Focus next client by index", group = "Client" }
  ),
  awful.key(
    { modkey },
    "#45",
    function()
      awful.client.focus.byidx(-1)
    end,
    { description = "Focus previous client by index", group = "Client" }
  ),
  awful.key(
    { modkey, "Shift" },
    "#44",
    function()
      awful.client.swap.byidx(1)
    end,
    { description = "Swap with next client by index", group = "Client" }
  ),
  awful.key(
    { modkey, "Shift" },
    "#45",
    function()
      awful.client.swap.byidx(-1)
    end,
    { description = "Swap with previous client by index", group = "Client" }
  ),
  awful.key(
    { modkey, "Control" },
    "#44",
    function()
      awful.screen.focus_relative(1)
    end,
    { description = "Focus the next screen", group = "Screen" }
  ),
  awful.key(
    { modkey, "Control" },
    "#45",
    function()
      awful.screen.focus_relative(-1)
    end,
    { description = "Focus the previous screen", group = "Screen" }
  ),
  awful.key(
    { modkey },
    "#30",
    awful.client.urgent.jumpto,
    { description = "Jump to urgent client", group = "Client" }
  ),
  awful.key(
    { modkey },
    "#36",
    function()
      awful.spawn(User_config.terminal)
    end,
    { description = "Open terminal", group = "Applications" }
  ),
  awful.key(
    { modkey, "Control" },
    "#27",
    awesome.restart,
    { description = "Reload awesome", group = "Awesome" }
  ),
  awful.key(
    { modkey },
    "#46",
    function()
      awful.tag.incmwfact(0.05)
    end,
    { description = "Increase client width", group = "Layout" }
  ),
  awful.key(
    { modkey },
    "#43",
    function()
      awful.tag.incmwfact(-0.05)
    end,
    { description = "Decrease client width", group = "Layout" }
  ),
  awful.key(
    { modkey, "Control" },
    "#43",
    function()
      awful.tag.incncol(1, nil, true)
    end,
    { description = "Increase the number of columns", group = "Layout" }
  ),
  awful.key(
    { modkey, "Control" },
    "#46",
    function()
      awful.tag.incncol(-1, nil, true)
    end,
    { description = "Decrease the number of columns", group = "Layout" }
  ),
  awful.key(
    { modkey, "Shift" },
    "#65",
    function()
      awful.layout.inc(-1)
    end,
    { description = "Select previous layout", group = "Layout" }
  ),
  awful.key(
    { modkey, "Shift" },
    "#36",
    function()
      awful.layout.inc(1)
    end,
    { description = "Select next layout", group = "Layout" }
  ),
  awful.key(
    { modkey },
    "#40",
    function()
      awesome.emit_signal("application_launcher::show")
    end,
    { descripton = "Application launcher", group = "Application" }
  ),
  awful.key(
    { modkey },
    "#26",
    function()
      awful.spawn(User_config.file_manager)
    end,
    { descripton = "Open file manager", group = "System" }
  ),
  awful.key(
    { modkey, "Shift" },
    "#26",
    function()
      awesome.emit_signal("module::powermenu:show")
    end,
    { descripton = "Session options", group = "System" }
  ),
  awful.key(
    {},
    "#107",
    function()
      awful.spawn(User_config.screenshot_program)
    end,
    { description = "Screenshot", group = "Applications" }
  ),
  awful.key(
    {},
    "XF86AudioLowerVolume",
    function(c)
      awful.spawn.easy_async_with_shell("pactl set-sink-volume @DEFAULT_SINK@ -2%", function()
        awesome.emit_signal("widget::volume_osd:rerun")
      end)
    end,
    { description = "Lower volume", group = "System" }
  ),
  awful.key(
    {},
    "XF86AudioRaiseVolume",
    function(c)
      awful.spawn.easy_async_with_shell("pactl set-sink-volume @DEFAULT_SINK@ +2%", function()
        awesome.emit_signal("widget::volume_osd:rerun")
      end)
    end,
    { description = "Increase volume", group = "System" }
  ),
  awful.key(
    {},
    "XF86AudioMute",
    function(c)
      awful.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle")
      awesome.emit_signal("widget::volume_osd:rerun")
    end,
    { description = "Mute volume", group = "System" }
  ),
  awful.key(
    {},
    "XF86MonBrightnessUp",
    function(c)
      awful.spawn.easy_async_with_shell(
        "pkexec xfpm-power-backlight-helper --get-brightness",
        function(stdout)
          awful.spawn("pkexec xfpm-power-backlight-helper --set-brightness " ..
            tostring(tonumber(stdout) + BACKLIGHT_SEPS))
          awesome.emit_signal("brightness::update")
        end
      )
    end,
    { description = "Raise backlight brightness", group = "System" }
  ),
  awful.key(
    {},
    "XF86MonBrightnessDown",
    function(c)
      awful.spawn.easy_async_with_shell(
        "pkexec xfpm-power-backlight-helper --get-brightness",
        function(stdout)
          awful.spawn(
            "pkexec xfpm-power-backlight-helper --set-brightness " ..
            tostring(tonumber(stdout) - BACKLIGHT_SEPS))
          awesome.emit_signal("brightness::update")
        end
      )
    end,
    { description = "Lower backlight brightness", group = "System" }
  ),
  awful.key(
    {},
    "XF86AudioPlay",
    function(c)
      awful.spawn("playerctl play-pause")
    end,
    { description = "Play / Pause audio", group = "System" }
  ),
  awful.key(
    {},
    "XF86AudioNext",
    function(c)
      awful.spawn("playerctl next")
    end,
    { description = "Play / Pause audio", group = "System" }
  ),
  awful.key(
    {},
    "XF86AudioPrev",
    function(c)
      awful.spawn("playerctl previous")
    end,
    { description = "Play / Pause audio", group = "System" }
  ),
  awful.key(
    { modkey },
    "#65",
    function()
      awesome.emit_signal("kblayout::toggle")
    end,
    { description = "Toggle keyboard layout", group = "System" }
  ),
  awful.key(
    { modkey },
    "#22",
    function()
      awful.spawn.easy_async_with_shell(
        [[xprop | grep WM_CLASS | awk '{gsub(/"/, "", $4); print $4}']],
        function(stdout)
          if stdout then
            ruled.client.append_rule {
              rule = { class = stdout:gsub("\n", "") },
              properties = {
                floating = true
              },
            }
            awful.spawn.easy_async_with_shell(
              "cat ~/.config/awesome/src/assets/cache/rules.txt",
              function(stdout2)
                for class in stdout2:gmatch("%a+") do
                  if class:match(stdout:gsub("\n", "")) then
                    return
                  end
                end
                awful.spawn.with_shell("echo -n '" ..
                  stdout:gsub("\n", "") .. ";' >> ~/.config/awesome/src/assets/cache/rules.txt")
                local c = mouse.screen.selected_tag:clients()
                for _, client in ipairs(c) do
                  if client.class:match(stdout:gsub("\n", "")) then
                    client.floating = true
                  end
                end
              end
            )
          end
        end
      )
    end
  ),
  awful.key(
    { modkey, "Shift" },
    "#22",
    function()
      awful.spawn.easy_async_with_shell(
        [[xprop | grep WM_CLASS | awk '{gsub(/"/, "", $4); print $4}']],
        function(stdout)
          if stdout then
            ruled.client.append_rule {
              rule = { class = stdout:gsub("\n", "") },
              properties = {
                floating = false
              },
            }
            awful.spawn.easy_async_with_shell(
              [[
                REMOVE="]] .. stdout:gsub("\n", "") .. [[;"
                STR=$(cat ~/.config/awesome/src/assets/cache/rules.txt)
                echo -n ${STR//$REMOVE/} > ~/.config/awesome/src/assets/cache/rules.txt
              ]],
              function()
                local c = mouse.screen.selected_tag:clients()
                for _, client in ipairs(c) do
                  if client.class:match(stdout:gsub("\n", "")) then
                    client.floating = false
                  end
                end
              end
            )
          end
        end
      )
    end
  )
)
