-----------------------------------
-- This is the titlebar module --
-----------------------------------

-- Awesome Libs
local awful = require("awful")
local color = require("theme.crylia.colors")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")
require("Main.Signals")

-- Icon directory path
local icondir = awful.util.getdir("config") .. "theme/crylia/assets/icons/titlebar/"

awful.titlebar.enable_tooltip = true
awful.titlebar.fallback_name = 'Client'

local double_click_event_handler = function(double_click_event)
	if double_click_timer then
		double_click_timer:stop()
		double_click_timer = nil
		double_click_event()
		return
	end
	double_click_timer = gears.timer.start_new(
		0.20,
		function()
			double_click_timer = nil
			return false
		end
	)
end

local create_click_events = function (c)
    local buttons = gears.table.join(
        awful.button(
            {},
            1,
            function ()
                double_click_event_handler(function ()
                    if c.floating then
                        c.float = false
                        return
                    end
                    c.maximized = not c.maximized
                    c:raise()
                end)
                c:activate { context = 'titlebar', action = 'mouse_move' }
            end
        ),
        awful.button(
            {},
            3,
            function ()
                c:activate { context = 'titlebar', action = 'mouse_resize' }
            end
        )
    )
    return buttons
end

local createresize_click_events = function (c)
    local buttons = gears.table.join(
        awful.button(
            {},
            1,
            function ()
                c:activate { context = 'titlebar', action = 'mouse_resize' }
            end
        )
    )
    return buttons
end

local create_titlebar = function (c, bg, size)
    local titlebar = awful.titlebar(c, {
        position = "left",
        bg = bg,
        size = size
    })

    titlebar : setup {
        {
            {
                {
                    awful.titlebar.widget.closebutton(c),
                    widget = wibox.container.background,
                    bg = color.color["Red200"],
                    shape = function (cr, height, width)
                        gears.shape.rounded_rect(cr, width, height, 4)
                    end,
                    id = "closebutton"
                },
                {
                    awful.titlebar.widget.maximizedbutton(c),
                    widget = wibox.container.background,
                    bg = color.color["Yellow200"],
                    shape = function (cr, height, width)
                        gears.shape.rounded_rect(cr, width, height, 4)
                    end,
                    id = "maximizebutton"
                },
                {
                    awful.titlebar.widget.minimizebutton(c),
                    widget = wibox.container.background,
                    bg = color.color["Green200"],
                    shape = function (cr, height, width)
                        gears.shape.rounded_rect(cr, width, height, 4)
                    end,
                    id = "minimizebutton"
                },
                spacing = dpi(10),
				layout  = wibox.layout.fixed.vertical,
                id = "spacing"
            },
            margins = dpi(8),
            widget = wibox.container.margin,
            id = "margin"
        },
        {
			buttons = create_click_events(c),
			layout = wibox.layout.flex.vertical
        },
        {
            {
                widget = awful.widget.clienticon(c)
            },
            margins = dpi(5),
            widget = wibox.container.margin
        },
        layout = wibox.layout.align.vertical,
        id = "main"
    }
    hover_signal(titlebar.main.margin.spacing.closebutton, color.color["Red200"])
    hover_signal(titlebar.main.margin.spacing.maximizebutton, color.color["Yellow200"])
    hover_signal(titlebar.main.margin.spacing.minimizebutton, color.color["Green200"])
end

local create_titlebar_dialog = function(c, bg, size)
	awful.titlebar(c, {position = "left", bg = bg, size = size}) : setup {
		{
			{
				{
                    awful.titlebar.widget.closebutton(c),
                    widget = wibox.container.background,
                    bg = color.color["Red200"],
                    shape = function (cr, height, width)
                        gears.shape.rounded_rect(cr, width, height, 4)
                    end
                },
                {
                    awful.titlebar.widget.minimizebutton(c),
                    widget = wibox.container.background,
                    bg = color.color["Green200"],
                    shape = function (cr, height, width)
                        gears.shape.rounded_rect(cr, width, height, 4)
                    end
                },
				spacing = dpi(7),
				layout  = wibox.layout.fixed.vertical
			},
			margins = dpi(8),
			widget = wibox.container.margin
		},
		{
			buttons = create_click_events(c),
			layout = wibox.layout.flex.vertical
		},
		nil,
		layout = wibox.layout.align.vertical
	}
end

