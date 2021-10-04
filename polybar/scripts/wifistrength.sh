#!/bin/bash

SSID=$(iwgetid -r)
SSIG=$(grep "$(iwgetid -m | awk '{ printf "%s", $1 }')" /proc/net/wireless | awk '{ printf "%i\n", int($3 * 100 / 70) }')

if [[ $SSID ]]; then
    echo "  $SSIG%"
else
    echo "睊 0%"
fi