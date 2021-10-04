#!/bin/bash

STATE=$(bluetoothctl show | grep Powered)
DEVICE_NAME=$(bluetoothctl info | grep Name: | awk '{ first = $1; $1 = ""; print $0 }')
POWERED=""
COLOR=""
STRING=""

if [[ $STATE == *'yes'* ]]
then
    POWERED="  ON"
    COLOR=""
else
    POWERED=" OFF"
    COLOR=""
fi

if [[ $DEVICE_NAME ]]
then
    POWERED=" "
fi

echo $POWERED$CONNECTED$DEVICE_NAME