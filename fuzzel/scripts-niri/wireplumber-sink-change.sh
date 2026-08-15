#!/usr/bin/env bash

# Get list of sinks with their names and descriptions using pactl
# Format: "name|description"
sink_info=$(pactl list sinks | grep -E "^[[:space:]]*(Name:|device.description =)" | \
    sed 's/^[[:space:]]*//' | \
    awk '/^Name:/ {name=$2} /^device.description =/ {desc=$3; gsub(/^"|"$/, "", desc); print name "|" desc}')

# Fallback if no description found
if [ -z "$sink_info" ]; then
    sink_info=$(pactl list sinks short | awk '{print $1 "|" $2}')
fi

# Get current default sink name
current_sink=$(pactl get-default-sink)

# Build associative array: name -> description, and menu lines
declare -A name_to_desc
menu_lines=""
while IFS='|' read -r name desc; do
    if [ -z "$desc" ]; then
        desc="$name"
    fi
    name_to_desc["$name"]="$desc"
    menu_lines+="$desc\n"
done <<< "$sink_info"

# Remove trailing newline
menu_lines=$(echo -e "$menu_lines" | sed '/^$/d')

# Determine current description for the message
current_desc=""
for name in "${!name_to_desc[@]}"; do
    if [ "$name" = "$current_sink" ]; then
        current_desc="${name_to_desc[$name]}"
        break
    fi
done
[ -z "$current_desc" ] && current_desc="(unknown)"

# Launch fuzzel with descriptions as choices (no markers)
chosen_desc=$(echo -e "$menu_lines" | fuzzel --dmenu --width 45 --lines 5 --mesg="Current audio output: ${current_desc}")

# If selection made, find corresponding sink name and set it
if [ -n "$chosen_desc" ]; then
    selected_name=""
    for name in "${!name_to_desc[@]}"; do
        if [ "${name_to_desc[$name]}" = "$chosen_desc" ]; then
            selected_name="$name"
            break
        fi
    done
    if [ -n "$selected_name" ]; then
        if [ "$selected_name" = "$current_sink" ]; then
            # Already using this sink – show a different notification
            if command -v notify-send &> /dev/null; then
                notify-send "Audio Output" "Already using: ${chosen_desc}"
            fi
        else
            # Switch to the new sink
            pactl set-default-sink "$selected_name"
            if command -v notify-send &> /dev/null; then
                notify-send "Audio Output" "Switched to: ${chosen_desc}"
            fi
        fi
    fi
fi
