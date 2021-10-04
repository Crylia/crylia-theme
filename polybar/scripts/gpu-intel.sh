#!/bin/bash

#gpu=$(timeout 1s sudo intel_gpu_top -o - | awk 'NR>=3{printf "\t%11s%14s%12s%\n" $8,$11,$14,$17}')
timeout 1s sudo intel_gpu_top -l | awk 'NR>=3{printf "\t%11s%14s%12s%\n" $8,$11,$14,$17}'
echo "iGPU $gpu"