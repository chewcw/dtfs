#!/bin/bash

# See https://i3wm.org/docs/userguide.html#_display_mode
# for different bar mode in i3wm

# Store the current bar mode in a file
# The file will be created if the file does not exist
BAR_MODE_FILE="$HOME/.config/i3/bar_mode"
if [ ! -f "$BAR_MODE_FILE" ]; then
    # by default it's dock mode
    echo "dock" > "$BAR_MODE_FILE"
fi

CURRENT_MODE=$(cat "$BAR_MODE_FILE")

# Toggle between hide, dock, and invisible mode
if [ "$CURRENT_MODE" == "dock" ]; then
    i3-msg "bar mode hide"
    echo "hide" > "$BAR_MODE_FILE"
elif [ "$CURRENT_MODE" == "hide" ]; then
    i3-msg "bar mode invisible"
    echo "invisible" > "$BAR_MODE_FILE"
else
    i3-msg "bar mode dock"
    echo "dock" > "$BAR_MODE_FILE"
fi
