------------------------------
-- This is the audio widget --
------------------------------

-- Awesome Libs
local awful = require("awful")
local color = require("src.theme.colors")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")
require("src.core.signals")

-- Icon directory path
local icondir = awful.util.getdir("config") .. "src/assets/icons/kblayout/"

return function(s)
    local kblayout_widget = wibox.widget {
        {
            {
                {
                    {
                        {
                            id = "icon",
                            widget = wibox.widget.imagebox,
                            resize = false,
                            image = gears.color.recolor_image(icondir .. "keyboard.svg", color["Grey900"])
                        },
                        id = "icon_layout",
                        widget = wibox.container.place
                    },
                    top = dpi(2),
                    widget = wibox.container.margin,
                    id = "icon_margin"
                },
                spacing = dpi(10),
                {
                    id = "label",
                    align = "center",
                    valign = "center",
                    widget = wibox.widget.textbox
                },
                id = "kblayout_layout",
                layout = wibox.layout.fixed.horizontal
            },
            id = "container",
            left = dpi(8),
            right = dpi(8),
            widget = wibox.container.margin
        },
        bg = color["Green200"],
        fg = color["Grey900"],
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 5)
        end,
        widget = wibox.container.background
    }

    local layout = "";
    local get_kblayout = function()
        awful.spawn.easy_async_with_shell(
            [[ setxkbmap -query | grep layout | awk '{print $2}' ]],
            function(stdout)
                layout = stdout:gsub("\n", "")
                kblayout_widget.container.kblayout_layout.label.text = layout
                return layout
            end
        )
        return layout
    end


    local function create_kb_layout_item(keymap)
        -- TODO: Add more, too lazy rn
        local longname, shortname

        local xkeyboard_country_code = {
            { "ad", "", "AND" }, -- Andorra
            { "af", "", "AFG" }, -- Afghanistan
            { "al", "", "ALB" }, -- Albania
            { "am", "", "ARM" }, -- Armenia
            { "ara", "", "ARB" }, -- Arabic
            { "at", "", "AUT" }, -- Austria
            { "az", "", "AZE" }, -- Azerbaijan
            { "ba", "", "BIH" }, -- Bosnia and Herzegovina
            { "bd", "", "BGD" }, -- Bangladesh
            { "be", "", "BEL" }, -- Belgium
            { "bg", "", "BGR" }, -- Bulgaria
            { "br", "", "BRA" }, -- Brazil
            { "bt", "", "BTN" }, -- Bhutan
            { "bw", "", "BWA" }, -- Botswana
            { "by", "", "BLR" }, -- Belarus
            { "ca", "", "CAN" }, -- Canada
            { "cd", "", "COD" }, -- Congo
            { "ch", "", "CHE" }, -- Switzerland
            { "cm", "", "CMR" }, -- Cameroon
            { "cn", "", "CHN" }, -- China
            { "cz", "", "CZE" }, -- Czechia
            { "de", "Deutsch (Germany)", "GER" }, -- Germany
            { "dk", "", "DNK" }, -- Denmark
            { "ee", "", "EST" }, -- Estonia
            { "es", "", "ESP" }, -- Spain
            { "et", "", "ETH" }, -- Ethiopia
            { "eu", "?", "?" }, -- EurKey
            { "fi", "", "FIN" }, -- Finland
            { "fo", "", "FRO" }, -- Faroe Islands
            { "fr", "", "FRA" }, -- France
            { "gb", "English (Bri'ish)", "ENG" }, -- United Kingdom
            { "ge", "", "GEO" }, -- Georgia
            { "gh", "", "GHA" }, -- Ghana
            { "gn", "", "GIN" }, -- Guinea
            { "gr", "", "GRC" }, -- Greece
            { "hr", "", "HRV" }, -- Croatia
            { "hu", "", "HUN" }, -- Hungary
            { "ie", "", "IRL" }, -- Ireland
            { "il", "", "ISR" }, -- Israel
            { "in", "", "IND" }, -- India
            { "iq", "", "IRQ" }, -- Iraq
            { "ir", "", "IRN" }, -- Iran
            { "is", "", "ISL" }, -- Iceland
            { "it", "", "ITA" }, -- Italy
            { "jp", "", "JPN" }, -- Japan
            { "ke", "", "KEN" }, -- Kenya
            { "kg", "", "KGZ" }, -- Kyrgyzstan
            { "kh", "", "KHM" }, -- Cambodia
            { "kr", "", "KOR" }, -- Korea
            { "kz", "", "KAZ" }, -- Kazakhstan
            { "la", "", "LAO" }, -- Laos
            { "latam", "?", "?" }, -- Latin America
            { "latin", "?", "?" }, -- Latin
            { "lk", "", "LKA" }, -- Sri Lanka
            { "lt", "", "LTU" }, -- Lithuania
            { "lv", "", "LVA" }, -- Latvia
            { "ma", "", "MAR" }, -- Morocco
            { "mao", "?", "?" }, -- Maori
            { "me", "", "MNE" }, -- Montenegro
            { "mk", "", "MKD" }, -- Macedonia
            { "ml", "", "MLI" }, -- Mali
            { "mm", "", "MMR" }, -- Myanmar
            { "mn", "", "MNG" }, -- Mongolia
            { "mt", "", "MLT" }, -- Malta
            { "mv", "", "MDV" }, -- Maldives
            { "ng", "", "NGA" }, -- Nigeria
            { "nl", "", "NLD" }, -- Netherlands
            { "no", "", "NOR" }, -- Norway
            { "np", "", "NRL" }, -- Nepal
            { "ph", "", "PHL" }, -- Philippines
            { "pk", "", "PAK" }, -- Pakistan
            { "pl", "", "POL" }, -- Poland
            { "pt", "", "PRT" }, -- Portugal
            { "ro", "", "ROU" }, -- Romania
            { "rs", "", "SRB" }, -- Serbia
            { "ru", "Русски (Russia)", "RUS" }, -- Russia
            { "se", "", "SWE" }, -- Sweden
            { "si", "", "SVN" }, -- Slovenia
            { "sk", "", "SVK" }, -- Slovakia
            { "sn", "", "SEN" }, -- Senegal
            { "sy", "", "SYR" }, -- Syria
            { "th", "", "THA" }, -- Thailand
            { "tj", "", "TJK" }, -- Tajikistan
            { "tm", "", "TKM" }, -- Turkmenistan
            { "tr", "", "TUR" }, -- Turkey
            { "tw", "", "TWN" }, -- Taiwan
            { "tz", "", "TZA" }, -- Tanzania
            { "ua", "", "UKR" }, -- Ukraine
            { "us", "English (United States)", "USA" }, -- USA
            { "uz", "", "UZB" }, -- Uzbekistan
            { "vn", "", "VNM" }, -- Vietnam
            { "za", "", "ZAF" } -- South Africa
        }

        for i, c in ipairs(xkeyboard_country_code) do
            if c[1] == keymap then
                longname = c[2]
                shortname = c[3]
            end
        end

        local kb_layout_item = wibox.widget {
            {
                {
                    {
                        -- Short name e.g. GER, ENG, RUS
                        {
                            {
                                text = shortname,
                                widget = wibox.widget.textbox,
                                font = user_vars.font.extrabold,
                                id = "kbmapname"
                            },
                            widget = wibox.container.margin,
                            id = "margin2"
                        },
                        nil,
                        {
                            {
                                text = longname,
                                widget = wibox.widget.textbox,
                                font = user_vars.font.bold,

                            },
                            widget = wibox.container.margin
                        },
                        spacing = dpi(15),
                        layout = wibox.layout.fixed.horizontal,
                        id = "container"
                    },
                    margins = dpi(10),
                    widget = wibox.container.margin,
                    id = "margin"
                },
                shape = function(cr, width, height)
                    gears.shape.rounded_rect(cr, width, height, 10)
                end,
                bg = color["Grey800"],
                fg = color["White"],
                widget = wibox.container.background,
                id = "background"
            },
            margins = dpi(5),
            widget = wibox.container.margin
        }
        Hover_signal(kb_layout_item.background, color["White"], color["Grey900"])
        kb_layout_item:connect_signal(
            "button::press",
            function()
                awful.spawn.easy_async_with_shell(
                    "setxkbmap " .. keymap,
                    function(stdout)
                        awesome.emit_signal("kblayout::hide:kbmenu")
                        get_kblayout()
                    end
                )
            end
        )
        return kb_layout_item
    end

    local function get_kblist()
        local kb_layout_items = {
            layout = wibox.layout.fixed.vertical
        }
        for i, keymap in pairs(user_vars.kblayout) do
            kb_layout_items[i] = create_kb_layout_item(keymap)
        end
        return kb_layout_items
    end

    local kb_menu_widget = awful.popup {
        screen = s,
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 5)
        end,
        widget = wibox.container.background,
        bg = color["Grey900"],
        fg = color["White"],
        width = dpi(100),
        max_height = dpi(600),
        visible = false,
        ontop = true,
        placement = function(c) awful.placement.align(c, { position = "top_right", margins = { right = dpi(255), top = dpi(60) } }) end
    }

    kb_menu_widget:setup(
        get_kblist()
    )

    local function toggle_kb_layout()
        awful.spawn.easy_async_with_shell(
            "setxkbmap -query | grep layout: | awk '{print $2}'",
            function(stdout)
                for j, n in ipairs(user_vars.kblayout) do
                    if stdout:match(n) then
                        if j == #user_vars.kblayout then
                            awful.spawn.easy_async_with_shell(
                                "setxkbmap " .. user_vars.kblayout[1],
                                function()
                                    get_kblayout()
                                end
                            )
                        else
                            awful.spawn.easy_async_with_shell(
                                "setxkbmap " .. user_vars.kblayout[j + 1],
                                function()
                                    get_kblayout()
                                end
                            )
                        end
                    end
                end
            end
        )
    end

    awesome.connect_signal(
        "kblayout::toggle",
        function()
            toggle_kb_layout()
        end
    )

    --kb_menu_widget:move_next_to(mouse.current_widget_geometry)
    -- Signals
    Hover_signal(kblayout_widget, color["Green200"])

    local kblayout_keygrabber = awful.keygrabber {
        autostart = false,
        stop_event = 'release',
        keypressed_callback = function(self, mod, key, command)
            if key == 'Escape' then
                awesome.emit_signal("kblayout::hide:kbmenu")
            end
        end
    }

    kblayout_widget:connect_signal(
        "button::press",
        function()
            if kb_menu_widget.visible then
                kb_menu_widget.visible = false
                kblayout_keygrabber:stop()
            else
                kb_menu_widget.visible = true
                kblayout_keygrabber:start()
            end
        end
    )

    awesome.connect_signal(
        "kblayout::hide:kbmenu",
        function()
            kb_menu_widget.visible = false
            kblayout_keygrabber:stop()
        end
    )

    get_kblayout()
    kb_menu_widget.visible = false
    return kblayout_widget
end
