-----------------------------------
-- This is the volume_old module --
-----------------------------------

-- Awesome Libs
local awful = require("awful")
local color = require("theme.crylia.colors")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")

-- Icon directory path
local icondir = awful.util.getdir("config") .. "theme/crylia/assets/icons/audio/"

-- Returns the volume_osd
return function ()

    local volume_osd_widget = wibox.widget{
        {
            {
                {
                    {
                        id = "label",
                        text = "Volume",
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
                            image = gears.color.recolor_image(icondir .. "volume-high.svg", color.color["White"]),
                            widget = wibox.widget.imagebox
                        },
                        id = "icon_margin",
                        top = dpi(12),
                        bottom = dpi(12),
                        widget = wibox.container.margin
                    },
                    {
                        {
                            id = "volume_slider",
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

    volume_osd_widget.container.osd_layout.icon_slider_layout.slider_layout.volume_slider:connect_signal(
        "property::value",
        function ()
            local volume_level = volume_osd_widget.container.osd_layout.icon_slider_layout.slider_layout.volume_slider:get_value()

            awful.spawn("amixer sset Master ".. volume_level .. "%", false)
            awesome.emit_signal("widget::volume")
            volume_osd_widget.container.osd_layout.label_value_layout.value:set_text(volume_level .. "%")

            awesome.emit_signal(
                "widget::volume:update",
                volume_level
            )

            if awful.screen.focused().show_volume_osd then
                awesome.emit_signal(
                    "module::volume_osd:show",
                    true
                )
            end

            local icon = icondir .. "volume"
            if volume_level < 1 then
                icon = icon .. "-mute"
            elseif volume_level >= 1 and volume_level < 34 then
                icon = icon .. "-low"
            elseif volume_level >= 34 and volume_level < 67 then
                icon = icon .. "-medium"
            elseif volume_level >= 67 then
                icon = icon .. "-high"
            end
            volume_osd_widget.container.osd_layout.icon_slider_layout.icon_margin.icon:set_image(gears.color.recolor_image(icon .. ".svg", color.color["White"]))
        end
    )

    local update_slider = function ()
        awful.spawn.easy_async_with_shell(
            [[ awk -F"[][]" '/dB/ { print $6 }' <(amixer sget Master) ]],
            function (stdout)
                if stdout:match("off") then
                    volume_osd_widget.container.osd_layout.label_value_layout.value:set_text("0%")
                    --volume_osd_slider.volume_slider:set_value(0)
                    volume_osd_widget.container.osd_layout.icon_slider_layout.icon_margin.icon:set_image(gears.color.recolor_image(icondir .. "volume-mute" .. ".svg", color.color["White"]))
                else
                    awful.spawn.easy_async_with_shell(
                    [[ awk -F"[][]" '/dB/ { print $2 }' <(amixer sget Master) ]],
                    function (stdout)
                            stdout = stdout:sub(1, -3)
                            volume_osd_widget.container.osd_layout.icon_slider_layout.slider_layout.volume_slider:set_value(tonumber(stdout))
                        end
                    )
                end
            end
        )
    end

    -- Signals
    awesome.connect_signal(
        "module::slider:update",
        function ()
            update_slider()
        end
    )

    awesome.connect_signal(
        "widget::volume:update",
        function (value)
            volume_osd_widget.container.osd_layout.icon_slider_layout.slider_layout.volume_slider:set_value(tonumber(value))
        end
    )

    update_slider()
    return volume_osd_widget
end