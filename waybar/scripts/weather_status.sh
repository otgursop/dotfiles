#!/bin/bash

# Weather for waybar - wttr.in
# Usage: weather-waybar [city]

CITY="${1:-Chelyabinsk}"
CACHE_FILE="/tmp/weather-${CITY}.cache"
CACHE_TIME=600  # 10 minutes

# Check cache
if [ -f "$CACHE_FILE" ]; then
    AGE=$(( $(date +%s) - $(stat -c %Y "$CACHE_FILE") ))
    if [ "$AGE" -lt "$CACHE_TIME" ]; then
        cat "$CACHE_FILE"
        exit 0
    fi
fi

# Fetch weather data (format: location, condition, temperature)
WEATHER=$(curl -s "wttr.in/${CITY}?format=%c+%t" 2>/dev/null)

if [ -n "$WEATHER" ]; then
    # Extract temperature
    TEMP=$(echo "$WEATHER" | grep -oP '[+-]?\d+' | tail -1)
    CONDITION=$(echo "$WEATHER" | grep -oP '^[^0-9+-]+' | sed 's/ *$//')
    
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
    else
        OUTPUT="🌡️ --"
    fi
else
    OUTPUT="🌡️ --"
fi

# Save to cache
echo "$OUTPUT" > "$CACHE_FILE"

# Output
echo "$OUTPUT"
