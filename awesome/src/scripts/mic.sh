#!/bin/bash

SINK=$(LC_ALL=C pactl get-default-source)

case $1 in

  "volume")
    echo $(LC_ALL=C pactl get-source-volume $SINK | awk '{print $5}')
  ;;

  "mute")
    echo $(LC_ALL=C pactl get-source-mute $SINK)
  ;;

  "toggle_mute")
    $(LC_ALL=C pactl set-source-mute $SINK toggle)
  ;;

  "set_volume")
    $(LC_ALL=C pactl set-source-volume $SINK $2)
  ;;

  "set_source")
    $(LC_ALL=C pactl set-default-source $2)
  ;;

esac
