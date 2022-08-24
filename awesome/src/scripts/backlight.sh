#!/bin/bash

case $1 in
  "get")
    echo $(xfpm-power-backlight-helper --get-brightness)
  ;;
  "set")
    echo $(pkexec xfpm-power-backlight-helper --set-brightness $2)
  ;;
esac
