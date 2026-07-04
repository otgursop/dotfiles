#!/bin/bash

# Weather for waybar - wttr.in
# Usage: weather-waybar [city]

CITY="${1:-Chelyabinsk}"
CACHE_FILE="/tmp/weather-${CITY}.cache"
CACHE_TIME=600  # 10 minutes

if [ -f "$CACHE_FILE" ]; then
    AGE=$(( $(date +%s) - $(stat -c %Y "$CACHE_FILE") ))
    if [ "$AGE" -lt "$CACHE_TIME" ]; then
        cat "$CACHE_FILE"
        exit 0
    fi
fi

WEATHER=$(curl -sf --max-time 5 "wttr.in/${CITY}?format=%c+%t" 2>/dev/null)

OUTPUT=""

if [ -n "$WEATHER" ]; then
    TEMP=$(echo "$WEATHER" | grep -oE '[+-]?[0-9]+' | tail -1)
    
    if [ -n "$TEMP" ]; then
        # Choose icon based on temperature
        if [ "$TEMP" -lt -10 ]; then
            ICON="🥶"
        elif [ "$TEMP" -lt 0 ]; then
            ICON="❄️"
        elif [ "$TEMP" -lt 15 ]; then
            ICON="🌤️"
        elif [ "$TEMP" -lt 25 ]; then
            ICON="☀️"
        else
            ICON="🔥"
        fi
        
        OUTPUT="${ICON} ${TEMP}°C"
    fi
fi

if [ -z "$OUTPUT" ]; then
    echo "🌡️ --"
    exit 0
fi

echo "$OUTPUT" > "$CACHE_FILE"

echo "$OUTPUT"
