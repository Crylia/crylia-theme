local awful = require("awful")

-- Autostart programs
--awful.spawn.with_shell("~/.screenlayout/single_screen.sh")
awful.spawn.with_shell("picom --experimental-backends")
awful.spawn.with_shell("xfce4-power-manager")
awful.spawn.with_shell("light-locker --lock-on-suspend --lock-on-lid &")
