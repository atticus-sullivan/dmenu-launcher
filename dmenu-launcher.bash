#!/bin/sh

cmd="$(dmenu-launcher-utils gen | sort | dmenu -i | dmenu-launcher-utils lut 2>&1)"

# Check if the command was successful
if [ $? -ne 0 ]; then
  # If the command failed, display the error using notify-send
  notify-send "dmenu-launcher" "$cmd"
  exit 1
fi

eval "$cmd" &
