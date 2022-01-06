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

    local function create_dock_element (program, name, size)

        local function create_indicator()
            local color = ""
            local indicators = {layout = wibox.layout.flex.horizontal}
            local t = 2
            local naughty = require("naughty")
            for i, indicator_screen in ipairs(screen) do
                for j, indicator_client in ipairs(indicator_screen.clients) do
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
                            forced_height = dpi(5),
                            bg = color
                        }
                        indicators[t] = indicator
                        t = t + 1
                    end
                end
            end
            return indicators
        end

        local dock_element = wibox.widget{
            {
                {
                    {
                        {
                            resize = true,
                            forced_width = size,
                            forced_height = size,
                            image = Get_icon_by_class_name("Papirus-Dark",program),
                            widget = wibox.widget.imagebox
                        },
                        create_indicator(),
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
                awful.spawn(program)
            end
        )

        local dock_tooltip = awful.tooltip{
            objects = {dock_element},
            text = name,
            mode = "outside",
            preferred_alignments = "middle",
            margins = dpi(10)
        }
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
            dock_elements[i] = create_dock_element(p[1], p[2], user_vars.vars.dock_icon_size)
        end

        return dock_elements
    end

    dock:setup {
        get_dock_elements(programs),
        layout = wibox.layout.fixed.vertical
    }

    -- TODO: This function runs only every second, it can be optimized by
    -- calling it every time the mouse is over the dock, a client changes it states ...
    -- but im too lazy rn
    local function check_for_dock_hide()
        for i, screen in ipairs(screen) do
            local mx, my = mouse.coords().x * 100 / screen.geometry.width, mouse.coords().y * 100 / screen.geometry.height
            if ((mx > 30) and (mx < 70)) and (my > 95) then
                dock.visible = true
                break;
            end
            for j, c in ipairs(screen.clients) do
                local y = c:geometry().y
                local h = c.height
                if (y + h) >= screen.geometry.height - user_vars.vars.dock_icon_size - 35 then
                    dock.visible = false
                    break;
                else
                    dock.visible = true
                end
            end
        end
    end
    local naughty = require("naughty")
    awesome.connect_signal(
        "manage",
        function ()
            naughty.notify({title = "hi"})
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
end