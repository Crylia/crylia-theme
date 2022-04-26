#!/bin/bash

if [[ $1 == "volume" ]]
then
echo $(LC_ALL=C pactl list sinks | grep '^[[:space:]]Volume:' | head -n $(( 47 + 1 )) | tail -n 1 | sed -e 's,.* \([0-9][0-9]*\)%.*,\1,')
elif [[ $1 == "mute" ]]
then
echo $(LC_ALL=C pactl list sinks | grep '^[[:space:]]Mute:' | head -n $(( 47 + 1 )) | tail -n 1 | sed -e 's,.* \([0-9][0-9]*\)%.*,\1,')
fi

