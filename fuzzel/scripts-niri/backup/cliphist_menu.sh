#!/bin/sh

chosen=$(cliphist list | fuzzel \
    --dmenu \
    --prompt "Clipboard: " \
    --lines 15 \
    --width 100)

if [ -n "$chosen" ]; then
    echo "$chosen" | cliphist decode | wl-copy
fi

