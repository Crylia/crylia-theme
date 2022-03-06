--------------------------------------------------------------------------------------------------------------
-- This is the statusbar, every widget, module and so on is combined to all the stuff you see on the screen --
--------------------------------------------------------------------------------------------------------------
-- Awesome Libs
local awful = require("awful")
local colors = require ("theme.crylia.colors")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")

return function(s, programs)

    local function create_dock_element (program, name, is_steam, size)
        is_steam = is_steam or false

        local dock_element = wibox.widget{
            {
                {
                    {
                        {
                            resize = true,
                            forced_width = size,
                            forced_height = size,
                            image = Get_icon("Papirus-Dark",program, is_steam),
                            widget = wibox.widget.imagebox
                        },
                        {
                            widget = nil,
                            layout = wibox.layout.align.horizontal,
                            id = "indicator"
                        },
                        layout = wibox.layout.align.vertical,
                        id = "dock_layout"
                    },
                    margins = dpi(5),
                    widget = wibox.container.margin,
                    id = "margin"
                },
                shape = function (cr, width, height)
                    gears.shape.rounded_rect(cr, width, height, 10)
                end,
                bg = colors.color["Grey900"],
                widget = wibox.container.background,
                id = "background"
            },
            margins = dpi(5),
            widget = wibox.container.margin
        }

        hover_signal(dock_element.background, colors.color["Grey800"], colors.color["White"])

        dock_element:connect_signal(
            "button::press",
            function ()
                if is_steam then
                    awful.spawn("steam steam://rungameid/" .. program)
                else
                    awful.spawn(program)
                end
            end
        )

        awful.tooltip {
            objects = {dock_element},
            text = name,
            mode = "outside",
            preferred_alignments = "middle",
            margins = dpi(10)
        }

        local function create_indicator()
            local color = ""
            local indicators
            local t = 1
            for indicator_screen in screen do
                for j,indicator_client in ipairs(indicator_screen.get_clients()) do
                    if indicator_client.class == program then
                        if indicator_client.maximized then
                            color = colors.color["Green200"]
                        elseif indicator_client.fullscreen then
                            color = colors.color["Red200"]
                        elseif indicator_client.focus then
                            color = colors.color["Blue200"]
                        elseif indicator_client.minimised then
                            color = colors.color["Pink200"]
                        else
                            color = colors.color["White"]
                        end

                        local indicator = wibox.widget{
                            widget = wibox.container.background,
                            shape = gears.shape.circle,
                            forced_height = dpi(50),
                            bg = color
                        }
                        indicators.add(indicator)
                        t = t + 1
                    end
                end
            end
            return indicators
        end

        dock_element.background.margin.dock_layout.indicator = create_indicator()

        return dock_element
    end

    local dock = awful.popup{
        widget = wibox.container.background,
        ontop = true,
        bg = colors.color["Grey900"],
        visible = true,
        screen = s,
        type = "dock",
        height = user_vars.vars.dock_icon_size + 10,
        placement = function(c) awful.placement.bottom(c, {margins = dpi(10)}) end,
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 15)
        end
    }

    local function get_dock_elements(pr)
        local dock_elements = {layout = wibox.layout.fixed.horizontal}

        for i, p in ipairs(pr) do
            dock_elements[i] = create_dock_element(p[1], p[2], p[3], user_vars.vars.dock_icon_size)
        end

        return dock_elements
    end

    dock:setup {
        get_dock_elements(programs),
        layout = wibox.layout.fixed.vertical
    }
    local naughty = require("naughty")
    --[[ TODO: This function runs every 0.1 second, it can be optimized by
    calling it every time the mouse is over the dock, a client changes it states ...
    but im too lazy rn ]]
    local function check_for_dock_hide()
        for s in screen do
            local mx, my = mouse.coords().x * 100 / s.geometry.width, mouse.coords().y * 100 / s.geometry.height
            if ((mx > 30) and (mx < 70)) and (my > 99) then
                dock.visible = true
                break;
            end
            for j,c in ipairs(s.get_clients()) do
                local y = c:geometry().y
                local h = c.height
                if (y + h) >= s.geometry.height - user_vars.vars.dock_icon_size - 35 then
                    dock.visible = false
                    break;
                else
                    dock.visible = true
                end
            end
        end
    end

    client.connect_signal(
        "manage",
        function ()
            check_for_dock_hide()
        end
    )

    local dock_intelligent_hide = gears.timer{
        timeout = 1,
        autostart = true,
        call_now = true,
        callback = function ()
            check_for_dock_hide()
        end
    }

    dock:connect_signal(
        "mouse::enter",
        function ()
            dock_intelligent_hide:stop()
        end
    )

    dock:connect_signal(
        "mouse::leave",
        function ()
            dock_intelligent_hide:again()
        end
    )
end
