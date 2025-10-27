#!/bin/sh

cmd="$(./target/release/dmenu-launcher-utils -c ./config.yml gen | sort | dmenu | ./target/release/dmenu-launcher-utils -c ./config.yml lut 2>&1)"

# Check if the command was successful
if [ $? -ne 0 ]; then
  # If the command failed, display the error using notify-send
  notify-send "dmenu-launcher" "$cmd"
  exit 1
fi

eval "$cmd" &
