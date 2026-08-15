#!/bin/sh

options="Power
System
Change wallpaper
Change GPU power
Change audio output (sink)
Color picker (select color format)"

chosen=$(echo -e "$options" | fuzzel \
    --dmenu \
    --mesg "The selected menu will be opened" \
    --lines 6 \
    --width 40)

case "$chosen" in
    "Power")
        ~/.config/fuzzel/scripts-niri/power-menu.sh ;;
    "System")
        ~/.config/fuzzel/scripts-niri/system-menu.sh ;;
    "Change GPU power")
        ~/.config/fuzzel/scripts-niri/amdgpu-power-menu.sh ;;
    "Change wallpaper")
        ~/.config/fuzzel/scripts-niri/wallpaper-change.sh ;;
    "Change audio output (sink)")
        ~/.config/fuzzel/scripts-niri/wireplumber-sink-change.sh ;;
    "Color picker (select color format)")
        ~/.config/fuzzel/scripts-niri/color-picker-menu.sh ;;
esac
