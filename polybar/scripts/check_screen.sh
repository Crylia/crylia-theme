#!/bin/bash
SECOND_SCREEN_ON=$(xrandr | grep -sw 'HDMI-1 connected 2160x1080')

if [[ $SECOND_SCREEN_ON == 'HDMI-1 connected 2160x1080'* ]]; then
    echo " "
else
    echo " "
fi