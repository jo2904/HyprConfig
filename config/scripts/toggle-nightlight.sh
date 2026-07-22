#!/bin/bash

# Aligné sur les profils de hyprsunset.conf (jour 6500K, nuit 3500K)
ON_TEMP=3500
OFF_TEMP=6500

# Ensure hyprsunset is running
if ! pgrep -x hyprsunset; then
  setsid uwsm app -- hyprsunset &
  sleep 1 # Give it time to register
fi

# Query the current temperature
CURRENT_TEMP=$(hyprctl hyprsunset temperature 2>/dev/null | grep -oE '[0-9]+')

if [[ "$CURRENT_TEMP" == "$OFF_TEMP" ]]; then
  hyprctl hyprsunset temperature "$ON_TEMP"
  notify-send "Night Light" "Activé (${ON_TEMP}K)" -t 2000
else
  hyprctl hyprsunset temperature "$OFF_TEMP"
  notify-send "Night Light" "Désactivé (${OFF_TEMP}K)" -t 2000
fi
