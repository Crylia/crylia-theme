-- Awesome Libs
local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")

screen.connect_signal(
    "added",
    function()
        awesome.restart()
    end
)

screen.connect_signal(
    "removed",
    function()
        awesome.restart()
    end
)

client.connect_signal(
    "manage",
    function(c)
        if awesome.startup and not c.size_hints.user_porition and not c.size_hints.program_position then
            awful.placement.no_offscreen(c)
        end
        c.shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 10)
        end
    end
)

client.connect_signal(
    'unmanage',
    function(c)
        if #awful.screen.focused().clients > 0 then
            awful.screen.focused().clients[1]:emit_signal(
                'request::activate',
                'mouse_enter',
                {
                    raise = true
                }
            )
        end
    end
)

client.connect_signal(
    'tag::switched',
    function(c)
        if #awful.screen.focused().clients > 0 then
            awful.screen.focused().clients[1]:emit_signal(
                'request::activate',
                'mouse_enter',
                {
                    raise = true
                }
            )
        end
    end
)


-- Sloppy focus
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

-- Workaround for focused border color, why in the love of god doesnt it work with
-- beautiful.border_focus
client.connect_signal("focus", function(c)
    c.border_color = "#616161"
end)

client.connect_signal("unfocus", function(c)
    c.border_color = beautiful.border_normal
end)

function Hover_signal(widget, bg, fg)
    local old_wibox, old_cursor, old_bg, old_fg
    widget:connect_signal(
        "mouse::enter",
        function()
            if bg then
                old_bg = widget.bg
                if string.len(bg) == 7 then
                    widget.bg = bg .. 'dd'
                else
                    widget.bg = bg
                end
            end
            if fg then
                old_fg = widget.fg
                widget.fg = fg
            end
            local w = mouse.current_wibox
            if w then
                old_cursor, old_wibox = w.cursor, w
                w.cursor = "hand1"
            end
        end
    )

    widget:connect_signal(
        "button::press",
        function()
            if bg then
                if bg then
                    if string.len(bg) == 7 then
                        widget.bg = bg .. 'bb'
                    else
                        widget.bg = bg
                    end
                end
            end
            if fg then
                widget.fg = fg
            end
        end
    )

    widget:connect_signal(
        "button::release",
        function()
            if bg then
                if bg then
                    if string.len(bg) == 7 then
                        widget.bg = bg .. 'dd'
                    else
                        widget.bg = bg
                    end
                end
            end
            if fg then
                widget.fg = fg
            end
        end
    )

    widget:connect_signal(
        "mouse::leave",
        function()
            if bg then
                widget.bg = old_bg
            end
            if fg then
                widget.fg = old_fg
            end
            if old_wibox then
                old_wibox.cursor = old_cursor
                old_wibox = nil
            end
        end
    )
end
