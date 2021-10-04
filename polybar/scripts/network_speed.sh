#!/bin/bash

NETWORK=$(awk '{if(l1){print $2-l1,$10-l2} else{l1=$2; l2=$10;}}' <(grep wlo1 /proc/net/dev) <(sleep 1; grep wlo1 /proc/net/dev))
UP=$(echo $NETWORK | awk '{ print $2 }')
DOWN=$(echo $NETWORK | awk '{ print $1 }')
UP=$(echo "scale=2 ; $UP / 1048576" | bc)
DOWN=$(echo "scale=2 ; $DOWN / 1048576" | bc)

echo " $DOWN MB/s  $UP MB/s"