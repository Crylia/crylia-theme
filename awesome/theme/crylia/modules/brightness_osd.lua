---------------------------------------
-- This is the brightness_osd module --
---------------------------------------

-- Awesome Libs
local awful = require("awful")
local color = require("theme.crylia.colors")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")

-- Icon directory path
local icondir = awful.util.getdir("config") .. "theme/crylia/assets/icons/brightness/"

-- TODO: fix backlight keys and osd not working correctly
return function (s)

    local brightness_osd_widget = wibox.widget{
        {
            {
                {
                    {
                        id = "label",
                        text = "Brightness",
                        align = "left",
                        valign = "center",
                        widget = wibox.widget.textbox
                    },
                    nil,
                    {
                        id = "value",
                        text = "0%",
                        align = "center",
                        valign = "center",
                        widget = wibox.widget.textbox
                    },
                    id = "label_value_layout",
                    forced_height = dpi(48),
                    layout = wibox.layout.align.horizontal,
                },
                {
                    {
                        {
                            id = "icon",
                            image = gears.color.recolor_image(icondir .. "brightness-high.svg", color.color["White"]),
                            widget = wibox.widget.imagebox
                        },
                        id = "icon_margin",
                        top = dpi(12),
                        bottom = dpi(12),
                        widget = wibox.container.margin
                    },
                    {
                        {
                            id = "brightness_slider",
                            bar_shape = gears.shape.rounded_rect,
                            bar_height = dpi(2),
                            bar_color = color.color["White"],
                            bar_active_color = color.color["White"],
                            handle_color = color.color["White"],
                            handle_shape = gears.shape.circle,
                            handle_width = dpi(15),
                            handle_border_color = color.color["White"],
                            handle_border_width = dpi(1),
                            maximum = 100,
                            widget = wibox.widget.slider
                        },
                        id = "slider_layout",
                        forced_height = dpi(24),
                        widget = wibox.container.place
                    },
                    id = "icon_slider_layout",
                    spacing = dpi(24),
                    layout = wibox.layout.fixed.horizontal
                },
                id = "osd_layout",
                layout = wibox.layout.fixed.vertical
            },
            id = "container",
            left = dpi(24),
            right = dpi(24),
            widget = wibox.container.margin
        },
        bg = color.color["Grey900"],
        widget = wibox.container.background,
        ontop = true,
        visible = true,
        type = "notification",
        forced_height = dpi(100),
        forced_width = dpi(300),
        offset = dpi(5),
    }

    brightness_osd_widget.container.osd_layout.icon_slider_layout.slider_layout.brightness_slider:connect_signal(
        "property::value",
        function ()
            local brightness_value = brightness_osd_widget.container.osd_layout.icon_slider_layout.slider_layout.brightness_slider:get_value()
            -- Performance is horrible, or it overrides and executes at the same time as the keybindings
            --awful.spawn("xbacklight -set " .. brightness_value, false)
            brightness_osd_widget.container.osd_layout.label_value_layout.value:set_text(brightness_value .. "%")

            awesome.emit_signal(
                "widget::brightness:update",
                brightness_value
            )

            if awful.screen.focused().show_brightness_osd then
                awesome.emit_signal(
                    "module::brightness_osd:show",
                    true
                )
            end

            local icon = icondir .. "brightness"
            if brightness_value >= 0 and brightness_value < 34 then
                icon = icon .. "-low"
            elseif brightness_value >= 34 and brightness_value < 67 then
                icon = icon .. "-medium"
            elseif brightness_value >= 67 then
                icon = icon .. "-high"
            end
            brightness_osd_widget.container.osd_layout.icon_slider_layout.icon_margin.icon:set_image(gears.color.recolor_image(icon .. ".svg", color.color["White"]))
        end
    )

    local update_slider = function ()
        awful.spawn.easy_async_with_shell(
            [[ xbacklight -get ]],
            function (stdout)
                stdout = stdout:sub(1,-9)
                brightness_osd_widget.container.osd_layout.icon_slider_layout.slider_layout.brightness_slider:set_value(tonumber(stdout))
            end
        )
    end

    awesome.connect_signal(
        "module::brightness_slider:update",
        function ()
            update_slider()
        end
    )

    awesome.connect_signal(
        "widget::brightness:update",
        function (value)
            brightness_osd_widget.container.osd_layout.icon_slider_layout.slider_layout.brightness_slider:set_value(tonumber(value))
        end
    )

    update_slider()

    local brightness_container = awful.popup{
        widget = wibox.container.background,
        ontop = true,
        bg = color.color["Grey900"],
        stretch = false,
        visible = false,
        placement = function (c) awful.placement.bottom_right(c, {margins = dpi(10)}) end,
        shape = function (cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 5)
        end
    }

    local hide_brightness_osd = gears.timer{
        timeout = 1,
        autostart = true,
        callback = function ()
            brightness_container.visible = false
        end
    }

    brightness_container:setup{
        brightness_osd_widget,
        layout = wibox.layout.fixed.horizontal
    }

    awesome.connect_signal(
        "widget::brightness_osd:rerun",
        function ()
            if hide_brightness_osd.started then
                hide_brightness_osd:again()
            else
                hide_brightness_osd:start()
            end
        end
    )

    awesome.connect_signal(
        "module::brightness_osd:show",
        function ()
            brightness_container.visible = true
        end
    )

    brightness_container:connect_signal(
        "mouse::enter",
        function ()
            brightness_container.visible = true
            hide_brightness_osd:stop()
        end
    )

    brightness_container:connect_signal(
        "mouse::leave",
        function ()
            brightness_container.visible = true
            hide_brightness_osd:again()
        end
    )
end