local create_titlebar_borderhack = function (c, bg, position)
    local borderhack = awful.titlebar(c, {
        position = position,
        bg = bg,
        size = "2"
    })
    borderhack : setup {
        {
            bg = bg,
            widget = wibox.container.background
        },
		{
			buttons = createresize_click_events(c),
			layout = wibox.layout.flex.vertical
		},
		nil,
		layout = wibox.layout.align.vertical
	}

    local old_wibox, old_cursor
    borderhack:connect_signal(
        "mouse::enter",
        function ()
            local w = mouse.current_client
            if w then
                old_cursor, old_wibox = w.cursor, w
                w.cursor = "hand1"
            end
        end
    )

    borderhack:connect_signal(
        "mouse::leave",
        function ()
            if old_wibox then
                old_wibox.cursor = old_cursor
                old_wibox = nil
            end
        end
    )

end

local draw_titlebar = function (c)
    if c.type == 'normal' and not c.requests_no_titlebar  then
        create_titlebar_borderhack(c, "#121212AA", "right")
        create_titlebar_borderhack(c, "#121212AA", "top")
        create_titlebar_borderhack(c, "#121212AA", "bottom")

        if c.class == 'Firefox' then
            create_titlebar(c, '#121212AA', 35)
        elseif c.name == "Steam" then
            create_titlebar(c, '#121212AA', 0)
        elseif c.name == "Settings" then
            create_titlebar(c, '#121212AA', 0)
        elseif c.class == "gcr-prompter" or c.class == "Gcr-prompter" then
            create_titlebar(c, '#121212AA', 0)
        else
            create_titlebar(c, '#121212AA', 35)
        end
    elseif c.type == 'dialog' then
        create_titlebar_dialog(c, '#121212AA', 35)
    elseif c.type == 'modal' then
    else
        create_titlebar_borderhack(c, "#121212AA", "right")
        create_titlebar_borderhack(c, "#121212AA", "top")
        create_titlebar_borderhack(c, "#121212AA", "bottom")
        create_titlebar_borderhack(c, "#121212AA", "left")
    end
end

client.connect_signal(
    "property::maximized",
    function (c)
        if c.maximized then
            Theme.titlebar_maximized_button_normal = icondir .. "unmaximize.svg"
            Theme.titlebar_maximized_button_active = icondir .. "unmaximize.svg"
            Theme.titlebar_maximized_button_inactive = icondir .. "unmaximize.svg"
        elseif not c.minimized then
            Theme.titlebar_maximized_button_normal = icondir .. "maximize.svg"
            Theme.titlebar_maximized_button_active = icondir .. "maximize.svg"
            Theme.titlebar_maximized_button_inactive = icondir .. "maximize.svg"
        end
    end
)

client.connect_signal(
    "request::titlebars",
    function (c)
        if c.maximized then
            Theme.titlebar_maximized_button_normal = icondir .. "unmaximize.svg"
            Theme.titlebar_maximized_button_active = icondir .. "unmaximize.svg"
            Theme.titlebar_maximized_button_inactive = icondir .. "unmaximize.svg"
        elseif not c.minimized then
            Theme.titlebar_maximized_button_normal = icondir .. "maximize.svg"
            Theme.titlebar_maximized_button_active = icondir .. "maximize.svg"
            Theme.titlebar_maximized_button_inactive = icondir .. "maximize.svg"
        end
        draw_titlebar(c)
        if not c.floating or c.maximized then
            awful.titlebar.hide(c, 'left')
            awful.titlebar.hide(c, 'right')
            awful.titlebar.hide(c, 'top')
            awful.titlebar.hide(c, 'bottom')
        end
    end
)

client.connect_signal(
    'property::floating',
    function (c)
        if c.floating and not c.maximized then
            if c.class == "Steam" then
                awful.titlebar.hide(c, 'left')
                awful.titlebar.hide(c, 'right')
                awful.titlebar.hide(c, 'top')
                awful.titlebar.hide(c, 'bottom')
            else
                awful.titlebar.show(c, 'left')
                awful.titlebar.show(c, 'right')
                awful.titlebar.show(c, 'top')
                awful.titlebar.show(c, 'bottom')
            end
        else
            awful.titlebar.hide(c, 'left')
            awful.titlebar.hide(c, 'right')
            awful.titlebar.hide(c, 'top')
            awful.titlebar.hide(c, 'bottom')
        end
    end
)