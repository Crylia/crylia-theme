-- Awesome libs
local gears = require("gears")
local awful = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup")
local ruled = require("ruled")

-- Third party libs
local json = require("src.lib.json-lua.json-lua")

-- Own libs
local backlight_helper = require("src.tools.helpers.backlight")

local capi = {
  awesome = awesome,
  mousegrabber = mousegrabber,
  mouse = mouse,
}

local modkey = User_config.modkey

awful.keygrabber {
  keybindings        = {
    awful.key {
      modifiers = { "Mod1" },
      key = "Tab",
      on_press = function()
        capi.awesome.emit_signal("window_switcher::select_next")
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
    capi.awesome.emit_signal("toggle_window_switcher")
  end,
  stop_callback      = function()
    capi.awesome.emit_signal("window_switcher::raise")
    capi.awesome.emit_signal("toggle_window_switcher")
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
    capi.awesome.restart,
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
      capi.awesome.emit_signal("application_launcher::show")
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
      capi.awesome.emit_signal("module::powermenu:show")
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
        capi.awesome.emit_signal("widget::volume_osd:rerun")
      end)
    end,
    { description = "Lower volume", group = "System" }
  ),
  awful.key(
    {},
    "XF86AudioRaiseVolume",
    function(c)
      awful.spawn.easy_async_with_shell("pactl set-sink-volume @DEFAULT_SINK@ +2%", function()
        capi.awesome.emit_signal("widget::volume_osd:rerun")
      end)
    end,
    { description = "Increase volume", group = "System" }
  ),
  awful.key(
    {},
    "XF86AudioMute",
    function(c)
      awful.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle")
      capi.awesome.emit_signal("widget::volume_osd:rerun")
    end,
    { description = "Mute volume", group = "System" }
  ),
  awful.key(
    {},
    "XF86MonBrightnessUp",
    function(c)
      backlight_helper.brightness_increase()
    end,
    { description = "Raise backlight brightness", group = "System" }
  ),
  awful.key(
    {},
    "XF86MonBrightnessDown",
    function(c)
      backlight_helper.brightness_decrease()
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
      capi.awesome.emit_signal("kblayout::toggle")
    end,
    { description = "Toggle keyboard layout", group = "System" }
  ),
  awful.key(
    { modkey },
    "#22",
    function()
      capi.mousegrabber.run(
        function(m)
          if m.buttons[1] then

            local handler = io.open("/home/crylia/.config/awesome/src/config/floating.json", "r")
            if not handler then return end
            local data_table = json:decode(handler:read("a")) or {}
            handler:close()

            if type(data_table) ~= "table" then return end

            local c = capi.mouse.current_client
            if not c then return end

            local client_data = {
              WM_NAME = c.name,
              WM_CLASS = c.class,
              WM_INSTANCE = c.instance,
            }

            -- Check if data_table already had the client then return
            for _, v in ipairs(data_table) do
              if v.WM_NAME == client_data.WM_NAME and
                  v.WM_CLASS == client_data.WM_CLASS and
                  v.WM_INSTANCE == client_data.WM_INSTANCE then
                return
              end
            end

            table.insert(data_table, client_data)

            ruled.client.append_rule {
              rule = { class = c.class, instance = c.instance },
              properties = {
                floating = true
              },
            }
            c.floating = true

            handler = io.open("/home/crylia/.config/awesome/src/config/floating.json", "w")
            if not handler then return end
            handler:write(json:encode(data_table))
            handler:close()
            capi.mousegrabber.stop()
          end
          return true
        end,
        "crosshair"
      )
    end
  ),
  awful.key(
    { modkey, "Shift" },
    "#22",
    function()
      capi.mousegrabber.run(
        function(m)
          if m.buttons[1] then

            local handler = io.open("/home/crylia/.config/awesome/src/config/floating.json", "r")
            if not handler then return end
            local data_table = json:decode(handler:read("a")) or {}
            handler:close()

            if type(data_table) ~= "table" then return end

            local c = capi.mouse.current_client
            if not c then return end

            local client_data = {
              WM_NAME = c.name,
              WM_CLASS = c.class,
              WM_INSTANCE = c.instance,
            }

            -- Remove client_data from data_table
            for k, v in ipairs(data_table) do
              if v.WM_CLASS == client_data.WM_CLASS and
                  v.WM_INSTANCE == client_data.WM_INSTANCE then
                table.remove(data_table, k)
                ruled.client.remove_rule {
                  rule = { class = c.class, instance = c.instance },
                  properties = {
                    floating = true
                  },
                }
                c.floating = false
                break
              end
            end

            handler = io.open("/home/crylia/.config/awesome/src/config/floating.json", "w")
            if not handler then return end
            handler:write(json:encode(data_table))
            handler:close()
            capi.mousegrabber.stop()
          end
          return true
        end,
        "crosshair"
      )
    end
  )
)
