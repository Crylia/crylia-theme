#!/bin/bash

SSID=$(iwgetid -r)
SSIG=$(grep "$(iwgetid -m | awk '{ printf "%s", $1 }')" /proc/net/wireless | awk '{ printf "%i\n", int($3 * 100 / 70) }')
IP=$(ip route get 8.8.8.8 | grep -oP 'src \K[^ ]+')
SIG=$(echo "$SSIG" | rev | cut -c 2- | rev)

NETWORK_UP=$(echo "scale=2 ; $(cat /proc/net/dev | awk '/wlo1:/ { print $2 }') / 1024" | bc)
NETWORK_DOWN=$(echo "scale=2 ; $(cat /proc/net/dev | awk '/wlo1:/ { print $10 }') / 1024" | bc)

#wifi off  

if [[ $SSID ]]; then
    echo "$IP $NETWORK_UP MB/s $NETWORK_DOWN MB/s"
else
    echo ""
fi
