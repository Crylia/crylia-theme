#!/bin/bash

killall -q polybar

if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar --reload crylia -c $HOME/.config/polybar/config.ini &
  done
else
  polybar crylia -c $HOME/.config/polybar/config.ini &
fi