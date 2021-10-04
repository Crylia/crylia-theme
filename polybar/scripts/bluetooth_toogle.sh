#!/bin/bash

STATE=$(bluetoothctl show | grep Powered)

if [[ $STATE == *"yes" ]]
then
    echo $(bluetoothctl power off)
else
    echo $(bluetoothctl power on)
fi
