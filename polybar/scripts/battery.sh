#!/usr/bin/bash

# This script uses upower to get all the battery informations
# https://upower.freedesktop.org/docs/Device.html

CHARGE=$(upower -i $(upower -e | grep '/battery') | grep --color=never -E percentage|xargs|cut -d' ' -f2|sed s/%//)
ICON=""
BAT_STATE=$(upower -i `upower -e | grep 'battery'` | grep -E 'state')
COLOR=""

#More Icons
#  

# Charging
if [[ $BAT_STATE == *'discharging'* ]]; then
    if [ $CHARGE -eq 0 ]; then
        ICON=""
        COLOR="%{F#fc8894}"
    elif [ $CHARGE -gt 0 ] && [ $CHARGE -le 10 ]; then
        ICON=""
        COLOR="%{F#fc8894}"
    elif [ $CHARGE -gt 10 ] && [ $CHARGE -le 20 ]; then
        ICON=""
        COLOR="%{F#fc8894}"
        #notify-send -u critical "Battery Warning" "20% charge remaining!"
    elif [ $CHARGE -gt 20 ] && [ $CHARGE -le 30 ]; then
        ICON=""
        COLOR="%{F#e3e3e3}"
    elif [ $CHARGE -gt 30 ] && [ $CHARGE -le 40 ]; then
        ICON=""
        COLOR="%{F#e3e3e3}"
    elif [ $CHARGE -gt 40 ] && [ $CHARGE -le 50 ]; then
        ICON=""
        COLOR="%{F#e3e3e3}"
    elif [ $CHARGE -gt 50 ] && [ $CHARGE -le 60 ]; then
        ICON=""
        COLOR="%{F#e3e3e3}"
    elif [ $CHARGE -gt 60 ] && [ $CHARGE -le 70 ]; then
        ICON=""
        COLOR="%{F#e3e3e3}"
    elif [ $CHARGE -gt 70 ] && [ $CHARGE -le 80 ]; then
        ICON=""
        COLOR="%{F#8be09c}"
    elif [ $CHARGE -gt 80 ] && [ $CHARGE -le 90 ]; then
        ICON=""
        COLOR="%{F#8be09c}"
    elif [ $CHARGE -gt 90 ]; then
        ICON=""
        COLOR="%{F#8be09c}"
    fi
# Discharging
elif [[ $BAT_STATE == *'charging'* ]]; then
if [ $CHARGE -eq 0 ]; then
        ICON=""
        COLOR="%{F#fc8894}"
    elif [ $CHARGE -gt 0 ] && [ $CHARGE -le 10 ]; then
        ICON=""
        COLOR="%{F#fc8894}"
    elif [ $CHARGE -gt 10 ] && [ $CHARGE -le 20 ]; then
        ICON=""
        COLOR="%{F#fc8894}"
    elif [ $CHARGE -gt 20 ] && [ $CHARGE -le 30 ]; then
        ICON=""
        COLOR="%{F#e3e3e3}"
    elif [ $CHARGE -gt 30 ] && [ $CHARGE -le 40 ]; then
        ICON=""
        COLOR="%{F#e3e3e3}"
    elif [ $CHARGE -gt 40 ] && [ $CHARGE -le 50 ]; then
        ICON=""
        COLOR="%{F#e3e3e3}"
    elif [ $CHARGE -gt 50 ] && [ $CHARGE -le 60 ]; then
        ICON=""
        COLOR="%{F#e3e3e3}"
    elif [ $CHARGE -gt 60 ] && [ $CHARGE -le 70 ]; then
        ICON=""
        COLOR="%{F#e3e3e3}"
    elif [ $CHARGE -gt 70 ] && [ $CHARGE -le 80 ]; then
        ICON=""
        COLOR="%{F#8be09c}"
    elif [ $CHARGE -gt 80 ] && [ $CHARGE -le 90 ]; then
        ICON=""
        COLOR="%{F#8be09c}"
    elif [ $CHARGE -gt 90 ]; then
        ICON=""
        COLOR="%{F#8be09c}"
    fi
elif [[ $BAT_STATE == *'fully-charged'* ]]; then
    ICON=""
    COLOR="%{F#8be09c}"
    #notify-send -u low "Battery Info" "Your battery is fully charged"
elif [[ $BAT_STATE == *'unknown'* ]]; then
    ICON=""
fi

STRING="$COLOR$ICON $CHARGE%"

# Final formatted output.
echo $STRING
