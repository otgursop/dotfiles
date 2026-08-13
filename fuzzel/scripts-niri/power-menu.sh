#!/bin/bash

options="Lock
Exit session
Power off monitors
Reboot
Power off"

choice=$(echo -e "$options" | fuzzel \
    --dmenu \
    --mesg "Power actions" \
    --lines 5 \
    --width 25)

case "$choice" in
    "Lock")
        swaylock -u -F --color 141514 ;;
    "Exit session")
        niri msg action quit ;;
    "Power off monitors")
        niri msg action power-off-monitors ;;
    "Reboot")
        systemctl reboot ;;
    "Power off")
        systemctl poweroff ;;
esac

