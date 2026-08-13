#!/usr/bin/env bash

# Current perfomance level
current=$(cat /sys/class/drm/card1/device/power_dpm_force_performance_level 2>/dev/null | tr '[:lower:]' '[:upper:]')

options="LOW
AUTO
HIGH"

chosen=$(echo -e "$options" | fuzzel \
    --dmenu \
    --lines 3 \
    --width 25 \
    --mesg "Current: $current")

case "$chosen" in
    "LOW")
        echo "low" | pkexec bash -c "tee /sys/class/drm/card1/device/power_dpm_force_performance_level > /dev/null" && notify-send "GPU power set to LOW"
        ;;
    "AUTO")
        echo "auto" | pkexec bash -c "tee /sys/class/drm/card1/device/power_dpm_force_performance_level > /dev/null" && notify-send "GPU power set to AUTO"
        ;;
    "HIGH")
        echo "high" | pkexec bash -c "tee /sys/class/drm/card1/device/power_dpm_force_performance_level > /dev/null" && notify-send "GPU power set to HIGH"
        ;;
esac
