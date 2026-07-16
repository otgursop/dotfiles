#!/usr/bin/env bash

# Get the list of clipboard items
cliphist_list=$(cliphist list)

# If the list is empty, show a message and exit
if [ -z "$cliphist_list" ]; then
  fuzzel -d --prompt-only "cliphist: please store something first"
  exit 0
fi

# Show the list in fuzzel and get the selected item
# Removed --with-nth because we no longer prepend icon data
item=$(echo "$cliphist_list" | fuzzel -d --prompt "Clipboard: " --placeholder "..." --lines 12 --width 100)
exit_code=$?

# ALT+0 to clear history (custom-10 in fuzzel.ini)
if [ "$exit_code" -eq 19 ]; then
  confirmation=$(echo -e "No\nYes" | fuzzel -d --placeholder "Delete history?" --lines 2)
  # cliphist wipe is the native and safe way to clear the database
  [ "$confirmation" == "Yes" ] && cliphist wipe

# ALT+1 to delete selected item (custom-1 in fuzzel.ini)
elif [ "$exit_code" -eq 10 ]; then
  if [ -n "$item" ]; then
    # Extract the ID (first column) and delete it
    item_id=$(echo "$item" | cut -f1)
    echo "$item_id" | cliphist delete
  fi

# Enter (default) to copy the selected item to clipboard
else
  [ -z "$item" ] || echo "$item" | cliphist decode | wl-copy
fi
