local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local dpi = require("beautiful").xresources.apply_dpi
local color = require("src.theme.colors")
require("src.tools.icon_handler")

local list_update = function(widget, buttons, label, data, objects)
    widget:reset()

    for i, object in ipairs(objects) do

        local tag_icon = wibox.widget {
            nil,
            {
                id = "icon",
                resize = true,
                widget = wibox.widget.imagebox
            },
            nil,
            layout = wibox.layout.align.horizontal
        }

        local tag_icon_margin = wibox.widget {
            tag_icon,
            forced_width = dpi(33),
            margins = dpi(3),
            widget = wibox.container.margin
        }

        local tag_label = wibox.widget {
            text = "",
            align = "center",
            valign = "center",
            visible = true,
            font = user_vars.font.extrabold,
            forced_width = dpi(25),
            widget = wibox.widget.textbox
        }

        local tag_label_margin = wibox.widget {
            tag_label,
            left = dpi(5),
            right = dpi(5),
            widget = wibox.container.margin
        }

        local tag_widget = wibox.widget {

            id = "widget_margin",
            {
                id = "container",
                tag_label_margin,
                layout = wibox.layout.fixed.horizontal
            },

            fg = color["White"],
            shape = function(cr, width, height)
                gears.shape.rounded_rect(cr, width, height, 5)
            end,
            widget = wibox.container.background
        }

        local function create_buttons(buttons, object)
            if buttons then
                local btns = {}
                for _, b in ipairs(buttons) do
                    local btn = awful.button {
                        modifiers = b.modifiers,
                        button = b.button,
                        on_press = function()
                            b:emit_signal('press', object)
                        end,
                        on_release = function()
                            b:emit_signal('release', object)
                        end
                    }
                    btns[#btns + 1] = btn
                end
                return btns
            end
        end

        tag_widget:buttons(create_buttons(buttons, object))

        local text, bg_color, bg_image, icon, args = label(object, tag_label)
        tag_label:set_text(object.index)
        if object.urgent == true then
            tag_widget:set_bg(color["RedA200"])
            tag_widget:set_fg(color["Grey900"])
        elseif object == awful.screen.focused().selected_tag then
            tag_widget:set_bg(color["White"])
            tag_widget:set_fg(color["Grey900"])
        else
            tag_widget:set_bg("#3A475C")
        end

        -- Set the icon for each client
        for _, client in ipairs(object:clients()) do
            tag_label_margin:set_right(0)
            local icon = wibox.widget {
                {
                    id = "icon_container",
                    {
                        id = "icon",
                        resize = true,
                        widget = wibox.widget.imagebox
                    },
                    widget = wibox.container.place
                },
                tag_icon_margin,
                forced_width = dpi(33),
                margins = dpi(6),
                widget = wibox.container.margin
            }
            icon.icon_container.icon:set_image(Get_icon(user_vars.icon_theme, client))
            tag_widget.container:setup({
                icon,
                strategy = "exact",
                layout = wibox.container.constraint,
            })
        end

        local old_wibox, old_cursor, old_bg
        tag_widget:connect_signal(
            "mouse::enter",
            function()
                old_bg = tag_widget.bg
                if object == awful.screen.focused().selected_tag then
                    tag_widget.bg = '#dddddd' .. 'dd'
                else
                    tag_widget.bg = '#3A475C' .. 'dd'
                end
                local w = mouse.current_wibox
                if w then
                    old_cursor, old_wibox = w.cursor, w
                    w.cursor = "hand1"
                end
            end
        )

        tag_widget:connect_signal(
            "button::press",
            function()
                if object == awful.screen.focused().selected_tag then
                    tag_widget.bg = '#bbbbbb' .. 'dd'
                else
                    tag_widget.bg = '#3A475C' .. 'dd'
                end
            end
        )

        tag_widget:connect_signal(
            "button::release",
            function()
                if object == awful.screen.focused().selected_tag then
                    tag_widget.bg = '#dddddd' .. 'dd'
                else
                    tag_widget.bg = '#3A475C' .. 'dd'
                end
            end
        )

        tag_widget:connect_signal(
            "mouse::leave",
            function()
                tag_widget.bg = old_bg
                if old_wibox then
                    old_wibox.cursor = old_cursor
                    old_wibox = nil
                end
            end
        )

        widget:add(tag_widget)
        widget:set_spacing(dpi(6))
    end
end

local tag_list = function(s)
    return awful.widget.taglist(
        s,
        awful.widget.taglist.filter.noempty,
        gears.table.join(
            awful.button(
                {},
                1,
                function(t)
                    t:view_only()
                end
            ),
            awful.button(
                { modkey },
                1,
                function(t)
                    if client.focus then
                        client.focus:move_to_tag(t)
                    end
                end
            ),
            awful.button(
                {},
                3,
                function(t)
                    if client.focus then
                        client.focus:toggle_tag(t)
                    end
                end
            ),
            awful.button(
                { modkey },
                3,
                function(t)
                    if client.focus then
                        client.focus:toggle_tag(t)
                    end
                end
            ),
            awful.button(
                {},
                4,
                function(t)
                    awful.tag.viewnext(t.screen)
                end
            ),
            awful.button(
                {},
                5,
                function(t)
                    awful.tag.viewprev(t.screen)
                end
            )
        ),
        {},
        list_update,
        wibox.layout.fixed.horizontal()
    )
end

return tag_list
