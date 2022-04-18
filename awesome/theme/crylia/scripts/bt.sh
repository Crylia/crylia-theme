#!/bin/bash

DEVICES=$(bluetoothctl paired-devices | cut -f2 -d' '|
                        while read -r uuid
                        do
                            info=`bluetoothctl info $uuid`
                            if echo "$info" | grep -q "Connected: yes"; then
                            echo "$info" | head -n 1 | grep "Device" | awk '{print $2}'
                        fi
                        done)
NAMES=$(bluetoothctl paired-devices | cut -f2 -d' '|
                        while read -r uuid
                        do
                            info=`bluetoothctl info $uuid`
                            if echo "$info" | grep -q "Connected: yes"; then
                            echo "$info" | grep "Name" | awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}'
                        fi
                        done)
for device in $DEVICES; do
	STRING=$(bluetoothctl info $device | grep 'Battery Percentage:' | awk '{print "\n   Battery: " $4 "%"}')
	echo " $(bluetoothctl info  ${device} | grep Name: | awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}') ${STRING}"
done

