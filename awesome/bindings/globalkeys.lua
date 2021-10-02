-- Awesome Libs
local gears = require("gears")
local awful = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup")

-- Resource Configuration
local modkey = RC.vars.modkey
local terminal = RC.vars.terminal

local _M = {}

function _M.get()
    local globalkeys = gears.table.join(
        awful.key(
            { modkey },
            "s",
            hotkeys_popup.show_help,
            {description="Cheet Sheet", group="Awesome"}
        ),
        -- Tag browsing
        awful.key(
            { modkey },
            "Left",
            awful.tag.viewprev,
            {description = "View previous", group = "Tag"}
        ),
        awful.key(
            { modkey },
            "Right",
            awful.tag.viewnext,
            {description = "View next", group = "Tag"}
        ),
        awful.key(
            { modkey },
            "Escape",
            awful.tag.history.restore,
            {description = "Go back", group = "Tag"}
        ),
        awful.key(
            { modkey },
            "j",
            function ()
                awful.client.focus.byidx( 1)
            end,
            {description = "Focus next by index", group = "Client"}
        ),
        awful.key(
            { modkey },
            "k",
            function ()
                awful.client.focus.byidx(-1)
            end,
            {description = "Focus previous by index", group = "Client"}
        ),
        awful.key(
            { modkey },
            "w",
            function () 
                RC.mainmenu:show()
            end,
            {description = "Show main menu", group = "Awesome"}
        ),
        awful.key(
            { modkey, "Shift" },
            "j",
            function () 
                awful.client.swap.byidx(  1)
            end,
            {description = "Swap with next client by index", group = "Client"}
        ),
        awful.key(
            { modkey, "Shift" },
            "k",
            function ()
                awful.client.swap.byidx( -1)
            end,
            {description = "Swap with previous client by index", group = "Client"}
        ),
        awful.key(
            { modkey, "Control" },
            "j",
            function () 
                awful.screen.focus_relative( 1)
            end,
            {description = "Focus the next screen", group = "Screen"}
        ),
        awful.key(
            { modkey, "Control" },
            "k",
            function () 
                awful.screen.focus_relative(-1)
            end,
            {description = "Focus the previous screen", group = "Screen"}
        ),
        awful.key(
            { modkey },
            "u",
            awful.client.urgent.jumpto,
            {description = "Jump to urgent client", group = "Client"}),
        awful.key(
            { modkey },
            "Tab",
            function ()
                awful.client.focus.history.previous()
                if client.focus then
                    client.focus:raise()
                end
            end,
            {description = "Go back", group = "Client"}
        ),
        awful.key(
            { modkey },
            "Return",
            function ()
                awful.spawn(terminal)
            end,
            {description = "Open terminal", group = "Launcher"}
        ),
        awful.key(
            { modkey, "Control" },
            "r",
            awesome.restart,
            {description = "Reload awesome", group = "Awesome"}
        ),
        awful.key(
            { modkey },
            "l",
            function ()
                awful.tag.incmwfact( 0.05)
            end,
            {description = "Increase master width factor", group = "Layout"}
        ),
        awful.key(
            { modkey },
            "h",
            function ()
                awful.tag.incmwfact(-0.05)
            end,
            {description = "Decrease master width factor", group = "Layout"}
        ),
        awful.key(
            { modkey, "Shift" },
            "h",
            function ()
                awful.tag.incnmaster( 1, nil, true)
            end,
            {description = "Increase the number of master clients", group = "Layout"}
        ),
        awful.key(
            { modkey, "Shift" },
            "l",
            function ()
                awful.tag.incnmaster(-1, nil, true)
            end,
            {description = "Decrease the number of master clients", group = "Layout"}
        ),
        awful.key(
            { modkey, "Control" },
            "h",
            function ()
                awful.tag.incncol( 1, nil, true)
            end,
            {description = "Increase the number of columns", group = "Layout"}
        ),
        awful.key(
            { modkey, "Control" },
            "l",
            function ()
                awful.tag.incncol(-1, nil, true)
            end,
            {description = "Decrease the number of columns", group = "Layout"}
        ),
        awful.key(
            { modkey },
            "space",
            function ()
                awful.layout.inc( 1)
            end,
            {description = "Select next", group = "Layout"}
        ),
        awful.key(
            { modkey, "Shift" },
            "space",
            function ()
                awful.layout.inc(-1)
            end,
            {description = "Select previous", group = "Layout"}
        ),
        awful.key(
            { modkey, "Control" },
            "n",
            function ()
                local c = awful.client.restore()
                -- Focus restored client
                if c then
                    c:emit_signal(
                        "request::activate", "key.unminimize", {raise = true}
                    )
                end
            end,
            {description = "Restore minimized", group = "Client"}
        ),
        awful.key(
            { modkey, "Control" },
            "Up",
            function ()
                awful.client.moveresize( 0, 0, 0, -20)
            end
        ),
        awful.key(
            { modkey, "Control" },
            "Down",
            function ()
                awful.client.moveresize( 0, 0, 0,  20)
            end
        ),
        awful.key(
            { modkey, "Control" },
            "Left",
            function ()
                awful.client.moveresize( 0, 0, -20, 0)
            end
        ),
        awful.key(
            { modkey, "Control" },
            "Right",
            function ()
                awful.client.moveresize( 0, 0,  20, 0)
            end
        ),
        awful.key(
            { modkey, "Shift" },
            "Down",
            function ()
                awful.client.moveresize( 0, 20, 0, 0)
            end
        ),
        awful.key(
            { modkey, "Shift" },
            "Up",
            function ()
                awful.client.moveresize( 0, -20, 0, 0)
            end
        ),
        awful.key(
            { modkey, "Shift" },
            "Left",
            function ()
                awful.client.moveresize(-20,   0,   0,   0)
            end
        ),
        awful.key(
            { modkey, "Shift" },
            "Right",
            function ()
                awful.client.moveresize( 20,   0,   0,   0)
            end
        ),
        awful.key(
	        { modkey },
	        "d",
	        function ()
	        	awful.spawn("rofi -show drun -theme ~/.config/rofi/appmenu/rofi.rasi")
	        end,
	        { descripton = "Start a Application", group = "Application" }
	    ),
        awful.key(
	        { modkey },
	        "Tab",
	        function ()
	        	awful.spawn("rofi -show window -theme ~/.config/rofi/appmenu/rofi.rasi")
	        end,
	        { descripton = "Start a Application", group = "Application" }
	    ),
        awful.key(
	        { modkey },
	        "e",
	        function ()
	        	awful.spawn('nautilus')
	        end,
	        { descripton = "Start a Application", group = "Application" }
	    ),
        awful.key(
            { },
            "Print",
            function ()
                awful.spawn("flameshot gui")
            end
        ),
        awful.key(
            { },
            "XF86AudioLowerVolume",
            function (c)
                awful.spawn("amixer sset Master 5%-")
                awesome.emit_signal("widget::volume")
                awesome.emit_signal("module::volume_osd:show", true)
                awesome.emit_signal("module::slider:update")
                awesome.emit_signal("widget::volume_osd:rerun")
            end
        ),
        awful.key(
            { },
            "XF86AudioRaiseVolume",
            function (c)
                awful.spawn("amixer sset Master 5%+")
                awesome.emit_signal("widget::volume")
                awesome.emit_signal("module::volume_osd:show", true)
                awesome.emit_signal("module::slider:update")
                awesome.emit_signal("widget::volume_osd:rerun")
            end
        ),
        awful.key(
            { },
            "XF86AudioMute",
            function (c)
                awful.spawn("pactl -- set-sink-mute @DEFAULT_SINK@ toggle")
                awesome.emit_signal("widget::volume")
                awesome.emit_signal("module::volume_osd:show", true)
                awesome.emit_signal("module::slider:update")
                awesome.emit_signal("widget::volume_osd:rerun")

            end
        ),
        awful.key(
            { modkey },
            "F5",
            function (c)
                awful.spawn("xbacklight -inc 10")
                awesome.emit_signal("module::brightness_osd:show", true)
                awesome.emit_signal("module::brightness_slider:update")
                awesome.emit_signal("widget::brightness_osd:rerun")
            end
        ),
        awful.key(
            { modkey },
            "F4",
            function (c)
                awful.spawn("xbacklight -dec 10")
                awesome.emit_signal("module::brightness_osd:show", true)
                awesome.emit_signal("module::brightness_slider:update")
                awesome.emit_signal("widget::brightness_osd:rerun")
            end
        ),
        awful.key(
            { modkey, "Shift" },
            "q",
            function ()
                local t = awful.screen.focused().selected_tag
                t:delete()
            end
        )
    )

  return globalkeys
end

return setmetatable({ }, { __call = function(_, ...) return _M.get(...) end })