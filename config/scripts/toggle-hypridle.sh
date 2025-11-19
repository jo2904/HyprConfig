#!/bin/bash

if pgrep -x hypridle >/dev/null; then
  pkill -x hypridle
  notify-send "Stop locking computer when idle"
else
  export XDG_RUNTIME_DIR="/run/user/$(id -u)"
  export HYPRLAND_INSTANCE_SIGNATURE=$(grep -z -oP "(?<=HYPRLAND_INSTANCE_SIGNATURE=)[^;]+" /proc/$(pgrep -x Hyprland)/environ)


  nohup hypridle >/dev/null 2>&1 &
  notify-send "Now locking computer when idle"
fi