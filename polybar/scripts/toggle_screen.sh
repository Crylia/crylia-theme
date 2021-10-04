#!/bin/bash
SECOND_SCREEN_ON=$(xrandr | grep 'HDMI-1 connected 2160x1080')

if [[ $SECOND_SCREEN_ON == 'HDMI-1 connected 2160x1080'* ]]; then
    xrandr --output eDP-1 --primary --mode 1920x1080 --pos 0x0 --rotate normal --output HDMI-1 --off --output HDMI-2 --off
    sleep 1
    nitrogen --restore
    sleep 1
    pkill -f bashtop
else
    xrandr --output eDP-1 --primary --mode 1920x1080 --pos 120x0 --rotate normal --output HDMI-1 --mode 1080x2160 --pos 0x1080 --rotate right --output HDMI-2 --off
    sleep 1
    nitrogen --restore
    alacritty -o font.size=5 -t TrackpadBashtop -e bashtop
fi