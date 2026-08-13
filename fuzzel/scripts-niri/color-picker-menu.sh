#!/usr/bin/sh

options="HEX
RGB
HSL
HSV
CMYK"

chosen=$(echo -e "$options" | fuzzel \
    --dmenu \
    --mesg "Color picker" \
    --lines 5 \
    --width 20)

case "$chosen" in
    "HEX") hyprpicker -a -f hex -n ;;
    "RGB") hyprpicker -a -f rgb -n ;;
    "HSL") hyprpicker -a -f hsl -n ;;
    "HSV") hyprpicker -a -f hsv -n ;;
    "CMYK") hyprpicker -a -f cmyk -n ;;
esac

