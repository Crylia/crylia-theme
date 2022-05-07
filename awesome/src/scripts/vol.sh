#!/bin/bash

SINK=$(LC_ALL=C pactl get-default-sink)

if [[ $1 == "volume" ]]
then
  echo $(LC_ALL=C pactl get-sink-volume $SINK | awk '{print $5}')
elif [[ $1 == "mute" ]]
then
  echo $(LC_ALL=C pactl get-sink-mute $SINK)
fi
