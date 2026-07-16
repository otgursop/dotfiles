#!/usr/bin/sh

options="hex
rgb
hsl
hsv
cmyk"

chosen=$(echo -e "$options" | fuzzel \
    --dmenu \
    --prompt "Pick a color: " \
    --placeholder "format..." \
    --lines 5 \
    --width 25)

case "$chosen" in
    "hex") hyprpicker -a -f hex -n ;;
    "rgb") hyprpicker -a -f rgb -n ;;
    "hsl") hyprpicker -a -f hsl -n ;;
    "hsv") hyprpicker -a -f hsv -n ;;
    "cmyk") hyprpicker -a -f cmyk -n ;;
esac

