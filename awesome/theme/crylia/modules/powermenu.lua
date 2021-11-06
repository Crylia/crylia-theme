--------------------------------
-- This is the network widget --
--------------------------------

-- Awesome Libs
local awful = require("awful")
local color = require("theme.crylia.colors")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")
local naughty = require("naughty")

-- Icon directory path
local icondir = awful.util.getdir("config") .. "theme/crylia/assets/icons/powermenu/"

return function ()

    local profile_picture = wibox.widget {
        image = icondir .. "defaultpfp.svg",
        resize = true,
        forced_height = dpi(200),
        clip_shape = function (cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 30)
        end,
        widget = wibox.widget.imagebox
    }

    local profile_name = wibox.widget {
        align = 'center',
        valign = 'center',
        text = " ",
        font = "JetBrains Mono Bold 30",
        widget = wibox.widget.textbox
    }

    local update_profile_picture = function ()
        awful.spawn.easy_async_with_shell(
            [=[ 
                iconPath="/var/lib/AccountsService/icons/${USER}"
                userIconPath="${HOME}/.config/awesome/theme/crylia/assets/userpfp/"
                if [[ -f "${userIconPath}" ]];
                then
                    if [[ -f "${iconPath}" ]];
                    then
                        if ! cmp --silent "${userIconPath}.png" "${iconPath}";
                        then
                            cp "${iconPath}" "${userIconPath}${USER}.png"
                        fi
                        printf "${userIconPath}.png"
                    else
                        printf "${userIconPath}.png"
                    fi
                    exit;
                else
                    if [[ -f "${iconPath}" ]];
                    then
                        cp "${iconPath}" "${userIconPath}${USER}.png"
                        printf "${userIconPath}${USER}.png"
                        exit;
                    fi
                fi
             ]=],
            function (stdout)
                if stdout then
                    profile_picture:set_image(stdout:gsub("\n", ""))
                else
                    profile_picture:set_image(icondir .. "defaultpfp.svg")
                end
            end
        )
    end

    update_profile_picture()
    local namestyle = "userhost"
    local update_user_name = function()
        awful.spawn.easy_async_with_shell(
            [=[
                fullname="$(getent passwd `whoami` | cut -d ':' -f 5)"
                user="$(whoami)"
                host="$(hostname)"
                if [[ "]=] .. namestyle .. [=[" == "userhost" ]];
                then
                    printf "$user@$host"
                elif [[ "]=] .. namestyle .. [=[" == "fullname" ]];
                then
                    printf "$fullname"
                else
                    printf "Rick Astley"
                fi
            ]=],
            function(stdout)
                if stdout:gsub("\n", "") == "Rick Astley" then
                    profile_picture:set_image(awful.util.getdir("config") .. "theme/crylia/assets/userpfp/" .. "rickastley.jpg")
                end
                profile_name:set_text(stdout)
            end
        )
    end
    update_user_name()

    local button = function(name, icon, bg_color, callback)
        local item = wibox.widget{
            {
                {
                    {
                        {
                            {
                                --image = gears.color.recolor_image(icon, color.color["Grey900"]),
                                image = icon,
                                resize = true,
                                forced_height = dpi(30),
                                widget = wibox.widget.imagebox
                            },
                            margins = dpi(0),
                            widget = wibox.container.margin
                        },
                        {
                            {
                                text = name,
                                font = "JetBrains Mono Bold 30",
                                widget = wibox.widget.textbox
                            },
                            margins = dpi(0),
                            widget = wibox.container.margin
                        },
                        widget = wibox.layout.fixed.horizontal
                    },
                    margins = dpi(10),
                    widget = wibox.container.margin
                },
                fg = color.color["Grey900"],
                bg = bg_color,
                shape = function (cr, width, height)
                    gears.shape.rounded_rect(cr, width, height, 10)
                end,
                widget = wibox.container.background
            },
            spacing = dpi(0),
            layout = wibox.layout.align.vertical
        }

        item:connect_signal(
            "button::release",
            function()
                callback()
            end
        )

        return item
    end

    local suspend_command = function()
        awful.spawn.easy_async_with_shell("dm-tool lock & systemctl suspend")
        awesome.emit_signal("module::powermenu:hide")
    end

    local logout_command = function()
        awesome.quit()
    end

    local lock_command = function()
        awful.spawn.easy_async_with_shell("dm-tool lock")
        awesome.emit_signal("module::powermenu:hide")
    end

    local shutdown_command = function()
        awful.spawn.easy_async_with_shell("shutdown now")
        awesome.emit_signal("module::powermenu:hide")
    end

    local reboot_command = function()
        awful.spawn.easy_async_with_shell("reboot")
        awesome.emit_signal("module::powermenu:hide")
    end

    local shutdown_button = button("Shutdown", icondir .. "shutdown.svg", color.color["Blue200"], shutdown_command)
    local reboot_button = button("Reboot", icondir .. "reboot.svg", color.color["Red200"], reboot_command)
    local suspend_button = button("Suspend", icondir .. "suspend.svg", color.color["Yellow200"], suspend_command)
    local logout_button = button("Logout", icondir .. "logout.svg", color.color["Green200"], logout_command)
    local lock_button = button("Lock", icondir .. "lock.svg", color.color["Orange200"], lock_command)

    local powermenu = wibox.widget {
        layout = wibox.layout.align.vertical,
        expand = "none",
        nil,
        {
            {
                nil,
                {
                    {
                        nil,
                        {
                            nil,
                            {
                                profile_picture,
                                margins = dpi(0),
                                widget = wibox.container.margin
                            },
                            nil,
                            expand = "none",
                            layout = wibox.layout.align.horizontal
                        },
                        nil,
                        layout = wibox.layout.align.vertical,
                        expand = "none"
                    },
                    spacing = dpi(50),
                    {
                        profile_name,
                        margins = dpi(0),
                        widget = wibox.container.margin
                    },
                    layout = wibox.layout.fixed.vertical
                },
                nil,
                expand = "none",
                layout = wibox.layout.align.horizontal
            },
            {
                nil,
                {
                    {
                        shutdown_button,
                        reboot_button,
                        logout_button,
                        lock_button,
                        suspend_button,
                        spacing = dpi(30),
                        layout = wibox.layout.fixed.horizontal
                    },
                    margins = dpi(0),
                    widget = wibox.container.margin
                },
                nil,
                expand = "none",
                layout = wibox.layout.align.horizontal
            },
            layout = wibox.layout.align.vertical
        },
        nil
    }
    return powermenu
end