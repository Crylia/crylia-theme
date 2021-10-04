#!/bin/bash

WIFI_STATUS=$(nmcli radio wifi)

if [[ $WIFI_STATUS == 'enabled' ]]
then
    echo $(nmcli radio wifi off)
elif [[ $WIFI_STATUS == 'disabled' ]]
then
    echo $(nmcli radio wifi on)
fi
